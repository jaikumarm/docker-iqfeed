#! /usr/bin/env python3
# coding=utf-8
#import pyiqfeed

import re
import sys
import time

wine_log_filename = '/home/wine/DTN/IQFeed/wine.log'
pattern1 = re.compile(r'wine: Unhandled')
pattern2 = re.compile(r'error 5')

def main():
  for line in open(wine_log_filename):
    if pattern1.search(line) or pattern2.search(line):
      #wine iqfeed crashed 
      print ("wine iqfeed crashed :(")
      sys.exit(1)

if __name__ == "__main__":
  main()
