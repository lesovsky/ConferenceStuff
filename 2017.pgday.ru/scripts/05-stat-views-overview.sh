#!/bin/bash

. 00-env

read -p "${sand}Press enter to start stat overview.${reset}"
psql -P pager=off -U postgres -c "\dv pg_stat*"

read -p "${sand}Show pg_stat_activity.${reset}"
psql -P pager=off -U postgres -c "\d pg_stat_activity"

read -p "${sand}Show pg_stat_bgwriter.${reset}"
psql -P pager=off -U postgres -c "\d pg_stat_bgwriter"

read -p "${sand}Show pg_stat_replication.${reset}"
psql -P pager=off -U postgres -c "\d pg_stat_replication"

read -p "${sand}Show pg_stat_progress_vacuum.${reset}"
psql -P pager=off -U postgres -c "\d pg_stat_progress_vacuum"

read -p "${sand}Show pg_stat_database.${reset}"
psql -P pager=off -U postgres -c "\d pg_stat_database"

read -p "${sand}Show pg_stat_all_tables.${reset}"
psql -P pager=off -U postgres -c "\d pg_stat_all_tables"

read -p "${sand}Show pg_stat_all_indexes.${reset}"
psql -P pager=off -U postgres -c "\d pg_stat_all_indexes"

read -p "${sand}Show pg_statio_all_tables.${reset}"
psql -P pager=off -U postgres -c "\d pg_statio_all_tables"

read -p "${sand}Show pg_statio_all_indexes.${reset}"
psql -P pager=off -U postgres -c "\d pg_statio_all_indexes"

read -p "${sand}Show pg_stat_user_functions.${reset}"
psql -P pager=off -U postgres -c "\d pg_stat_user_functions"

read -p "${sand}Show pg_stat_statements.${reset}"
psql -P pager=off -U postgres -c "\d pg_stat_statements"

echo "${calm}End.${reset}"
