#!/bin/bash

. ~/.ip53/ip53.config || { echo Run ./install.sh first && exit 1; }
COMMENT="Auto updating @ `date`"

function update() {
    TMPFILE=$(mktemp /tmp/temporary-file.XXXXXXXX)
    TEMPLATE="$(cat ~/.ip53/json.tmpl)"
    eval "echo \"$TEMPLATE\"" > $TMPFILE

    aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch file://"$TMPFILE" \
        --query '[ChangeInfo.Comment, ChangeInfo.Id, ChangeInfo.Status, ChangeInfo.SubmittedAt]' --output text
    rm $TMPFILE
}

IP=`curl -4sS http://checkip.amazonaws.com` || { echo checkip.amazonaws.com failed && exit 2; }

AWSOUT="$(aws route53 list-resource-record-sets --hosted-zone $ZONE_ID --start-record-name $RECORD_NAME --max-items 1 --output json)"

[ $? -eq 0 ] || { printf "$AWSOUT" && exit 3; }

AWSIP="$(jq -r '.ResourceRecordSets[].ResourceRecords[].Value' <<< $AWSOUT)"

[ "$IP" ==  "$AWSIP" ] || { echo "IP has changed to $IP" && update; }
