#!/bin/bash

# Inserts one tile into the data store, 1 row at a time.
# Usage: ./insert [start_row_number]
# e.g. : "./insert 1" starts at the first row
#        "./insert 230" resumes from row 230

# If the connection fails, it will retry after 30 seconds. 
# You can abort it with ctrl+c

# Get your cookie string at your-app-name.appspot.com/load
COOKIE="--cookie=ACSID=AJKiYcG9LWK4UVV34IBnWo07ShnMveNNNEPlCbnVJlXyTcxd4lakTGwQJdrhqa33mo9zXXSSZK0kJRQJoTZ0c2Tki1UAiDh7IiHBZ1fQG3B2jVRfhgspGQQWQAqjZY1N0uK8vjUHpeUViCYRo8h8DTzsUBQpdBe7uuLfFQUkMAd-hM3qVTYHTEiR2cn8KWcGdQ9YjCTf7CTNb1ImIsTenS1mD61Hv_1tef-ixD00O1cZ8R0wUYBaBFq41GfKAAD_YaemUFr_6Hji8esBjrngDnFdkNXa_B3x_rusaHS3mizGIVdPXnlwwBESHbB_MvSWan6-qGU3scW442ELLmWvxOvr0m4UqQZwGQBDDPGEcxvaolgeuceUlSozobAMh5Yfu-MhdDzFOeYBgqAlHLZxUw4630wiQye7VbrBxdn7VXQKxlGBrjbJgxafyXaZYb8_A9LdCkOxpx6Y"

# If you use the offline data store, the cookie will look like this by defalt:
# COOKIE="--cookie='dev_appserver_login="test@example.com:True"'"

# Enter location of the bulk upload client on your system
BULKLOADCLIENT="/home/sjors/gapp/tools/bulkload_client.py"

# Enter location where you put your version of the App Engine application:
#APPURL="http://altitude.sprovoost.nl/load" # Returns a "Bad Gateway" error
APPURL="http://osm-route-altitude-profile.appspot.com/load"

# You can also use the local datastore:
#APPURL="http://localhost:8080/load"

for ((a=$1; a <= 1200 ; a++))
do
  SUCCESS="false"
  while [ $SUCCESS = "false" ]; do
    python import-google-apps-engine.py online $a 2> error.txt
    cat error.txt | grep KeyboardInterrupt > stop
    if [ -s stop ]; then
      echo "Keyboard Interrupt : stopping..."
      rm stop
      exit
    fi

    $BULKLOADCLIENT --filename data/tile.csv --kind Altitude --url $APPURL --batch_size 150 $COOKIE 2>> error.txt

    cat error.txt | grep KeyboardInterrupt > stop
    if [ -s stop ]; then
      echo "Keyboard Interrupt : stopping..."
      rm stop
      exit
    fi

    cat error.txt | grep "Import succcessful" > success

    if [ -s success ]; then 
      SUCCESS="true" 
      rm success
    else
      echo "An error occured! Server probably overloaded. Let's try again..."
      echo "Retry tile $a... in 30 seconds"
      sleep 30
    fi

  done
done                           # A construct borrowed from 'ksh93'.
