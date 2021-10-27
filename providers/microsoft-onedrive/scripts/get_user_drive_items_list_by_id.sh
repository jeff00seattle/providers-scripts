#!/usr/bin/env bash

USAGE="\nUsage: $0\n
[-h|--help]\n
[-v|--verbose]\n
[--drive]\n
[--item]\n
"

usage() { echo -e ${USAGE} 1>&2; exit 1; }

# read the options
OPTS=`getopt -o hv --long help,verbose,drive:,item: -n 'get_user_drive_item_list_by_id.sh' -- "$@"`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; usage ; exit 1 ; fi

# echo "$OPTS"
eval set -- "$OPTS"

HELP=false
VERBOSE=false
RECURSIVE=false
DRIVE_ID=""
ITEM_ID=""

while true; do
  case "$1" in
    -h | --help )       usage ;;
    -v | --verbose )    VERBOSE=true; shift ;;
    --drive )           DRIVE_ID=$2 ; shift; shift ;;
    --item )            ITEM_ID=$2 ; shift; shift ;;
    -- )                shift; break ;;
    * )                 break ;;
  esac
done

if [ -z "$DRIVE_ID" ]
  then
    echo "Provide --drive" ; usage ; exit 1
fi

if [ -z "$ITEM_ID" ]
  then
    echo "Provide --item" ; usage ; exit 1
fi

source ../../../shared/credentials/credentials_token_parse.sh

echo "  DRIVE_ID: $DRIVE_ID"
echo "  ITEM_ID: $ITEM_ID"

PROTOCOL="https"
HOSTNAME="graph.microsoft.com"
API_VERSION="v1.0"
PATHNAME="${API_VERSION}/me/drives/$DRIVE_ID/items/$ITEM_ID/children"
CURL_REQUEST="GET"

source ../../../shared/curl/curl_get.sh
source ../../../shared/curl/curl_response.sh

echo "${HTTP_BODY}" |
    jq '.'

echo -e '\n-------------------------\n'
