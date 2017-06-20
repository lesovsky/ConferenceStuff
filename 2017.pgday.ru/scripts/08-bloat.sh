#!/bin/bash

. 00-env

echo -n -e "${sand}Create pgstattuple extension${reset}"
psql -c "create extension if not exists pgstattuple" -U postgres pgbench_6gb &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

echo -n -e "${sand}Create pg_prewarm extension${reset}"
psql -c "create extension if not exists pg_prewarm" -U postgres pgbench_6gb &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

echo -n -e "${sand}Create pg_buffercache extension${reset}"
psql -c "create extension if not exists pg_buffercache" -U postgres pgbench_6gb &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

echo -n -e "${sand}Perform VACUUM FULL on table ${reset}"
psql -c "vacuum full games" -U postgres pgbench_6gb &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

echo -n -e "${sand}Prewarm test table ${reset}"
psql -c "select pg_prewarm('games')" -U postgres pgbench_6gb &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

echo -n -e "${sand}Check test table's size in the buffercache\n${reset}"
psql -f sql/08-check-games-buffercache.sql -U postgres pgbench_6gb

echo -n -e "${sand}Check test table's size and bloat\n${reset}"
psql -f sql/08-check-games-bloat.sql -U postgres pgbench_6gb

echo -n -e "${sand}Disable autovacuum on test table${reset}"
psql -c "ALTER TABLE games SET (autovacuum_enabled = 'off')" -U postgres pgbench_6gb &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

read -p "${sand}Press Enter to start updating data${reset}"
pgbench -n -c 8 -T 60 -f sql/08-update-games.pgb -U postgres pgbench_6gb

echo -n -e "${sand}Check test table's size in the buffercache\n${reset}"
psql -f sql/08-check-games-buffercache.sql -U postgres pgbench_6gb

echo -n -e "${sand}Check test table's size and bloat\n${reset}"
psql -f sql/08-check-games-bloat.sql -U postgres pgbench_6gb

read -p "${sand}Press Enter to start updating data${reset}"
pgbench -n -c 8 -T 60 -f sql/08-update-games.pgb -U postgres pgbench_6gb

echo -n -e "${sand}Check test table's size in the buffercache\n${reset}"
psql -f sql/08-check-games-buffercache.sql -U postgres pgbench_6gb

echo -n -e "${sand}Check test table's size and bloat\n${reset}"
psql -f sql/08-check-games-bloat.sql -U postgres pgbench_6gb

read -p "${sand}Press Enter to test with enabled autovacuum${reset}"
### 
echo -n -e "${sand}Perform VACUUM FULL on table ${reset}"
psql -c "vacuum full games" -U postgres pgbench_6gb &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

echo -n -e "${sand}Prewarm test table ${reset}"
psql -c "select pg_prewarm('games')" -U postgres pgbench_6gb &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

echo -n -e "${sand}Check test table's size in the buffercache\n${reset}"
psql -f sql/08-check-games-buffercache.sql -U postgres pgbench_6gb

echo -n -e "${sand}Check test table's size and bloat\n${reset}"
psql -f sql/08-check-games-bloat.sql -U postgres pgbench_6gb

echo -n -e "${sand}Enable autovacuum and set scale factor to 0.01 on test table${reset}"
psql -c "ALTER TABLE games SET (autovacuum_enabled = 'on', autovacuum_vacuum_scale_factor = 0.01)" -U postgres pgbench_6gb &>/dev/null && echo "${calm} OK${reset}" || echo "${fail} FAILED${reset}"

read -p "${sand}Press Enter to start updating data${reset}"
pgbench -n -c 8 -T 60 -f sql/08-update-games.pgb -U postgres pgbench_6gb

echo -n -e "${sand}Check test table's size in the buffercache\n${reset}"
psql -f sql/08-check-games-buffercache.sql -U postgres pgbench_6gb

echo -n -e "${sand}Check test table's size and bloat\n${reset}"
psql -f sql/08-check-games-bloat.sql -U postgres pgbench_6gb

read -p "${sand}Press Enter to start updating data${reset}"
pgbench -n -c 8 -T 60 -f sql/08-update-games.pgb -U postgres pgbench_6gb

echo -n -e "${sand}Check test table's size in the buffercache\n${reset}"
psql -f sql/08-check-games-buffercache.sql -U postgres pgbench_6gb

echo -n -e "${sand}Check test table's size and bloat\n${reset}"
psql -f sql/08-check-games-bloat.sql -U postgres pgbench_6gb

echo "${calm}End.${reset}"
