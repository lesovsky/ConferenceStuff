ALTER SYSTEM SET min_wal_size TO '200MB';
ALTER SYSTEM SET max_wal_size TO '200MB';
ALTER SYSTEM SET archive_timeout TO '10s';
SELECT pg_reload_conf();
