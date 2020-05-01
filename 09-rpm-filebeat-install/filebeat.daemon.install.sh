#!/bin/bash
sudo yum update -y && sudo yum install curl -y
sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
sudo curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.5.2-x86_64.rpm
sudo curl -L -O https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-7.5.2-x86_64.rpm
sudo mkdir /var/log/filebeat
sudo mkdir /var/log/heartbeat
sudo yum localinstall filebeat-7.5.2-x86_64.rpm -y
sudo rpm -vi heartbeat-7.5.2-x86_64.rpm && yum install heartbeat-elastic -y
sudo systemctl enable filebeat && sudo systemctl start filebeat
sudo systemctl enable heartbeat-elastic && sudo systemctl start heartbeat-elastic

sudo cat <<EOF > /etc/filebeat/filebeat.yml
#==========================  Modules configuration =============================
filebeat.modules:
#=========================== Filebeat inputs ===================================
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/*.log
#============================= Filebeat modules ================================
filebeat.config.modules:
  path: /etc/filebeat/modules.d/*.yml
  reload.enabled: false

#==================== Elasticsearch template setting ===========================
setup.template.settings:
  index.number_of_shards: 1

#-------------------------- Elasticsearch output -------------------------------
output.elasticsearch:
  hosts: ["http://esingest.dteixeira.com.br:9200"]
  # hosts: ["https://esingest.dteixeira.com.br:9203"]
  username: "user_cli"
  password: "GyQSoXW9w0pBnV"

#================================ Outputs ======================================
#----------------------------- Logstash output ---------------------------------
# output.logstash:
#   hosts: ["http://logsth.dteixeira.com.br:5044"]
#   hosts: ["https://logsth.dteixeira.com.br:5043"]

#================================ Logging ======================================
logging.to_files: true
EOF

sudo cat <<EOF > /etc/filebeat/modules.d/system.yml
#------------------------------- System Module ---------------------------------
- module: system
  syslog:
  enabled: true
  auth:
    enabled: true
    var.paths: ["/var/log/secure"]

#------------------------------- Auditd Module ---------------------------------
- module: auditd
  log:
    enabled: true
    var.paths: ["/var/log/audit/audit.log"]
EOF

sudo cat <<EOF > /etc/heartbeat/heartbeat.yml
#================================ Heartbeat ====================================
# Configure monitors inline
heartbeat.monitors:
- type: icmp
  schedule: '*/5 * * * * * *'
  hosts: ["127.0.0.1"]
  mode: any
  timeout: 16s
  wait: 1s

# ==================== Elasticsearch template setting ==========================
setup.template.settings:
  index.number_of_shards: 1
  index.codec: best_compression

# -------------------------- Elasticsearch output ------------------------------
output.elasticsearch:
  # Array of hosts to connect to.
  hosts: ["http://esingest.dteixeira.com.br:9200"]
  # hosts: ["https://esingest.dteixeira.com.br:9203"]
  username: "user_cli"
  password: "GyQSoXW9w0pBnV"

# ================================ Procesors ===================================
processors:
  - add_host_metadata: ~
  - add_cloud_metadata: ~

heartbeat.scheduler:
  limit: 10

EOF

sudo systemctl restart filebeat
sudo systemctl restart heartbeat-elastic

exit 0