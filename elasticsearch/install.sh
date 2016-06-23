#!/bin/bash

set -ex

mkdir -p ${HOME}
ln -s /usr/share/elasticsearch /usr/share/java/elasticsearch

#/usr/share/elasticsearch/bin/plugin -i com.floragunn/search-guard/0.5.1 -url https://github.com/lukas-vlcek/origin-aggregated-logging/releases/download/v0.1/search-guard-0.5.1.zip

/usr/share/elasticsearch/bin/plugin install -b com.floragunn/search-guard-ssl/2.3.3.13
/usr/share/elasticsearch/bin/plugin install -b com.floragunn/search-guard-2/2.3.3.1

# TODO: update the following plugins
#/usr/share/elasticsearch/bin/plugin -i io.fabric8.elasticsearch/openshift-elasticsearch-plugin/0.14
#/usr/share/elasticsearch/bin/plugin -i io.fabric8/elasticsearch-cloud-kubernetes/1.3.0

mkdir /elasticsearch
chmod -R og+w /usr/share/java/elasticsearch ${HOME} /elasticsearch
