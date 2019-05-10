#!/bin/bash

source ./config/demo.cfg
source ./delta_configs/env.delta


CONNECT_HOST=localhost

if [[ $1 ]];then
    CONNECT_HOST=$1
fi

HEADER="Content-Type: application/json"
DATA=$( cat << EOF
{
  "name": "aws-s3-sink-avro",
  "config": {
    "name": "aws-s3-sink-avro",
    "connector.class": "io.confluent.connect.s3.S3SinkConnector",
    "tasks.max": "1",
    "s3.region": "$DEMO_REGION_LC",
    "s3.bucket.name": "$DEMO_BUCKET_NAME",
    "s3.part.size": "5242880",
    "flush.size": "8",
    "storage.class": "io.confluent.connect.s3.storage.S3Storage",
    "format.class": "io.confluent.connect.s3.format.avro.AvroFormat",
    "schema.generator.class": "io.confluent.connect.storage.hive.schema.DefaultSchemaGenerator",
    "partitioner.class": "io.confluent.connect.storage.partitioner.DefaultPartitioner",
    "schema.compatibility": "NONE",
    "topics": "$KAFKA_TOPIC_NAME_OUT",
    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
    "value.converter": "io.confluent.connect.avro.AvroConverter",
    "value.converter.basic.auth.credentials.source": "$BASIC_AUTH_CREDENTIALS_SOURCE",
    "value.converter.schema.registry.basic.auth.user.info": "$SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO",
    "value.converter.schema.registry.url": "$SCHEMA_REGISTRY_URL",
    "confluent.topic.bootstrap.servers": "$BOOTSTRAP_SERVERS",
    "confluent.topic.security.protocol": "SASL_SSL",
    "confluent.topic.sasl.mechanism": "PLAIN",
    "confluent.topic.sasl.jaas.config": "$REPLICATOR_SASL_JAAS_CONFIG",
    "producer.interceptor.classes": "io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor"
  }
}
EOF
)

echo "curl -X POST -H \"${HEADER}\" --data \"${DATA}\" http://${CONNECT_HOST}:8087/connectors"
curl -X POST -H "${HEADER}" --data "${DATA}" http://${CONNECT_HOST}:8087/connectors
if [[ $? != 0 ]]; then
  echo "ERROR: Could not successfully submit connector. Please troubleshoot Connect."
  exit $?
fi
