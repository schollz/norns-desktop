FROM debian:stretch
LABEL stage=setup

## install audiowaveform 
RUN apt-get update -yq
RUN apt-get install -y cdbs cmake libmad0-dev libid3tag0-dev libsndfile1-dev libgd-dev libboost-filesystem-dev libboost-program-options-dev libboost-regex-dev git make cmake gcc g++ libmad0-dev \
  libid3tag0-dev libsndfile1-dev libgd-dev libboost-filesystem-dev \
  libboost-program-options-dev \
  libboost-regex-dev
RUN git clone https://github.com/bbc/audiowaveform.git /tmp/audiowaveform
RUN mkdir -p /tmp/audiowaveform/build
WORKDIR /tmp/audiowaveform/build
RUN cmake -D ENABLE_TESTS=0 .. && make && make install
RUN audiowaveform --help

## setup environment 

ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    PATH="/usr/local/go/bin:/home/we/node/bin:/home/we/node/node_modules/bin:$PATH" \
    NORNS_TAG=71772c6ea43c90f15e7a5d3b7755d4beacc64c5b \
    NORNS_REPO=https://github.com/monome/norns.git \
    MAIDEN_TAG=ce4471e25a45c87040817c0619f3596fa43060aa \
    MAIDEN_REPO=https://github.com/schollz/maiden.git \
    GOLANG_VERSION=1.19 \
    JACK2_VERSION=1.9.19 \
    LIBMONOME_VERSION=1.4.4 \
    NANOMSG_VERSION=1.1.5 \
    SUPERCOLLIDER_VERSION=3.12.0 \
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
            wget libstdc++


## INSTALL GO ##
RUN wget https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz -O /tmp/go.tar.gz
RUN tar -C /usr/local -xzvf /tmp/go.tar.gz
RUN rm -r /tmp/go.tar.gz
RUN go version

## INSTALL LDOC ##
RUN luarocks install ldoc

## INSTALL JACK2 ##
RUN mkdir -p /tmp/jack2
RUN wget https://github.com/jackaudio/jack2/archive/v$JACK2_VERSION.tar.gz -O /tmp/jack2/jack2.tar.gz
WORKDIR /tmp/jack2
RUN tar xvfz jack2.tar.gz
WORKDIR /tmp/jack2/jack2-$JACK2_VERSION
RUN ./waf configure --classic --alsa=yes --firewire=no --iio=no --portaudio=no --prefix /usr
RUN ./waf
RUN ./waf install
WORKDIR /
RUN rm -rf /tmp/jack2
RUN ldconfig

