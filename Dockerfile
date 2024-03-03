# install ROS2 Humble
ARG ROS_VERSION=humble
FROM osrf/ros:${ROS_VERSION}-desktop
ARG ROS_VERSION

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install python3-pip python-is-python3

# Gazeboの公式パッケージリポジトリを追加
RUN apt-get install -y lsb-release wget gnupg && \
    wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null

# GazeboとROS 2 Humbleの関連パッケージをインストール
RUN apt-get install -y \
  ignition-fortress \
  ros-humble-ros-gz-sim \
  ros-humble-ros-ign-bridge

# rviz描画関連パッケージをインストール
RUN apt-get install -y \
  ros-humble-joint-state-publisher \
  ros-humble-joint-state-publisher-gui \
  ros-humble-robot-state-publisher

# 作業ディレクトリを設定
WORKDIR /root/ros2_ws/src
RUN git clone --branch develop https://github.com/Arcanain/arcanain_tutorial.git \
    && git clone https://github.com/Arcanain/arcanain_simulator.git \
    && git clone https://github.com/Arcanain/keyboard_teleop.git

# ビルドプロセス
WORKDIR /root/ros2_ws
RUN /bin/bash -c "source /opt/ros/${ROS_VERSION}/setup.bash && colcon build"

# 環境設定
RUN echo "source /opt/ros/${ROS_VERSION}/setup.bash" >> ~/.bashrc
RUN echo "source /root/ros2_ws/install/setup.bash" >> ~/.bashrc