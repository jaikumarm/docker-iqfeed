FROM ubuntu:16.04

# Set correct environment variables
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV WINEARCH win32
ENV DISPLAY :0
ENV WINE_MONO_VERSION 4.5.6
ENV IQFEED_INSTALLER="iqfeed_client_5_2_5_0.exe"
ENV WINEPREFIX /root/.wine

# Updating and upgrading a bit.
	# Install vnc, window manager and basic tools
RUN apt-get update && \
	apt-get install -y --no-install-recommends  && \
  apt-get install -y git curl x11vnc xdotool supervisor fluxbox net-tools nodejs &&\
	dpkg --add-architecture i386 && \
# We need software-properties-common to add ppas.
	apt-get install -y --no-install-recommends software-properties-common && \
  add-apt-repository ppa:ubuntu-wine/ppa && \
	apt-get update && \
	apt-get install -y --no-install-recommends wine1.8 cabextract unzip p7zip zenity xvfb && \
	curl -SL https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks  -o /usr/local/bin/winetricks && \
# Installation of winbind to stop ntlm error messages.
	apt-get install -y --no-install-recommends winbind &&\
# Get latest version of mono for wine
	mkdir -p /usr/share/wine/mono && \
	curl -SL 'http://sourceforge.net/projects/wine/files/Wine%20Mono/$WINE_MONO_VERSION/wine-mono-$WINE_MONO_VERSION.msi/download' -o /usr/share/wine/mono/wine-mono-$WINE_MONO_VERSION.msi && \
  chmod +x /usr/share/wine/mono/wine-mono-$WINE_MONO_VERSION.msi &&\
	mkdir -p /usr/share/wine/gecko && \
  curl -SL 'http://dl.winehq.org/wine/wine-gecko/2.40/wine_gecko-2.40-x86.msi' -o /usr/share/wine/gecko/wine_gecko-2.40-x86.msi &&\
# Cleaning up.
	apt-get autoremove -y --purge software-properties-common && \
  apt-get autoremove -y --purge && \
  apt-get clean -y && \
  rm -rf /home/wine/.cache && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Add novnc
RUN cd /root && git clone https://github.com/kanaka/noVNC.git && \
  cd noVNC/utils && git clone https://github.com/kanaka/websockify websockify &&\
	cd /root/noVNC && ln -s vnc_auto.html index.html

WORKDIR /root/

# Add supervisor conf
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN curl -SL http://www.iqfeed.net/$IQFEED_INSTALLER -o /root/$IQFEED_INSTALLER

ADD iqfeed_startup.sh /root/iqfeed_startup.sh
RUN chmod +x /root/iqfeed_startup.sh
# Add iqfeed proxy app
ADD app /root/app

ENV WINEPREFIX /root/.wine
CMD ["/usr/bin/supervisord"]
# Expose Ports
EXPOSE 9101
EXPOSE 8081
EXPOSE 5010
