#!/bin/bash

. 00-env

echo -n -e "${sand}Create pg_stat_statements extension ${reset}"
psql -c "create extension if not exists pg_stat_statements" -U postgres pgbench_6gb &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Reset pg_stat_statements stats ${reset}"
psql -c "select pg_stat_statements_reset()" -U postgres pgbench_6gb &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Reset tables stats ${reset}"
psql -c "select pg_stat_reset()" -U postgres pgbench_6gb &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Remove index ${reset}"
psql -c "alter table products drop constraint products_pkey" -U postgres pgbench_6gb &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

read -p "${sand}Press any key to start pgbench.${reset}"
echo -n -e "${sand}Start pgbench... \n${reset}"
pgbench -T 60 -P 10 -c 8 -f sql/09-sequential-scan.pgb -U postgres pgbench_6gb

read -p "${sand}Show pg_stat_all_tables_stat.${reset}"
psql -c "select relname,seq_scan,seq_tup_read,idx_scan,idx_tup_fetch from pg_stat_all_tables where relname = 'products'" -U postgres pgbench_6gb

read -p "${sand}Show pg_stat_statements.${reset}"
psql -P pager=off -x -c "select * from pg_stat_statements where query ~* 'from products'" -U postgres pgbench_6gb

read -p "${sand}Show pg_stat_statements report.${reset}"
psql -P pager=on -f sql/09-query_stat_total.sql -U postgres pgbench_6gb

read -p "${sand}Press any key to continue.${reset}"
echo -n -e "${sand}Add index ${reset}"
psql -c "alter table products add primary key (id)" -U postgres pgbench_6gb &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

read -p "${sand}Press any key to start pgbench.${reset}"
echo -n -e "${sand}Start pgbench... \n${reset}"
pgbench -T 60 -P 10 -c 8 -f sql/09-sequential-scan.pgb -U postgres pgbench_6gb

echo "${calm}End.${reset}"
