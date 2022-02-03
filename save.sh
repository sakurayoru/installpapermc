#!/bin/sh

USERNAME='minecraft'
SERVICE='paper'
SPI_PATH='/opt/mc/server/'
NOW=$(date '+%H:%M:%S')

cd $SPI_PATH || exit
 
ME=$(whoami)
 
if [ "$ME" = $USERNAME ] ; then
  if pgrep -u $USERNAME -f $SERVICE > /dev/null
    then
      screen -p 0 -S $SERVICE -X eval 'stuff "save-all"\015'
      echo "$NOW Saved $SERVICE"
      exit 0;
    else
      echo "$SERVICE was not runnning."
      exit 0;
  fi
else
  echo "Please run the" $USERNAME "user."
  exit 0;
fi

