FROM docker.elastic.co/kibana/kibana:7.5.2

USER root

RUN yum install -y \
    zip \
    unzip && \
    rm -rf /var/cache/yum/* && \
    yum clean all

ADD https://github.com/bitsensor/elastalert-kibana-plugin/releases/download/1.1.0/elastalert-kibana-plugin-1.1.0-7.5.0.zip /tmp/elastalert-kibana-plugin-1.1.0-7.5.2.zip

RUN cd /tmp && \
    unzip elastalert-kibana-plugin-1.1.0-7.5.2.zip kibana/elastalert-kibana-plugin/package.json && \
    sed -i "s/7\.5\.0/7\.5\.2/g" kibana/elastalert-kibana-plugin/package.json && \
    zip elastalert-kibana-plugin-1.1.0-7.5.2.zip kibana/elastalert-kibana-plugin/package.json && \
    /usr/share/kibana/bin/kibana-plugin install --allow-root file:///tmp/elastalert-kibana-plugin-1.1.0-7.5.2.zip

USER kibana