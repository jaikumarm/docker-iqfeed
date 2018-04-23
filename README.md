Dockerized IQFeed client with X11VNC for remote viewing
=======================

Update: APR 2018
    Remove novnc and instead use x11vnc for remote viewing and also full rewrite of the Docker file to cleanup and reduce container size.
    Also not need to connecto the container to initiate IQFeed Client installer, IQFeed Client launcher script will install client if it not able to fine the client binary.

Usage
-----

```
docker run -e LOGIN=<your iqfeed login> -e PASSWORD=<your iqfeed password> -p 5009:5010 -p 8081:8081 -p 9100:9101 jaikumarm/iqfeed:v5270
```

This is fairly a opinionated configuration based on my own setup, and most of the code is borrowed or inspired from
https://github.com/bratchenko/docker-iqfeed and https://github.com/solarkennedy/wine-x11-novnc-docker

