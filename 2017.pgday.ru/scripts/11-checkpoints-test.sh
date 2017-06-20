#!/bin/bash

. 00-env

echo -n -e "${sand}Configure checkpoints... ${reset}"
psql -U postgres -f sql/11-checkpoints-bad-config.sql &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"
echo -n -e "${calm}max_wal_size = ...\ncheckpoint_timeout = ...\ncheckpoint_completion_target = ...\n"

echo -n -e "${sand}Drop caches: ${reset}"
bash -c "echo 3 > /proc/sys/vm/drop_caches" && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Restart postgres for apply changes: ${reset}"
pg_ctlcluster 9.6 main restart -m fast &> /dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Vacuum test table... ${reset}"
psql -U postgres -c 'VACUUM FULL products' pgbench_6gb &>/dev/null
psql -U postgres -c 'VACUUM products' pgbench_6gb &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

read -p "${sand}Press any key to start pgbench.${reset}"
echo -n -e "${sand}Start pgbench... \n${reset}"
psql -U postgres -c "select pg_stat_reset_shared('bgwriter')" &>/dev/null
pgbench -U postgres -c 8 -T 180 -P 1 -R 5000 -f sql/11-checkpoints-pgbench-test.pgb pgbench_6gb

read -p "${sand}Show pg_stat_bgwriter stat.${reset}"
psql -U postgres -P pager=off -x -f sql/11-checkpoints-ckpt-bgwr-report.sql

read -p "${sand}Press any key to continue.${reset}"

echo -n -e "${sand}Configure better checkpoints... ${reset}"
psql -U postgres -f sql/11-checkpoints-better-config.sql &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"
echo -n -e "${calm}max_wal_size = ...\ncheckpoint_timeout = ...\ncheckpoint_completion_target = ...\n"

echo -n -e "${sand}Drop caches: ${reset}"
bash -c "echo 3 > /proc/sys/vm/drop_caches" && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Restart postgres for apply changes: ${reset}"
pg_ctlcluster 9.6 main restart -m fast &> /dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Vacuum test table... ${reset}"
psql -U postgres -c 'VACUUM FULL products' pgbench_6gb &>/dev/null
psql -U postgres -c 'VACUUM products' pgbench_6gb &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

read -p "${sand}Press any key to start pgbench.${reset}"
echo -n -e "${sand}Start pgbench... \n${reset}"
psql -U postgres -c "select pg_stat_reset_shared('bgwriter')" &>/dev/null
pgbench -U postgres -c 8 -T 180 -P 1 -R 5000 -f sql/11-checkpoints-pgbench-test.pgb pgbench_6gb

read -p "${sand}Show pg_stat_bgwriter stat.${reset}"
psql -U postgres -P pager=off -x -f sql/11-checkpoints-ckpt-bgwr-report.sql

echo -n -e "${sand}Restore defaults checkpoint settings... ${reset}"
psql -U postgres -f sql/11-checkpoints-restore-settings.sql &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"
