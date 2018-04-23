FROM ubuntu:16.04

# Set correct environment variables
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV DISPLAY :0

# Creating the wine user and setting up dedicated non-root environment: replace 1001 by your user id (id -u) for X sharing.
RUN useradd -u 1001 -d /home/wine -m -s /bin/bash wine
ENV HOME /home/wine
WORKDIR /home/wine
	
# Setting up the wineprefix to force 32 bit architecture.
ENV WINEPREFIX /home/wine/.wine
ENV WINEARCH win32

# Disabling warning messages from wine, comment for debug purpose.
ENV WINEDEBUG -all

#########################START  INSTALLATIONS##########################

# We don't want any interaction from package installation during the docker image building.
ENV DEBIAN_FRONTEND noninteractive

# We want the 32 bits version of wine allowing winetricks.
RUN	dpkg --add-architecture i386 && \

# Updating and upgrading a bit.
	apt-get update && \
	apt-get upgrade -y && \

# We need software-properties-common to add ppas and wget and apt-transport-https to add repositories and their keys.
	apt-get install -y --no-install-recommends software-properties-common apt-transport-https wget && \

# Adding required ppas: and wine.
	add-apt-repository ppa:graphics-drivers/ppa && \
	wget -nc https://dl.winehq.org/wine-builds/Release.key && \
	apt-key add Release.key && \
	add-apt-repository https://dl.winehq.org/wine-builds/ubuntu/ && \
	apt-get update && \

# Installation of wine, winetricks and its utilities and temporary xvfb to install latest winetricks and its tricks during docker build.
	apt-get install -y --no-install-recommends winehq-stable cabextract unzip p7zip zenity xvfb && \
	wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
	chmod +x winetricks && mv winetricks /usr/local/bin && \

# Installation of winbind to stop ntlm error messages.
	apt-get install -y --no-install-recommends winbind && \

# Installation of p11 to stop p11 kit error messages.
	apt-get install -y --no-install-recommends p11-kit-modules:i386 libp11-kit-gnome-keyring:i386 && \

# Installation of winetricks' tricks as wine user, comment if not needed.
	su -p -l wine -c 'winecfg && wineserver --wait' && \
	su -p -l wine -c 'winetricks -q winxp && wineserver --wait' && \
	su -p -l wine -c 'winetricks -q corefonts && wineserver --wait' && \
	su -p -l wine -c 'winetricks -q dotnet40 && wineserver --wait' && \
	su -p -l wine -c 'winetricks -q xna40 && wineserver --wait' && \

# Cleaning up.
	apt-get autoremove -y --purge software-properties-common && \
	apt-get autoremove -y --purge && \
	apt-get clean -y && \
	rm -rf /home/wine/.cache && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#########################END OF INSTALLATIONS##########################
