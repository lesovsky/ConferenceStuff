#!/bin/bash

psql -U postgres -d postgres -c 'drop database if exists pgday2017'
psql -U postgres -d postgres -c 'create database pgday2017'
pgbench -i -s 1 -U postgres -d pgday2017
psql -f sql/01-fill-test-data.sql -U postgres -d pgday2017
