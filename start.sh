#!/bin/bash

USERNAME='minecraft'
JARFILE='paper.jar'
SERVICE='paper'
SPI_PATH='/opt/mc/server/'
ME=$(whoami)
MEM="2G"

if [ "$ME" = "$USERNAME" ] ; then
  if (screen -list | grep -o "${SERVICE}") > /dev/null ; then
    echo "$SERVICE is already running!"
    exit 0;
  else
    sleep 5
    cd $SPI_PATH || exit
    pwd
    screen -AmdS $SERVICE java -server -Xmx$MEM -Xms$MEM -jar $JARFILE nogui
  fi
else
  echo "Please run the" $USERNAME "user."
  exit 0;
fi

