#!/bin/bash

. 00-env

echo -n -e "${sand}Setup archiving settings ${reset}"
psql -f sql/07-archive-config.sql &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Perform checkpoints to clear impact of previous tests ${reset}"
sleep 12;
for i in {1..8}; do
  psql -c "CHECKPOINT" &>/dev/null;
  sleep 1;
done && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Reset archiver stats ${reset}"
psql -c "SELECT pg_stat_reset_shared('archiver');" &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Show current XLOGDIR size and XLOG settings\n${reset}"
du -sh /var/lib/pgsql/9.5/data/pg_xlog/|awk '{print $2" "$1}'
psql -qAtXF " " -c "select 'max_wal_size'as setting ,setting as value from pg_settings where name = 'max_wal_size' union all select 'wal_keep_segments' as setting ,setting as value from pg_settings where name = 'wal_keep_segments'"

echo -n -e "${sand}Setup archive command ${reset}"
psql -c "ALTER SYSTEM SET archive_command TO 'cp %p /dev/null'" &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Reload postgres ${reset}"
psql -c "SELECT pg_reload_conf()" &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

read -p "${sand}Press Enter to run pgbench ${reset}"
pgbench -n -c 2 -T 60 -f sql/07-update-games.pgb pgbench &>/dev/null

echo -n -e "${sand}Show current XLOGDIR size\n${reset}"
du -sh /var/lib/pgsql/9.5/data/pg_xlog/|awk '{print $2" "$1}'

echo -n -e "${sand}Show current archiver stats\n${reset}"
psql -x -c "select * from pg_stat_archiver"

read -p "Press Enter to continue"

echo -n -e "${sand}Break archive_command ${reset}"
psql -c "ALTER SYSTEM SET archive_command TO 'cp %p /dev/null/%f'" &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"
psql -c "SELECT pg_reload_conf()" &>/dev/null

read -p "${sand}Press Enter to run pgbench ${reset}"
pgbench -n -c 3 -T 60 -f sql/07-update-games.pgb pgbench &>/dev/null

echo -n -e "${sand}Show current XLOGDIR size\n${reset}"
du -sh /var/lib/pgsql/9.5/data/pg_xlog/|awk '{print $2" "$1}'

echo -n -e "${sand}Show current archiver stats\n${reset}"
psql -x -c "select * from pg_stat_archiver"

read -p "Press Enter to continue"

echo -n -e "${sand}Restore archive_command ${reset}"
psql -c "ALTER SYSTEM SET archive_command TO 'cp %p /dev/null'" &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"
psql -c "SELECT pg_reload_conf()" &>/dev/null

echo -n -e "${sand}Wait archive_timeout and run checkpoints ${reset}"
sleep 12;
for i in {1..8}; do
  psql -c "CHECKPOINT" &>/dev/null;
  sleep 1;
done && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

read -p "${sand}Press Enter to show current XLOGDIR size${reset}"
du -sh /var/lib/pgsql/9.5/data/pg_xlog/|awk '{print $2" "$1}'

echo -n -e "${sand}Show current archiver stats\n${reset}"
psql -x -c "select * from pg_stat_archiver"
