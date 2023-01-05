# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## 2023-01-05
### Changed
- updating ubuntu to 22.04 from 20.04 and wine6 from stable to devel
- no change in IQFeed Client version still 6.2.0.25 (dockerhub image: jaikumarm/iqfeed:v62025-w6d)

## 2021-11-12
### Changed
- updating IQFeed Client version to 6.2.0.25 (dockerhub image: jaikumarm/iqfeed:v62025-w6)

## 2021-10-28
### Changed
- updating IQFeed Client version to 6.2.0.23 (dockerhub image: jaikumarm/iqfeed:v62023-w6)
- IQFeed Client 6.2.x is now a 64bit binary so updating wine to 64bit

## 2021-04-12
### Changed
- updating wine to 6.0 and ubuntu 20.04 (focal) as 19.10 (eoan) is out of support
- updating dockerhub image: jaikumarm/iqfeed:v61020-w6

## 2020-03-02
### Changed
- updating wine to 5.0 hoping to resolve the frequent crashes seen on earlier versions
- updating base ubuntu image to eoan (19.10) as wine 5.0 depends on libfaudio0 which is not available on 18.04
- updating dockerhub image: jaikumarm/iqfeed:v61020-w5

## 2019-09-27
### Changed
- updating IQFeed Client version to 6.1.0.20 (dockerhub image: jaikumarm/iqfeed:v61020)

## 2019-06-13
### Changed
- updating IQFeed Client version to 6.0.1.1 (dockerhub image: jaikumarm/iqfeed:v6011)

## 2018-08-20
### Changed
- updating base container image from ubuntu 16.04 to 18.04 (dockerhub image: jaikumarm/iqfeed:v6005)

## 2018-08-05
### Changed
- updating IQFeed Client version to 6.0.0.5 (dockerhub image: jaikumarm/iqfeed:v6005)

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
