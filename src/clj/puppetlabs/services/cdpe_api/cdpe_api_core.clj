(ns puppetlabs.services.cdpe-api.cdpe-api-core
  (:require
   [clojure.tools.logging :as log]
   [clojure.java.io :as io]
   [clojure.walk :as walk]
   [puppetlabs.trapperkeeper.services.status.status-core :as status-core]
   [puppetlabs.services.master.master-core :as master-core]
   [puppetlabs.services.jruby-pool-manager.jruby-core :as jruby-core]
   [puppetlabs.services.protocols.jruby-puppet :as jruby-puppet]
   [puppetlabs.services.request-handler.request-handler-core :as jruby-handler]
   [puppetlabs.puppetserver.jruby-request :as jruby-middleware]
   [puppetlabs.comidi :as comidi]
   [ring.util.response :as response])
  (:import
    (com.puppetlabs.puppetserver JRubyPuppetResponse)))


;; Core namespace functionality

(defn create-status-callback
  "Creates a callback function for the trapperkeeper-status library.
  Used to report the presence of this Puppet Server extension."
  [context]
  (fn
    [level]
      (let [level>= (partial status-core/compare-levels >= level)]
        {:state :running
         ;; TODO: Report key performance metrics here.
         :status {}})))

(defn compile-catalog
  "Compiles a catalog for a node. Request is a Ring request map that has
  been transformed for consumption by JRuby and handler is a JRuby object that
  implements the RequestHandler Java API."
  [jruby-instance ruby-request]
  ;; FIXME: Handle the possiblity of runScriptlet encountering an error and
  ;; returning nil instead of a PuppetX::Puppetlabs::DiffApi::JRubyHandler
  ;; object.
  (let [ruby-handler (.runScriptlet jruby-instance
                                    "require 'puppet_x/puppetlabs/cd4pe_api/jruby_handler'
                                    PuppetX::Puppetlabs::CD4PEApi::JRubyHandler.instance")]
    ;; Dispatch to JRubyHandler.handle()
    (.callMethodWithArgArray jruby-instance
                             ruby-handler
                             "handle"
                             (into-array Object [ruby-request])
                             JRubyPuppetResponse)))

;; Re-implementation of jruby-handler and jruby-middleware functions.
(defn wrap-with-jruby-instance
  "A re-implementation of jruby-middleware/wrap-with-jruby-instance that
  exposes the scripting container in addition to the JRubyPuppet interface."
  [handler jruby-service]
  (let [jruby-pool (jruby-puppet/get-pool-context jruby-service)]
    (fn [request]
      (let [borrow-reason {:request (dissoc request :ssl-client-cert)}]
        (jruby-core/with-jruby-instance jruby-instance jruby-pool borrow-reason
          (-> request
              (assoc :jruby-instance (:jruby-puppet jruby-instance))
              (assoc :jruby-container (:scripting-container jruby-instance))
              handler))))))

(defn jruby-script-handler
  "An implementation of request-handler-core/jruby-request-handler from
  Puppet Server which dispatches directly to a Ruby eval instead
  of routing through the JRubyPuppet interface."
  [config current-code-id]
  (fn [request]
    (->> request
         jruby-handler/wrap-params-for-jruby
         (jruby-handler/with-code-id current-code-id)
         (jruby-handler/as-jruby-request config)
         walk/stringify-keys
         jruby-handler/make-request-mutable
         (compile-catalog (:jruby-container request))
         jruby-handler/response->map)))

(defn create-jruby-handler
  "Basically jruby-handler/build-request-handler with a handler calls Ruby eval
  instead of methods from the JRubyPuppet interface."
  [jruby-service puppet-config code-id-fn]
  (let [config (jruby-handler/config->request-handler-settings puppet-config)]
    (-> (jruby-script-handler config code-id-fn)
        (wrap-with-jruby-instance jruby-service)
        jruby-middleware/wrap-with-error-handling)))

(defn create-wrapped-jruby-handler
  "Builds a wrapped JRuby handler similar to that provided by
  the RequestHandlerService after being wrapped with authorization
  and other middleware from the MasterService.

  The reason we duplicate it here is so that we can set up a JRuby
  borrow context that exposes the Ruby scripting container instead
  of the limited methods offered by the
  com.puppetlabs.puppetserver.JRubyPuppet interface."
  [puppet-config code-id-fn jruby-service auth-handler]
  (let [jruby-handler (create-jruby-handler jruby-service puppet-config code-id-fn)
        puppet-version (get-in puppet-config [:puppetserver :puppet-version])
        use-legacy-auth? (get-in puppet-config
                                 [:jruby-puppet :use-legacy-auth-conf]
                                 false)]
    (master-core/get-wrapped-handler jruby-handler
                                     auth-handler
                                     puppet-version
                                     use-legacy-auth?)))

;; Core HTTP route handling functions.
(defn create-request-routes
  "Builds a Comidi routing tree that responds to GET requests for cdpe to compile a catalog."
  [jruby-handler]
  (comidi/routes
    (comidi/context "/puppet/v3"
     (comidi/routes
      (comidi/GET ["/cd4pe/compile/" [#".*" :rest]] request
                  (jruby-handler request))))))

(defn create-request-handler
  "Creates a Ring handler that responds to GET requests for catalog diffs.
  using ruby code from puppet_x/puppetlabs/diff_api"
  [handler]
  (comidi/routes->handler
    (create-request-routes handler)))
