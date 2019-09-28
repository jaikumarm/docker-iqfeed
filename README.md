Dockerized IQFeed client with X11VNC for remote viewing
=======================

[![CircleCI](https://circleci.com/gh/jaikumarm/docker-iqfeed.svg?style=svg)](https://circleci.com/gh/jaikumarm/docker-iqfeed)

See [CHANGELOG](./CHANGELOG.md) for a list of notable changes

Usage
-----

With `docker run`
```
docker run -e IQFEED_PRODUCT_ID=CHANGEME \
    -e IQFEED_LOGIN=CHANGEME \
    -e IQFEED_PASSWORD=CHANGEME \
    -p 5009:5010 -p 5901:5901 -p 9100:9101 -p 9300:9301 \
    -v /var/log/iqfeed:/home/wine/DTN/IQFeed \
    -d jaikumarm/iqfeed:v61020
```

With `docker-compose` edit the docker-compose.yml with your iqfeed credentials, then run
```
docker-compose -f docker-compose.yml up -d iqfeed
```


In docker logs of the container and you should see
```
...
2018-05-15 23:05:27,462 INFO success: fluxbox entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2018-05-15 23:05:27,462 INFO success: xvfb entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2018-05-15 23:05:27,463 INFO success: x11vnc entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2018-05-15 23:05:27,464 INFO success: pyiqfeed-admin-conn entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2018-05-15 23:05:27,464 INFO success: wine-iqfeed-startup entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2018-05-15 23:05:27,464 INFO success: iqfeed-proxy entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2018-05-15 23:05:27,858 INFO reaped unknown pid 32
2018-05-15 23:05:47,284 INFO pyiqfeed_admin_conn.<module>.140:  iqfeed service connected.
...
```

If you see `iqfeed service connected.` it means it all good. 

You can also see a very chatty version of whats going on with iqfeed client if you tail `/var/log/iqfeed/IQConnectLog.txt` or `/var/log/iqfeed/pyiqfeed-admin-conn.log`. 


SideNote:
As of right now for some reason not known to me the iqfeed client will crash every few days or hours :( I have worked around it by building the docker container health check script that monitors for wine crashes in the wine.log file and will mark the conatainer as `unhealthy`. Once this is done the container can be restarted by an external service, most popular ways are either docker stacks or docker-autoheal. I use autoheal becasue its simpler and good enough for my usecase. See `docker-compose.yml` file for details.

```
docker-compose -f docker-compose.yml up -d autoheal
```


This is fairly a opinionated configuration based on my own needs, if you dont like it fork it!

Also some of the code is borrowed and/or inspired from
https://github.com/bratchenko/docker-iqfeed and https://github.com/webanck/docker-wine-steam

