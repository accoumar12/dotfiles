#!/bin/bash

SHARE="//192.168.0.51/datasets"
USER="maccou"
PASSWORD="Nautilus12@"

if [ -z "$1" ]; then
  echo "Usage: $0 <filename>"
  exit 1
fi

FILE_TO_DOWNLOAD=$1

smbclient $SHARE -U $USER%$PASSWORD <<EOF
cd 3D/stp/Airbus
prompt
mget "$FILE_TO_DOWNLOAD"
quit
EOF
