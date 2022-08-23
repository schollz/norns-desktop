run: dust
	docker build -t norns-docker .
	docker run --rm -it \
		--cap-add=SYS_NICE \
	        --cap-add=SYS_ADMIN \
		--cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
		--ulimit rtprio=95 --ulimit memlock=-1 --shm-size=256m \
		-p 5000:5000 \
		-p 5555:5555 \
		-p 5556:5556 \
		-p 5900:5900 \
		-p 8889:8889 \
		-p 8000:8000 \
		-v `pwd`/dust:/home/we/dust \
		-v /sys/fs/cgroup/:/sys/fs/cgroup:ro \
		-p 10111:10111/udp \
		--tmpfs /tmp --tmpfs /run \
		norns-docker 

dust:
	mkdir -p dust
	mkdir -p dust/data
	mkdir -p dust/audio 
	mkdir -p dust/audio/tape
	mkdir -p dust/code
	cd dust/code && \
	git clone https://github.com/norns-study-group/pirate-radio.git
	git clone https://github.com/tehn/awake.git
	sudo chown -R we:we dust

