#!/bin/bash
export WINEDEBUG=+tid,+seh,+loaddll

iqconnect_exe="/root/.wine/drive_c/Program Files/DTN/IQFeed/iqconnect.exe"
if [ -f "$iqconnect_exe" ]
then
	echo "$iqconnect_exe found. launching iqfeed client"
	python3 /root/launch_iqfeed.py --headless &> /root/DTN/IQFeed/iqfeed_client.log
else
	echo "$iqconnect_exe not found. installer failed, exiting.."
fi
echo "iqfeed statup script completed, exiting.."
