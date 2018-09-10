(ns puppetlabs.services.cdpe-api.cdpe-api-service-test
  (:require
    [clojure.test :refer :all]
    [clojure.java.io :as io]
    [clojure.walk :as walk]

    [puppetlabs.http.client.sync :as http-client]
    [cheshire.core :as json]
    [me.raynes.fs :as fs]
    ;; Zweikopf converts data between JRuby and Clojure objects.
    ;; NOTE: To cut overhead, the tests below don't initialize zweikopf
    ;; with a JRuby interpreter of its own. This means that zweikopf/clojurize
    ;; might blow up if passed exotic Ruby data structures like Rational or
    ;; struct.
    [zweikopf.core :as zweikopf]

    [puppetlabs.trapperkeeper.app :as tk-app]
    [puppetlabs.trapperkeeper.bootstrap :as tk-bootstrap]
    [puppetlabs.trapperkeeper.config :as tk-config]
    [puppetlabs.trapperkeeper.services.status.status-core :as status-core]
    [puppetlabs.trapperkeeper.testutils.bootstrap :as tst-bootstrap]

    ;; Provided by puppetlabs/puppetserver with the "test" classifier.
    [puppetlabs.services.jruby.jruby-puppet-testutils :as jruby-testutils]
    [puppetlabs.services.cdpe-api-service.cdpe-api-service :as cdpe-api]))


;; Test Configuration

(defn test-resource
  "Locates a path within the registered Java resource directories and returns
  a fully qualified path"
  [path]
  (-> path
      io/resource
      .getPath))

(def bootstrap-config (test-resource "cdpe-api/bootstrap.cfg"))
(def app-config (test-resource "cdpe-api/config.conf"))
(def logback-config (test-resource "cdpe-api/logback-test.xml"))
(def puppet-confdir (test-resource "cdpe-api/fixtures/puppet"))

(def listen-address "localhost")
(def listen-port 18140)
(def base-url (str "https://" listen-address ":" listen-port))

(def ssl-cert (test-resource "cdpe-api/ssl/cdpe-api.test.cert.pem"))
(def ssl-key (test-resource "cdpe-api/ssl/cdpe-api.test.key.pem"))
(def ca-cert (test-resource "cdpe-api/ssl/ca.cert.pem"))

(def app-services
  (tk-bootstrap/parse-bootstrap-config! bootstrap-config))

(def base-config
  "Load Puppet Server dev configuration, but turn logging down,
  shift to a different port and disable SSL client auth."
  (-> app-config

      tk-config/load-config

      (assoc-in [:global :logging-config] logback-config)

      (assoc-in [:webserver :ssl-host] listen-address)
      (assoc-in [:webserver :ssl-port] listen-port)
      (assoc-in [:webserver :ssl-cert] ssl-cert)
      (assoc-in [:webserver :ssl-key] ssl-key)
      (assoc-in [:webserver :ssl-ca-cert] ca-cert)
      (assoc-in [:webserver :client-auth] "none")

      ;; The tests borrow one instance to generate test data, so we need
      ;; a second instance free to handle HTTP requests.
      (assoc-in [:jruby-puppet :max-active-instances] 2)
      (assoc-in [:jruby-puppet :master-var-dir] (fs/tmpdir))
      (assoc-in [:jruby-puppet :master-conf-dir] puppet-confdir)))


;; Helper Functions

(defn PUT
  [path body]
  (http-client/put (str base-url path)
                    {:headers {"Accept" "application/json"
                               "Content-type" "application/json"}
                     :ssl-ca-cert ca-cert
                     :body body
                     :as :text}))

(defn GET
  [path]
  (http-client/get (str base-url path)
                    {:headers {"Accept" "application/json"}
                     :ssl-ca-cert ca-cert
                     :as :text}))


;; Test Cases

(deftest ^:integration cdpe-api-service
  (printf "Testing against Puppet Server version: %s%n" cdpe-api/puppetserver-version)

  (tst-bootstrap/with-app-with-config app app-services base-config
    (testing "puppetserver-cdpe-api plugin is enabled appropriately"
      (let [response (GET "/status/v1/services?level=debug")
            body (-> response :body json/parse-string)
            ;; When run against an incompatible Puppet Server version, we
            ;; expect the TK status service to return a response that does
            ;; not reference the facts-upload service, i.e. nil, which
            ;; indicates the service was not mounted.
            expected-version (if (cdpe-api/compatible-puppetserver-version?)
                                 cdpe-api/version
                                 nil)]
        (is (= 200 (:status response)))
        (is (= expected-version (get-in body ["cdpe-api-service" "service_version"])))))))
