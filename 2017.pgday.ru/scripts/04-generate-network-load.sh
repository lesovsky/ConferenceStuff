#!/bin/bash

pgbench -P 1 -f pgbench/04-network-load.pgb -T 600 -h 127.0.0.1 -U postgres pgday2017
