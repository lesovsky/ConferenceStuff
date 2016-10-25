#!/bin/bash

. 00-env

echo -n -e "${sand}Create test database: ${reset}"
psql -c "create database pgbench" &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset} -- can't create database"

echo -n -e "${sand}Create pgbench tables: ${reset}"
pgbench -i pgbench &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset} -- can't init pgbench"

echo -n -e "${sand}Create test tables: ${reset}\n"
psql -f sql/02-test-data.sql pgbench
