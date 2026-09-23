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
    echo "install vim java25 epel-release screen"
    dnf -y install vim wget java-25-openjdk epel-release
    dnf -y install screen

    echo ""
    echo "open port 25565/tcp"
    firewall-cmd --add-port=25565/tcp
    firewall-cmd --runtime-to-permanent
    firewall-cmd --list-ports

    echo ""
    echo "create minecraft use directory"
    mkdir -p /opt/mc/{server,sh}

    echo ""
    echo "use paper base version?"
    echo "(example:1.18.1)"
    echo "(example:26.2)"
    read -r MINECRAFT_VERSION

    # First check if the requested version has a stable build
    BUILDS_RESPONSE=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/${PROJECT}/versions/${MINECRAFT_VERSION}/builds)
    echo ""
    echo "BUILDS_RESPONSE"
    echo "$BUILDS_RESPONSE"
    
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
        BUILD = $(basename "$PAPERMC_URL" .jar)
        touch /opt/mc/server/paper-"$BUILD"
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
