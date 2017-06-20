#!/bin/bash

. 00-env

echo -n -e "${sand}Create pg_stat_statements extension ${reset}"
psql -c "create extension if not exists pg_stat_statements" -U postgres pgbench_6gb &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Reset pg_stat_statements stats ${reset}"
psql -c "select pg_stat_statements_reset()" -U postgres pgbench_6gb &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Reset databases' stats ${reset}"
psql -c "select pg_stat_reset()" -U postgres pgbench_6gb &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Reset work_mem to defaults: ${reset}"
psql -qAtX -U postgres -c "ALTER SYSTEM RESET work_mem" &>/dev/null 
psql -U postgres -c "select pg_reload_conf()" &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

sleep 2;

echo -n -e "${sand}Current work_mem: ${reset}"
psql -qAtX -U postgres -c "show work_mem"

read -p "${sand}Press any key to start pgbench.${reset}"
echo -n -e "${sand}Start pgbench... \n${reset}"
pgbench -c 8 -T 60 -P 10 -U postgres -f sql/10-work-mem-test.pgb pgbench_6gb

read -p "${sand}Show pg_stat_statements.${reset}"
psql -P pager=off -c "select datname,temp_files,pg_size_pretty(temp_bytes) from pg_stat_database where datname = 'pgbench_6gb'" -U postgres pgbench_6gb

read -p "${sand}Show pg_stat_statements.${reset}"
psql -P pager=off -x -c "select * from pg_stat_statements where query ~* 'from products'" -U postgres pgbench_6gb

read -p "${sand}Show pg_stat_statements report.${reset}"
psql -P pager=on -f sql/09-query_stat_total.sql -U postgres pgbench_6gb

read -p "${sand}Press any key to continue.${reset}"
echo -n -e "${sand}Increase work_mem ${reset}"
psql -U postgres -c "alter system set work_mem to '8MB'" &>/dev/null
psql -U postgres -c "select pg_reload_conf()" &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

read -p "${sand}Press any key to start pgbench.${reset}"
echo -n -e "${sand}Start pgbench... \n${reset}"
pgbench -c 8 -T 60 -P 10 -U postgres -f sql/10-work-mem-test.pgb pgbench_6gb
