ALTER SYSTEM SET min_wal_size TO '800MB';
ALTER SYSTEM SET max_wal_size TO '800MB';
ALTER SYSTEM SET checkpoint_timeout TO '90s';
ALTER SYSTEM SET checkpoint_completion_target TO '0.9';
