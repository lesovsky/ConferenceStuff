#!/bin/bash

. 00-env

echo -n -e "${sand}Create pg_stat_statements extension ${reset}"
psql -c "create extension if not exists pg_stat_statements" pgbench &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Reset pg_stat_statements stats ${reset}"
psql -c "select pg_stat_statements_reset()" pgbench &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Reset work_mem to defaults: ${reset}"
psql -qAtX -c "ALTER SYSTEM RESET work_mem" &>/dev/null 
psql -c "select pg_reload_conf()" &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

sleep 2;

echo -n -e "${sand}Current work_mem: ${reset}"
psql -qAtX -c "show work_mem"

read -p "${sand}Press any key to start pgbench.${reset}"
echo -n -e "${sand}Start pgbench... \n${reset}"
pgbench -T 60 -P 10 -f sql/10-work-mem-test.pgb pgbench

read -p "${sand}Press any key to continue.${reset}"
echo -n -e "${sand}Increase work_mem ${reset}"
psql -c "alter system set work_mem to '8MB'" &>/dev/null
psql -c "select pg_reload_conf()" &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

read -p "${sand}Press any key to start pgbench.${reset}"
echo -n -e "${sand}Start pgbench... \n${reset}"
pgbench -T 60 -P 10 -f sql/10-work-mem-test.pgb pgbench
