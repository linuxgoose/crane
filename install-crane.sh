#!/bin/bash

# Check permissions
if [ "$(id -u)" -ne "0" ]; then
  echo "You need to be root"
  exit 1
fi

#Welcome Message
echo -e "Starting Crane Email Service installation script..."
sleep 1
echo -e "Welcome to Crane Email Service! Let's get down to business with figuring out some configuration items."
echo -e "-----------------------------------------------------------------------------"
sleep 1

# Capture Environment Variables
echo -e "What port do you want Crane to run on? [8080] (Required)"
read port_input
if [ -z $port_input ]
then
    port_input=8080
fi

echo -e "Where will the email be sent to? (Required)"
read email_to_input

echo -e "Where should email be allowed to be sent to? (Required)"
read allowed_to_input

echo -e "What should the from email address be? (Required)"
read email_from_input

echo -e "-----------------------------------------------------------------------------"
sleep 1
echo -e "Now let's configure your SMTP settings."
sleep 1

echo -e "What is the SMTP host? (Required)"
read smtp_host_input

echo -e "What is the SMTP port? [587] (Required)"
read smtp_port_input
if [ -z $smtp_port_input ]
then
    smtp_port_input=587
fi

echo -e "What is the SMTP user? (Required)"
read smtp_user_input

echo -e "What is the SMTP password? (Required)"
read smtp_pass_input

echo -e "-----------------------------------------------------------------------------"
sleep 1
echo -e "Do you want to configure the spamlist? (Y/N)"
read configure_spamlist
if [ $configure_spamlist = "Y" ]
then
    echo -e "Type in the spamlist words separated by a comma (i.e. gambling,casino)"
    read spamlist_input
elif [ $configure_spamlist = "y" ]
then
    echo -e "Type in the spamlist words separated by a comma (i.e. gambling,casino)"
    read spamlist_input
fi

echo -e "Do you want to configure the denylist? (Y/N)"
read configure_denylist
if [ $configure_denylist = "Y" ]
then
    echo -e "Type in the spamlist words separated by a comma (i.e. submit)"
    read denylist_input
elif [ $configure_denylist = "y" ]
then
    echo -e "Type in the denylist words separated by a comma (i.e. submit)"
    read denylist_input
fi

echo -e "-----------------------------------------------------------------------------"
sleep 1
echo -e "Creating crane-service.sh file..."
sleep 2

# Create (or replace)
if [ -e crane-service.sh ]
then
    rm crane-service.sh
fi

echo "#!/bin/bash

#Start Crane Service
while true
do
 echo "Crane service starting."
 cd $PWD
 PORT=$port_input EMAIL_TO=$email_to_input \
 ALLOWED_TO=$allowed_to_input EMAIL_FROM=$email_from_input SMTP_USER=$smtp_user_input \
 SMTP_PASS=$smtp_pass_input SMTP_HOST=$smtp_host_input SMTP_PORT=$smtp_port_input \
 SPAMLIST=$spamlist_input DENYLIST=$denylist_input /usr/local/go/bin/go run .

 sleep 10
done
echo "Crane service has been stopped."

" >> crane-service.sh

sudo chmod +x crane-service.sh
echo -e "Executable permissions applied..."

sleep 1
echo -e "The crane-service.sh file has been created successfully!"

echo -e "-----------------------------------------------------------------------------"
sleep 1
echo -e "Do you want to configure the systemd service for Crane? Note: this is not required if you are only updating environment variables! (Y/N)"
read configure_systemd
if [ $configure_systemd = "Y" ]
then
    # Create (or replace)
if [ -e /lib/systemd/system/crane.service ]
then
    rm /lib/systemd/system/crane.service
fi
    echo "[Unit]
Description=Crane email form service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$PWD
ExecStart=$PWD/crane-service.sh

Restart=on-failure
RestartSec=10

StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=appgoservice


[Install]
WantedBy=multi-user.target
    " >> /lib/systemd/system/crane.service
    echo -e "Would you like to enable the service now? (Y/N)"
read enable_systemd
if [ $enable_systemd = "Y" ]
then
    sudo systemctl daemon-reload
    sudo systemctl enable crane.service
    sudo systemctl start crane.service
elif [ $enable_systemd = "y" ]
then
    sudo systemctl daemon-reload
    sudo systemctl enable crane.service
    sudo systemctl start crane.service
fi
elif [ $configure_systemd = "y" ]
then
    # Create (or replace)
if [ -e /lib/systemd/system/crane.service ]
then
    rm /lib/systemd/system/crane.service
fi
    echo "[Unit]
Description=Crane email form service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$PWD
ExecStart=$PWD/crane-service.sh

Restart=on-failure
RestartSec=10

StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=appgoservice


[Install]
WantedBy=multi-user.target
    " >> /lib/systemd/system/crane.service
    echo -e "Would you like to enable the service now? (Sudo privileges are required) (Y/N)"
read enable_systemd
if [ $enable_systemd = "Y" ]
then
    sudo systemctl daemon-reload
    sudo systemctl enable crane.service
    sudo systemctl start crane.service
elif [ $enable_systemd = "y" ]
then
    sudo systemctl daemon-reload
    sudo systemctl enable crane.service
    sudo systemctl start crane.service
fi
fi

sleep 1

echo -e "The Crane systemd service has been created successfully!"

echo -e "-----------------------------------------------------------------------------"
sleep 1
echo "Crane has been successfull installed and set up!"