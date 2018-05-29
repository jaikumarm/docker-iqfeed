FROM ubuntu:16.04

# Set correct environment variables
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV DISPLAY :1
#ENV IQFEED_INSTALLER_BIN="iqfeed_client_5_2_7_0.exe"
ENV IQFEED_INSTALLER_BIN="iqfeed_client_6_0_0_3.exe"

# Creating the wine user and setting up dedicated non-root environment: replace 1001 by your user id (id -u) for X sharing.
RUN useradd -u 1000 -d /home/wine -m -s /bin/bash wine
ENV HOME /home/wine
WORKDIR /home/wine

# Setting up the wineprefix to force 32 bit architecture.
ENV WINEPREFIX /home/wine/.wine
ENV WINEARCH win32

# Disabling warning messages from wine, comment for debug purpose.
ENV WINEDEBUG -all

# We don't want any interaction from package installation during the docker image building.
ENV DEBIAN_FRONTEND noninteractive

# We want the 32 bits version of wine allowing winetricks.
RUN	dpkg --add-architecture i386 && \
# Updating and upgrading a bit.
	apt-get update && \
	apt-get upgrade -y && \
# We need software-properties-common to add ppas and wget and apt-transport-https to add repositories and their keys.
	apt-get install -y --no-install-recommends software-properties-common apt-transport-https wget unzip curl sudo vim git && \
# Adding x11vnc, supervisor and nodejs
	apt-get install -y --no-install-recommends xvfb x11vnc xdotool supervisor fluxbox xterm net-tools nodejs && \
# Adding required ppas: for installing wine.
	apt-get purge wine.* && \
	wget -nc https://dl.winehq.org/wine-builds/Release.key && apt-key add Release.key && \
	add-apt-repository 'deb http://dl.winehq.org/wine-builds/ubuntu/ xenial main' && \
	#add-apt-repository ppa:ricotz/unstable &&\
	#add-apt-repository -y ppa:ubuntu-wine/ppa && \
	apt-get update && \
# Installation of wine, winetricks and its utilities and temporary xvfb to install latest winetricks and its tricks during docker build.
	apt-get install -y --no-install-recommends winehq-stable && \
	#apt-get install -y --install-recommends wine1.8 && \	
	apt-get install -y --no-install-recommends wine-mono wine-gecko && \
	apt-get install -y --no-install-recommends cabextract p7zip zenity && \
	wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
	chmod +x winetricks && \
	mv winetricks /usr/local/bin && \
# Installation of winbind to stop ntlm error messages.
	apt-get install -y --no-install-recommends winbind && \
# Installation of p11 to stop p11 kit error messages.
	#apt-get install -y --no-install-recommends p11-kit-modules:i386 libp11-kit-gnome-keyring:i386 && \
# Cleaning up.
	apt-get autoremove -y --purge && \
	apt-get clean -y && \
	rm -rf /home/wine/.cache && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN \
# Installation of winetricks' tricks as wine user, comment if not needed.
	su -p -l wine -c 'winecfg && wineserver --wait' && \
	#su -p -l wine -c 'winetricks -q winxp && wineserver --wait' && \
	#su -p -l wine -c 'winetricks -q corefonts && wineserver --wait' && \
	su -p -l wine -c 'winetricks -q nocrashdialog && wineserver --wait' && \
# Download Install iqfeed client
	curl -SL http://www.iqfeed.net/$IQFEED_INSTALLER_BIN -o /home/wine/.wine/drive_c/$IQFEED_INSTALLER_BIN && \
	su -p -l wine -c '/usr/bin/xvfb-run -s -noreset -a /usr/bin/wine /home/wine/.wine/drive_c/$IQFEED_INSTALLER_BIN /S && wineserver --wait' && \
# Install python for pyiqfeed
	apt-get update && \
	apt-get install -y --no-install-recommends python3 python3-setuptools python3-numpy && \
	apt-get install -y --no-install-recommends python3-pip python3-tz python3-psycopg2 python3-dateutil python3-sqlalchemy python3-pandas &&\
# Cleaning up.
	apt-get autoremove -y --purge && \
	apt-get clean -y && \
	rm -rf /home/wine/.cache && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add pyiqfeed 
RUN git clone https://github.com/jaikumarm/pyiqfeed.git && \
    cd pyiqfeed && \
    python3 setup.py install && \
    cd .. && rm -rf pyiqfeed
	
ADD launch_iqfeed.py /home/wine/launch_iqfeed.py
ADD pyiqfeed_admin_conn.py /home/wine/pyiqfeed_admin_conn.py
ADD is_iqfeed_running.py /home/wine/is_iqfeed_running.py

# Add iqfeed proxy app
ADD app /home/wine/app
ADD iqfeed_startup.sh /home/wine/iqfeed_startup.sh

RUN \
	usermod -aG sudo wine && \
	echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
	chmod +x /home/wine/iqfeed_startup.sh && \
	chown -R wine:wine /home/wine/*.*

# Add supervisor conf
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
#USER wine

CMD ["/usr/bin/supervisord"]
#CMD ["/home/wine/iqfeed_startup.sh"]
# Expose Ports
EXPOSE 9101
EXPOSE 5010
EXPOSE 5901
