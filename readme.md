## How to install Minecraft on Ubuntu v20.04?
With this installer, you'll be able to install Minecraft server on Ubuntu v20.04 without programming. A seed from the most popular worlds will be chosen to setup your game. With a simple monitor, the status of your server will be checked every 12 minutes. When down, the monitor will automatically start your Minecraft server again. This script is inspired by the tutorial provided at <a href="https://linuxize.com/post/how-to-install-minecraft-server-on-ubuntu-18-04/">linuxize.com</a>. Follow the commands below to initiate the setup. 

````
sudo su
rm -fr /tmp/LP09-Minecraft
git clone https://github.com/NTaravati/LP09-Minecraft /tmp/LP09-Minecraft
chmod a+x -R /tmp/LP09-Minecraft
/tmp/LP09-Minecraft/./install.sh

````

## Restore backups
Your Minecraft server will create a snapshot everyday at 8:15, 16:15 and 23:15. Back-ups are saved in /opt/minecraft/backups. Backups older than 7 days will be automatically deleted. With the following commands, you can recover a backup.

```

```

## Folder structure and understanding the script
The Minecraft server is installed within the following directories:
```
- /opt/minecraft/server 
- /opt/minecraft/mcrcon
- /opt/minecraft/backuos
```

The following cronjobs are installed:

```
15 8,16,23 * * * chown root:root /opt/minecraft/backup.sh && chmod 700 /opt/minecraft/backup.sh; /usr/bin/screen -dmS MCbackup /opt/minecraft/backup.sh >/dev/null 2>&1
*/12 * * * * chown root:root /opt/minecraft/startifdown.sh && chmod 700 /opt/minecraft/startifdown.sh; /opt/minecraft/startifdown.sh >/dev/null 2>&1
```

To start, stop or restart your Minecraft server, please run the following commands.

```
systemctl start minecraft
systemctl stop minecraft
systemctl restart minecraft
systemctl status minecraft
```

## Recommended server settings
Please use a server with at least 2 GB ram. AWS Lightsail and DigitalOcean offers various plans to start your server for just $10/month with plenty of storage, bandwidth and CPU power to run your server with a maximum of 20 players. 