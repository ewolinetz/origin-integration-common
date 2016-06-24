#!/bin/bash

set -euo pipefail

secret_dir=/etc/elasticsearch/secret
config_dir=/etc/elasticsearch/config

# ES seems to be picky about its config/ dir and permissions within it -- ln -s would yield incorrect permissions...
[ -f $secret_dir/searchguard.key ] && cp $secret_dir/searchguard.key $ES_CONF/$CLUSTER_NAME.key
[ -f $secret_dir/searchguard.truststore ] && cp $secret_dir/searchguard.truststore $ES_CONF/$CLUSTER_NAME.truststore
[ -f $config_dir/elasticsearch.yml ] && cp $config_dir/elasticsearch.yml $ES_CONF/elasticsearch.yml
[ -f $config_dir/logging.yml ] && cp $config_dir/logging.yml $ES_CONF/logging.yml

[ -f $secret_dir/key ] && cp $secret_dir/key $ES_CONF/key
[ -f $secret_dir/truststore ] && cp $secret_dir/truststore $ES_CONF/truststore

[ -f $secret_dir/admin-cert ] && cp $secret_dir/admin-cert $ES_CONF/admin-cert
[ -f $secret_dir/admin-key ] && cp $secret_dir/admin-key $ES_CONF/admin-key
[ -f $secret_dir/admin-ca ] && cp $secret_dir/admin-ca $ES_CONF/admin-ca

# the amount of RAM allocated should be half of available instance RAM.
# ref. https://www.elastic.co/guide/en/elasticsearch/guide/current/heap-sizing.html#_give_half_your_memory_to_lucene
regex='^([[:digit:]]+)([GgMm])$'
if [[ "${INSTANCE_RAM:-}" =~ $regex ]]; then
	num=${BASH_REMATCH[1]}
	unit=${BASH_REMATCH[2]}
	if [[ $unit =~ [Gg] ]]; then
		((num = num * 1024)) # enables math to work out for odd Gi
	fi
	if [[ $num -lt 256 ]]; then
		echo "INSTANCE_RAM set to ${INSTANCE_RAM} but must be at least 256M"
		exit 1
	fi
	export ES_JAVA_OPTS="${ES_JAVA_OPTS:-} -Xms128M -Xmx$(($num/2))m"
else
	echo "INSTANCE_RAM env var is invalid: ${INSTANCE_RAM:-}"
	exit 1
fi

exec /usr/share/elasticsearch/bin/elasticsearch --path.conf=$ES_CONF &

# somehow wait for ES to start and then run the following?
# ALT - make this a post deploy pod?

#ln -s /usr/share/elasticsearch/config/${CLUSTER_NAME}.key /usr/share/elasticsearch/config/${CLUSTER_NAME}.key.jks
ln -s /usr/share/elasticsearch/config/${CLUSTER_NAME}.truststore /usr/share/elasticsearch/config/${CLUSTER_NAME}.truststore.jks
cp /etc/elasticsearch/secret/admin-jks /usr/share/elasticsearch/config/admin.jks

sleep 30
# for some reason this app will only accept the file type as JKS if it ends with .jks
/usr/share/elasticsearch/plugins/search-guard-2/tools/sgadmin.sh  \
   -cd ${HOME}/sgconfig/ \
   -ks /usr/share/elasticsearch/config/admin.jks \
   -ts /usr/share/elasticsearch/config/${CLUSTER_NAME}.truststore.jks  \
	 -cn ${CLUSTER_NAME} \
	 -kspass kspass \
	 -tspass tspass \
   -nhnv

sleep inf
