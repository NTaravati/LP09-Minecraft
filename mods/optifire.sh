#!/bin/bash
###########################
# WELCOME
echo "We will add Minecraft Optifire addon to enhance graphics"
systemctl stop minecraft

###########################
# INITIATE SETUP
# > DOWNLOAD MOD
/usr/bin/java /tmp/LP09-Minecraft/mods/forge-1.16.4.jar
/usr/bin/java /tmp/LP09-Minecraft/mods/OptiFine_1.16.5.jar

###########################
# FINISH
systemctl start minecraft
systemctl status minecraft