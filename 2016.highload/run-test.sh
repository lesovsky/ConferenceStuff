#!/bin/bash

pgbench -n -c 3 -f test.iud.pgb -P 10 -r -T 3600 -U postgres pgbench
