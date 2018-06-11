# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## 2018-06-11
### Changed
- using IQFeed Client version 6.0.0.4 (dockerhub image: jaikumarm/iqfeed:v6004)

## 2018-05-29
### Changed
- using IQFeed Client version 6.0.0.3 (beta) (dockerhub image: jaikumarm/iqfeed:v6003)

## 2018-05
### Changed
- removed installer from iqfeed launcher script and moved it to Docker build process via Dockerfile
- using IQFeed Client version 6.0.0.2 (beta) (dockerhub image: jaikumarm/iqfeed:v6002)

### Added
- Added client login via pyiqfeed admin connection and logging to file
- Added healthcheck to monitor if wine iqfeed process is running or crashed (PS: use docker-autoheal to restart unhealthy containers)

## 2018-04
### Added
- No need to connect to the container to initiate IQFeed Client installer, IQFeed Client launcher script will install client if it is not able to find the client binary.

### Changed
- Removed novnc and instead use x11vnc for remote viewing and also full rewrite of the Dockerfile to cleanup and reduce container size (1.8G to 1.3G).
- using IQFeed Client version 5.2.7.0 (dockerhub image: jaikumarm/iqfeed:v5270)
