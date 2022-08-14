#!/usr/bin/env bash

set -eu
umask 004

echo "Configuring wine"
mkdir -p /opt/app-root/winedata/WINE64 >/dev/null
pushd /opt/app-root/winedata >/dev/null
winecfg >/dev/null 2>&1
popd >/dev/null
sleep 15

echo "Generating server config (${GAMEDIR}/config.cfg)"
cat >${GAMEDIR}/config.cfg <<EOF
// Dedicated Server Settings.
// Server IP address - Note: If you have a router, this address is the internal address, and you need to configure ports forwarding, append the current game port here as well
serverIP ${SERVER_IP}
// Steam Communication Port - Note: If you have a router you will need to open this port.
serverSteamPort ${STEAM_PORT-8766}
// Game Communication Port - Note: If you have a router you will need to open this port.
serverGamePort ${GAME_PORT-27015}
// Query Communication Port - Note: If you have a router you will need to open this port.
serverQueryPort ${QUERY_PORT-27016}
// Server display name
serverName ${SERVER_NAME-"The Forest Game"}
// Maximum number of players
serverPlayers ${SERVER_PLAYERS-8}
// Server password. blank means no password
serverPassword ${SERVER_PASSWORD:-""}
// Server administration password. blank means no password
serverPasswordAdmin ${SERVER_PASSWORD_ADMIN:-""}
// Your Steam account name. blank means anonymous (see Steam server account bellow)
serverSteamAccount ${SERVER_STEAM_ACCOUNT:-""}
// Enable VAC (Valve Anti Cheat) on the server. off by default, uncomment to enable
enableVAC ${ENABLE_VAC:-""}
// Time between server auto saves in minutes
serverAutoSaveInterval ${SERVER_AUTO_SAVE_INTERVAL-15}
// Game difficulty mode. Must be set to "Peaceful" "Normal" or "Hard"
difficulty ${DIFFICULTY-"Normal"}
// New or continue a game. Must be set to "New" or "Continue"
initType ${INIT_TYPE-"New"}
// Slot to save the game. Must be set 1 2 3 4 or 5
slot ${SLOT-1}
// Show event log. Must be set "off" or "on"
showLogs ${SHOW_LOGS-"off"}
// Contact email for server admin
serverContact ${SERVER_CONTACT-"email@gmail.com"}
// No enemies. Must be set to "on" or "off"
veganMode ${VEGAN_MODE-"off"}
// No enemies during day time. Must be set to "on" or "off"
vegetarianMode ${VEGETARIAN_MODE-"off"}
// Reset all structure holes when loading a save. Must be set to "on" or "off"
resetHolesMode ${RESET_HOLES_MODE-"off"}
// Regrow 10% of cut down trees when sleeping. Must be set to "on" or "off"
treeRegrowMode ${TREE_REGROW_MODE-"off"}
// Allow building destruction. Must be set to "on" or "off"
allowBuildingDestruction ${ALLOW_BUILDING_DESTRUCTION-"on"}
// Allow enemies in creative games. Must be set to "on" or "off"
allowEnemiesCreativeMode ${ALLOW_ENEMIES_CREATIVE_MODE-"off"}
// Allow clients to use the built in development console. Must be set to "on" or "off"
allowCheat ${ALLOW_CHEAT-"off"}
// Allows defining a custom folder for save slots, leave empty to use the default location
saveFolderPath ${SAVE_FOLDER_PATH-"${APPDATA}"}
// Target FPS when no client is connected
targetFpsIdle ${TARGET_FPS_IDLE-5}
// Target FPS when there is at least one client connected
targetFpsActive ${TARGET_FPS_ACTIVE-60}
EOF

echo "Starting server via xvfb-run, wine, and ${GAMEDIR}/TheForestDedicatedServer.exe"
xvfb-run --server-num 1 --auto-servernum --server-args='-screen 0 640x480x24:32' wine64 ${GAMEDIR}/TheForestDedicatedServer.exe -savefolderpath "${APPDATA}" -configfilepath "${GAMEDIR}/config.cfg" $@ &
BPID=$!

function _int() {
   echo "Stopping container."
   echo "SIGINT received, shutting down server!"
   kill -9 ${BPID}
   wait ${BPID}
   exit 0
}

# Set SIGINT handler
trap _int SIGINT

# Set SIGTERM handler
trap _int SIGTERM

wait ${BPID}