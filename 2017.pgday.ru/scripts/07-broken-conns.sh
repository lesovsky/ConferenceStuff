#!/bin/bash

. 00-env

read -p "${sand}Press Enter to run broken conns${reset}"
./broken-conns &

sleep 45

read -p "${sand}Show idle transactions.${reset}"
psql -P pager=on -U postgres -c "select pid,state,now()-xact_start as xact_age,query from pg_stat_activity where state = 'idle in transaction'"

read -p "${sand}Show waiting statements.${reset}"
psql -P pager=on -U postgres -c "select pid,wait_event_type,wait_event,now()-query_start as query_age,query from pg_stat_activity where wait_event_type is not null or wait_event is not null"

read -p "${sand}Show non-granted locks.${reset}"
psql -P pager=on -U postgres -c "select locktype,relation::regclass,pid,mode from pg_locks where not granted"

read -p "${sand}Show locks tree information.${reset}"
psql -P pager=on -U postgres -f sql/07-show-locks-tree.sql

read -p "${sand}Show advanced locks information.${reset}"
psql -P pager=on -x -U postgres -f sql/07-show-locks.sql
