#/bin/bash

# start screen
Xvfb :0 -screen 0 1280x640x16 -fbdir /tmp &
sleep 1
cd /home/we/norns-desktop
LOGGER=info /usr/local/go/bin/go run oled-server.go -window-name 'matron' -port 8889 &
sleep 1

# start jack
export JACK_NO_START_SERVER=1
export JACK_NO_AUDIO_RESERVATION=1
/usr/bin/jackd -R -P 95 -d alsa -d hw:USB &
sleep 1

# start crone
/home/we/norns/build/crone/crone &

# start sc
/home/we/norns/build/ws-wrapper/ws-wrapper 'ws://*:5556' /usr/local/bin/sclang -i maiden &

# start matron 
export DISPLAY=:0
/home/we/norns/build/ws-wrapper/ws-wrapper 'ws://*:5555' /home/we/norns/build/matron/matron &

# start maiden
cd /home/we/maiden && ./maiden server --app ./app/build --data ~/dust --doc ~/norns/doc &

# optional, start icecast
# icecast2 -c /home/we/norns-desktop/icecast.xml &
# sleep 0.5
# darkice -c /home/we/norns-desktop/darkice.cfg &
# sleep 0.5
# jack_connect crone:output_1 darkice:left
# jack_connect crone:output_2 darkice:right
