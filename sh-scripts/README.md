About
=====

Here is my collection of scripts that I wrote to help me sync some files between some servers, through AWS S3.
But, just to mention, S3 is obviously not mandatory... you can use `rsync` or whatever tool you'd like.


Required tools
==============

 - s3cmd (http://s3tools.org/s3cmd)
 - AWS S3 bucket


Available commands
==================

### backup.sh

    |-> backupDatabases
    |-> backupImages
    |-> backupAll
    |
    |
    |-> syncDatabases
    |-> syncImages
    |-> syncAll


### deploy.sh

    |-> syncDatabases
    |-> syncImages
    |-> syncAll
    |
    |
    |-> deployDatabases
    |-> deployImages
    |-> deployAll
    |
    |-> daSQL

### daSQL

    - createDB [dbname]
    - dropDB [dbname]
    - listDBs
    - console
    - populateSoft [dbname] [file]  # This just imports an sql file
    - populateHard [dbname] [file]  # This deletes the database, creates it again
                                    # and then imports the sql file


How-to
======

### 1.
You'll have to configure `s3cmd` on the servers where you want to execute `backup.sh` and `deploy.sh`,
in order to establish a connection with your S3 service.
I've used IAM policies, and have created a user that only has access to my backups bucket on S3,
and then executed `s3cmd --configure` to type in that user's access credentials.

### 2.
Copy `config-base.sh` to `config.sh`, on each server, and adjust it's parameters with the ones that
fit your environment's configuration.

### 3.
The designed flow, is to run `backup.sh` script on the server hosting the original files,
either manually or having crontabs to automate the process, i.e.:

    @daily /home/user/resources/sh-scripts/backup.sh backupDatabases > /home/user/resources/sh-scripts/bdb_output.log 2>&1
    @daily /home/user/resources/sh-scripts/backup.sh syncDatabases > /home/user/resources/sh-scripts/sbd_output.log 2>&1

And then having `deploy.sh` on the destination server, in order to sync files from S3.

### 4.
Extra utility in `deploy.sh` is the `daSQL` command, which basically is a helper to save time onto executing common `MySQL` commands.

### 5.
You can either setup an alias towards the path of the scripts, i.e.:

    alias backup.sh='/home/user/resources/sh-scripts/backups.sh'

Or having a symlink for it into your `/usr/local/bin` directory, i.e.:

    ln -s /home/user/resources/sh-scripts/staging.sh /usr/local/bin/staging.sh

And for the daSQL, I personally have an alias:

    alias daSQL='staging.sh daSQL'
