#!/bin/bash
set -x

plugins=("$@")
echo "Downloading plugins..."

for plugin in "${plugins[@]}"; do
   echo "Installing $plugin ..."
   /usr/local/bin/install-plugins.sh configuration-as-code:1.44
done

echo "Moving plugins to shared volume ..."
mkdir /var/jenkins_home/plugins
cp -r /usr/share/jenkins/ref/plugins/* /var/jenkins_home/plugins/