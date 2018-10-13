FROM openjdk:8-jdk

ARG LOGSTASH_VERSION

ENV LOGSTASH_VERSION ${LOGSTASH_VERSION:-6.4.0}
ENV LOGSTASH_HOME /opt/logstash
ENV LOGSTASH_PACKAGE logstash-${LOGSTASH_VERSION}.tar.gz
ENV LOGSTASH_GID 992
ENV LOGSTASH_UID 992 
ENV LOGSTASH_PATH_SETTINGS ${LOGSTASH_HOME}/config


COPY ./scripts/logstash-starter.sh /usr/local/bin/
COPY ./scripts/start.sh /usr/local/bin/start.sh
# install Logstash
RUN set -ex \
 && mkdir ${LOGSTASH_HOME} \
 && curl -O https://artifacts.elastic.co/downloads/logstash/${LOGSTASH_PACKAGE} \
 && tar xzf ${LOGSTASH_PACKAGE} -C ${LOGSTASH_HOME} --strip-components=1 \
 && rm -f ${LOGSTASH_PACKAGE} \
# add user
 && useradd -r -s /usr/bin/bash -d ${LOGSTASH_HOME} -c "Logstash service user" -u ${LOGSTASH_UID} -g root logstash \
 && mkdir -p /var/log/logstash \
 && chown -R logstash:root /var/log/logstash \
 && chown -R logstash:root /opt/logstash/

RUN set -ex \
 && chmod -R 775 /opt/logstash \
 ## Prepare the starter scripts
 && sed -i -e 's#^LS_HOME=$#LS_HOME='$LOGSTASH_HOME'#' /usr/local/bin/logstash-starter.sh \
 && chmod 775 /usr/local/bin/logstash-starter.sh \
 && chmod 775 /usr/local/bin/start.sh \
 && chmod 775 /tmp \
 && chmod -R 775 /var/log/logstash

USER logstash

EXPOSE 9600
EXPOSE 5044

ENTRYPOINT [ "/usr/local/bin/start.sh" ]

