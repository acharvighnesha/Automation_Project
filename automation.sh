#!/bin/sh
echo "started automating basic tasks"
export AWS_ACCESS_KEY_ID=AKIAVEWXEMNO6URD6E2K
export AWS_SECRET_ACCESS_KEY=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
export AWS_DEFAULT_REGION=us-east-1
S3_BUCKET="upgrad-vighnesha"
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
name="vighnesha-httpd-logs-$(date '+%d%m%Y-%H%M%S').tar"
tar -cvf /tmp/$name /var/log/apache2/*.log
echo "successfully created tar file, $name"
sudo apt update
sudo apt install awscli --yes
aws s3 cp /tmp/$name s3://$S3_BUCKET
echo "upload successfully to s3 bucket $$S3_BUCKET"