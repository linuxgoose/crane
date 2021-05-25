# Crane

<img src="https://jordansukenik.com/content/images/size/w750/2021/05/crane-traced.png" width="100">

Crane is a small tool written in Go that enables the ability to send HTML form requests, for example from static websites without a dynamic backend, via email. It can be used for contact forms created on [Ghost](https://ghost.org) pages should a user not want to use a third-party service like TypeForm or FormSpree.

Crane is a fork of the [MailyGo](https://codeberg.org/jlelse/MailyGo) app by [jlelse](https://jlelse.dev/).

Crane is lean and resource-saving. It can be installed with just one executable file.

## Prerequisites

In order to run Crane without any issues you'll need the following:
* Go - v1.4.2 or higher

## Installation

Crane can be installed by the following command.

```bash
git  clone http://github.com/linuxgoose/crane
```

Crane can then be started manually with the below command after all environment variables have been set within the bash script.

```bash
bash crane-service.sh
```

**Note:** If you experience issues with running the bash script, try modifying the script with **`sudo chmod +x crane-service.sh`**

Alternatively, you can run the included installation script. This script will capture all of the required environment variables for **`crane-service.sh`** and if wanted, create and enable the systemd service.

```bash
sudo bash install-crane.sh
```

If you'd like to run Crane as a service, go to the systemd section for how to set up the service.

## Configuration

To run the server, you must set a few environment variables from the list below.

| Name | Type | Default value | Usage |
|---|---|---|---|
| **`SMTP_USER`** | required | - | The SMTP user |
| **`SMTP_PASS`** | required | - | The SMTP password |
| **`SMTP_HOST`** | required | - | The SMTP host |
| **`SMTP_PORT`** | optional | 587 | The SMTP port |
| **`EMAIL_FROM`** | required | - | The sender mail address |
| **`EMAIL_TO`** | required | - | Default recipient |
| **`ALLOWED_TO`** | required | - | All allowed recipients (separated by `,`) |
| **`PORT`** | optional | `8080` | The port on which the Crane server will listen |
| **`HONEYPOTS`** | optional | `_t_email` | Honeypot form fields (separated by `,`) |
| **`GOOGLE_API_KEY`** | optional | - | Google API Key for the [Google Safe Browsing API](https://developers.google.com/safe-browsing/v4/) |
| **`SPAMLIST`** | optional | `gambling,casino` | List of spam words to identify and reject |
| **`DENYLIST`** | optional | `submit` | List of fields names to deny |

## Special form fields

You can find a sample form in the `form.html` file. Only fields whose name do not start with an underscore (`_`) will be sent by email. Fields with an underscore serve as control fields for special purposes:

| Name | Type | Default value | Usage |
|---|---|---|---|
| **`_to`** | optional | - | Recipient, it must be in `ALLOWED_TO`, hidden |
| **`_replyTo`** | optional | - | Email address which should be configured as replyTo, (most probably not hidden) |
| **`_redirectTo`** | optional | - | URL to redirect to, hidden |
| **`_formName`** | optional | - | Name of the form, hidden |
| **`_t_email`** | optional | - | (Default) "Honeypot" field, not hidden, advised (see notice below) |

## Spam protection

Crane offers the option to use a [Honeypot](https://en.wikipedia.org/wiki/Honeypot\_(computing)) field, which is basically another input, but it's hidden to the user with either a CSS rule or some JavaScript. It is very likely, that your public form will get the attention of some bots some day and then the spam starts. But bots try to fill every possible input field and will also fill the honeypot field. Crane won't send mails of form submissions where a honeypot field is filled. So you should definitely use it.

If a Google Safe Browsing API key is set, submitted URLs will also get checked for threats.

## Systemd service creation

Crane can be set up as a **`systemd`** service by calling the included **`crane.sh`** script. Simply create the **`systemd`** service.

```shell
sudo nano /lib/systemd/system/crane.service
```

Paste the below details into the created file after configuring the **`WorkingDirectory`** and **`ExecStart`**.

```shell
[Unit]
Description=Crane email form service
After=network.target

[Service]
Type=simple
User=your_user
WorkingDirectory=/home/your_user/crane
ExecStart=/home/your_user/crane/crane-service.sh

Restart=on-failure
RestartSec=10

StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=appgoservice


[Install]
WantedBy=multi-user.target
```

Reload the systemd daemon.

```shell
 sudo systemctl daemon-reload
```

Then enable the service.

```shell
sudo systemctl enable crane.service
```

And start it.

```shell
sudo systemctl start crane.service
```

You can check the status of the service with the below to ensure it is actively running. You should see **`Crane service starting.`** with no errors following.

```shell
sudo systemctl status crane.service
```

## Update Crane

Crane comes with an included update script. To update crane, run the following command in the app's folder.

```shell
sudo bash update.sh
```

## License

Crane is licensed under the MIT license, so you can do basically everything with it, but nevertheless, please contribute your improvements to make Crane better for everyone. See the LICENSE file.