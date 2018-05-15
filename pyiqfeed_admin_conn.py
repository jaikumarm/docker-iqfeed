#! /usr/bin/env python3
# coding=utf-8

"""
This is an example that launches IQConnect.exe.

You need a file called localconfig.py (described in README.md that can be
imported here.

This code just launches IQConnect.exe and returns.

You probably want this to launch from cron and exit when you stop
trading, either at an end of day or at an end of week.

You probably also want to  open a socket to IQConnect.exe and maybe read
from the Admin Socket and log some data or put it on a dashboard.  You
can find out for example if your trading code is not reading ticks fast
enough or if the socket get closed.

Note that IQConnect.exe exits once the last connection to it is closed
so you want to keep at least one socket to it open unless you want
IQConnect.exe to exit.

Read the comments and code in service.py for more details.

This program launches an instance of IQFeed.exe if it isn't running, creates
an AdminConn and writes messages received by the AdminConn to stdout. It looks
for a file with the name passed as the option ctrl_file, defaults to
/tmp/stop_iqfeed.ctrl. When it sees that file it drops it's connection to
IQFeed.exe, deletes the control file and exits. If there are no other open
connections to IQFeed.exe, IQFeed.exe will by default exit 5 seconds later.

"""

import os
import sys
import time
import socket
import select
import subprocess
import logging
from typing import Sequence

import argparse
import pyiqfeed as iq

log_filename = "/var/log/distdnd/pyiqfeed-admin-conn.log"

logging.basicConfig(filename=log_filename,
                    level=logging.DEBUG,
                    format='%(asctime)s %(message)s')
# define a Handler which writes INFO messages or higher to the sys.stderr
console = logging.StreamHandler()
console.setLevel(logging.INFO)
# set a format which is simpler for console use
formatter = logging.Formatter(
    '%(asctime)s %(levelname)-4s %(module)s.%(funcName)s.%(lineno)d:  %(message)s')
# tell the handler to use this format
console.setFormatter(formatter)
# add the handler to the root logger
logging.getLogger('').addHandler(console)

logging.info('PyIQFeed admin conn started.')


class CustomVerboseIQFeedListener(iq.VerboseIQFeedListener):
    """
    Verbose version of SilentIQFeedListener.
    See documentation for SilentIQFeedListener member functions.
    """

    def __init__(self, name: str):
        self._name = name

    def feed_is_stale(self) -> None:
        logging.info("%s: Feed Disconnected" % self._name)

    def feed_is_fresh(self) -> None:
        logging.info("%s: Feed Connected" % self._name)

    def feed_has_error(self) -> None:
        logging.info("%s: Feed Reconnect Failed" % self._name)

    def process_conn_stats(self, stats: iq.FeedConn.ConnStatsMsg) -> None:
        logging.debug("%s: Connection Stats:" % self._name)
        logging.debug(stats)

    def process_timestamp(self, time_val: iq.FeedConn.TimeStampMsg):
        logging.info("%s: Timestamp:" % self._name)
        logging.info(time_val)

    def process_error(self, fields):
        logging.info("%s: Process Error:" % self._name)
        logging.info(fields)

class CustomVerboseIQFeedAdminListener(CustomVerboseIQFeedListener):
    def __init__(self, name: str):
        super().__init__(name)

    def process_register_client_app_completed(self) -> None:
        logging.info("%s: Register Client App Completed" % self._name)

    def process_remove_client_app_completed(self) -> None:
        logging.info("%s: Remove Client App Completed" % self._name)

    def process_current_login(self, login: str) -> None:
        logging.info("%s: Current Login: %s" % (self._name, login))

    def process_current_password(self, password: str) -> None:
        logging.info("%s: Current Password: %s" % (self._name, password))

    def process_login_info_saved(self) -> None:
        logging.info("%s: Login Info Saved" % self._name)

    def process_autoconnect_on(self) -> None:
        logging.info("%s: Autoconnect On" % self._name)

    def process_autoconnect_off(self) -> None:
        logging.info("%s: Autoconnect Off" % self._name)

    def process_client_stats(self,client_stats: iq.AdminConn.ClientStatsMsg) -> None:
        logging.debug("%s: Client Stats:" % self._name)
        logging.debug(client_stats)


if __name__ == "__main__":

    # Modify code below to connect to the socket etc as described above

    while True:
        if iq.service._is_iqfeed_running():            
            admin_conn = iq.AdminConn(name="Launcher")
            admin_listener = CustomVerboseIQFeedAdminListener("Launcher-Admin-listen")
            admin_conn.add_listener(admin_listener)
            with iq.ConnConnector([admin_conn]) as connected:
                if not iq.service._is_iqfeed_running():
                    logging.info("iqfeed service connection reset")
                    break
                #admin_conn.client_stats_off()
                #logging.info("iqfeed service connected.")
                time.sleep(30)
        else:
            logging.info("iqfeed service not connected.")
            time.sleep(15)
