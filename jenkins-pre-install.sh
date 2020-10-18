#!/bin/bash
echo "Downloading plugins..."
/usr/local/bin/install-plugins.sh configuration-as-code:1.44
echo "copy plugins to shared volume"
mkdir /var/jenkins_home/plugins
cp -r /usr/share/jenkins/ref/plugins/* /var/jenkins_home/plugins/