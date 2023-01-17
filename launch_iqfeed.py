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

dtn_product_id = os.environ["IQFEED_PRODUCT_ID"]
dtn_login = os.environ["IQFEED_LOGIN"]
dtn_password = os.environ["IQFEED_PASSWORD"]

class CustomFeedService(iq.FeedService):
    def launch(self,
               timeout: int=20,
               check_conn: bool=True,
               headless: bool=False,
               nohup: bool=True) -> None:
        """
        Launch IQConnect.exe if necessary
        :param timeout: Throw if IQConnect is not listening in timeout secs.
        :param check_conn: Try opening connections to IQFeed before returning.
        :param headless: Set to true if running in headless mode on X windows.
        :param nohup: Set to true if you want IQFeed launched with nohup
        :return: True if IQConnect is now listening for connections.
        """
        # noinspection PyPep8
        iqfeed_args = ("-product %s -version %s -login %s -password %s -autoconnect -savelogininfo" %
                       (self.product, self.version, self.login, self.password))

        
        if not iq.service._is_iqfeed_running():
            if sys.platform == 'win32':
                # noinspection PyPep8Naming
                ShellExecute = __import__('win32api').ShellExecute
                # noinspection PyPep8Naming
                SW_SHOWNORMAL = __import__('win32con').SW_SHOWNORMAL
                ShellExecute(0, "open", "IQConnect.exe", iqfeed_args, "",
                             SW_SHOWNORMAL)
            elif sys.platform == 'darwin' or sys.platform == 'linux':
                base_iqfeed_call = "wine64 iqconnect.exe %s 2>&1 > /root/DTN/IQFeed/wine.log " % iqfeed_args
                prefix_str = ""
                if nohup:
                    prefix_str += "nohup "
                if headless:
                    prefix_str += "xvfb-run -s -noreset -a "
                iqfeed_call = prefix_str + base_iqfeed_call

                logging.info("Running %s" % iqfeed_call)
                subprocess.Popen(iqfeed_call,
                                 shell=True,
                                 stdin=subprocess.DEVNULL,
                                 stdout=subprocess.DEVNULL,
                                 stderr=subprocess.DEVNULL,
                                 preexec_fn=os.setpgrp)
            if check_conn:
                start_time = time.time()
                while not iq.service._is_iqfeed_running(iqfeed_host=self.iqfeed_host,
                                             iqfeed_ports=self.iqfeed_ports):
                    time.sleep(1)
                    if time.time() - start_time > timeout:
                        raise RuntimeError("Launching IQFeed timed out.")
        else:
            logging.warning(
                "Not launching IQFeed.exe because it is already running.")


class CustomVerboseIQFeedListener(iq.VerboseIQFeedListener):
    def process_conn_stats(self, stats: iq.FeedConn.ConnStatsMsg) -> None:
        pass



if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Launch IQFeed.")
    parser.add_argument('--nohup', action='store_true',
                        dest='nohup', default=False,
                        help="Don't kill IQFeed.exe when this script exists.")
    parser.add_argument('--headless', action="store_true",
                        dest='headless', default=False,
                        help="Launch IQFeed in a headless XServer.")
    parser.add_argument('--control_file', action='store',
                        dest='ctrl_file', default="/tmp/stop_iqfeed.ctrl",
                        help='Stop running if this file exists.')
    arguments = parser.parse_args()

    IQ_FEED = CustomFeedService(product=dtn_product_id,
                             version="IQFEED_LAUNCHER",
                             login=dtn_login,
                             password=dtn_password)

    nohup = arguments.nohup
    headless = arguments.headless
    ctrl_file = arguments.ctrl_file
    IQ_FEED.launch(timeout=60,
                   check_conn=True,
                   headless=headless,
                   nohup=nohup)

    # Modify code below to connect to the socket etc as described above
    admin_conn = iq.AdminConn(name="Launcher")
    admin_listener = CustomVerboseIQFeedListener("Launcher-listen")
    admin_conn.add_listener(admin_listener)
    with iq.ConnConnector([admin_conn]) as connected:
        admin_conn.client_stats_off()
        while not os.path.isfile(ctrl_file):
            admin_conn.client_stats_off()
            time.sleep(30)

    os.remove(ctrl_file)
