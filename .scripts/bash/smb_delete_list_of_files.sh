#!/bin/bash
# Add an empty line at the end. because when reads processes af file it expects each line to end with a new line character.

SHARE="//192.168.0.51/datasets"
USER="maccou"
PASSWORD="Nautilus12@"

# Start smbclient session and interactively delete files
smbclient $SHARE -U $USER%$PASSWORD <<EOF
cd 3D/stp/Renault
prompt
$(while read -r file; do echo "del $file"; done < ./files_to_delete.txt)
quit
EOF
