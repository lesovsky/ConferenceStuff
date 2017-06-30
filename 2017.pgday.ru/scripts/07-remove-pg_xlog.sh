#!/bin/bash

. 00-env
rm /var/log/postgresql/postgresql-test.log

read -p "${sand}Press Enter to initialize test instance.${reset}"
sudo -u postgres /usr/lib/postgresql/9.6/bin/initdb -D /db/9.6/test -A trust 
echo ${calm}Done.${reset}

echo -n -e "${sand}Configuring test instance... ${reset}"
sudo -u postgres sed -i -e 's/#port = 5432/port = 20000/' -e 's/#max_wal_size = 1GB/max_wal_size = 500MB/' /db/9.6/test/postgresql.conf &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

echo -n -e "${sand}Start test instance... ${reset}"
sudo -u postgres /usr/lib/postgresql/9.6/bin/pg_ctl -D /db/9.6/test -l /var/log/postgresql/postgresql-test.log start &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"
sleep 2

read -p "${sand}Press Enter to create test tables.${reset}"
sudo -u postgres pgbench -i -s 20 -p 20000
echo ${calm}Done.${reset}

read -p "${sand}Press Enter to run test workload.${reset}"
sudo -u postgres pgbench -T 60 -P 5 -c 8 -p 20000
echo ${calm}Done.${reset}

read -p "${sand}Press Enter to remove pg_xlog content.${reset}"
sudo -u postgres rm -rf /db/9.6/test/pg_xlog/* &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

read -p "${sand}Press Enter to restart instance.${reset}"
sudo -u postgres /usr/lib/postgresql/9.6/bin/pg_ctl -D /db/9.6/test -l /var/log/postgresql/postgresql-test.log -m fast restart &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"

read -p "${sand}Press Enter to show log.${reset}"
tail -n 10 /var/log/postgresql/postgresql-test.log

read -p "${sand}Press Enter to reset xlog.${reset}"
sudo -u postgres /usr/lib/postgresql/9.6/bin/pg_resetxlog -D /db/9.6/test/ 2>/dev/null

echo -n -e "${sand}Start test instance... ${reset}"
sudo -u postgres /usr/lib/postgresql/9.6/bin/pg_ctl -D /db/9.6/test -l /var/log/postgresql/postgresql-test.log start &>/dev/null && echo "${calm}OK${reset}" || echo "${fail}FAILED${reset}"
sleep 2

read -p "${sand}Press Enter to show log.${reset}"
tail -n 4 /var/log/postgresql/postgresql-test.log

read -p "${sand}Press Enter to show process list.${reset}"
ps f -p $(head -n 1 /db/9.6/test/postmaster.pid) --ppid $(head -n 1 /db/9.6/test/postmaster.pid)

read -p "${sand}Press Enter to remove test instance.${reset}"
sudo -u postgres /usr/lib/postgresql/9.6/bin/pg_ctl -D /db/9.6/test -l /var/log/postgresql/postgresql-test.log stop &>/dev/null
sleep 2
rm -rf /db/9.6/test

echo ${calm}End.${reset}
