#!/bin/bash

set -e

read -p 'Server:' host
host="${host:=localhost:4064}"

read -p 'Username: ' username
username="${username:=demo}"

read -sp 'Password: ' password

echo "Logged in $username@$host"

set -x

OMERO_DIST='/home/omero/OMERO.server'
IDR_METADATA='/tmp/idr-metadata'


populate_ann () {
    local object=${1:-};
    local path=${2:-};
    local ns=${3:-};
    local log_file="log_populate_ann_$object"

    if [ -n "$object" ] && [ -n "$path" ] && [ -n "$ns" ]; then
        # populate new annotations
        echo "populate new $ns annotations $object $path"
        echo "#########  BEGINING populate new $ns annotations $object $path  ################" >> $log_file
        $OMERO_DIST/bin/omero metadata populate --context bulkmap --cfg $path-bulkmap-config.yml $object --localcfg "{\"ns\":\"$ns\"}" --report >> $log_file 2>&1
        echo "#########  END populate new $ns annotations $object $path  ################" >> $log_file
    fi

}


while read -r obj path ns; do

    # IMPORTANT EOL
    echo "$obj $path $ns #######################"

    # populate new annotations
    set +x
    $OMERO_DIST/bin/omero login -u $username -w "$password" -s $host
    set -x
    populate_ann $obj "$IDR_METADATA/$path" $ns
    $OMERO_DIST/bin/omero logout

    echo "$obj DONE ##################################"

done < demo33_input.txt
