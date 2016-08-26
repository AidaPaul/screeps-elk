#!/usr/bin/env bash
# Python
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install python-dev
sudo apt-get -y install python-pip
sudo apt-get -y install curl
sudo apt-get -y install git
sudo apt-get -y install apt-transport-https software-properties-common python-software-properties
sudo pip install -r /opt/screeps-elk/requirements.txt

# Java
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
sudo apt-get -y install oracle-java8-installer

# Elastic
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
sudo apt-get update
sudo apt-get -y install elasticsearch
sudo update-rc.d elasticsearch defaults 95 10
sudo service elasticsearch start

# Kibana
echo "deb http://packages.elastic.co/kibana/4.5/debian stable main" | sudo tee -a /etc/apt/sources.list.d/kibana-4.5.x.list
sudo apt-get update
sudo apt-get -y install kibana
sudo cp /opt/screeps-elk/kibana.yml /opt/kibana/config/kibana.yml
sudo update-rc.d kibana defaults 96 9
sudo service kibana restart

# Logstash
echo 'deb http://packages.elastic.co/logstash/2.3/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash-2.3.x.list
sudo apt-get update
sudo apt-get -y install logstash
sudo cp /opt/screeps-elk/etc/logstash/conf.d/* /etc/logstash/conf.d/
sudo update-rc.d kibana defaults 96 8
sudo service logstash start

# Elasticdump
curl -sL https://deb.nodesource.com/setup_6.x | sudo bash -
sudo apt-get install -y nodejs
sudo npm install elasticdump -g

# Kibana stuffs
elasticdump \
--input=/opt/screeps-elk/imports/kibana-mapping.json \
--output=http://localhost:9200/.kibana \
--type=mapping
elasticdump \
--input=/opt/screeps-elk/imports/kibana-data.json \
--output=http://localhost:9200/.kibana \
--type=data

# Nginx as reverse proxy
sudo apt-get install -y nginx
sudo cp /opt/screeps-elk/etc/nginx/htpasswd /etc/nginx/htpasswd
sudo cp /opt/screeps-elk/etc/nginx/sites-available/default /etc/nginx/sites-available/default
sudo update-rc.d nginx defaults 97 8
sudo service nginx restart
