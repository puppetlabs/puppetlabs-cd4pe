(ns tk-devtools
  (:require [clojure.repl :refer :all]
            [clojure.pprint :as pprint]
            [clojure.java.io :as io]
            [clojure.tools.namespace.repl :refer [set-refresh-dirs refresh]]
            [puppetlabs.trapperkeeper.app :as tka]
            [puppetlabs.trapperkeeper.bootstrap :as bootstrap]
            [puppetlabs.trapperkeeper.config :as config]
            [puppetlabs.trapperkeeper.core :as tk]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Basic system life cycle

(def system nil)

;; Ensure only source files from the current project are refreshed. This
;; excludes the checkouts directory as puppetserver has tests containing
;; relative paths that don't resolve correctly.
(set-refresh-dirs "./src/clj" "./dev")

(def bootstrap-config
  (-> "catalog-diff-api/bootstrap.cfg"
      io/resource
      .getPath))
(def app-config
  (-> "catalog-diff-api/config.conf"
      io/resource
      .getPath))

(defn init []
  (alter-var-root #'system
                  (fn [_] (tk/build-app
                            (bootstrap/parse-bootstrap-config! bootstrap-config)
                            (config/load-config app-config))))
  (alter-var-root #'system tka/init)
  (tka/check-for-errors! system))

(defn start []
  (alter-var-root #'system
                  (fn [s] (if s (tka/start s))))
  (tka/check-for-errors! system))

(defn stop []
  (alter-var-root #'system
                  (fn [s] (when s (tka/stop s)))))

(defn go []
  (stop)
  (init)
  (start))

(defn reset []
  (stop)
  (refresh :after 'tk-devtools/go))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Utilities for interacting with running system

(defn context
  "Get the current TK application context.  Accepts an optional array
  argument, which is treated as a sequence of keys to retrieve a nested
  subset of the map (a la `get-in`)."
  ([]
   (context []))
  ([keys]
   (get-in @(tka/app-context system) keys)))

(defn print-context
  "Pretty-print the current TK application context.  Accepts an optional
  array of keys (a la `get-in`) to print a nested subset of the context."
  ([]
   (print-context []))
  ([keys]
   (pprint/pprint (context keys))))
