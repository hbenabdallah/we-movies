#!/bin/bash

CONTAINER_SERVICE=${CONTAINER_SERVICE:-false}
USER_ID=${UID:-1000}
USER_NAME=${USER_NAME:-"user"}
USER_START=${USER_START:-$USER_NAME}
USER_VERBOSE=${USER_VERBOSE:-false}
USER_SHELL=${SHELL:-"/bin/bash"}

# Validate CONTAINER_SERVICE
if [ "${CONTAINER_SERVICE}" != "true" ] && [ "${CONTAINER_SERVICE}" != "false" ]; then
    echo "ERROR: "
    echo "  Variable CONTAINER_SERVICE isn't valid ! (Values accepted : true/false)"
    exit 1
fi

# Validate USER_VERBOSE
if [ "${USER_VERBOSE}" != "true" ] && [ "${USER_VERBOSE}" != "false" ]; then
    echo "ERROR: "
    echo "  Variable USER_VERBOSE isn't valid ! (Values accepted : true/false)"
    exit 1
fi

# Define user
# Force root in GITLAB CI because doesn't support gosu
if [ "${USER_ID}" == 0 ] || [ "${GITLAB_CI}" == "true" ]; then

    HOME="/root"
    USER_NAME=root
    USER_START=root

else

    # Create user $USER_NAME
    if [ "${USER_VERBOSE}" == "true" ]; then
        echo "Create user \"$USER_NAME\" with UID \"$USER_ID\""
    fi

    useradd --shell $USER_SHELL -u $USER_ID -o -c "" -M $USER_NAME

    # Load Home
    HOME="/home/$USER_START"
    mkdir -p $HOME

fi

# Create env variable
export HOME=$HOME
export USER_NAME=$USER_NAME
export USER_START=$USER_START

# Load home files
cp -rf /data/home-files/. $HOME/
chown -R $USER_NAME:$USER_NAME $HOME

# Start periodic command scheduler cron
service cron start &
