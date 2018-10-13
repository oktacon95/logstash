#!/bin/bash

if [ -z "$LOGSTASH_START" ]; then
  LOGSTASH_START=1
fi
if [ "$LOGSTASH_START" -ne "1" ]; then
  echo "LOGSTASH_START is set to something different from 1, not starting..."
else
  # override LS_HEAP_SIZE variable if set
  if [ ! -z "$LS_HEAP_SIZE" ]; then
    awk -v LINE="-Xmx$LS_HEAP_SIZE" '{ sub(/^.Xmx.*/, LINE); print; }' ${LOGSTASH_PATH_SETTINGS}/jvm.options \
        > ${LOGSTASH_PATH_SETTINGS}/jvm.options.new && mv ${LOGSTASH_PATH_SETTINGS}/jvm.options.new ${LOGSTASH_PATH_SETTINGS}/jvm.options
    awk -v LINE="-Xms$LS_HEAP_SIZE" '{ sub(/^.Xms.*/, LINE); print; }' ${LOGSTASH_PATH_SETTINGS}/jvm.options \
        > ${LOGSTASH_PATH_SETTINGS}/jvm.options.new && mv ${LOGSTASH_PATH_SETTINGS}/jvm.options.new ${LOGSTASH_PATH_SETTINGS}/jvm.options
  fi

  # override LS_OPTS variable if set
  if [ ! -z "$LS_OPTS" ]; then
    awk -v LINE="LS_OPTS=\"$LS_OPTS\"" '{ sub(/^LS_OPTS=.*/, LINE); print; }' /etc/init.d/logstash \
        > /etc/init.d/logstash.new && mv /etc/init.d/logstash.new /etc/init.d/logstash && chmod +x /etc/init.d/logstash
  fi

  exec /usr/local/bin/logstash-starter.sh

fi
