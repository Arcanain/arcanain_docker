# Fetch ROS2 Hubmle official image
ARG ROS_VERSION=humble
FROM osrf/ros:${ROS_VERSION}-desktop
ARG ROS_VERSION

RUN apt-get update && apt-get -y upgrade

# Install Python3 and pip
RUN apt-get install -y \
  python-is-python3 \
  python3-pip \
  && rm -rf /var/lib/apt/lists/*

# Add Gazebo official repository
RUN apt-get update && apt-get install -y \
  lsb-release \
  gnupg \
  wget \
  && rm -rf /var/lib/apt/lists/*
RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null

# Install Gazebo and ROS2 Humble related packages
RUN apt-get update && apt-get install -y \
  ignition-fortress \
  ros-humble-ros-gz-sim \
  ros-humble-ros-ign-bridge \
  && rm -rf /var/lib/apt/lists/*

# Insall rviz related pachages
RUN apt-get update && apt-get install -y \
  ros-humble-joint-state-publisher \
  ros-humble-joint-state-publisher-gui \
  ros-humble-robot-state-publisher \
  && rm -rf /var/lib/apt/lists/*

# Install ROS2 Humble packages and clang-format
RUN apt-get update && apt-get install -y \
  clang-format \
  ros-humble-ament-clang-format \
  ros-humble-ament-cmake-clang-format \
  ros-humble-ament-cmake-uncrustify \
  ros-humble-ament-uncrustify \
  && rm -rf /var/lib/apt/lists/*

# Install dependencies
RUN apt-get update && apt-get install -y --install-recommends \
  build-essential \
  coinor-libipopt-dev \
  gfortran \
  liblapack-dev \
  libmumps-dev \
  swig \
  && rm -rf /var/lib/apt/lists/*
  
# Install matplotlib
RUN pip3 install matplotlib

# Clone CasADi repository and build packages
WORKDIR /root
RUN git clone https://github.com/casadi/casadi.git --recursive

WORKDIR /root/casadi/build
RUN cmake -DWITH_PYTHON=ON -DWITH_IPOPT=ON -DWITH_OPENMP=ON -DWITH_THREAD=ON .. && \
  make && \
  make install

# Clone Arcanain repositories
WORKDIR /root/ros2_ws/src
RUN git clone --branch develop https://github.com/Arcanain/arcanain_tutorial.git \
    && git clone https://github.com/Arcanain/arcanain_simulator.git \
    && git clone https://github.com/Arcanain/keyboard_teleop.git \
    && git clone https://github.com/Arcanain/arcanain_control_tutorial.git \
    && git clone https://github.com/Arcanain/mpc_cbf_planner.git

# Build ROS2 packages
WORKDIR /root/ros2_ws
RUN /bin/bash -c "source /opt/ros/${ROS_VERSION}/setup.bash && colcon build --parallel-workers 1"

# Set up environment
RUN echo "source /opt/ros/${ROS_VERSION}/setup.bash" >> ~/.bashrc
RUN echo "source /root/ros2_ws/install/setup.bash" >> ~/.bashrc