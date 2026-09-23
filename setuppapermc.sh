#!/bin/bash
USERNAME='root'
PROJECT="paper"
USER_AGENT="cool-project/1.0.0 (contact@me.com)"
ME=$(whoami)

if [ "$ME" == "$USERNAME" ] ; then
    echo ""
    echo "create minecraft excute user"
    useradd -m minecraft

    echo ""
    echo "package update"
    dnf update -y

    echo ""
    echo "install vim epel-release screen"
    dnf -y install vim wget epel-release
    dnf -y install screen

    echo ""
    echo "create minecraft use directory"
    mkdir -p /opt/mc/{server,sh}

    echo ""
    echo "use paper base version?"
    echo "(example:1.18.1)"
    echo "(example:26.2)"
    read -r MINECRAFT_VERSION
    case "${MINECRAFT_VERSION}" in
        # Minecraft after 26.1
        26.*)
        JAVA_VERSION=25
            ;;
    
        # Minecraft 1.21.x / after 1.20.5
        1.20.[5-9]|1.20.*|1.21.*)
            JAVA_VERSION=21
            ;;
    
        # Minecraft 1.18 to 1.20.4
        1.18.*|1.19.*|1.20.0|1.20.1|1.20.2|1.20.3|1.20.4)
            JAVA_VERSION=17
            ;;
    
        # Minecraft 1.17.x
        1.17.*)
            JAVA_VERSION=16
            ;;
    
        # Minecraft before 1.16.5
        *)
            JAVA_VERSION=8
            ;;
    esac
    echo "instal openjdk-$JAVA_VERSION"
    dnf -y install java-$JAVA_VERSION-openjdk

    echo ""
    echo "Use minecraft Port No?"    
    read -r MINECRAFT_PORT
    echo "open port $MINECRAFT_PORT/tcp"
    firewall-cmd --add-port=$MINECRAFT_PORT/tcp
    firewall-cmd --runtime-to-permanent
    firewall-cmd --list-ports

    echo ""
    echo "Use MC Server name?"
    echo "example : sakurayoru => sakurayoru Minecraft Server"
    read -r MINECRAFT_NAME

    echo ""
    echo "Use MC Server seed?"
    read -r seed

    echo ""
    echo "Use MC Server difficulty?"
    read -r MCdiff



    echo "difficulty=$MCdiff"  >> /opt/mc/server/server.properties
    echo "level-seed=$seed"  >> /opt/mc/server/server.properties
    echo "motd=$MINECRAFT_NAME Minecraft Server" >> /opt/mc/server/server.properties
    echo "server-port=$MINECRAFT_PORT" >> /opt/mc/server/server.properties

    # First check if the requested version has a stable build
    BUILDS_RESPONSE=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/${PROJECT}/versions/${MINECRAFT_VERSION}/builds)
    
    # Check if the API returned an error
    if echo "$BUILDS_RESPONSE" | jq -e '.ok == false' > /dev/null 2>&1; then
        ERROR_MSG=$(echo "$BUILDS_RESPONSE" | jq -r '.message // "Unknown error"')
        echo "Error: $ERROR_MSG"
        exit 1
    fi
    
    # Try to get a stable build URL for the requested version
    PAPERMC_URL=$(echo "$BUILDS_RESPONSE" | jq -r 'first(.[] | select(.channel == "STABLE") | .downloads."server:default".url) // "null"')
    FOUND_VERSION="$MINECRAFT_VERSION"
    echo ""
    echo "FOUND_VERSION"
    echo "$FOUND_VERSION"
    # If no stable build for requested version, find the latest version with a stable build
    if [ "$PAPERMC_URL" == "null" ]; then
        echo "No stable build for version $MINECRAFT_VERSION, searching for latest version with stable build..."
      
        # Get all versions for the project (using the same endpoint structure as the "Getting the latest version" example)
        # The versions are organized by version group, so we need to extract all versions from all groups
        # Then sort them properly as semantic versions (newest first)
        VERSIONS=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/${PROJECT} | \
            jq -r '.versions | to_entries[] | .value[]' | \
            sort -V -r)
    echo ""
        # Iterate through versions to find one with a stable build
        for VERSION in $VERSIONS; do
            VERSION_BUILDS=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/${PROJECT}/versions/${VERSION}/builds)
        
            # Check if this version has a stable build
            STABLE_URL=$(echo "$VERSION_BUILDS" | jq -r 'first(.[] | select(.channel == "STABLE") | .downloads."server:default".url) // "null"')
        
            if [ "$STABLE_URL" != "null" ]; then
                PAPERMC_URL="$STABLE_URL"
                FOUND_VERSION="$VERSION"
                echo "Found stable build for version $VERSION"
                break
            fi
        done
    fi
    
    if [ "$PAPERMC_URL" != "null" ]; then
        # Download the latest Paper version
    echo ""
    echo "PAPERMC_URL"
    echo "$PAPERMC_URL"
    
    echo ""
    echo "VERSION_BUILDS"
    echo "$VERSION_BUILDS"
        curl --output /opt/mc/server/paper.jar $PAPERMC_URL
        echo "Download completed (version: $FOUND_VERSION)"
        echo "" > /opt/mc/server/$(basename "$PAPERMC_URL" .jar)

    else
        echo "No stable builds available for any version :("
        exit 1
    fi
    
    echo ""
    echo "eula true? or false?"
    echo "type ture or false"
    read -r mceula

    if [ "$mceula" = "true" ]; then
        echo ""
        echo "eula=true" > /opt/mc/server/eula.txt
    else
        echo ""
        echo "eula=false" > /opt/mc/server/eula.txt
    fi

    echo ""
    echo "copy script"
    cp start.sh /opt/mc/sh/
    cp stop.sh /opt/mc/sh/
    cp save.sh /opt/mc/sh/
    chmod +x /opt/mc/sh/start.sh
    chmod +x /opt/mc/sh/stop.sh
    chmod +x /opt/mc/sh/save.sh
    chmod +x /opt/mc/server/paper.jar

    echo ""
    echo "change owner"
    chown -R minecraft:minecraft /opt

    echo ""
    echo "copy systemd script"
    cp paper-restart.service /usr/lib/systemd/system/
    cp paper-restart.timer /usr/lib/systemd/system/
    cp paper-save.service /usr/lib/systemd/system/
    cp paper-save.timer /usr/lib/systemd/system/
    cp paper.service /usr/lib/systemd/system/

    echo ""
    echo "enable & start systemd service"
    systemctl enable paper-restart.service
    systemctl enable --now paper-restart.timer
    systemctl enable --now paper-save.service
    systemctl enable --now paper-save.timer
    systemctl enable --now paper.service
else
    echo "Please run the $USERNAME User."
    exit 0;
fi
