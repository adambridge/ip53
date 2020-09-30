#!/bin/bash

# Install dependencies
which aws >/dev/null || sudo apt-get install awscli
which jq >/dev/null || sudo apt-get install jq

# Create ~/.ip53 and local bin dirs if they don't exist
BIN=~/bin
[ -d $BIN ] || mkdir $BIN
[ -d ~/.ip53 ] || mkdir ~/.ip53
 
# Get directory that the install.sh and ip53.sh are in
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Copy ip53.sh to bin and create link ip53 
cp $SCRIPTDIR/ip53.sh $BIN/ip53.sh
ln -fs $BIN/ip53.sh $BIN/ip53

# Add bin to PATH if necessary
[ `basename $SHELL` = "bash" ] && PROFILE=~/.bash_profile || PROFILE=~/.profile
[ -e $PROFILE ] && . $PROFILE
which ip53 >/dev/null || echo "export PATH=\"\$PATH:$BIN\"     # IP53-AUTO-INSTALL" >> $PROFILE

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
crontab -l | grep -v "IP53-AUTO-INSTALL$" > $TMPFILE

cat <<EOF >> $TMPFILE
*/5 * * * * $BIN/ip53 | sed "s/^/\$(date): /" >> ~/.ip53/ip53.log 2>&1     # IP53-AUTO-INSTALL
EOF

crontab $TMPFILE
rm $TMPFILE
