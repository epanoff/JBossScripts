#!/bin/bash

if [ "$#" -ne 5 ]
then
  echo "Usage: $0 MANAGEMENT_SERVER PROFILE USER PASSWORD FILEPATH_TO_JNDI_LIST"
  exit 1
fi

MANAGEMENT_SERVER=$1
PROFILE=$2
USER=$3
PASSWORD=$4
FILEPATH_TO_JNDI_LIST=$5


grep JNDI $FILEPATH_TO_JNDI_LIST | while read JNDI_STRING
do
    BEFORE_EQUAL=$((`expr index "$JNDI_STRING" "="` - 1 ))
    AFTER_EQUAL=$((`expr index "$JNDI_STRING" "="` + 1 ))
    
    curl --digest -u $USER:$PASSWORD 'http://$MANAGEMENT_SERVER:9990/management' --header "Content-Type: application/json" -d "{\"operation\":add\",\"binding-type\":\"simple\",\"type\":\"java.lang.String\",\"value\":\"${JNDI_STRING:AFTER_EQUAL}\", \"address\":[\"subsystem\",\"naming\",\"binding\",\"${JNDI_STRING:0:BEFORE_EQUAL}\"], \"json.pretty\":1}"

done


