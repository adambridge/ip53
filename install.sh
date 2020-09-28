#!/bin/bash

# Install dependencies
sudo apt-get install dnsutils awscli jq

# Create ~/bin and ~/.ip53 if they don't exist
file -d ~/bin || mkdir ~/bin
file -d ~/.ip53 || mkdir ~/.ip53
 
# Get directory that the install.sh and ip53.sh are in
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Create link in ~/bin pointing to ip53.sh 
LNK=$(echo ~/bin/ip53)
file -d $LNK || ln -s $SCRIPTDIR/ip53.sh $LNK

echo Enter Route 53 hosted zone ID:
read ZONEID
echo Enter Route 53 record name:
read RECORD

# Install crontab
TMPFILE=$(mktemp /tmp/temporary-file.XXXXXXXX)
crontab -l | grep -v "#IP53-AUTO-INSTALL$" > $TMPFILE

cat <<EOF >> $TMPFILE
*/1 * * * * bash -x $LNK --record=$RECORD --zone=$ZONE > ~/.ip53/ip53.log 2>&1 #IP53-AUTO-INSTALL
EOF

crontab $TMPFILE
cat $TMPFILE
rm $TMPFILE
