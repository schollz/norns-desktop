FROM debian:stretch
LABEL stage=setup


## setup environment 
ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    PATH="/usr/local/go/bin:/home/we/node/bin:/home/we/node/node_modules/bin:$PATH" \
    NORNS_TAG=2204a94628babbd03025fca41f838b40a7ed6a2a \
    NORNS_REPO=https://github.com/schollz/norns.git \
    MAIDEN_TAG=ce4471e25a45c87040817c0619f3596fa43060aa \
    MAIDEN_REPO=https://github.com/schollz/maiden.git \
    GOLANG_VERSION=1.19.4 \
    JACK2_VERSION=1.9.19 \
    LIBMONOME_VERSION=1.4.4 \
    NANOMSG_VERSION=1.1.5 \
    SUPERCOLLIDER_VERSION=3.12.2 \
    SUPERCOLLIDER_PLUGINS_VERSION=3.11.1


RUN apt-get update -yq
RUN apt-get install -qy --no-install-recommends \
            libncursesw5-dev sox sudo git libicu-dev libudev-dev pkg-config libncurses5-dev libssl-dev \
            apt-transport-https \
            dbus \ 
            apt-utils \
            ca-certificates \
            gnupg2 \
            build-essential \
            bzip2 \
            cmake \
            curl \
            gdb \
            git \
            ladspalist \
            libasound2-dev \
            libavahi-client-dev \
            libavahi-compat-libdnssd-dev \
            libcwiid-dev \
            libcairo2-dev \
            libevdev-dev \
            libfftw3-dev \
            libicu-dev \
            liblo-dev \
            liblua5.1-dev \
            liblua5.3-dev \
            libreadline6-dev \
            libsndfile1-dev \
            libudev-dev \
            libxt-dev \
            luarocks \
            pkg-config \
            python-dev \
            unzip \
            wget libstdc++ \ 
            cdbs libmad0-dev libid3tag0-dev libsndfile1-dev libgd-dev libboost-filesystem-dev libboost-program-options-dev libboost-regex-dev git make cmake gcc g++ libmad0-dev \
            libid3tag0-dev libsndfile1-dev libgd-dev libboost-filesystem-dev \
            libboost-program-options-dev \
            libboost-regex-dev


## install audiowaveform 
RUN git clone https://github.com/bbc/audiowaveform.git /tmp/audiowaveform && \
    mkdir -p /tmp/audiowaveform/build && \
    cd /tmp/audiowaveform/build && \
    cmake -D ENABLE_TESTS=0 .. && make && make install && \
    audiowaveform --help

## INSTALL GO ##
RUN wget https://golang.org/dl/go$GOLANG_VERSION.linux-arm64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzvf /tmp/go.tar.gz && \
    rm -r /tmp/go.tar.gz && \
    go version

## INSTALL LDOC ##
RUN luarocks install ldoc

## INSTALL JACK2 ##
RUN mkdir -p /tmp/jack2 && \ 
    wget https://github.com/jackaudio/jack2/archive/v$JACK2_VERSION.tar.gz -O /tmp/jack2/jack2.tar.gz && \
    cd /tmp/jack2 && \
    tar xvfz jack2.tar.gz && \
    cd /tmp/jack2/jack2-$JACK2_VERSION && \
    ./waf configure --classic --alsa=yes --firewire=no --iio=no --portaudio=no --prefix /usr && \
    ./waf && ./waf install && cd / && rm -rf /tmp/jack2 && ldconfig

