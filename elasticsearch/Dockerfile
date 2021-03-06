FROM centos:centos7

MAINTAINER OpenShift Development <dev@lists.openshift.redhat.com>

EXPOSE 9200
EXPOSE 9300
USER 0

ENV HOME=/opt/app-root/src \
  JAVA_VER=1.8.0 \
  ES_VER=2.3.3 \
  ES_CONF=/usr/share/elasticsearch/config \
  INSTANCE_RAM=512G \
  NODE_QUORUM=1 \
  RECOVER_AFTER_NODES=1 \
  RECOVER_EXPECTED_NODES=1 \
  RECOVER_AFTER_TIME=5m \
  PLUGIN_LOGLEVEL=INFO \
  ES_USER=elasticsearch \
  ES_GROUP=elasticsearch

LABEL io.k8s.description="Elasticsearch container to serve as APIMan backend" \
  io.k8s.display-name="Elasticsearch ${ES_VER}" \
  io.openshift.expose-services="9200:https, 9300:https" \
  io.openshift.tags="apiman,elasticsearch"

ADD elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
# install the RPMs in a separate step so it can be cached
RUN rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch && \
    yum install -y --setopt=tsflags=nodocs \
                java-1.8.0-openjdk-headless \
                elasticsearch-${ES_VER} && \
    yum clean all
# initial boring elasticsearch.yml is just to enable plugin installation.
# put the real config in place in a deployment with a ConfigMap.
ADD elasticsearch.yml logging.yml /etc/elasticsearch/config/
ADD sgconfig/ ${HOME}/sgconfig/
ADD install.sh openshift-elasticsearch-plugin-2.3.3.zip ${HOME}/
RUN ${HOME}/install.sh
ADD run.sh ${HOME}/

WORKDIR ${HOME}
USER 1000
CMD ["sh", "/opt/app-root/src/run.sh"]
