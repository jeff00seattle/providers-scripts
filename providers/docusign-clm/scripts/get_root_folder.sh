#!/usr/bin/env bash

USAGE="\nUsage: $0\n
[-h|--help]\n
[-v|--verbose]\n
[-p|--parse]\n
"

usage() { echo -e ${USAGE} 1>&2; exit 1; }

# read the options
OPTS=`getopt -o hvp --long help,verbose,parse -n 'get_root_folder.sh' -- "$@"`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; usage ; exit 1 ; fi

eval set -- "$OPTS"

HELP=false
VERBOSE=false
PARSE=false

# extract options and their arguments into variables.
while true; do
  case "$1" in
    -h | --help )       usage ;;
    -v | --verbose )    VERBOSE=true ; shift ;;
    -p | --parse )      PARSE=true ; shift ;;
    -- )                shift; break ;;
    * )                 break ;;
  esac
done

CURL_REQUEST="GET"

source ../credentials/credentials_springcm_parse.sh
source ../credentials/credentials_docusign_account_parse.sh
source ../credentials/credentials_springcm_account_parse.sh
source ../credentials/credentials_docusign_token_parse.sh

source ./curl/curl_get_root_folder.sh

source ../../../shared/curl/curl_response.sh
source ../../../shared/helpers/url_parse.sh

if [ ${PARSE} = true ]
  then
    #parseURL $(echo ${HTTP_BODY} | jq '.ParentFolder.Href')
    #PARENT_ID=$(echo ${URL_COMPONENTS} | jq '. | .path' | cut -d/ -f3 | tr -d '"')

    parseURL $(echo ${HTTP_BODY} | jq '.Documents.Href')
    DOCUMENTS_ID=$(echo ${URL_COMPONENTS} | jq '. | .path' | cut -d/ -f3 | tr -d '"')

    parseURL $(echo ${HTTP_BODY} | jq '.Folders.Href')
    FOLDERS_ID=$(echo ${URL_COMPONENTS} | jq '. | .path' | cut -d/ -f3 | tr -d '"')

    parseURL $(echo ${HTTP_BODY} | jq '.Href')
    FOLDER_ID=$(echo ${URL_COMPONENTS} | jq '. | .path' | cut -d/ -f3 | tr -d '"')

    ROOT_FOLDER=$(echo ${HTTP_BODY} |
        jq
    #    --arg parent_id "${PARENT_ID}"
        --arg documents_id "${DOCUMENTS_ID}"
        --arg folders_id "${FOLDERS_ID}"
        --arg folder_id "${FOLDER_ID}" '.
            | {Name,
    #        ParentFolder: .ParentFolder | {href: .Href, id: $parent_id},
            Documents: .Documents | {href: .Href, id: $documents_id},
            Folders: .Folders | {href: .Href, id: $folders_id},
            CreateDocument: {href: .CreateDocumentHref},
            href: .Href,
            id: $folder_id}')

     echo "${ROOT_FOLDER}" |
        jq '.'
else
     echo "${HTTP_BODY}" |
        jq '.'
fi
