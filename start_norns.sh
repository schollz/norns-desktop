#/bin/bash

export JACK_NO_START_SERVER=1
export JACK_NO_AUDIO_RESERVATION=1
export DISPLAY=:0

Xvfb :0 -screen 0 1280x640x16 -fbdir /tmp &
sleep 1
cd /home/we/ && LOGGER=info /usr/local/go/bin/go run oled-server.go -window-name 'matron' -port 8889 &
sleep 1
jackd -V
$(cat /etc/jackdrc) &
sleep 1
/home/we/norns/build/crone/crone &
sleep 1
/home/we/norns/build/ws-wrapper/ws-wrapper ws://*:5556 /usr/local/bin/sclang -i maiden &
sleep 2
/home/we/norns/build/ws-wrapper/ws-wrapper ws://*:5555 /home/we/norns/build/matron/matron &
sleep 1
cd /home/we/maiden && ./maiden server --app ./app/build --data ~/dust --doc ~/norns/doc &
sleep 1
icecast2 -c /etc/icecast2/icecast.xml &
sleep 1
darkice -c /etc/darkice.cfg &
sleep 1
jack_connect crone:output_1 darkice:left
jack_connect crone:output_2 darkice:right
tail -f /dev/null # stay alive
