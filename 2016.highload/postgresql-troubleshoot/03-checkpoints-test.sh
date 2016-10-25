#!/bin/bash

. 00-env

echo -n -e "${sand}Configure checkpoints... ${reset}"
psql -f sql/03-checkpoints-bad-config.sql &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"
echo -n -e "${calm}max_wal_size = 300MB\ncheckpoint_timeout = 30s\ncheckpoint_completion_target = 0.1\n"

echo -n -e "${sand}Drop caches: ${reset}"
sudo -u root bash -c "echo 3 > /proc/sys/vm/drop_caches" && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Restart postgres for apply changes: ${reset}"
pg_ctl -w -D /var/lib/pgsql/${PG_VERSION}/data -m fast restart &> /dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Vacuum test table... ${reset}"
psql -c 'VACUUM FULL products' pgbench &>/dev/null
psql -c 'VACUUM products' pgbench &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

read -p "${sand}Press any key to start pgbench.${reset}"
echo -n -e "${sand}Start pgbench... \n${reset}"
pgbench -T 180 -P 1 -R 900 -f sql/03-checkpoints-pgbench-test.pgb pgbench

read -p "${sand}Press any key to continue.${reset}"

echo -n -e "${sand}Configure better checkpoints... ${reset}"
psql -f sql/03-checkpoints-better-config.sql &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"
echo -n -e "${calm}max_wal_size = 800MB\ncheckpoint_timeout = 90s\ncheckpoint_completion_target = 0.9\n"

echo -n -e "${sand}Drop caches: ${reset}"
sudo -u root bash -c "echo 3 > /proc/sys/vm/drop_caches" && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Restart postgres for apply changes: ${reset}"
pg_ctl -w -D /var/lib/pgsql/${PG_VERSION}/data -m fast restart &> /dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Vacuum test table... ${reset}"
psql -c 'VACUUM FULL products' pgbench &>/dev/null
psql -c 'VACUUM products' pgbench &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

read -p "${sand}Press any key to start pgbench.${reset}"
echo -n -e "${sand}Start pgbench... \n${reset}"
pgbench -T 180 -P 1 -R 900 -f sql/03-checkpoints-pgbench-test.pgb pgbench

echo -n -e "${sand}Restore defaults checkpoint settings... ${reset}"
psql -f sql/03-checkpoints-restore-settings.pgb &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"
