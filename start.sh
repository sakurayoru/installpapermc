#!/bin/bash

USERNAME='minecraft'
JARFILE='paper.jar'
SERVICE='paper'
PAPER_OPTION='-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true'
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

