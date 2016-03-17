#!/bin/bash

##
## Sync backup data and deploy it
##
## - AUTHOR:  Alexandru Budurovici
## - VERSION: 1.4
##
## Changelog:
##   1.0 - Initial release.
##   1.1 - Migrated towards a more functional way. Every action has its own function now
##   1.2 - Script now includes a config file, instead of running custom config
##   1.3 - Added daSQL helper function, for common MySQL commands
##       - Added confirm helper function, that allows to run a confirmation before a command
##   1.4 - Added the option to process individual databases
##       - Renamed deployClones to deployAll
##       - Added deployImages
##
##

###
## @TODO:
##  - Convert this into a web actionable interface, to force some process when needed
###

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

###
## Functions to sync
##   Databases
##   Images
###
function syncDatabases()
{
    echo " - Make sure $DB_BACKUP_DIRECTORY exists"
    echo
    mkdir -p $DB_BACKUP_DIRECTORY

    echo " - Synchronizing files from $S3_DBS_URL to $DB_BACKUP_DIRECTORY"
    echo
    $S3_CMD sync $S3_DBS_URL $DB_BACKUP_DIRECTORY
}

function syncImages()
{
    echo " - Make sure $IMAGES_BACKUP_DIRECTORY exists"
    echo
    mkdir -p $IMAGES_BACKUP_DIRECTORY

    echo " - Synchronizing files from $S3_IMAGES_URL to $IMAGES_BACKUP_DIRECTORY"
    echo
    $S3_CMD sync $S3_IMAGES_URL $IMAGES_BACKUP_DIRECTORY
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


###
## Functions to deploy
##   Databases
##   Images
###
function deployDatabases()
{
    cd $DB_BACKUP_DIRECTORY
    
    databases=`ls`
    
    echo "Choose which database or databases you would like to deploy from the following list, by typing its exact name or leave blank to process all"
    echo
    for database in $databases; do
        echo " - $database"
    done;
    echo

    echo -n "Type in your choice or choices, separated by whitespace: "
    echo
    
    read -e -a options

    if [ ${#options[*]} == 0 ]; then
        echo "Processing all databases"
        echo
        for SQL in $(ls *.gz);
        do
            # Process the .sql files
            echo " - Processing $SQL"
            echo
            zcat $SQL | mysql -u $MYSQL_USER -p$MYSQL_PASS
        done
    else
        echo
        echo "${#options[*]} database(s) to process"
        echo
        for database in ${options[*]}; do
            # Process the .sql files
            echo " - Processing $database"
            echo
            zcat $database | mysql -u $MYSQL_USER -p$MYSQL_PASS
        done
    fi
   
    echo " All done!"

    exit $?
}

function deployImages()
{
    cd $IMAGES_BACKUP_DIRECTORY

    for imagesArchive in $(ls *.tgz);
    do
        tar -xvf $imagesArchive
        echo
        #if [ -z "$3" && $3 == "" ]; then
        #read -p "Do you want to remove $imagesArchive? (y/n)" option
        #if [ $option = "y" ]; then
            rm $imagesArchive
        #fi
    done
}


##
# Invoke all the deploy functions in one sequence of commands
##
function deployAll()
{
    echo "---------------------------------"
    echo "|  STARTING DEPLOYMENT PROCESS  |"
    echo "---------------------------------"
    echo

    deployDatabases
    deployImages

    echo
    echo "---------------------------------"
    echo "|  DEPLOYMENT PROCESS FINISHED  |"
    echo "---------------------------------"
}


##
# Helper to run faster through some mysql commands
##
function daSQL()
{
    mySQL="mysql -u $MYSQL_USER -p$MYSQL_PASS"

    if [ -z "$1" ]; then
        echo "List of available commands: "
        echo "   - createDB [dbname]"
        echo "   - dropDB [dbname]"
        echo "   - listDBs"
        echo "   - console"
        echo "   - populateSoft [dbname] [file]  # This just imports an sql file"
        echo "   - populateHard [dbname] [file]  # This deletes the database, creates it again"
        echo "                                   # and then imports the sql file"
        echo
        exit 1
    fi

    if [ "$1" == 'listDBs' ]; then
        $mySQL -e "SHOW DATABASES;"
        exit $?
    fi

    if [ "$1" == 'console' ]; then
        $mySQL
    fi

    if [ ! -z "$2" ]; then
        if [ "$1" == 'createDB' ]; then
            $mySQL -e "CREATE DATABASE $2 CHARACTER SET utf8 COLLATE utf8_general_ci;"
            exit $?
        fi

        if [ "$1" == 'dropDB' ]; then
            confirm "Drop $2 database?" && $mySQL -e "DROP DATABASE $2;"
            exit $?
        fi
    
        if [ ! -z "$3" ]; then
            if [ "$1" == 'populateSoft' ]; then
                $mySQL $2 < $3
                exit $?
            fi
            
            if [ "$1" == 'populateHard' ]; then
                confirm "Populate hard $2? " && daSQL dropDB $2;
                daSQL createDB $2;
                daSQL populateSoft $2 $3;
                exit $?
            fi
        else
            echo "Missing 3rd argument"
            exit 2
        fi
    else
        echo "Missing 2nd argument"
        exit 2
    fi
}

##
# Helper for confirmations
##
confirm ()
{
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}


##
# Display available commands
##
if [ $# -lt 1 ]; then
    echo "Available commands: "
    echo "  |"
    echo "  |-> syncDatabases"
    echo "  |-> syncImages"
    echo "  |-> syncAll"
    echo "  |"
    echo "  |"
    echo "  |-> deployDatabases"
    echo "  |-> deployImages"
    echo "  |-> deployAll"
    echo "  |"
    echo "  |-> daSQL"
    exit 1
else
    func_name="$1"
    echo
    echo "    - Invoking ${func_name} - "
    echo
    eval ${func_name} $2 $3
fi
