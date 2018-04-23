#!/bin/bash
iqconnect_exe="/home/wine/.wine/drive_c/Program Files/DTN/IQFeed/iqconnect.exe"
if [ -f "$iqconnect_exe" ]
then
	echo "$iqconnect_exe found. launching iqfeed client"
  /usr/bin/wine /home/wine/.wine/drive_c/Program\ Files/DTN/IQFeed/iqconnect.exe -autoconnect
	sleep 30
else
  echo "$iqconnect_exe not found. launcing iqfeed client installer"
	cd /home/wine/
  wine /home/wine/.wine/drive_c/$IQFEED_INSTALLER_BIN /S
  sleep 30
	cd
	if [ -f "$iqconnect_exe" ]
	then
    echo "$iqconnect_exe found. installer succeeded, launcing iqfeed client.."
		/usr/bin/wine /home/wine/.wine/drive_c/Program\ Files/DTN/IQFeed/iqconnect.exe -autoconnect
  else
    echo "$iqconnect_exe not found. installer failed, exiting.."
	fi
fi
