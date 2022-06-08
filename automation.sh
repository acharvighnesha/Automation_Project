#!/bin/sh
MY_NAME="vighnesha"
S3_BUCKET="upgrad-vighnesha"
BOOK_KEEPING_PATH=/var/www/html/inventory.html
echo "started automating basic tasks"
export AWS_ACCESS_KEY_ID=AKIAVEWXEMNO6URD6E2K
export AWS_SECRET_ACCESS_KEY=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
export AWS_DEFAULT_REGION=us-east-1
sudo apt update -y
PKG_NAME="apache2"
PKG_PRESENT=$(dpkg-query -W --showformat='${Status}\n' $PKG_NAME|grep "install ok installed")
#checking if apache2 package is present ,if not , installing it
echo is package present $PKG_NAME: $PKG_PRESENT
if [ "" = "PKG_PRESENT" ]; then
  echo "No $PKG_NAME. Setting up $PKG_NAME."
  sudo apt install $PKG_NAME --yes
  else 
  echo "$PKG_NAME package is already present"
fi

#checking if HTTP Apache service is enabled
STATUS="$(systemctl is-active apache2)"
ENABLED="$(systemctl is-enabled apache2)"
if [ "${ENABLED}" = "enabled" ]; then
    echo "apache2 service is enabled"
    else
    echo "apache2 is not enabled"
fi

if [ "${STATUS}" = "active" ]; then
    echo "apache2 service is active"
    else
    echo "apache2 is not active, starting the service"
fi
#Script ensures that HTTP Apache server is running
if [ "${STATUS}" != "active"  ] || [ "${ENABLED}" != "enabled"  ] ; then
    echo "starting apache2 server"
    systemctl start apache2
    echo "started apache2 server"
fi

echo "creating a ter file"
name="${MY_NAME}-httpd-logs-$(date '+%d%m%Y-%H%M%S').tar"
tar -cvf /tmp/$name /var/log/apache2/*.log
echo "successfully created tar file, $name"
sudo apt update
sudo apt install awscli --yes
aws s3 cp /tmp/$name s3://$S3_BUCKET
echo "upload successfully to s3 bucket $$S3_BUCKET"

#adding book keeping logs
CURR_TIME=$(date '+%d%m%Y-%H%M%S')
FILE_SIZE=`du -k "/tmp/$name" | cut -f1`
if [ -e $BOOK_KEEPING_PATH ]
then
    echo "exists"
    echo "<p>httpd-logs &nbsp&nbsp&nbsp $CURR_TIME &nbsp &nbsp&nbsp  tar &nbsp &nbsp &nbsp $FILE_SIZE K</p>">>$BOOK_KEEPING_PATH
    echo "appended"
else
    echo "not exists"
    mkdir -p "/var/www"
    mkdir -p "/var/www/html"
    touch $BOOK_KEEPING_PATH
    echo "<html>" >>$BOOK_KEEPING_PATH
    echo "<h5> Log Type &emsp;&emsp; Date Created   &emsp; &emsp; &emsp; &emsp;  Type &emsp; Size</h5>" >>$BOOK_KEEPING_PATH
    echo "<body>" >>$BOOK_KEEPING_PATH
fi

#creating cron file to run the job daily 8AM
CRON_FILE=/etc/cron.d/automation
if [ -e $CRON_FILE ]
then
	echo "crontab file exists"
else
	touch $CRON_FILE
	echo "0 8 * * * root /root/Automation_Project/automation.sh">$CRON_FILE
fi