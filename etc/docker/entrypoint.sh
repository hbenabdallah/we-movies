#!/bin/bash

/usr/sbin/sshd

SSH_DB_IP=${SSH_DB_IP:-false}
SSH_PRV_KEY=${SSH_PRV_KEY:-false}

if [ -f /bin/entrypoint-ubuntu ]; then
    source entrypoint-ubuntu
fi

if [ -f /bin/entrypoint-php ]; then
    source entrypoint-php
fi

if [ -f /bin/entrypoint-nginx ]; then
    source entrypoint-nginx
fi

if [ "${SSH_DB_IP}" != "false" ] && [ "${SSH_PRV_KEY}" != "false" ]; then

    echo " * Creating ssh key"

    mkdir -p $HOME/.ssh
    chmod 0700 $HOME/.ssh

    # Add the keys and set permissions
    echo "Host ${SSH_DB_IP}\n\tStrictHostKeyChecking no\n" >> $HOME/.ssh/config
    echo "$SSH_PRV_KEY" > $HOME/.ssh/id_rsa

    chmod 600 $HOME/.ssh/id_rsa

    ssh-keyscan $SSH_DB_IP > $HOME/.ssh/known_hosts
fi

# Launch command
if [ "${USER_VERBOSE}" == "true" ]; then
    echo "Starting with user \"$USER_START\""
fi

sleep 2

USER_START=root

# Exec command
if [ "${GITLAB_CI}" == "true" ] && [ "${CONTAINER_SERVICE}" == "false" ]; then
    /bin/bash
elif [ "${USER_START}" == "root" ]; then
    $@
else
    /usr/local/bin/gosu $USER_START $@
fi
