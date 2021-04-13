FROM ubuntu:focal

WORKDIR /root/
ENV HOME /root

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

ENV WINEPREFIX /root/prefix32
ENV WINEARCH win32
ENV DISPLAY :0

ENV IQFEED_INSTALLER_BIN="iqfeed_client_6_1_0_20.exe"
ENV IQFEED_LOG_LEVEL 0xB222

ENV WINEDEBUG -all

RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get upgrade -yq && \
    apt-get install -yq --no-install-recommends \
        software-properties-common apt-utils supervisor xvfb wget tar gpg-agent bbe netcat-openbsd net-tools && \
    # Adding x11vnc and fluxbox
	#apt-get install -y --no-install-recommends x11vnc xdotool fluxbox xterm && \
    wget -O - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
    echo 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' |tee /etc/apt/sources.list.d/winehq.list && \
    apt-get update && apt-get install -yq --no-install-recommends winehq-stable winbind winetricks cabextract && \
    mkdir /opt/wine-stable/share/wine/mono && \
    wget -O - https://dl.winehq.org/wine/wine-mono/4.9.4/wine-mono-bin-4.9.4.tar.gz |tar -xzv -C /opt/wine-stable/share/wine/mono && \
    mkdir /opt/wine-stable/share/wine/gecko && \
    wget -O /opt/wine-stable/share/wine/gecko/wine-gecko-2.47.1-x86.msi https://dl.winehq.org/wine/wine-gecko/2.47.1/wine-gecko-2.47.1-x86.msi && \
    wget -O /opt/wine-stable/share/wine/gecko/wine-gecko-2.47.1-x86_64.msi https://dl.winehq.org/wine/wine-gecko/2.47.1/wine-gecko-2.47.1-x86_64.msi && \
    # Install python for pyiqfeed
    apt-get install -yq --no-install-recommends \
        git python3 python3-setuptools python3-numpy python3-pip python3-tz \
        python3-psycopg2 python3-dateutil python3-sqlalchemy python3-pandas &&\
    # Cleaning up.
    apt-get autoremove -y --purge && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#RUN wget -O - https://github.com/novnc/noVNC/archive/v1.1.0.tar.gz | tar -xzv -C /root/ && mv /root/noVNC-1.1.0 /root/novnc && ln -s /root/novnc/vnc_lite.html /root/novnc/index.html
#RUN wget -O - https://github.com/novnc/websockify/archive/v0.9.0.tar.gz | tar -xzv -C /root/ && mv /root/websockify-0.9.0 /root/novnc/utils/websockify

RUN \
    winecfg && wineserver --wait && \
    #xvfb-run -s -noreset -a winetricks -q nocrashdialog vcrun2012 corefonts winxp && wineserver --wait && \
    # Download Install iqfeed client
    wget -nv http://www.iqfeed.net/$IQFEED_INSTALLER_BIN -O /root/$IQFEED_INSTALLER_BIN && \
    xvfb-run -s -noreset -a wine /root/$IQFEED_INSTALLER_BIN /S && wineserver --wait && \
    wine reg add HKEY_CURRENT_USER\\\Software\\\DTN\\\IQFeed\\\Startup /t REG_DWORD /v LogLevel /d $IQFEED_LOG_LEVEL /f && wineserver --wait && \
    # Add pyiqfeed 
    git clone https://github.com/jaikumarm/pyiqfeed.git && \
    cd pyiqfeed && \
    python3 setup.py install && \
    cd .. && rm -rf pyiqfeed && \
    # 'hack' to allow the client to listen on other interfaces
    bbe -e 's/127.0.0.1/000.0.0.0/g' "/root/prefix32/drive_c/Program Files/DTN/IQFeed/iqconnect.exe" > "/root/prefix32/drive_c/Program Files/DTN/IQFeed/iqconnect_patched.exe" &&\
    rm -rf /root/prefix32/.cache /var/lib/apt/lists/* $HOME/prefix32/drive_c/iqfeed_install.exe


ADD launch_iqfeed.py /root/launch_iqfeed.py
ADD pyiqfeed_admin_conn.py /root/pyiqfeed_admin_conn.py
ADD is_iqfeed_running.py /root/is_iqfeed_running.py
ADD iqfeed_startup.sh /root/iqfeed_startup.sh
RUN chmod +x /root/iqfeed_startup.sh && mkdir -p /root/DTN/IQFeed

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 5009 9100 9200 9300 9400 
EXPOSE 5900 8080

CMD ["/usr/bin/supervisord"]
