#!/bin/bash
#/usr/bin/Xvfb :1 -screen 0 1024x768x24 &
#nodejs /home/wine/app/proxy.js &
export WINEDEBUG=+tid,+seh,+loaddll

iqconnect_exe="/home/wine/.wine/drive_c/Program Files/DTN/IQFeed/iqconnect.exe"
if [ -f "$iqconnect_exe" ]
then
	echo "$iqconnect_exe found. launching iqfeed client"
	python3 /home/wine/launch_iqfeed.py --headless &> /home/wine/iqfeed_client.log
  #/usr/bin/wine /home/wine/.wine/drive_c/Program\ Files/DTN/IQFeed/iqconnect.exe -autoconnect
else
#  echo "$iqconnect_exe not found. launcing iqfeed client installer"
#	cd /home/wine/
#  /usr/bin/wine /home/wine/.wine/drive_c/$IQFEED_INSTALLER_BIN /S &> /home/wine/iqfeed_client_installer.log
#  sleep 10
#	cd
#	if [ -f "$iqconnect_exe" ]
#	then
#    echo "$iqconnect_exe found. installer succeeded, launcing iqfeed client.."
#		python3 /home/wine/launch_iqfeed.py --headless &> /home/wine/iqfeed_client.log
#		#/usr/bin/wine /home/wine/.wine/drive_c/Program\ Files/DTN/IQFeed/iqconnect.exe -autoconnect
#  else
#		echo "$iqconnect_exe not found. installer failed, exiting.."
#	fi
	echo "$iqconnect_exe not found. installer failed, exiting.."
fi
echo "iqfeed statup script completed, exiting.."
