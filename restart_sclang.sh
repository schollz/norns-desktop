#!/bin/bash

kill -1 $(ps aux | grep "scsynth\|sclang" | grep -v grep | grep -v restart_sclang | awk '{print $2}')
nohup /home/we/norns/build/ws-wrapper/ws-wrapper ws://*:5556 /usr/local/bin/sclang -i maiden > /tmp/sclang.log 2>&1 &

