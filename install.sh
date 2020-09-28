#!/bin/bash

# Install dependencies
sudo apt-get install dnsutils awscli jq

# Create ~/bin and ~/.ip53 if they don't exist
[ -d ~/bin ] || mkdir ~/bin
[ -d ~/.ip53 ] || mkdir ~/.ip53
 
# Get directory that the install.sh and ip53.sh are in
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Create link in ~/bin pointing to ip53.sh 
LNK=$(echo ~/bin/ip53)
[ -e $LNK ] || rm $LNK
ln -s $SCRIPTDIR/ip53.sh $LNK

# Copy template.json to ~/.ip53
cp $SCRIPTDIR/json.tmpl ~/.ip53/json.tmpl

echo Enter Route 53 hosted zone ID \(e.g. H6DWNY8UJ3Q1\):
read ZONE_ID
echo Enter Route 53 record name \(e.g. my.domain.com\):
read RECORD_NAME

cat << EOF > ~/.ip53/ip53.config
ZONE_ID=$ZONE_ID
RECORD_NAME=$RECORD_NAME
EOF

# Install crontab
TMPFILE=$(mktemp /tmp/temporary-file.XXXXXXXX)
crontab -l | grep -v "#IP53-AUTO-INSTALL$" > $TMPFILE

cat <<EOF >> $TMPFILE
*/5 * * * * bash $LNK | sed "s/^/\$(date): /" >> ~/.ip53/ip53.log 2>&1 #IP53-AUTO-INSTALL
EOF

crontab $TMPFILE
rm $TMPFILE
