#!/bin/bash

. 00-env

read -p "${sand}Press Enter to run clients${reset}"
./too-many-conns

read -p "${sand}Press Enter to run clients using pgbouncer.${reset}"
./conns-to-pgbouncer
