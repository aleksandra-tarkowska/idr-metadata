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


delete_ann () {
    local object=${1:-};
    local ns=${2:-};
    local log_file="log_delete_ann_$object"

    if [ -n "$object" ] && [ -n "$ns" ]; then
        # delete annotations
        echo "delete $ns annotations $object"
        echo "#########  BEGINING delete $ns annotations $object  ################" >> $log_file
        $OMERO_DIST/bin/omero metadata populate --batch 10 --wait 600 --context deletemap --localcfg "{\"ns\":\"$ns\"}" $object --report >> $log_file 2>&1
        echo "#########  END delete $ns annotations $object  ################" >> $log_file
    fi

}


while read -r obj path ns; do

    # IMPORTANT EOL
    echo "##  $obj $path $ns  ##"

    # delete annotations
    set +x
    $OMERO_DIST/bin/omero login -u $username -w "$password" -s $host
    set -x
    delete_ann $obj $ns
    $OMERO_DIST/bin/omero logout

    echo "##  $obj DONE  ##"

done < demo33_input_delete.txt
