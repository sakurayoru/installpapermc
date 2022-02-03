#!/bin/bash

USERNAME='minecraft'
SERVICE='paper'

ME=$(whoami)

if [ "$ME" == "$USERNAME" ] ; then
  if (screen -list | grep -o "${SERVICE}") > /dev/null ; then
    echo "Stopping $SERVICE"
    screen -p 0 -S $SERVICE -X eval 'stuff "say あと30秒でサーバーが停止します。"\015'
    screen -p 0 -S $SERVICE -X eval 'stuff "discordsrv bcast あと30秒でサーバーが停止します。"\015'
    sleep 10
    screen -p 0 -S $SERVICE -X eval 'stuff "say あと20秒でサーバーが停止します。"\015'
    sleep 10
    screen -p 0 -S $SERVICE -X eval 'stuff "say まもなくサーバーが停止します。"\015'
    screen -p 0 -S $SERVICE -X eval 'stuff "save-off"\015'
    screen -p 0 -S $SERVICE -X eval 'stuff "save-all flush"\015'
    sleep 10
    screen -p 0 -S $SERVICE -X eval 'stuff "stop"\015'
    sleep 10
    while [ -n "$(screen -list | grep -o "${SERVICE}")" ]
      do
        screen -p 0 -S $SERVICE -X eval 'stuff ""\015'
        sleep 5
    done
    echo "Stopped $SERVICE server"
    exit 0;
  else
    echo "$SERVICE was not runnning."
    exit 0;
  fi
else
  echo "Please run the" $USERNAME "user."
  exit 0;
fi

