#!/bin/bash
# Sourced by the entrypoint and by every interactive shell (docker exec).
source /opt/ros/jazzy/setup.bash
source /opt/unitree_ros2/cyclonedds_ws/install/setup.bash
if [ -f /ws/install/setup.bash ]; then source /ws/install/setup.bash; fi

export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
# UNITREE_IFACE is set at `docker run` time, so the image itself never changes:
#   lo      -> laptop / simulation (same as the README's setup_local.sh)
#   enp3s0  -> whatever NIC on head360 is on the robot's 192.168.123.x network
IFACE=${UNITREE_IFACE:-lo}
export CYCLONEDDS_URI="<CycloneDDS><Domain><General><Interfaces><NetworkInterface name=\"${IFACE}\" priority=\"default\" multicast=\"default\"/></Interfaces></General></Domain></CycloneDDS>"
