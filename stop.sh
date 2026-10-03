#!/bin/bash

USERNAME='minecraft'
SERVICE='paper'

echo "DEBUG: start"

ME=$(whoami)
echo "DEBUG: whoami=$ME"

if [ "$ME" = "$USERNAME" ] ; then
    echo "DEBUG: user OK"

    echo "DEBUG: screen list"
    screen -list

    if (screen -list | grep -o "${SERVICE}") > /dev/null ; then
        echo "DEBUG: found screen: $SERVICE"
        echo "Stopping $SERVICE"

        echo "DEBUG: sending 30sec message"
        screen -p 0 -S "$SERVICE" -X eval 'stuff "say あと30秒でサーバーが停止します。\015"'

        echo "DEBUG: sending discordsrv"
        screen -p 0 -S "$SERVICE" -X eval 'stuff "discordsrv bcast あと30秒でサーバーが停止します。\015"'

        echo "DEBUG: sleep 10"
        sleep 10

        echo "DEBUG: sending 20sec message"
        screen -p 0 -S "$SERVICE" -X eval 'stuff "say あと20秒でサーバーが停止します。\015"'

        sleep 10

        echo "DEBUG: sending final message"
        screen -p 0 -S "$SERVICE" -X eval 'stuff "say まもなくサーバーが停止します。\015"'

        echo "DEBUG: save-off"
        screen -p 0 -S "$SERVICE" -X eval 'stuff "save-off\015"'

        echo "DEBUG: save-all"
        screen -p 0 -S "$SERVICE" -X eval 'stuff "save-all flush\015"'

        sleep 10

        echo "DEBUG: sending stop"
        screen -p 0 -S "$SERVICE" -X eval 'stuff "stop\015"'

        echo "DEBUG: waiting for screen"

        for i in {1..12}
        do
          if ! screen -list | grep -q "${SERVICE}"; then
            echo "Stopped $SERVICE server"
            exit 0
          fi
        sleep 5
        done

        echo "ERROR: Timed out waiting for $SERVICE server to stop"
        exit 1

        echo "DEBUG: screen stopped"
        echo "Stopped $SERVICE server"
        exit 0

    else
        echo "$SERVICE was not running."
        exit 0
    fi
else
    echo "Please run the $USERNAME user."
    exit 0
fi
