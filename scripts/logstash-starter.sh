#!/bin/sh

name=logstash

LS_USER=logstash
LS_GROUP=root
LS_HOME=
LS_HEAP_SIZE="500m"
LS_JAVA_OPTS="-Djava.io.tmpdir=${LS_HOME}"
LS_LOG_DIR=/var/log/logstash
LS_LOG_FILE="${LS_LOG_DIR}/${name}-plain.log"
LS_CONF_DIR=/etc/logstash/conf.d
LS_OPEN_FILES=16384
LS_NICE=19
LS_OPTS=

program=${LS_HOME}/bin/logstash
args="--path.config ${LS_CONF_DIR} --path.logs ${LS_LOG_DIR} ${LS_OPTS}"

export LS_HEAP_SIZE LS_JAVA_OPTS LS_USE_GC_LOGGING

touch ${LS_LOG_FILE}
chmod 775 ${LS_LOG_FILE}
echo starting logstash
# Run the program 
exec $program $args
