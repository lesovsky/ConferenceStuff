#!/bin/bash

. 00-env

echo -n -e "${sand}Stop existing cluster if it exists: ${reset}"
if [[ -f /var/lib/pgsql/${PG_VERSION}/data/postmaster.pid ]]; then
  pg_ctl -w -D /var/lib/pgsql/${PG_VERSION}/data -m fast stop &>/dev/null && echo "${calm}OK${reset}" || echo "${fail} FAILED${reset} -- can't stop existing cluster"
else
  echo "${sand}SKIP${reset}"
fi

echo -n -e "${sand}Remove cluster directory if it exists: ${reset}"
rm -rf /var/lib/pgsql/${PG_VERSION}/data/ &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset} -- can't remove data directory"

echo -n -e "${sand}Init new cluster: ${reset}"
initdb -A trust -D /var/lib/pgsql/${PG_VERSION}/data &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset} -- initdb has failed"

echo -n -e "${sand}Start new cluster: ${reset}"
pg_ctl -w -D /var/lib/pgsql/${PG_VERSION}/data start &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset} -- postgres start has failed"

echo -n -e "${sand}Configure shared buffers, logging, tracking... ${reset}"
psql -f sql/01-init-config.sql &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Drop caches: ${reset}"
sudo -u root bash -c "echo 3 > /proc/sys/vm/drop_caches" && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Restart postgres for apply changes: \n${reset}"
pg_ctl -D /var/lib/pgsql/${PG_VERSION}/data -m fast restart

