FROM jaikumarm/iqfeed:base-wine

# Set correct environment variables
ENV IQFEED_INSTALLER_BIN="iqfeed_client_5_2_7_0.exe"

# Updating and upgrading a bit.
	# Install vnc, window manager and basic tools
RUN apt-get update && \
  apt-get install -y curl supervisor nodejs &&\
# Cleaning up.
  apt-get autoremove -y --purge && \
  apt-get clean -y && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /home/wine

RUN curl -SL http://www.iqfeed.net/$IQFEED_INSTALLER_BIN -o /home/wine/.wine/drive_c/$IQFEED_INSTALLER_BIN

# Add supervisor conf
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD iqfeed_startup.sh /home/wine/iqfeed_startup.sh

# Add iqfeed proxy app
ADD app /home/wine/app

RUN chmod +x /home/wine/iqfeed_startup.sh

CMD ["/usr/bin/supervisord"]
# Expose Ports
EXPOSE 9101
EXPOSE 5010
