#!/bin/bash

kill -1 $(ps aux | grep "matron" | grep build | grep norns | grep -v grep | grep -v restart_matron | awk '{print $2}')
nohup /home/we/norns/build/ws-wrapper/ws-wrapper ws://*:5555 /home/we/norns/build/matron/matron > /dev/null 2>&1 &

