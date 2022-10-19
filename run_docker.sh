docker kill $(docker ps -a -q --filter="name=norns-docker")
docker rm norns-docker
#docker build --rm -t norns-docker .
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
	-v `pwd`/repl-endpoints.json:/home/we/maiden/app/build/repl-endpoints.json \
	-p 10111:10111/udp \
	--device /dev/snd \
	--name norns-docker \
	--group-add $(getent group audio | cut -d: -f3) \
	norns-docker 
sleep 1
docker logs --follow $(docker ps -a -q --filter="name=norns-docker")
