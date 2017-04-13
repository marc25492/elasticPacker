#!/bin/bash

sleep 30

#Install Java
sudo yum install -y java-1.7.0-openjdk-devel
sudo export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.131-2.6.9.0.el7_3.x86_64


########### Install from tar.gz file (Downloaded from Elastic Homepage) ##############################
#cd /usr/local/bin
#sudo curl -O https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.4.1/elasticsearch-2.4.1.tar.gz
#sudo tar -xvzf elasticsearch-2.4.1.tar.gz
#sudo rm elasticsearch-2.4.1.tar.gz
#sudo sed -i '/network.host:/c\network.host: 0.0.0.0' elasticsearch-2.4.1/config/elasticsearch.yml
#export ES_HOME=/usr/local/bin/elasticsearch-2.4.1
#sudo groupadd -r elastic
#sudo useradd -r -g elastic -s /sbin/nologin -d /home/elastic -c "Elasticsearch user" elastic
#sudo chown -R elastic:elastic $ES_HOME
#sudo $ES_HOME/bin/plugin install license
#yes | sudo $ES_HOME/bin/plugin install shield


## Download RPM package
sudo wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/2.3.3/elasticsearch-2.3.3.rpm
sudo rpm -ivh elasticsearch-2.3.3.rpm

########### Configure Elastic to run as a Cluster of AWS EC2 Instances ###############################
sudo chkconfig --add elasticsearch
cd /usr/share/elasticsearch/
#yes | sudo bin/plugin install cloud-aws
sudo wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/plugin/cloud-aws/2.3.3/cloud-aws-2.3.3.zip
sudo bin/plugin install file:cloud-aws-2.3.3.zip


## Configure the RAM elasticsearch uses
sudo sed -i '/#ES_HEAP_SIZE=2g/c\ES_HEAP_SIZE=512m' /etc/sysconfig/elasticsearch

## Configure the network host to be 0.0.0.0
sudo sed -i '/# network.host: 192.168.0.1/c\network.host: 0.0.0.0' /etc/elasticsearch/elasticsearch.yml


## Set up Auto-discovery in the AWS Cloud (using the cloud-aws plugin)
sudo sed -i '/# cluster.name: my-application/c\cluster.name: esonaws' /etc/elasticsearch/elasticsearch.yml
sudo sed -i '$ a\cloud.aws.access_key: '"$AWS_ACCESS_KEY" /etc/elasticsearch/elasticsearch.yml
sudo sed -i '$ a\cloud.aws.secret_key: '"$AWS_SECRET_KEY" /etc/elasticsearch/elasticsearch.yml
sudo sed -i '$ a\cloud.aws.region: eu-west-2' /etc/elasticsearch/elasticsearch.yml
sudo sed -i '$ a\cloud.aws.ec2.endpoint: ec2.eu-west-2.amazonaws.com' /etc/elasticsearch/elasticsearch.yml
sudo sed -i '$ a\discovery.type: ec2' /etc/elasticsearch/elasticsearch.yml




########### Starts the service & tests the connectivity
sudo service elasticsearch start
sleep 15
# Check Cluster Health
curl localhost:9200/_cluster/health?pretty

sleep 5

# Load in some dummy data
cd ~/auto_load
. ./load_data.sh

sleep 5
# Perform GET request - expects the response: Alfred Hajos
curl localhost:9200/olympic/person/p_1



