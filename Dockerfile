FROM ubuntu:eoan

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
ENV WINEDEBUG -all

RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get -y full-upgrade && \
    #apt-get -y install xvfb x11vnc xdotool wget tar supervisor net-tools fluxbox gnupg2 && \
    apt-get -y install xvfb xdotool wget tar supervisor net-tools gnupg2 && \
    wget -O - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
    echo 'deb https://dl.winehq.org/wine-builds/ubuntu/ eoan main' |tee /etc/apt/sources.list.d/winehq.list && \
    apt-get update && apt-get -y install winehq-stable && \
    mkdir /opt/wine-stable/share/wine/mono && \
    wget -O - https://dl.winehq.org/wine/wine-mono/4.9.4/wine-mono-bin-4.9.4.tar.gz |tar -xzv -C /opt/wine-stable/share/wine/mono && \
    mkdir /opt/wine-stable/share/wine/gecko && \
    wget -O /opt/wine-stable/share/wine/gecko/wine-gecko-2.47.1-x86.msi https://dl.winehq.org/wine/wine-gecko/2.47.1/wine-gecko-2.47.1-x86.msi && \
    wget -O /opt/wine-stable/share/wine/gecko/wine-gecko-2.47.1-x86_64.msi https://dl.winehq.org/wine/wine-gecko/2.47.1/wine-gecko-2.47.1-x86_64.msi && \
    # Install python for pyiqfeed
    apt-get update && \
    apt-get install -y --no-install-recommends git nodejs && \
    apt-get install -y --no-install-recommends python3 python3-setuptools python3-numpy && \
    apt-get install -y --no-install-recommends python3-pip python3-tz python3-psycopg2 python3-dateutil python3-sqlalchemy python3-pandas &&\
    # Cleaning up.
    apt-get autoremove -y --purge && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#RUN wget -O - https://github.com/novnc/noVNC/archive/v1.1.0.tar.gz | tar -xzv -C /root/ && mv /root/noVNC-1.1.0 /root/novnc && ln -s /root/novnc/vnc_lite.html /root/novnc/index.html
#RUN wget -O - https://github.com/novnc/websockify/archive/v0.9.0.tar.gz | tar -xzv -C /root/ && mv /root/websockify-0.9.0 /root/novnc/utils/websockify

RUN \
    # Download Install iqfeed client
    wget -nv http://www.iqfeed.net/$IQFEED_INSTALLER_BIN -O /root/$IQFEED_INSTALLER_BIN && \
    xvfb-run -s -noreset -a /opt/wine-stable/bin/wine /root/$IQFEED_INSTALLER_BIN /S && wineserver --wait && \
    # Add pyiqfeed 
    git clone https://github.com/jaikumarm/pyiqfeed.git && \
    cd pyiqfeed && \
    python3 setup.py install && \
    cd .. && rm -rf pyiqfeed

ADD launch_iqfeed.py /root/launch_iqfeed.py
ADD pyiqfeed_admin_conn.py /root/pyiqfeed_admin_conn.py
ADD is_iqfeed_running.py /root/is_iqfeed_running.py
ADD iqfeed_startup.sh /root/iqfeed_startup.sh
ADD app /root/app
RUN chmod +x /root/iqfeed_startup.sh && mkdir -p /root/DTN/IQFeed

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 9101
EXPOSE 9201
EXPOSE 9301
EXPOSE 9401
EXPOSE 5010
EXPOSE 5901
EXPOSE 8080

CMD ["/usr/bin/supervisord"]