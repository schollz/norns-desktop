#!/bin/bash

kill -9 $(ps aux | grep "matron" | grep build | grep norns | grep -v grep | grep -v restart_matron | awk '{print $2}')
DISPLAY=:0 nohup /home/we/norns/build/ws-wrapper/ws-wrapper ws://*:5555 /home/we/norns/build/matron/matron > /tmp/matron.log &2>1 &

