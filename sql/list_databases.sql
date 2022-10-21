SELECT datname as databases
FROM pg_database
WHERE datistemplate = false
and datname <> 'postgres';
