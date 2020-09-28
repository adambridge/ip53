#!/bin/bash

# Install dependencies
sudo apt-get install awscli jq

# Create ~/bin and ~/.ip53 if they don't exist
[ -d ~/bin ] || mkdir ~/bin
[ -d ~/.ip53 ] || mkdir ~/.ip53
 
# Get directory that the install.sh and ip53.sh are in
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Copy to ~/bin/ip53.sh and create link ~/bin/ip53 
cp $SCRIPTDIR/ip53.sh ~/bin/ip53.sh
ln -fs ~/bin/ip53.sh ~/bin/ip53

# Copy template.json to ~/.ip53
cp $SCRIPTDIR/json.tmpl ~/.ip53/json.tmpl

# Get Route 53 zone ID and record name
if [ ! -e ~/.ip53/ip53.config ]; then
    echo Enter Route 53 hosted zone ID \(e.g. H6DWNY8UJ3Q1\): && read ZONE_ID
    echo Enter Route 53 record name \(e.g. my.domain.com\): && read RECORD_NAME
    echo ZONE_ID=$ZONE_ID > ~/.ip53/ip53.config
    echo RECORD_NAME=$RECORD_NAME >> ~/.ip53/ip53.config
fi

# Install crontab
TMPFILE=$(mktemp /tmp/temporary-file.XXXXXXXX)
crontab -l | grep -v "#IP53-AUTO-INSTALL$" > $TMPFILE

cat <<EOF >> $TMPFILE
*/5 * * * * ~/bin/ip53 | sed "s/^/\$(date): /" >> ~/.ip53/ip53.log 2>&1 #IP53-AUTO-INSTALL
EOF

crontab $TMPFILE
rm $TMPFILE
