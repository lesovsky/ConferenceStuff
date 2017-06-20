#!/bin/bash

. 00-env

read -p "${sand}Reset logging settings.${reset}"
psql -P pager=off -U postgres -f sql/06-reset-logging.sql

echo "${sand}Restarting PostgreSQL...${reset}"
pg_ctlcluster 9.6 main restart -m fast

read -p "${sand}Press enter to show current logging settings.${reset}"
psql -P pager=off -U postgres -c "select name,setting from pg_settings where name in ('shared_preload_libraries', 'track_commit_timestamp', 'hot_standby_feedback', 'log_min_duration_statement', 'log_checkpoints', 'log_line_prefix', 'log_lock_waits', 'log_replication_commands', 'track_activities', 'track_counts', 'track_io_timing', 'track_functions', 'track_activity_query_size', 'log_autovacuum_min_duration')"
