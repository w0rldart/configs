#!/bin/bash

######################
## common variables ##
######################

# Date format
DATE=$(date +%d-%m-%y)

# Path to s3cmd
S3_CMD="s3cmd"

# Where are the backups files? Both for destination as origin (backups.sh and deploy.sh)
BACKUP_PATH='/home/alex/backups'

# Destination for different types of backup
DB_BACKUP_DIRECTORY="$BACKUP_PATH/databases/"
IMAGES_BACKUP_DIRECTORY="$BACKUP_PATH/images/"

## Paths to s3 backups bucket
S3_DBS_URL="s3://backups.w0rldart/databases/latest/"
S3_DB_ARCHIVES_URL="s3://backups.w0rldart/databases/archives/$DATE/"

S3_IMAGES_URL="s3://backups.w0rldart/images/latest/"
S3_IMAGE_ARCHIVES_URL="s3://backups.w0rldart/images/archives/$DATE/"


##########################
## backups.sh variables ##
##########################

# Base path for directories to backup
SOURCE_PATH='/home/alex/www'

# Specify directories to backup that are in SOURCE_PATH
DIRECTORIES_TO_BACKUP="mysite.com/uploads/images myothersite.com/wp-content/uploads"


######################
## MySQL parameters ##
######################
MYSQL_HOST='localhost'
MYSQL_USER=''
MYSQL_PASS=''