## UPGRADE CMAKE ##
RUN mkdir -p /tmp/cmake  && cd /tmp/cmake && \
    wget https://github.com/Kitware/CMake/releases/download/v3.24.1/cmake-3.24.1-linux-x86_64.tar.gz && \ 
    tar -xvzf cmake-3.24.1-linux-x86_64.tar.gz && \
    mv cmake-3.24.1-linux-x86_64/bin/* /usr/local/bin/ && \
    mv cmake-3.24.1-linux-x86_64/share/cmake-3.24 /usr/local/share/ && \
    cd / && rm -rf /tmp/cmake

## INSTALL SUPERCOLLIDER ##
RUN mkdir -p /tmp/supercollider && cd /tmp/supercollider && \
    wget https://github.com/supercollider/supercollider/releases/download/Version-$SUPERCOLLIDER_VERSION/SuperCollider-$SUPERCOLLIDER_VERSION-Source.tar.bz2 -O sc.tar.bz2 && \
    tar xvf sc.tar.bz2 && cd /tmp/supercollider/SuperCollider-$SUPERCOLLIDER_VERSION-Source && \
    mkdir -p build && cd /tmp/supercollider/SuperCollider-$SUPERCOLLIDER_VERSION-Source/build && \
    cmake -DCMAKE_BUILD_TYPE="Release" \
          -DCMAKE_INSTALL_PREFIX=/usr/local \
          -DBUILD_TESTING=OFF \
          -DENABLE_TESTSUITE=OFF \
          -DNATIVE=OFF \
          -DINSTALL_HELP=OFF \
          -DSC_IDE=OFF \
          -DSC_QT=OFF \
          -DSC_ED=OFF \
          -DSC_EL=OFF \
          -DSUPERNOVA=OFF \
          -DSC_VIM=OFF \
          .. && \
    make -j1 && make install && cd /

## INSTALL SUPERCOLLIDER PLUGINS ##
RUN mkdir -p /tmp/sc3-plugins && cd /tmp/sc3-plugins && \
    git clone --depth=1 --recursive --branch Version-$SUPERCOLLIDER_PLUGINS_VERSION https://github.com/supercollider/sc3-plugins.git && \
    cd /tmp/sc3-plugins/sc3-plugins && mkdir -p build && \
    cd /tmp/sc3-plugins/sc3-plugins/build && \
    cmake -DSC_PATH=/tmp/supercollider/SuperCollider-$SUPERCOLLIDER_VERSION-Source \
          -DNATIVE=OFF \
          .. && \
    cmake --build . --config Release -- -j1 && \
    cmake --build . --config Release --target install && \
    cd / && rm -rf /tmp/sc3-plugins && ldconfig

## INSTALL NANOMSG ##
RUN mkdir -p /tmp/nanomsg && cd /tmp/nanomsg && \
    wget https://github.com/nanomsg/nanomsg/archive/$NANOMSG_VERSION.tar.gz -O nanomsg.tar.gz && \
    tar -xvzf nanomsg.tar.gz && cd /tmp/nanomsg/nanomsg-$NANOMSG_VERSION && \
    mkdir -p /tmp/nanomsg/nanomsg-$NANOMSG_VERSION/build && \
    cd /tmp/nanomsg/nanomsg-$NANOMSG_VERSION/build && \
    cmake .. && cmake --build . && cmake --build . --target install && \
    cd / && rm -rf /tmp/nanomsg && ldconfig

## INSTALL LIBMONOME ##
RUN cd /tmp/ && wget https://github.com/monome/libmonome/archive/v$LIBMONOME_VERSION.tar.gz -O libmonome.tar.gz && \
    tar -xvzf libmonome.tar.gz && cd /tmp/libmonome-$LIBMONOME_VERSION && \
    ./waf configure --disable-udev --disable-osc && \
    ./waf && ./waf install && \
    cd / && rm -rf /tmp/libmonome-$LIBMONOME_VERSION && ldconfig

## INSTALL AUBIOONSET 
RUN git clone https://git.aubio.org/aubio/aubio /tmp/aubio && cd /tmp/aubio && \
    make && cd /tmp/aubio && ./waf install --destdir=/ && ldconfig && \
    cd / && rm -rf /tmp/aubio && aubioonset --help

LABEL stage=build
#I can't seem to get systemd to work
# RUN apt update -q && apt install -y systemd systemd-sysv init
RUN apt-get update -q && \
     apt-get install -qy --no-install-recommends \
             python3-pip \
             python3-setuptools \
             python3-wheel \
             tmux \
             vim \
             libboost-dev \
             # oled display
             libsdl2-dev \
             x11vnc \
             xvfb \
             # display server
             x11-apps \
             imagemagick \
             icecast2 \
             lame \
             espeak \
             ffmpeg \
             vorbis-tools \
             darkice && \
     apt-get clean && \
     rm -rf /var/lib/apt/lists/* && \
     pip3 install tmuxp==1.4.0

# darkice installs libjack-jackd2-0, we need to remove it
RUN dpkg --remove --force-depends libjack-jackd2-0

## add we / sleep ##
RUN groupadd we -g 1000 && \
    useradd we -g 1000 -u 1000 -m -s /bin/bash && \
    adduser we sudo
USER we
WORKDIR /home/we

## INSTALL NODE ##
RUN wget https://nodejs.org/dist/v18.15.0/node-v18.15.0-linux-armv7l.tar.xz -O /tmp/node.tar.xz
RUN mkdir -p /home/we/node
RUN tar -xJf /tmp/node.tar.xz -C /home/we/node
RUN mv /home/we/node/node-*/* /home/we/node/
RUN mkdir -p /home/we/node/node_modules
RUN npm config set prefix "/home/we/node/node_modules"
RUN npm install -g npm yarn
RUN npm -v
RUN node -v

# MAIDEN - build release then install it.
RUN git clone $MAIDEN_REPO maiden_src && \
     cd maiden_src && \
     git checkout $MAIDEN_TAG && \
     make release-local && \
     tar -xvf dist/maiden.tgz -C /home/we && \
     /home/we/maiden/project-setup.sh

