#!/bin/bash

. 00-env

echo -n -e "${sand}Create pgstattuple extension${reset}"
psql -c "create extension if not exists pgstattuple" pgbench &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

echo -n -e "${sand}Create pg_prewarm extension${reset}"
psql -c "create extension if not exists pg_prewarm" pgbench &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

echo -n -e "${sand}Create pg_buffercache extension${reset}"
psql -c "create extension if not exists pg_buffercache" pgbench &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

echo -n -e "${sand}Perform VACUUM FULL on table ${reset}"
psql -c "vacuum full games" pgbench &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

echo -n -e "${sand}Prewarm test table ${reset}"
psql -c "select pg_prewarm('games')" pgbench &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

echo -n -e "${sand}Check test table's size in the buffercache\n${reset}"
psql -f sql/06-check-games-buffercache.sql pgbench

echo -n -e "${sand}Check test table's size and bloat\n${reset}"
psql -f sql/06-check-games-bloat.sql pgbench

echo -n -e "${sand}Disable autovacuum on test table${reset}"
psql -c "ALTER TABLE games SET (autovacuum_enabled = 'off')" pgbench &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

read -p "${sand}Press Enter to start updating data${reset}"
pgbench -n -c 2 -T 60 -f sql/06-update-games.pgb pgbench 

echo -n -e "${sand}Check test table's size in the buffercache\n${reset}"
psql -f sql/06-check-games-buffercache.sql pgbench

echo -n -e "${sand}Check test table's size and bloat\n${reset}"
psql -f sql/06-check-games-bloat.sql pgbench

read -p "${sand}Press Enter to start updating data${reset}"
pgbench -n -c 2 -T 60 -f sql/06-update-games.pgb pgbench 

echo -n -e "${sand}Check test table's size in the buffercache\n${reset}"
psql -f sql/06-check-games-buffercache.sql pgbench

echo -n -e "${sand}Check test table's size and bloat\n${reset}"
psql -f sql/06-check-games-bloat.sql pgbench

read -p "${sand}Press Enter to test with enabled autovacuum${reset}"
### 
echo -n -e "${sand}Perform VACUUM FULL on table ${reset}"
psql -c "vacuum full games" pgbench &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

echo -n -e "${sand}Prewarm test table ${reset}"
psql -c "select pg_prewarm('games')" pgbench &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

echo -n -e "${sand}Check test table's size in the buffercache\n${reset}"
psql -f sql/06-check-games-buffercache.sql pgbench

echo -n -e "${sand}Check test table's size and bloat\n${reset}"
psql -f sql/06-check-games-bloat.sql pgbench

echo -n -e "${sand}Enable autovacuum and set scale factor to 0.01 on test table${reset}"
psql -c "ALTER TABLE games SET (autovacuum_enabled = 'on', autovacuum_vacuum_scale_factor = 0.01)" pgbench &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

read -p "${sand}Press Enter to start updating data${reset}"
pgbench -n -c 2 -T 60 -f sql/06-update-games.pgb pgbench 

echo -n -e "${sand}Check test table's size in the buffercache\n${reset}"
psql -f sql/06-check-games-buffercache.sql pgbench

echo -n -e "${sand}Check test table's size and bloat\n${reset}"
psql -f sql/06-check-games-bloat.sql pgbench

read -p "${sand}Press Enter to start updating data${reset}"
pgbench -n -c 2 -T 60 -f sql/06-update-games.pgb pgbench 

echo -n -e "${sand}Check test table's size in the buffercache\n${reset}"
psql -f sql/06-check-games-buffercache.sql pgbench

echo -n -e "${sand}Check test table's size and bloat\n${reset}"
psql -f sql/06-check-games-bloat.sql pgbench
