# norns on docker

this is heavily based off https://github.com/winder/norns-dev

this only works with linux amd64.

it might work with other computers/architectures, but things will have to be changed.

## prerequisites

- docker
- golang
- other:

```
sudo apt install gcc liblua5.3-dev
```

## urls

if you are using it locally, here's the urls you'll need:

- http://localhost:8889 to see the screen
- http://localhost:8000/radio.mp3 to hear the sound
- http://localhost:5000 to use maiden