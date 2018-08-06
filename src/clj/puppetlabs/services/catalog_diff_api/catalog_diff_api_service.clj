(ns puppetlabs.services.catalog-diff-api.catalog-diff-api-service
  "Defines the diff-api-service for Trapperkeeper"
  (:require
   [clojure.edn :as edn]
   [clojure.string :as string]
   [clojure.tools.logging :as log]
   [puppetlabs.services.catalog-diff-api.catalog-diff-api-core :as core]
   [puppetlabs.trapperkeeper.core :refer [defservice]]
   [puppetlabs.trapperkeeper.services :as services]
   [puppetlabs.trapperkeeper.services.status.status-core :as status-core]))


(def version
  "The diff_api module version, from project.clj"
  (status-core/get-artifact-version "puppetlabs" "catalog-diff-api"))

(def puppetserver-version
  "Retrieve Puppet Server version in use.

  This function retrieves just the X and Y components of the version
  and casts them to a floating point number that can be compared."
  (try
    (as-> (status-core/get-artifact-version "puppetlabs" "puppetserver") x
          (string/split x #"\.")
          (take 2 x)
          (string/join "." x)
          (edn/read-string x))
    (catch Exception e
      (log/errorf "Couldn't determine Puppet Server version %s" e)
      nil)))

(defprotocol CatalogDiffApiService)


(defn compatible-puppetserver-version?
  "Determine whether Puppet Server is compatible with diff_api.

  This function returns a simple boolean value."
  []
  (if (nil? puppetserver-version)
    false
    (and
      (>= puppetserver-version 5.3)
      ;; TODO: Test against Puppet Server 6.
      (< puppetserver-version 6.0))))

(defservice catalog-diff-api-service
  CatalogDiffApiService
  [[:StatusService register-status]
   [:WebserverService add-ring-handler]

   [:PuppetServerConfigService get-config]
   [:CaService get-auth-handler]
   [:VersionedCodeService current-code-id]
   ;; We don't import any functions from the MasterService. This declaration
   ;; is just here to ensure this service is initialized after the
   ;; MasterService.
   [:MasterService]]
  (init [this context]
    ;; TODO: Only build the route handler if we detect a compatible version of
    ;; Puppet Server.
    (if (compatible-puppetserver-version?)
      (do
        (log/info "Initializing CatalogDiffApiService")
        (let [puppet-config (get-config)
              auth-handler (get-auth-handler)
              jruby-service (services/get-service this :JRubyPuppetService)
              jruby-handler (core/create-wrapped-jruby-handler puppet-config
                                                               current-code-id
                                                               jruby-service
                                                               auth-handler)
              ring-handler (core/create-request-handler jruby-handler)]

          (register-status "catalog-diff-api-service" version 1
                           (core/create-status-callback context))

          (assoc context :request-handler ring-handler)))
      (do
        (log/warnf "The catalog_diff_api plugin is not compatible with Puppet Server version %s and should be removed from this node. Skipping service initialization."
                    puppetserver-version)
        context)))


  (start [this context]
    ;; FIXME: Use the WebroutingService to lookup which path the MasterService
    ;; is mounted at.
    (when-let [handler (:request-handler context)]
      (log/info "Starting CatalogDiffApiService")
      ;; /catalog-diff might make more sense, but could be unintentionally
      ;; exposed via auth.conf handlers that match against /catalog*
      (add-ring-handler handler "/puppet/v3/diff-catalog"))

    context))
