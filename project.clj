(def pe-puppetserver-version
  "Version of PE Puppet Server to develop and test against. Defaults to 5.x."
  (get (System/getenv) "PE_PUPPETSERVER_VERSION" "2018.1.0.71"))

(defproject puppetlabs/cdpe-api "0.0.1"
  :description "Puppet Server endpoint for CD4PE."
  :license {:name "Apache License 2.0"
            :url "http://www.apache.org/licenses/LICENSE-2.0.html"}

  :pedantic? :abort

  :min-lein-version "2.7.1"

  :plugins [[lein-parent "0.3.4"]]

  ;; Puppet Server 5.x uses clj-parent 1.x
  ;; Puppet Server 6.x uses clj-parent 2.x
  ;; TODO: Add switch based on PUPPETSERVER_VERSION
  :parent-project {:coords [puppetlabs/clj-parent "1.7.8"]
                   :inherit [:managed-dependencies]}

  :source-paths ["src/clj"]
  :test-paths ["test/clj/integration"]

  :dependencies [[org.clojure/clojure]

                 [ring/ring-core]

                 [puppetlabs/comidi]
                 [puppetlabs/ring-middleware]

                 [puppetlabs/trapperkeeper]
                 [puppetlabs/trapperkeeper-status]
                 [puppetlabs/trapperkeeper-webserver-jetty9]

                 [puppetlabs/pe-puppetserver ~pe-puppetserver-version]]

  :profiles {:dev {:source-paths ["dev"]
                   :repl-options {:init-ns tk-devtools}
                   :resource-paths ["dev-resources"]
                   :dependencies [[org.clojure/tools.namespace]
                                  [org.clojure/tools.nrepl]

                                  [cheshire]
                                  [ring-mock]

                                  ;; Re-declare dependencies with "test"
                                  ;; classifiers to pull in additional testing
                                  ;; code, helper functions and libraries.
                                  [puppetlabs/trapperkeeper-webserver-jetty9 nil :classifier "test"]
                                  [puppetlabs/trapperkeeper nil :classifier "test" :scope "test"]
                                  [puppetlabs/kitchensink nil :classifier "test" :scope "test"]

                                  [puppetlabs/http-client]
                                  [me.raynes/fs]
                                  ;; Convert data between JRuby and Clojure objects.
                                  [zweikopf "1.0.2" :exclusions [org.jruby/jruby-complete]]

                                  [puppetlabs/puppetserver ~puppetserver-version :classifier "test" :scope "test"]]}

             :puppet-module {:jar-name "cdpe-api.jar"}}

  :test-selectors {:integration :integration}

  :aliases {"tk" ["trampoline" "run"
                  "--bootstrap-config" "dev-resources/cdpe-api/bootstrap.cfg"
                  "--config" "dev-resources/cdpe-api/config.conf"]}

  :main puppetlabs.trapperkeeper.main)
