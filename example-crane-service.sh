#!/bin/bash

#Start Crane Service
while true
do
 echo "Crane service starting."
 cd /home/your_user/crane
 PORT=8080 EMAIL_TO= ALLOWED_TO= EMAIL_FROM= SMTP_USER= SMTP_PASS= SMTP_HOST= SMTP_PORT=587 BLACKLIST=gambling,casino go run .

 sleep 10
done
echo "Crane service has been stopped."