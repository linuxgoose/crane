#!/bin/bash

#Start update of Crane
echo -e "Starting update of Crane..."
sleep 1

#Stop Crane
echo -e "Checking if Crane service exists..."
sleep 1
if systemctl --all --type service | grep -q "crane"
then   
  echo -e "Stopping Crane service..."
  sleep 1
  sudo systemctl stop crane
fi
sleep 1

#Pull changes
git pull
sleep 1

#Start Crane
if systemctl --all --type service | grep -q "crane"
then
  echo -e "Restarting Crane service..."
  sleep 1
  sudo systemctl start crane
fi
sleep 1

#Prompt to update crane-service.sh

echo "------------------------------------------------------------------------"
echo "Crane has been successfully updated! If you'd like to use new environment fields, please run through the installation script again."