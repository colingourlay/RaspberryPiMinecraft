#!/bin/bash
# Author: James A. Chambers - https://jamesachambers.com/
# More information at https://jamesachambers.com/raspberry-pi-minecraft-server-script-with-startup-service/
# GitHub Repository: https://github.com/TheRemote/RaspberryPiMinecraft
# Minecraft Server stop script - primarily called by minecraft service but can be ran manually with ./stop.sh

# Set path variable
USERPATH="pathvariable"
PathLength=${#USERPATH}
if [[ "$PathLength" -gt 12 ]]; then
    PATH="$USERPATH"
else
    echo "Unable to set path variable.  You likely need an updated version of SetupMinecraft.sh from GitHub!"
fi

# Check to make sure we aren't running as root
if [[ $(id -u) = 0 ]]; then
   echo "This script is not meant to run as root or sudo.  Please run as a normal user with ./stop.sh.  Exiting..."
   exit 1
fi

# Check if server is running
if ! screen -list | grep -q "\.minecraft"; then
  echo "Server is not currently running!"
  exit 1
fi

# Stop the server
echo "Stopping Minecraft server ..."
screen -Rd minecraft -X stuff "say Closing server (stop.sh called)...$(printf '\r')"
screen -Rd minecraft -X stuff "stop$(printf '\r')"

# Wait up to 30 seconds for server to close
StopChecks=0
while [ $StopChecks -lt 30 ]; do
  if ! screen -list | grep -q "\.minecraft"; then
    break
  fi
  sleep 1;
  StopChecks=$((StopChecks+1))
done

# Force quit if server is still open
if screen -list | grep -q "\.minecraft"; then
  echo "Minecraft server still hasn't closed after 30 seconds, closing screen manually"
  screen -S minecraft -X quit
fi

echo "Minecraft server stopped."

# Sync all filesystem changes out of temporary RAM
sync
