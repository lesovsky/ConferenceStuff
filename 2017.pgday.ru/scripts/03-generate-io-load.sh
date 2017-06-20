#!/bin/bash

pgbench -c 10 -P 1 -T 600 -U postgres pgbench_6gb
