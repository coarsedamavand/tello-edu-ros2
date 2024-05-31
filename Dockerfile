# Following from http://devanshdhrafani.com/blog/2021/04/15/dockerros2.html
# ROS2 Foxy Fitzroy is made to run on Ubuntu 20.04. So in the first line, we download the Ubuntu 20.04 Docker Image:
FROM ubuntu:20.04

# Set locale as per https://docs.ros.org/en/foxy/Installation/Ubuntu-Install-Debians.html
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# setup the sources so that the system knows where to look for ROS2 packages
RUN apt update && apt install -y curl gnupg2 lsb-release
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# The ROS installation asks for configuration prompts in between the installation. 
# Especially for selecting the timezone and keyboard language. 
# Using DEBIAN_FRONTEND=noninteractive allows to bypass this step by letting the installer pick the defaults. 
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y ros-foxy-desktop

WORKDIR /root/dev_ws/src
RUN git clone https://github.com/ros/ros_tutorials.git -b foxy-devel
WORKDIR /root/dev_ws

# Finally, we install rosdep and colcon. Both are essential packages for ROS2. 
# Rosdep helps resolves errors associated with missing dependencies. 
# Colcon is the next iteration of catkin_make and other tools that were used for building packages in ROS1.
RUN apt-get install python3-rosdep -y
RUN rosdep init
RUN rosdep update
RUN rosdep install -i --from-path src --rosdistro foxy -y
RUN apt install python3-colcon-common-extensions -y

# For using ROS commands in any new terminal, we need to source the setup.bash file. 
# To avoid the hassle of sourcing the file in every terminal, we normally add a script to the .bashrc file. 
# A similar thing can be done for Docker Containers.
# The COPY command copies the entrypoint shell script to the root of the Docker Container. 
# This script will source the setup.bash file.
# The command ENTRYPOINT allows us to set the script which will run each time a container is started. 
# Finally the CMD command is used to set bash as the default executable when the container is first started.
COPY ros2_entrypoint.sh /root/.
ENTRYPOINT ["/root/ros2_entrypoint.sh"]
CMD ["bash"]

# Install the driver, build, and test
RUN scripts/install.sh
RUN scripts/build.sh
RUN scripts/run.sh