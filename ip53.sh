#!/bin/bash

. ~/.ip53/ip53.config
COMMENT="Auto updating @ `date`"

function update_route53() {
    TMPFILE=$(mktemp /tmp/temporary-file.XXXXXXXX)
    TEMPLATE="$(cat ~/.ip53/json.tmpl)"
    eval "echo \"$TEMPLATE\"" > $TMPFILE

    aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch file://"$TMPFILE" \
        --query '[ChangeInfo.Comment, ChangeInfo.Id, ChangeInfo.Status, ChangeInfo.SubmittedAt]' --output text
    rm $TMPFILE
}

IP=`curl -4sS http://checkip.amazonaws.com` || { echo checkip.amazonaws.com failed && exit 1; }

AWSIP="$(aws route53 list-resource-record-sets --hosted-zone $ZONE_ID --start-record-name $RECORD_NAME \
        --max-items 1 --output json | jq -r \ '.ResourceRecordSets[].ResourceRecords[].Value')"

[ ! "$IP" ==  "$AWSIP" ] || { echo "IP has changed to $IP" && update_route53; }
