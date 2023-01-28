#!/bin/bash
cd /server/ || exit 1
if [ ! -e "valheim_server.x86_64" ]; then
    # shellcheck disable=SC2086
    /steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType linux +force_install_dir "/server/" +login anonymous +app_update 896660 $STEAMCMD_ARGS +quit
fi


export templdpath=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
export SteamAppId=892970

export tempboxldpath=$BOX64_LD_LIBRARY_PATH
export BOX64_LD_LIBRARY_PATH=./linux64:./valheim_server_Data/MonoBleedingEdge/x86_64:./valheim_server_Data/Plugins:/steamcmd/linux64:/steamcmd/linux32:$BOX64_LD_LIBRARY_PATH

# Tip: Make a local copy of this script to avoid it being overwritten by steam.
# NOTE: Minimum password length is 5 characters & Password cant be in the server name.
# NOTE: You need to make sure the ports 2456-2458 is being forwarded to your server through your local router & firewall.
# shellcheck disable=SC2086
/usr/local/bin/box64 ./valheim_server.x86_64 -nographics -batchmode -name "${SERVERNAME:-Dedicated}" -port "${PORT:-2456}" -world "${WORLDNAME:-world}" -public "${ISPUBLIC:-0}" ${EXTRAARGS}

export BOX64_LD_LIBRARY_PATH=$tempboxldpath
export LD_LIBRARY_PATH=$templdpath
