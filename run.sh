#!/bin/bash
#
# First run creates the container; later runs reuse it and open a new shell.
#   bash run.sh                                   # laptop: container "a2w_nav_dev", Cyclone on lo
#   NAME=head360_nav UNITREE_IFACE=enp3s0 RESTART=unless-stopped bash run.sh   # on head360
#
# Settings below (interface, domain, mounts) are fixed when the container is
# created. To change them: docker rm -f <name>, then run this script again.
IMAGE=${IMAGE:-a2w-nav:jazzy}
NAME=${NAME:-a2w_nav_dev}
WS=${WS:-$HOME/a2w_ws}
RESTART=${RESTART:-no}          # "unless-stopped" on the robot = comes back after reboot
mkdir -p "$WS/src"

# Allow GUI (rviz2) from the container; harmless on a headless robot.
if [ -n "$DISPLAY" ]; then xhost +local:docker > /dev/null 2>&1; fi

# Only request GPU passthrough if an NVIDIA GPU is actually present
GPU_FLAGS=""
if command -v nvidia-smi > /dev/null 2>&1; then
  GPU_FLAGS="--runtime=nvidia --gpus all"
fi

# Reuse the container if it already exists
if docker container inspect "$NAME" > /dev/null 2>&1; then
  docker start "$NAME" > /dev/null
  exec docker exec -it "$NAME" bash
fi

# Otherwise create it (no --rm, so it survives exits)
docker run -d \
  --name "$NAME" \
  --restart "$RESTART" \
  --net=host --ipc=host \
  -e UNITREE_IFACE=${UNITREE_IFACE:-lo} \
  -e ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-0} \
  -e XDG_RUNTIME_DIR=/tmp/runtime-root \
  -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
  --device /dev/dri:/dev/dri --group-add video \
  $GPU_FLAGS \
  -v "$WS":/ws \
  "$IMAGE" sleep infinity > /dev/null

exec docker exec -it "$NAME" bash
