#!/bin/sh

set -e

# Make sure to set up a daily backup at midnight "0 0 * * *"

# Current time
TIME=`/bin/date +%Y-%m-%dT%H%M%SZ`

# Gzip backup file
BACKUP_FILE="mongobackup-$TIME.gzip"

echo "Backing up $MONGO_HOST/$MONGO_DB to s3://$S3_BUCKET/ on $TIME";
mongodump\
  --username=$MONGO_USERNAME\
  --password=$MONGO_PASSWORD\
  --host=$MONGO_HOST\
  --port=$MONGO_PORT\
  --db=$MONGO_DB\
  --authenticationDatabase=$MONGO_AUTH_DB\
  --archive=$BACKUP_FILE\
  --gzip

echo "Configuring s3cmd..."
echo "[default]" > .s3cfg
echo "access_key = $S3_ACCESS_KEY" >> .s3cfg
echo "secret_key = $S3_SECRET_KEY" >> .s3cfg
echo "host_base = $S3_ENDPOINT" >> .s3cfg
echo "host_bucket = %(bucket)s.$S3_ENDPOINT" >> .s3cfg
echo "bucket_location = US" >> .s3cfg
echo "use_https = True" >> .s3cfg
cat .s3cfg

echo "Uploading to S3"
s3cmd put $BACKUP_FILE s3://$S3_BUCKET

echo "Removing backup file locally"
rm -f $BACKUP_FILE

echo "Backup available at https://$S3_BUCKET.$S3_ENDPOINT/$BACKUP_FILE"
echo "Link to the bucket https://cloud.digitalocean.com/spaces/$S3_BUCKET"