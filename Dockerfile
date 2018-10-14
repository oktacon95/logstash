FROM openjdk:8-jdk

ARG LOGSTASH_VERSION
ARG GEMS

ENV LOGSTASH_VERSION ${LOGSTASH_VERSION:-6.4.0}
ENV LOGSTASH_HOME /opt/logstash
ENV LOGSTASH_PACKAGE logstash-${LOGSTASH_VERSION}.tar.gz
ENV LOGSTASH_GID 992
ENV LOGSTASH_UID 992 
ENV LOGSTASH_PATH_SETTINGS ${LOGSTASH_HOME}/config
ENV GEMS ${GEMS}

COPY ./scripts/logstash-starter.sh /usr/local/bin/
COPY ./scripts/start.sh /usr/local/bin/start.sh
# install Logstash
RUN set -ex \
 && mkdir ${LOGSTASH_HOME}

# Following command doesn't work cause of our lovely education network. Therefore, we have to cheat a little bit
# RUN curl -O https://artifacts.elastic.co/downloads/logstash/${LOGSTASH_PACKAGE}

COPY ./logstash-6.4.0.tar.gz /

RUN tar xzf ${LOGSTASH_PACKAGE} -C ${LOGSTASH_HOME} --strip-components=1 \
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

RUN if ! [[ -z $GEMS ]]; then $LOGSTASH_HOME/bin/logstash-plugin install $GEMS; fi

EXPOSE 9600
EXPOSE 5044

ENTRYPOINT [ "/usr/local/bin/start.sh" ]