# # MATRON (Norns)
RUN git clone $NORNS_REPO && \
     cd /home/we/norns && \
     git checkout $NORNS_TAG && \
     git submodule update --init --recursive && \
     ./waf configure --desktop && \
     ./waf build --desktop

# Build PortedPlugins
RUN mkdir -p /home/we/.local/share/SuperCollider/Extensions/
RUN cd /tmp &&  wget https://github.com/supercollider/supercollider/archive/refs/tags/Version-3.12.2.tar.gz && \
    tar -xvzf Version-3.12.2.tar.gz && \
    rm Version-3.12.2.tar.gz && \
    git clone https://github.com/madskjeldgaard/portedplugins && \
    cd portedplugins && \
    git submodule update --init --recursive && \
    sed -i 's/^/#include <stddef.h>\n/' /tmp/portedplugins/DaisySP/Source/Filters/allpass.cpp && \
    sed -i 's/^/#include <stddef.h>\n/' /tmp/portedplugins/DaisySP/Source/Filters/allpass.h && \
    mkdir build && \
    cd build && \
    cmake .. -DCMAKE_BUILD_TYPE='Release' -DSC_PATH=/tmp/supercollider-Version-3.12.2 -DCMAKE_INSTALL_PREFIX=/home/we/.local/share/SuperCollider/Extensions/ -DSUPERNOVA=OFF && \
    cmake --build . --config Release && \
    cmake --build . --config Release --target install

## build oled server
COPY ["oled-server.go", "/home/we/oled-server.go"]
COPY ["go.mod", "/home/we/go.mod"]
COPY ["go.sum", "/home/we/go.sum"]
COPY ["static", "/home/we/static"]
WORKDIR /home/we/
RUN go build -v -x

# # DUST - maiden data directory.
# #RUN /home/we/maiden/project-setup.sh
RUN sed -i 's/norns.disk/100000/g' /home/we/norns/lua/core/menu/tape.lua
RUN sed -i 's/screensaver.time = 900/screensaver.time = 90000000/g' /home/we/norns/lua/core/screen.lua
#RUN sed -i 's/if cmd=="\/remote\/key" then/if cmd=="\/remote\/brd" then keyboard.process(1,n,val) elseif cmd=="\/remote\/key" then/g' /home/we/norns/lua/core/osc.lua
#RUN sed -i 's/if _menu.keyboardcode/if c=="MINUS" then _menu.penc(3,value*-1) elseif c=="EQUAL" then _menu.penc(3,value) end; if _menu.keyboardcode/g' /home/we/norns/lua/core/menu.lua
#RUN sed -i 's/if value==1 then/if value>=1 then/g' /home/we/norns/lua/core/menu.lua
#RUN sed -i 's/elseif _menu.mode then _menu.keycode(c,value)/elseif (c=="F1" or c=="F2" or c=="F3" or c=="F4") and value==1 then _menu.set_mode(true); _menu.keycode(c,value) elseif (c=="F5" and value==1) then _menu.set_mode(not _menu.mode) elseif _menu.mode then _menu.keycode(c,value)/g' norns/lua/core/keyboard.lua
RUN mkdir -p /home/we/.local/share/SuperCollider/Extensions
RUN cp /home/we/norns/sc/norns-config.sc /home/we/.local/share/SuperCollider/Extensions/
RUN git clone https://github.com/schollz/faustsc /tmp/faustsc && cd /tmp/faustsc && \
    make && \
    mv /tmp/faustsc/fverb/build /home/we/.local/share/SuperCollider/Extensions/fverb

## copy restart files
COPY restart_sclang.sh /home/we/norns/restart_sclang.sh
COPY restart_matron.sh /home/we/norns/restart_matron.sh
USER root
RUN chmod +x /home/we/norns/restart_*.sh
RUN chown -R we:we /home/we/norns/restart_*.sh
RUN echo 'we:sleep' | chpasswd
RUN echo 'we ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
USER we

COPY ["norns.yaml", "/home/we/.tmuxp/norns.yaml"]
COPY ["start_norns.sh", "/home/we/"]
COPY ["tmux.conf", "/home/we/.tmux.conf"]
COPY icecast.xml /etc/icecast2/icecast.xml
COPY darkice.cfg /etc/darkice.cfg
COPY matronrc.lua /home/we/norns/matronrc.lua
# COPY maiden /home/we/maiden/maiden
# CMD /bin/bash
CMD /home/we/start_norns.sh
# CMD ["tmuxp","load","norns"]
# ENTRYPOINT "tmuxp load -d norns" && /bin/bash
# CMD tmuxp load -d norns && /binb/bash
