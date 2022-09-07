#!/bin/bash

# Ubuntu configuration
USER_NAME=${USER_NAME:-user}

# PHP Configuration
PHP_TIMEZONE=${PHP_TIMEZONE:-Europe/Paris}
PHP_XDEBUG_ENABLE=${PHP_XDEBUG_ENABLE:-false}
PHP_XDEBUG_REMOTE_HOST=${PHP_XDEBUG_REMOTE_HOST:-172.17.0.1}
PHP_XDEBUG_REMOTE_PORT=${PHP_XDEBUG_REMOTE_PORT:-9000}
PHP_XDEBUG_SESSION_KEY=${PHP_XDEBUG_SESSION_KEY:-XDEBUG}
PHP_DISPLAY_ERRORS=${PHP_DISPLAY_ERRORS:-false}
PHP_FPM_LOG_PATH=${PHP_FPM_LOG_PATH:-/dev/stdout}

# Checking PHP Timezone
if [[ ! "${PHP_TIMEZONE}" =~ ^[A-Z]{1}[a-z]+/[A-Z]{1}[a-z]+$ ]]; then
    echo "ERROR: "
    echo "  Variable PHP_TIMEZONE isn't valid ! (Format accepted : [A-Z]{1}[a-z]+/[A-Z]{1}[a-z]+)"
    exit 1
fi

# Checking PHP Xdebug Enable
if [ "${PHP_XDEBUG_ENABLE}" != "true" ] && [ "${PHP_XDEBUG_ENABLE}" != "false" ]; then
    echo "ERROR: "
    echo "  Variable PHP_XDEBUG_ENABLE isn't valid ! (Values accepted : true/false)"
    exit 1
fi

# Checking PHP Display Errors
if [ "${PHP_DISPLAY_ERRORS}" != "true" ] && [ "${PHP_DISPLAY_ERRORS}" != "false" ]; then
    echo "ERROR: "
    echo "  Variable PHP_DISPLAY_ERRORS isn't valid ! (Values accepted : true/false)"
    exit 1
fi

# Fix USER_NAME with UID 0
if [ "${USER_ID}" == "0" ]; then
    USER_NAME=root
fi

# Config PHP Timezone
sed -i "s|;date.timezone =.*|date.timezone = ${PHP_TIMEZONE}|g" /etc/php/${PHP_VERSION}/cli/php.ini
sed -i "s|;date.timezone =.*|date.timezone = ${PHP_TIMEZONE}|g" /etc/php/${PHP_VERSION}/fpm/php.ini

# Config user
sed -i "s|^user =.*|user = $USER_NAME|g" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
sed -i "s|^group =.*|group = $USER_NAME|g" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

# Configura PHP FPM Logs
sed -i "s|error_log = .*|error_log = ${PHP_FPM_LOG_PATH}|g" /etc/php/${PHP_VERSION}/fpm/php-fpm.conf

# Configura PHP FPM
sed -i "s|{PHP_VERSION}|${PHP_VERSION}|g" /etc/php/${PHP_VERSION}/fpm/php-fpm.conf

# Configura PHP Xdebug
if [ "${PHP_XDEBUG_ENABLE}" == "false" ]; then
    rm -f /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini
    rm -f /etc/php/${PHP_VERSION}/fpm/conf.d/20-xdebug.ini
else
    export XDEBUG_CONFIG="idekey=${PHP_XDEBUG_SESSION_KEY}"
    echo 'export XDEBUG_CONFIG="idekey=${PHP_XDEBUG_SESSION_KEY}"' >> /data/home-files/.bashrc

    # Configure xdebug to cli
    sed -i "s|PHP_XDEBUG_REMOTE_HOST|${PHP_XDEBUG_REMOTE_HOST}|" /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini
    sed -i "s|PHP_XDEBUG_REMOTE_PORT|${PHP_XDEBUG_REMOTE_PORT}|" /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini
    sed -i "s|PHP_XDEBUG_SESSION_KEY|${PHP_XDEBUG_SESSION_KEY}|" /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini
    # Configure xdebug to fpm
    sed -i "s|PHP_XDEBUG_REMOTE_HOST|${PHP_XDEBUG_REMOTE_HOST}|" /etc/php/${PHP_VERSION}/fpm/conf.d/20-xdebug.ini
    sed -i "s|PHP_XDEBUG_REMOTE_PORT|${PHP_XDEBUG_REMOTE_PORT}|" /etc/php/${PHP_VERSION}/fpm/conf.d/20-xdebug.ini
    sed -i "s|PHP_XDEBUG_SESSION_KEY|${PHP_XDEBUG_SESSION_KEY}|" /etc/php/${PHP_VERSION}/fpm/conf.d/20-xdebug.ini
fi

# Configura PHP Display Errors
if [ "${PHP_DISPLAY_ERRORS}" == "true" ]; then
    sed -i "s|display_errors =.*|display_errors = On|g" /etc/php/${PHP_VERSION}/cli/php.ini
    sed -i "s|display_errors =.*|display_errors = On|g" /etc/php/${PHP_VERSION}/fpm/php.ini
else
    sed -i "s|display_errors =.*|display_errors = Off|g" /etc/php/${PHP_VERSION}/cli/php.ini
    sed -i "s|display_errors =.*|display_errors = Off|g" /etc/php/${PHP_VERSION}/fpm/php.ini
fi

# If ubuntu default user is loaded as root, allow php-fpm worker started as root
if [ "${USER_NAME}" == "root" ]; then
    COMMAND="php-fpm --allow-to-run-as-root"
else
    # Load logs permissions
    if [ "${PHP_FPM_LOG_PATH}" != "/dev/stdout" ]; then
        if [ ! -f "${PHP_FPM_LOG_PATH}" ]; then
            mkdir -p "$(dirname "$PHP_FPM_LOG_PATH")"
            touch $PHP_FPM_LOG_PATH
        fi

        chown -R $USER_NAME:$USER_NAME "$(dirname "$PHP_FPM_LOG_PATH")"
    fi

    COMMAND="php-fpm"
fi

# Start nginx
echo " * Starting php-fpm"
/usr/bin/$COMMAND -D
