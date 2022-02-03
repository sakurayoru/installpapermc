#!/bin/bash
echo ""
echo "create minecraft excute user"
useradd -m minecraft

echo ""
echo "package update"
dnf update -y

echo ""
echo "install vim java17 epel-release screen"
dnf -y install vim wget java-17-openjdk epel-release
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
read -r PAPERVERSION

echo ""
echo "search latest build"
BUILDNUM=$(curl https://papermc.io/api/v2/projects/paper/versions/"$PAPERVERSION" | sed 's/^\[{\(.*\)}]$/\1/' | tr ',' '\n' | tail -n1 | sed s/\]\}//)

echo ""
echo "Download paper-$PAPERVERSION-$BUILDNUM"
wget https://papermc.io/api/v2/projects/paper/versions/"$PAPERVERSION"/builds/"$BUILDNUM"/downloads/paper-"$PAPERVERSION"-"$BUILDNUM".jar -O /opt/mc/server/paper.jar
touch /opt/mc/server/paper-"$PAPERVERSION"-"$BUILDNUM"

echo ""
echo "eula true? or false?"
echo "type ture or false"
read -r mceula

if [ "$mceula" = "true" ]; then
    echo ""
    echo "eula=true" > /opt/mc/server/eula.txt
else
    echo ""
    echo "eula" > /opt/mc/server/eula.txt
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