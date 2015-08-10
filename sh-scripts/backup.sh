#!/bin/bash

##
## Script to backup directories and databases;
##
## - AUTHOR:  Alexandru Budurovici
## - VERSION: 1.4
##
## Changelog:
##   1.0 - Initial release.
##          |- Backing databases, webs and media files mentioned in variables
##          |- Controlling what to backup through variables
##
##   1.1 - Migrated to a more functional way, and, dumping all databases available for an account
##   1.2 - Script now includes a config file, instead of running custom config
##   1.3 - Option to process all functions in a row
##   1.4 - Removed backupWebs and syncWebs functions, to promote the usage of GIT repositories
##
##

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

## Load the config file
configFile=$SCRIPT_DIR/config.sh

if [ ! -f $configFile ]; then
    echo
    echo -e "\033[31m config.sh file is missing\033[0m"
    echo
else
    source $configFile
fi


###################
## The processor ##
###################

## Go to home folder and make sure the needed directories exists
if [ ! -d "$DB_BACKUP_DIRECTORY" ]; then
	mkdir -p $DB_BACKUP_DIRECTORY
fi

if [ ! -d "$IMAGES_BACKUP_DIRECTORY" ]; then
	mkdir -p $IMAGES_BACKUP_DIRECTORY
fi


###
## Functions to backup
##	Databases
##	Images
###
function backupDatabases()
{
    # List all the databases
    DATABASES=`mysql -u $MYSQL_USER -p$MYSQL_PASS -e "SHOW DATABASES;" | tr -d "| " | grep -v "\(Database\|information_schema\|performance_schema\|mysql\|test\)"`

    ## Backup MySQL:s
    for DB in $DATABASES
    do
        BACKUP_FILE=$DB_BACKUP_DIRECTORY/${DB}.sql

        ## Dump the database
        echo
        echo " - Dumping the $DB database at $BACKUP_FILE"
        `mysqldump -u $MYSQL_USER -p$MYSQL_PASS -h $MYSQL_HOST -r $BACKUP_FILE --opt --databases $DB`

        ## Compress the sql
        echo " - Compressing & Deleting the output file"
        `gzip -f $BACKUP_FILE`

		if [ -f $BACKUP_FILE ]; then
			rm $BACKUP_FILE
		fi
    done
}

function backupImages()
{
	echo "Going to $SOURCE_PATH"
	echo

	# Sleep for 1 second
	sleep 1

	cd $SOURCE_PATH

    ## Iterate the directories to backup
    for DIR_TO_BACKUP in $DIRECTORIES_TO_BACKUP
    do
        #
        #                                                   replace / to -
        #                                           ______________    ______________
        BACKUP_FILE=$IMAGES_BACKUP_DIRECTORY/$(echo $DIR_TO_BACKUP | sed 's/\//-/g').tgz
        tar -czhvf ${BACKUP_FILE} $DIR_TO_BACKUP
    done
}

##
# Invoke all the backup functions in one sequence of commands
##
function backupAll()
{
    echo "-------------------------------"
    echo "|   STARTING BACKUP PROCESS    |"
    echo "-------------------------------"
    echo

    backupDatabases
    backupImages

    echo "-------------------------------"
    echo "|   BACKUP PROCESS FINISHED    |"
    echo "-------------------------------"
}


###
## Functions to sync
##	 Databases
##	 Images
###
function syncDatabases()
{
    ## Upload the new version
    echo " - Synchronizing files into $S3_DBS_URL"
    echo
    $S3_CMD --reduced-redundancy sync $DB_BACKUP_DIRECTORY $S3_DBS_URL

    ## Upload the file to the archive repository
    echo " - Synchronizing archive files into $S3_DB_ARCHIVES_URL"
    echo
    $S3_CMD --reduced-redundancy sync $DB_BACKUP_DIRECTORY $S3_DB_ARCHIVES_URL
}

function syncImages()
{
    ## Upload the new version
    echo " - Synchronizing files into $S3_IMAGES_URL"
    echo " - Executing $S3_CMD --reduced-redundancy sync $IMAGES_BACKUP_DIRECTORY $S3_IMAGES_URL"
    echo
    $S3_CMD --reduced-redundancy sync $IMAGES_BACKUP_DIRECTORY $S3_IMAGES_URL

    ## Upload the file to the archive repository
    echo " - Synchronizing archive files into $S3_IMAGE_ARCHIVES_URL"
    echo " - Executing $S3_CMD --reduced-redundancy sync $IMAGES_BACKUP_DIRECTORY $S3_IMAGE_ARCHIVES_URL"
    echo
    $S3_CMD --reduced-redundancy sync $IMAGES_BACKUP_DIRECTORY $S3_IMAGE_ARCHIVES_URL
}

##
# Invoke all the sync functions in one sequence of commands
##
function syncAll()
{
    echo "-------------------------------"
    echo "|    STARTING SYNC PROCESS    |"
    echo "-------------------------------"
    echo

    syncDatabases
    syncImages

    echo "-------------------------------"
    echo "|    SYNC PROCESS FINISHED    |"
    echo "-------------------------------"
}


##
# Display available commands
##
if [ $# -lt 1 ]; then
    echo "Available commands: "
    echo "  |"
    echo "  |-> backupDatabases"
    echo "  |-> backupImages"
    echo "  |-> backupAll"
    echo "  |"
    echo "  |"
    echo "  |-> syncDatabases"
    echo "  |-> syncImages"
    echo "  |-> syncAll"
    exit 1
else
    func_name="$1"
    echo
    echo "    - Invoking ${func_name} - "
    echo
    eval ${func_name}
fi
