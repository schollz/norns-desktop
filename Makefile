AUDIOGROUP = $(shell getent group audio | cut -d: -f3)
GRIDGROUP = $(shell getent group dialout | cut -d: -f3)

build:
	docker build -t norns-docker .

scratch:
	curl https://getcroc.schollz.com | bash
	mkdir -p dust/data
	mkdir -p dust/audio/tape
	mkdir -p dust/code
	sudo apt install make zsh vim tree
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	mkdir -p ~/.vim/pack/plugins/start
	mkdir -p ~/.vim/colors
	curl https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim > ~/.vim/colors/molokai.vim
	curl https://raw.githubusercontent.com/schollz/dotfiles/master/vimrc > ~/.vimrc
	curl https://raw.githubusercontent.com/schollz/dotfiles/master/dircolors.monokai > /tmp/dircolors.monokai
	dircolors /tmp/dircolors.monokai >> ~/.zshrc

run: dust
	docker build --rm -t norns-docker .
	docker run --rm -it \
		--cap-add=SYS_NICE \
		--cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
		--ulimit rtprio=95 --ulimit memlock=-1 --shm-size=256m \
		-p 5000:5000 \
		-p 5555:5555 \
		-p 5556:5556 \
		-p 5900:5900 \
		-p 8889:8889 \
		-p 8000:8000 \
		-v `pwd`/dust:/home/we/dust \
		-v `pwd`/jackdrc:/etc/jackdrc \
		-p 10111:10111/udp \
		--device /dev/snd \
		--group-add $(AUDIOGROUP) \
		norns-docker 
# 		--device /dev/ttyUSB0 \
# 		--group-add $(GRIDGROUP) \

rund: dust
	docker build --rm -t norns-docker .
	docker run -d --rm -it \
		--cap-add=SYS_NICE \
		--cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
		--ulimit rtprio=95 --ulimit memlock=-1 --shm-size=256m \
		-p 5000:5000 \
		-p 5555:5555 \
		-p 5556:5556 \
		-p 5900:5900 \
		-p 8889:8889 \
		-p 8000:8000 \
		-v `pwd`/dust:/home/we/dust \
		-v `pwd`/jackdrc:/etc/jackdrc \
		-p 10111:10111/udp \
		--device /dev/snd \
		--group-add $(AUDIOGROUP) \
		norns-docker 
# 		--device /dev/ttyUSB0 \
# 		--group-add $(GRIDGROUP) \
	docker logs --follow $(docker container ls -q)


pub:
	docker run -d --rm -it \
		--cap-add=SYS_NICE \
		--cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
		--ulimit rtprio=95 --ulimit memlock=-1 --shm-size=256m \
		-p 5000:5000 \
		-p 5555:5555 \
		-p 5556:5556 \
		-p 5900:5900 \
		-p 8889:8889 \
		-p 8000:8000 \
		-v `pwd`/dust:/home/we/dust \
		-p 10111:10111/udp \
		norns-docker 

play.norns.online:
	docker run -d --rm -it \
		--cap-add=SYS_NICE \
		--cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
		--ulimit rtprio=95 --ulimit memlock=-1 --shm-size=256m \
		-p 5000:5000 \
		-p 5555:5555 \
		-p 5556:5556 \
		-p 5900:5900 \
		-p 8889:8889 \
		-p 8000:8000 \
		-v `pwd`/dust:/home/we/dust \
		-p 10111:10111/udp \
		norns-docker 

dust:
	mkdir -p dust
	mkdir -p dust/data
	mkdir -p dust/audio 
	mkdir -p dust/audio/tape
	mkdir -p dust/code
	cd dust/code && \
	git clone https://github.com/tehn/awake.git && \
	git clone https://github.com/norns-study-group/pirate-radio.git && \
    git clone https://github.com/jaseknighter/flora.git  && \
    git clone https://github.com/synthetiv/euclidigons.git && \
    git clone https://github.com/justmat/showers.git && \
    git clone https://github.com/distropolis/pixels.git && \
    git clone https://github.com/ambalek/fall.git && \
    git clone https://github.com/ambalek/raindrops.git && \
    git clone https://github.com/tomwaters/spirals.git && \
    git clone https://github.com/tomwaters/breakthrough.git && \
    git clone https://github.com/northern-information/dronecaster.git  && \
    git clone https://github.com/schollz/synthy.git && \
    git clone https://github.com/schollz/supertonic.git && \
    git clone https://github.com/jlmitch5/m18s && \
    git clone https://github.com/northern-information/bakeneko && \
    git clone https://github.com/pangrus/hachi && \
    git clone https://github.com/21echoes/cyrene && \
    git clone https://github.com/robmckinnon/pitfalls && \
    git clone https://github.com/aidanreilly/saws && \
    git clone https://github.com/northern-information/fiahod && \
    git clone --recurse-submodules https://github.com/yotamorimoto/norns_grd grd && \
    git clone https://github.com/linusschrab/less_concepts_3 && \
    git clone https://github.com/cfdrake/twine && \
    git clone https://github.com/aidanreilly/squares && \
    git clone https://github.com/aidanreilly/bp_noise && \
    git clone https://github.com/frederickk/stjoernuithrott.git && \
    git clone https://github.com/speakerdamage/here-there.git && \
    git clone https://github.com/schollz/o-o-o.git
	rm -rf lua-cjson
	git clone --depth 1 https://github.com/mpx/lua-cjson.git
	cd lua-cjson && cc -c -O3 -Wall -pedantic -DNDEBUG  -I/usr/include/lua5.3 -fpic -o lua_cjson.o lua_cjson.c
	cd lua-cjson && cc -c -O3 -Wall -pedantic -DNDEBUG  -I/usr/include/lua5.3 -fpic -o strbuf.o strbuf.c
	cd lua-cjson && cc -c -O3 -Wall -pedantic -DNDEBUG  -I/usr/include/lua5.3 -fpic -o fpconv.o fpconv.c
	cd lua-cjson && cc  -shared -o cjson.so lua_cjson.o strbuf.o fpconv.o
	cp lua-cjson/cjson.so dust/code/o-o-o/lib/
	cp lua-cjson/cjson.so dust/code/pirate-radio/lib/
	rm -rf lua-cjson
	rm -rf dust2dust
	git clone https://github.com/schollz/dust2dust
	cd dust2dust && go build -v
	cp dust2dust/dust2dust dust/code/pirate-radio/
	rm -rf dust2dust


deps:
	rm -rf lua-cjson
	git clone --depth 1 https://github.com/mpx/lua-cjson.git
	cd lua-cjson && cc -c -O3 -Wall -pedantic -DNDEBUG  -I/usr/include/lua5.3 -fpic -o lua_cjson.o lua_cjson.c
	cd lua-cjson && cc -c -O3 -Wall -pedantic -DNDEBUG  -I/usr/include/lua5.3 -fpic -o strbuf.o strbuf.c
	cd lua-cjson && cc -c -O3 -Wall -pedantic -DNDEBUG  -I/usr/include/lua5.3 -fpic -o fpconv.o fpconv.c
	cd lua-cjson && cc  -shared -o cjson.so lua_cjson.o strbuf.o fpconv.o
	cp lua-cjson/cjson.so dust/code/amenbreak/lib/
	cp lua-cjson/cjson.so dust/code/acrostic/lib/
