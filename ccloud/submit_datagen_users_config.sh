#!/bin/bash

source delta_configs/env.delta

CONNECT_HOST=localhost

if [[ $1 ]];then
    CONNECT_HOST=$1
fi

HEADER="Content-Type: application/json"
DATA=$( cat << EOF
{
  "name": "datagen-users",
  "config": {
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "kafka.topic": "users",
    "quickstart": "users",
    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
    "value.converter": "io.confluent.connect.avro.AvroConverter",
    "value.converter.basic.auth.credentials.source": "$BASIC_AUTH_CREDENTIALS_SOURCE",
    "value.converter.schema.registry.basic.auth.user.info": "$SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO",
    "value.converter.schema.registry.url": "$SCHEMA_REGISTRY_URL",
    "producer.interceptor.classes": "io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor",
    "max.interval": 1000,
    "iterations": 1000000000,
    "tasks.max": "1"
  }
}
EOF
)

echo "curl -X POST -H \"${HEADER}\" --data \"${DATA}\" http://${CONNECT_HOST}:8087/connectors"
curl -X POST -H "${HEADER}" --data "${DATA}" http://${CONNECT_HOST}:8087/connectors
echo
