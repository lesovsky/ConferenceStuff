#!/bin/bash

. 00-env

echo -n -e "${sand}Create pg_stat_statements extension ${reset}"
psql -c "create extension if not exists pg_stat_statements" pgbench &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Reset pg_stat_statements stats ${reset}"
psql -c "select pg_stat_statements_reset()" pgbench &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Remove index ${reset}"
psql -c "alter table products drop constraint products_pkey" pgbench &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

read -p "${sand}Press any key to start pgbench.${reset}"
echo -n -e "${sand}Start pgbench... \n${reset}"
pgbench -T 60 -P 10 -f sql/09-sequential-scan.pgb pgbench

read -p "${sand}Press any key to continue.${reset}"
echo -n -e "${sand}Add index ${reset}"
psql -c "alter table products add primary key (id)" pgbench &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

read -p "${sand}Press any key to start pgbench.${reset}"
echo -n -e "${sand}Start pgbench... \n${reset}"
pgbench -T 60 -P 10 -f sql/09-sequential-scan.pgb pgbench
