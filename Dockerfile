FROM osrf/ros:jazzy-desktop
SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

RUN apt-get update && apt-get install -y --no-install-recommends \
      ros-jazzy-rmw-cyclonedds-cpp \
      ros-jazzy-rosidl-generator-dds-idl \
      libyaml-cpp-dev git python3-colcon-common-extensions \
      ros-jazzy-navigation2 ros-jazzy-nav2-bringup \
      ros-jazzy-slam-toolbox ros-jazzy-pointcloud-to-laserscan \
      ros-jazzy-tf2-tools ros-jazzy-rqt-tf-tree \
      ros-jazzy-ros-gz ros-jazzy-xacro \
      ros-jazzy-robot-state-publisher ros-jazzy-joint-state-publisher-gui \
    && rm -rf /var/lib/apt/lists/*

ARG LIVOX_SDK2_TAG=v1.3.1
RUN git clone -q --depth 1 --branch ${LIVOX_SDK2_TAG} https://github.com/Livox-SDK/Livox-SDK2 /tmp/Livox-SDK2 \
 && cmake -S /tmp/Livox-SDK2 -B /tmp/Livox-SDK2/build -DCMAKE_CXX_FLAGS="-include cstdint" \
 && cmake --build /tmp/Livox-SDK2/build -j$(nproc) \
 && cmake --install /tmp/Livox-SDK2/build \
 && ldconfig \
 && rm -rf /tmp/Livox-SDK2

ARG UNITREE_ROS2_COMMIT=668d1ec5a05d1c38d3306bdca7d59f2ba3581a88
RUN mkdir -p /opt/unitree_ros2 && cd /opt/unitree_ros2 \
 && git init -q \
 && git remote add origin https://github.com/unitreerobotics/unitree_ros2 \
 && git fetch -q --depth 1 origin ${UNITREE_ROS2_COMMIT} \
 && git checkout -q FETCH_HEAD \
 && git rev-parse HEAD > /opt/unitree_ros2/COMMIT \
 && cd /opt/unitree_ros2/cyclonedds_ws \
 && source /opt/ros/jazzy/setup.bash \
 && colcon build

COPY ros_env.sh /ros_env.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && echo "source /ros_env.sh" >> /root/.bashrc
 
WORKDIR /ws
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
