#!/bin/bash
set -ex

curl --version || yum install python-pip curl -y
aws --version || pip install awscli
jq --version || yum install jq -y
command -v vector >/dev/null 2>&1 || { curl -1sLf 'https://repositories.timber.io/public/vector/cfg/setup/bash.rpm.sh' | sudo -E bash; yum install vector -y; }

REGION=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | awk '{ print substr($1, 1, length($1)-1) }'`
aws configure set default.region $REGION
aws configure set default.output text
instance_id=`/opt/aws/bin/ec2-metadata -i | awk '{ print $2 }'`
host_name=`aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" "Name=key,Values=Name" | cut -f 5`
hostnamectl set-hostname --static $host_name


tag_cluster_name=`aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" "Name=key,Values=cluster_name" | cut -f 5`
tag_escluster=`aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" "Name=key,Values=escluster" | cut -f 5`

if [ ! -z $tag_cluster_name ];then
    APP_NAME=$tag_cluster_name
elif [ ! -z $tag_escluster ];then
    APP_NAME=$tag_escluster
else
    echo "Can't find tag:escluster, tag:escluster"
    echo "\$APP_NAME not set"
    exit 1
fi

account_id=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document |jq -r '.accountId'`
tag_env=`aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" "Name=key,Values=env" | cut -f 5`
if [ $account_id = "***" ];then
    echo "Send to prod Kafka"
    KAFKA_SERVERS="kafka-log.prod.internal:9092,kafka-log.prod.internal:9092,kafka-log.prod.internal:9092"
    KAFKA_TOPIC="prod-elasticsearch-ec2"
elif [[ $tag_env =~ (prod|cloud) ]];then
    echo "Send to cloud Kafka"
    KAFKA_SERVERS="kafka-log.prod.internal:9092,kafka-log.prod.internal:9092,kafka-log.prod.internal:9092"
    KAFKA_TOPIC="cloud-elasticsearch-ec2"
else
    echo "Send to dev Kafka"
    KAFKA_SERVERS="kafka-log.nonprod.internal:9092,kafka-log.nonprod.internal:9092,kafka-log.nonprod.internal:9092"
    KAFKA_TOPIC="dev-elasticsearch-ec2"
fi


CPUQuota=$(($(nproc) <= 2 ? 25 : 100))%

cat > /etc/vector/vector.yaml <<EOF
api:
  enabled: true
sources:
  file:
    type: file
    include:
      # - /var/log/**/*.log
      - /var/log/elasticsearch/*.log
    multiline:
      start_pattern: '^\[?[0-9]{4}-[0-9]{2}-[0-9]{2}'
      mode: "halt_before"
      condition_pattern: '^\[?[0-9]{4}-[0-9]{2}-[0-9]{2}'
      timeout_ms: 1000
transforms:
  aws_ec2_metadata:
    type: aws_ec2_metadata
    inputs: ["file"]
    endpoint: http://169.254.169.254
    fields:
      - instance-id
      - local-ipv4
    refresh_interval_secs: 3600
    refresh_timeout_secs: 1
    required: true
    tags:
      - Name
  remap:
    inputs: ["aws_ec2_metadata"]
    type: remap
    source: |-
      .appName = "${APP_NAME}"
      .source = "ec2"
      .logType = "elasticsearch"
sinks:
  # print:
  #   type: console
  #   inputs: ["remap"]
  #   encoding:
  #     codec: json
  kafka:
    type: kafka
    inputs: ["remap"]
    bootstrap_servers: ${KAFKA_SERVERS}
    librdkafka_options:
      linger.ms: "100"
    encoding:
      codec: json
    compression: zstd
    topic: ${KAFKA_TOPIC}
EOF


cat > /usr/lib/systemd/system/vector.service <<EOF
[Unit]
Description=Vector
Documentation=https://vector.dev
After=network-online.target
Requires=network-online.target
[Service]
User=root
Group=root
ExecStartPre=/usr/bin/vector validate -C /etc/vector/
ExecStart=/usr/bin/vector -c /etc/vector/vector.yaml
ExecReload=/usr/bin/vector validate -C /etc/vector/
ExecReload=/bin/kill -HUP \$MAINPID
Restart=always
RestartSec=60
AmbientCapabilities=CAP_NET_BIND_SERVICE
EnvironmentFile=-/etc/default/vector
CPUQuota=${CPUQuota}
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl restart vector
systemctl status vector
