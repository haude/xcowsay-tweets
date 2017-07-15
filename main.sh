#!/bin/bash

# set -xv # verbose them all
export CAPTURE_TMP_FILE_NAME=$(mktemp -u)
export DATE_SIGNATURE=$(date +%Y%m%d-%H:%M:%S)
export CAPTURED_FILE=${CAPTURE_TMP_FILE_NAME}-${DATE_SIGNATURE}.png

capture(){
    import ${CAPTURED_FILE}
}

compose(){
    DEFAULT_MSG="#frotuneoftheday"
    [ -z "$TWEET_MSG" ] && TWEET_MSG=$DEFAULT_MSG
    export TWEET_MSG
}

tweet(){
    # mixing little bit of ruby world, can't find better yet
    # install: gem install twurl
    # configure it as in wiki: twurl authorize --consumer-key key --consumer-secret secret
    source /usr/share/chruby/chruby.sh && chruby 2.4.1 #this is my way of doing it
    
    media_id=$(twurl -H upload.twitter.com \
                     -X POST "/1.1/media/upload.json" \
                     --file ${CAPTURED_FILE} \
                     --file-field "media" \
                   | jq '.media_id_string' \
                   | sed 's/"//g')
    
    msg="status=${TWEET_MSG}&media_ids=${media_id}"
    echo "twurl -d \"${msg}\" /1.1/statuses/update.json"
    twurl -d "${msg}" /1.1/statuses/update.json
}

view(){
    # feh ${CAPTURED_FILE}
    xcowsay --cow-size=small -d "${CAPTURED_FILE}"
}

capture && compose && view && tweet 

