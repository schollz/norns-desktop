# norns on docker

this is a (mostly) turn-key solution to get norns running on a laptop (or server). norns will run in a web browser that can be controlled and seen and heard. it will *not* allow audio input or external devices (grid or midi). also only works with linux amd64 - it might work with other computers/architectures, but things will have to be changed.

this is heavily based off https://github.com/winder/norns-dev. the main differences is that I'm using a web browser to interact with norns and I'm trying to keep it as up to date as possible with the main monome branch.

## prerequisites

- docker
- golang
- other:

```
> sudo apt install gcc liblua5.3-dev make
```

## install

to build and run:

```
> make
```

## urls

if you are using it locally, here's the urls you'll need:

- http://localhost:8889 to see the screen
- http://localhost:8000/radio.mp3 to hear the sound
- http://localhost:5000 to use maiden