#!/usr/bin/env bash
# Variables
name_folder="/home/steam/steamapps/DST/bin"
screen_master="Master"
screen_caves="Caves"

# Script Variables
servershards=(${screen_master} ${screen_caves})

# Functions
function restart_server {
# this has to be run separate as the caves server should never come online before the master server.
kill_server ${screen_master}
kill_server ${screen_caves}
start_server ${screen_master}
start_server ${screen_caves}
}

function kill_server {
# $1 is screen name
screen -dr $1 -X -S quit
}

function update_steam {
cd /home/steam
/home/steam/steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/steam/steamapps/DST +app_update 343050 validate +quit
}

function update_server {
# $1 is shard name
./dontstarve_dedicated_server_nullrenderer -console -cluster MyDediServer -shard $1 -only_update_server_mods
}

function start_server {
# $1 is screen name and shard name
cd ${name_folder}
screen -dmS $1 ./dontstarve_dedicated_server_nullrenderer -console -cluster MyDediServer -shard $1
}

# The actual script
script /dev/null

# quit the current running servers
echo "Stopping running server"
sleep 2
for i in "${servershards[@]}"
    do
        kill_server ${i}
    done

# copy mod installation file to make sure all mods will be downloaded
echo "Copying fresh mod config to cluster"
cp /home/steam/steamapps/DST/mods/dedicated_server_mods_setup.lua.bak /home/steam/steamapps/DST/mods/dedicated_server_mods_setup.lua
# copy the override file to the server shards
cp /home/steam/steamapps/DST/mods/modoverrides.lua /home/steam/.klei/DoNotStarveTogether/MyDediServer/Master/modoverrides.lua
cp /home/steam/steamapps/DST/mods/modoverrides.lua /home/steam/.klei/DoNotStarveTogether/MyDediServer/Caves/modoverrides.lua
sleep 1

# Update the mods
echo "Update the server mods"
for i in "${servershards[@]}"
    do
        update_server ${i}
    done

# Let the steam client update the game itself
echo "Updating the game server"
update_steam
sleep 1

# sleep waiting for the steam client to have updated everything
echo "Starting the game server"
sleep 10

for i in "${servershards[@]}"
    do
        start_server ${i}
    done