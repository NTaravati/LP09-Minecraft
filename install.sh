#!/bin/bash
###########################
# WELCOME
# source: https://linuxize.com/post/how-to-install-minecraft-server-on-ubuntu-18-04/
echo "We will install Minecraft server to play online"
echo "Recommendations:"
echo "- Make sure that port 19132 is whitelisted in your firewall"
echo "- Make sure that you're running the same Minecraft version on your PC"
read -p "Would you like to install Forge and OptiFine mod as well? [y/n]" OptiFiney
echo "Script last updated: 13-02-2021, v1.16.5. Source: https://www.minecraft.net/en-us/download/server/"
downloadURL="https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar" #v1.16.5, Java edition

###########################
# INITIATE SETUP
# > UPDATE SERVER
while ! echo y | apt-get update; do sleep 10 && apt-get update; done
while ! echo y | apt-get install -y software-properties-common; do sleep 10 && apt-get install -y software-properties-common;done
while ! echo y | apt-get install -y openjdk-11-jre-headless; do sleep 10 && apt-get install -y sudo apt install openjdk-11-jre-headless;done
while ! echo y | apt-get install -y gcc; do sleep 10 && apt-get install -y gcc;done

# > ALLOW FIREWALL
ufw allow 25565
ufw allow 19132 

# > CREATE FOLDERS
mkdir -p /opt/minecraft/server/
chmod a+x /opt/minecraft/server/
cd /opt/minecraft/server/

###########################
# DOWNLOAD MINECRAFT
# > SOURCE: https://www.minecraft.net/en-us/download/server/
wget $downloadURL /opt/minecraft/server/

# > AGREE WITH TERMS
touch /opt/minecraft/server/eula.txt
echo 'eula=true' >> /opt/minecraft/server/eula.txt

# > SET MINECRAFT PROPERTIES
seeds=(8638613833825887773 3227028068011494221 1777181425785 -1654510255 2327370183894455166 3427891657823464 9816485297234 321708923 -4186746847636013829 -8427444967367737379 189354817 5672120378 9176963463659858407 1013382714437321718 -1389577003656398696 -7255571058704538969 -1613247987266390429) # source: https://www.rockpapershotgun.com/best-minecraft-seeds-for-1-16-5

cat > /opt/minecraft/server/server.properties << EOF
#Minecraft server properties
allow-flight=false
allow-nether=true
announce-player-achievements=true
difficulty=1
enable-query=false
enable-rcon=true
enable-command-block=false
force-gamemode=false
gamemode=0
generate-structures=true
generator-settings=
hardcore=false
level-name=GreenHouse
level-seed=${seeds[$RANDOM%${#types[@]}]}
level-type=DEFAULT
max-build-height=256
max-build-players=20
max-tick-time=60000
max-world-size=20000000
motd=Team Green House server
network-compression-threshold=256
online-mode=true
op-permission-level=4
player-idle-timeout=60
pvp=true
query.port=25565
rcon.password=
rcon.port=25575
resource-pack=
resource-pack-hash=
server-ip=
server-port=19132
snooper-enabled=true
spawn-animals=true
spawn-monsters=true
spawn-npcs=true
spawn-protection=16
use-native-transport=true
view-distance=12
white-list=false
EOF

# > ENABLE RCON
mkdir -p /opt/minecraft/tools
git clone https://github.com/Tiiffi/mcrcon.git /opt/minecraft/mcrcon
cd /opt/minecraft/mcrcon
gcc -std=gnu11 -pedantic -Wall -Wextra -O2 -s -o mcrcon mcrcon.c
./mcrcon -h

###########################
# MINECRAFT ENABLE SERVICE
# > SET MEMORY LIMIT
totalMem=$(free -m | awk '/Mem:/ { print $2 }')
if [ $totalMem -lt 2048 ]; then
    memoryAllocs=Xms512M
    memoryAllocx=Xmx1G
else
    memoryAllocs=Xms1G
    memoryAllocx=Xmx2G
fi

# > CREATE START SCRIPT
cat > /etc/systemd/system/minecraft.service << EOF
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=root
Nice=1
KillMode=none
SuccessExitStatus=0 1
ProtectHome=true
ProtectSystem=full
PrivateDevices=true
NoNewPrivileges=true
WorkingDirectory=/opt/minecraft/server
ExecStart=/usr/bin/java -$memoryAllocx -$memoryAllocs -jar server.jar nogui
ExecStop=/opt/minecraft/mcrcon -H 127.0.0.1 -P 25575 stop

[Install]
WantedBy=multi-user.target
EOF

# > ENABLE SERVICE
systemctl daemon-reload
systemctl enable minecraft

# > RELOAD SERVICE IF DOWN
cat > /opt/startifdown.sh << EOF
#!/bin/bash
# CONTROLEER OF MINECRAFT DRAAIT, ZO NIET: START
ps -ef | grep minecraft |grep -v grep > /dev/null
if [ \$? != 0 ]; then
       /etc/init.d/minecraft start > /dev/null
fi
EOF
chmod 755 /opt/startifdown.sh

# > ADD CRONJOB
crontab -l | grep -q "/opt/startifdown.sh" && echo 'cronjob reeds toegevoegd' || crontab -l | { cat; echo "*/12 * * * * chown root:root /opt/startifdown.sh && chmod 700 /opt/startifdown.sh; /opt/startifdown.sh >/dev/null 2>&1"; } | crontab -

###########################
# SET BACKUP SCRIPT
cat > /opt/minecraft/backup.sh << EOF
#!/bin/bash
# SET DIR
mkdir -p /opt/minecraft/backups
chmod 777 /opt/minecraft/backups

# CREATE BACKUP
DATE=\$(TZ=":Europe/Amsterdam" date +"%y%m%d%H%M")
MAP="/opt/minecraft/server"
tar -cv \$MAP | gzip > "/opt/minecraft/backups/\$DATE Minecraft backup.tar.gz"

# DELETE OLDER BACKUPS
find /opt/minecraft/backups/ -type f -mtime +7 -name '*.gz' -delete
EOF
chmod 755 /opt/minecraft/backup.sh

# > BACKUP MINECRAFT TWICE A DAY
crontab -l | grep -q "/opt/minecraft/backup.sh" && echo 'cronjob reeds toegevoegd' || crontab -l | { cat; echo "15 8,16,23 * * * chown root:root /opt/minecraft/backup.sh && chmod 700 /opt/minecraft/backup.sh; /usr/bin/screen -dmS MCbackup /opt/minecraft/backup.sh >/dev/null 2>&1"; } | crontab -

###########################
# FINISH
if [[ $OptiFiney == "y" ]]; then
  source "$(dirname "${BASH_SOURCE[0]}")/mods/install.sh"
else
  echo "Installation finished. Minecraft will now be executed. The first time launching the server can take max. 15 minutes."
fi

# > RUN MINECRAFT to initiate world. Can take a while
systemctl start minecraft
systemctl status minecraft
#systemctl stop minecraft
