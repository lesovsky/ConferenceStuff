#!/bin/bash

. 00-env

echo -n -e "${sand}Disable autovacuum on test table${reset}"
psql -c "ALTER TABLE test SET (autovacuum_enabled = 'off')" pgbench &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

read -p "${sand}Press Enter to start updating data${reset}"
pgbench -n -c 3 -P 5 -r -T 200 -f sql/07-bloat2.pgb pgbench 
