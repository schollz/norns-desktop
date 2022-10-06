#/bin/bash

sudo /etc/init.d/dbus start
sudo chown -R we:we /home/we/dust
Xvfb :0 -screen 0 1280x640x16 -fbdir /tmp &
cd /home/we/
LOGGER=info /usr/local/go/bin/go run oled-server.go -window-name 'matron' -port 8889 &
sleep 1
export JACK_NO_START_SERVER=1
export JACK_NO_AUDIO_RESERVATION=1
jackd -V
$(cat /etc/jackdrc) &
cd /home/we/norns
sleep 1
/home/we/norns/build/crone/crone &
cd /home/we/norns/sc
sleep 1
timeout 0.5 /home/we/norns/build/ws-wrapper/ws-wrapper ws://*:5556 /usr/local/bin/sclang -i maiden
./install.sh
timeout 0.5 /home/we/norns/build/ws-wrapper/ws-wrapper ws://*:5556 /usr/local/bin/sclang -i maiden
sleep 0.5
/home/we/norns/build/ws-wrapper/ws-wrapper ws://*:5556 /usr/local/bin/sclang -i maiden &
sleep 0.5
export DISPLAY=:0
cd /home/we/norns
sleep 0.5
/home/we/norns/build/ws-wrapper/ws-wrapper ws://*:5555 /home/we/norns/build/matron/matron &
sleep 0.5
icecast2 -c /etc/icecast2/icecast.xml &
sleep 0.5
darkice -c /etc/darkice.cfg &
sleep 0.5
jack_connect crone:output_1 darkice:left
jack_connect crone:output_2 darkice:right
cd /home/we/maiden
./maiden server --app ./app/build --data ~/dust --doc ~/norns/doc &
tail -f /dev/null # stay alive
