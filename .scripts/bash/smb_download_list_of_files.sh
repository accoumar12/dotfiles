#!/bin/bash

SHARE="//192.168.0.51/datasets"
USER="maccou"
PASSWORD="password"

# Start smbclient session and interactively download files
smbclient $SHARE -U $USER%$PASSWORD <<EOF
cd 3D/stp/Airbus
prompt
$(while read -r file; do echo "mget $file"; done < ./files_to_download.txt)
quit
EOF
