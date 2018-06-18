#! /usr/bin/env python3
# coding=utf-8
#import pyiqfeed

import re
import sys
import time

wine_log_filename = '/home/wine/DTN/IQFeed/wine.log'
pattern1 = re.compile(r'wine: Unhandled')
pattern2 = re.compile(r'error 5')

pyiqfeed_admin_conn_log_filename = "/home/wine/DTN/IQFeed/pyiqfeed-admin-conn.log"
pattern3 = re.compile(r'iqfeed service not running.')

def main():
  for line in open(wine_log_filename):
    if pattern1.search(line) or pattern2.search(line):
      #wine iqfeed crashed 
      print ("wine iqfeed crashed :(")
      sys.exit(1)

  with open(pyiqfeed_admin_conn_log_filename) as f:
    for line in f: pass

  if pattern3.search(line):
    #checking only yhe last line for string\
    print("iqfeed service not running :(")
    sys.exit(1)

if __name__ == "__main__":
  main()
