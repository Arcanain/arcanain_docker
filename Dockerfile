# Use the official ROS image as the base image
FROM ros:humble-ros-core-jammy

# Set shell for running commands
SHELL ["/bin/bash", "-c"]

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    git \
    python3-colcon-common-extensions \
    python3-colcon-mixin \
    python3-rosdep \
    python3-vcstool \
    && rm -rf /var/lib/apt/lists/*

# bootstrap rosdep
RUN rosdep init && \
  rosdep update --rosdistro $ROS_DISTRO

# setup colcon mixin and metadata
RUN colcon mixin add default \
      https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml && \
    colcon mixin update && \
    colcon metadata add default \
      https://raw.githubusercontent.com/colcon/colcon-metadata-repository/master/index.yaml && \
    colcon metadata update

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-desktop=0.10.0-1* \
    && rm -rf /var/lib/apt/lists/*


# (3) 一般ユーザを作成 (例: ubuntu)
#     -u 1000, -g 1000 はホストのUID/GIDと合わせるとパーミッションの衝突が少なくなる
RUN useradd -m -s /bin/bash -u 1000 ubuntu \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# (4) 以降は一般ユーザubuntuで作業
USER ubuntu
WORKDIR /home/ubuntu

# (5) ROSのsetupを毎回読み込ませたければ、~/.bashrc に追記する等の方法がある
# 例：
# RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/ubuntu/.bashrc


# Set the entrypoint to source ROS setup.bash and run a bash shell
CMD ["/bin/bash"]