## UPGRADE CMAKE ##
RUN mkdir -p /tmp/cmake 
WORKDIR /tmp/cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.24.1/cmake-3.24.1-linux-x86_64.tar.gz
RUN tar -xvzf cmake-3.24.1-linux-x86_64.tar.gz
RUN mv cmake-3.24.1-linux-x86_64/bin/* /usr/local/bin/
RUN mv cmake-3.24.1-linux-x86_64/share/cmake-3.24 /usr/local/share/
WORKDIR /
RUN rm -rf /tmp/cmake

## INSTALL SUPERCOLLIDER ##
RUN mkdir -p /tmp/supercollider
WORKDIR /tmp/supercollider
RUN wget https://github.com/supercollider/supercollider/releases/download/Version-$SUPERCOLLIDER_VERSION/SuperCollider-$SUPERCOLLIDER_VERSION-Source.tar.bz2 -O sc.tar.bz2
RUN tar xvf sc.tar.bz2
WORKDIR /tmp/supercollider/SuperCollider-$SUPERCOLLIDER_VERSION-Source
RUN mkdir -p build
WORKDIR /tmp/supercollider/SuperCollider-$SUPERCOLLIDER_VERSION-Source/build
RUN cmake -DCMAKE_BUILD_TYPE="Release" \
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
          ..
RUN make -j1
RUN make install
WORKDIR /

## INSTALL SUPERCOLLIDER PLUGINS ##
RUN mkdir -p /tmp/sc3-plugins
WORKDIR /tmp/sc3-plugins
RUN git clone --depth=1 --recursive --branch Version-$SUPERCOLLIDER_PLUGINS_VERSION https://github.com/supercollider/sc3-plugins.git
WORKDIR /tmp/sc3-plugins/sc3-plugins
RUN mkdir -p build
WORKDIR /tmp/sc3-plugins/sc3-plugins/build
RUN cmake -DSC_PATH=/tmp/supercollider/SuperCollider-$SUPERCOLLIDER_VERSION-Source \
          -DNATIVE=OFF \
          ..
RUN cmake --build . --config Release -- -j1
RUN cmake --build . --config Release --target install
WORKDIR /
RUN rm -rf /tmp/sc3-plugins
RUN ldconfig

## INSTALL NANOMSG ##
RUN mkdir -p /tmp/nanomsg
WORKDIR /tmp/nanomsg
RUN wget https://github.com/nanomsg/nanomsg/archive/$NANOMSG_VERSION.tar.gz -O nanomsg.tar.gz
RUN tar -xvzf nanomsg.tar.gz
WORKDIR /tmp/nanomsg/nanomsg-$NANOMSG_VERSION
RUN mkdir -p /tmp/nanomsg/nanomsg-$NANOMSG_VERSION/build
WORKDIR /tmp/nanomsg/nanomsg-$NANOMSG_VERSION/build
RUN cmake ..
RUN cmake --build .
RUN cmake --build . --target install
WORKDIR /
RUN rm -rf /tmp/nanomsg
RUN ldconfig

## INSTALL LIBMONOME ##
WORKDIR /tmp/
RUN wget https://github.com/monome/libmonome/archive/v$LIBMONOME_VERSION.tar.gz -O libmonome.tar.gz
RUN tar -xvzf libmonome.tar.gz
WORKDIR /tmp/libmonome-$LIBMONOME_VERSION
RUN ./waf configure --disable-udev --disable-osc
RUN ./waf
RUN ./waf install
WORKDIR /
RUN rm -rf /tmp/libmonome-$LIBMONOME_VERSION
RUN ldconfig

## add we / sleep ##
RUN groupadd we -g 1000 && \
    useradd we -g 1000 -u 1000 -m -s /bin/bash
RUN adduser we sudo

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

USER we
WORKDIR /home/we

## INSTALL NODE ##
RUN wget https://nodejs.org/dist/v16.17.0/node-v16.17.0-linux-x64.tar.xz -O /tmp/node.tar.xz
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


COPY restart_sclang.sh /home/we/norns/restart_sclang.sh
COPY restart_matron.sh /home/we/norns/restart_matron.sh
USER root
RUN chmod +x /home/we/norns/restart_*.sh
RUN chown -R we:we /home/we/norns/restart_*.sh
RUN echo 'we:sleep' | chpasswd
RUN echo 'we ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
USER we

# # DUST - maiden data directory.
# #RUN /home/we/maiden/project-setup.sh
RUN sed -i 's/norns.disk/100000/g' /home/we/norns/lua/core/menu/tape.lua
RUN sed -i 's/screensaver.time = 900/screensaver.time = 90000000/g' /home/we/norns/lua/core/screen.lua

COPY ["oled-server.go", "/home/we/oled-server.go"]
COPY ["go.mod", "/home/we/go.mod"]
COPY ["go.sum", "/home/we/go.sum"]
COPY ["static", "/home/we/static"]
WORKDIR /home/we/
RUN go build -v -x
COPY ["norns.yaml", "/home/we/.tmuxp/norns.yaml"]
COPY ["tmux.conf", "/home/we/.tmux.conf"]
COPY repl-endpoints.json /home/we/maiden/app/build/repl-endpoints.json
COPY icecast.xml /etc/icecast2/icecast.xml
COPY darkice.cfg /etc/darkice.cfg
COPY matronrc.lua /home/we/norns/matronrc.lua
# COPY maiden /home/we/maiden/maiden
RUN mkdir -p /home/we/.local/share/SuperCollider/Extensions/
#CMD /bin/bash
CMD tmuxp load norns

