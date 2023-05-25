\connect cd4pe
SELECT nspname || '.' || relname AS relation,
       pg_size_pretty(pg_table_size(C.oid))
FROM pg_class C
         LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE nspname NOT IN ('information_schema',
                      'pg_catalog',
                      'pg_toast')
ORDER BY pg_table_size(C.oid) DESC;

\connect query
SELECT nspname || '.' || relname AS relation,
       pg_size_pretty(pg_table_size(C.oid))
FROM pg_class C
         LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE nspname NOT IN ('information_schema',
                      'pg_catalog',
                      'pg_toast')
ORDER BY pg_table_size(C.oid) DESC;