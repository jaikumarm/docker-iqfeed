Dockerized IQFeed client with X11VNC for remote viewing
=======================

Update: APR 2018
-----

* Remove novnc and instead use x11vnc for remote viewing and also full rewrite of the Dockerfile to cleanup and reduce container size.
* Also no need to connect to the container to initiate IQFeed Client installer, IQFeed Client launcher script will install client if it is not able to find the client binary.

Usage
-----

```
docker run -e LOGIN=<your iqfeed login> -e PASSWORD=<your iqfeed password> -p 5009:5010 -p 8081:8081 -p 9100:9101 jaikumarm/iqfeed:v5270
```

In docker logs of the container and you should see
```
...
2018-04-22 03:42:02,004 INFO spawned: 'fluxbox' with pid 11
/home/wine/.wine/drive_c/Program Files/DTN/IQFeed/iqconnect.exe not found. launcing iqfeed client installer
22/04/2018 03:42:02 passing arg to libvncserver: -rfbport
22/04/2018 03:42:02 passing arg to libvncserver: 5901
...
Disconnected. Reconnecting in 1 second.
/home/wine/.wine/drive_c/Program Files/DTN/IQFeed/iqconnect.exe found. installer succeeded, launcing iqfeed client..
Connecting to port  9300
Disconnected. Reconnecting in 1 second.
2018-04-22 03:42:52,506 INFO reaped unknown pid 128
Connecting to port  9300
Disconnected. Reconnecting in 1 second.
Connecting to port  9300
Connected.
```

If you see `Connected.` it means it all good. You can also uncomment line 83 in app/proxy.js which will print every string recevied on the socket data port, very very chatty. 


This is fairly a opinionated configuration based on my own needs, if you dont like it fork it!

And some of the code is borrowed and/or inspired from
https://github.com/bratchenko/docker-iqfeed and https://github.com/webanck/docker-wine-steam

