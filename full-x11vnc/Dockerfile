FROM jaikumarm/iqfeed:minimal-iqfeed

# Updating and upgrading a bit.
	# Install vnc, window manager and basic tools
RUN apt-get update && \
  apt-get install -y x11vnc xdotool fluxbox &&\
# Cleaning up.
  apt-get autoremove -y --purge && \
  apt-get clean -y && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add supervisor conf
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]

# Expose Ports
EXPOSE 5901
