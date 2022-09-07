#!/bin/bash

# Ubuntu configuration
USER_NAME=${USER_NAME:-user}

# NGINX Configuration
NGINX_LOG_ACCESS_PATH=${NGINX_LOG_ACCESS_PATH:-/dev/stdout}
NGINX_LOG_ERROR_PATH=${NGINX_LOG_ERROR_PATH:-/dev/stdout}
NGINX_VHOST_ROOT=${NGINX_VHOST_ROOT:-public}
NGINX_VHOST_FRONTAL_FILE=${NGINX_VHOST_FRONTAL_FILE:-index.php}
NGINX_VHOST_PHP_FPM=${NGINX_VHOST_PHP_FPM:-true}
NGINX_VHOST_PHP_FPM_HOST=${NGINX_VHOST_PHP_FPM_HOST:-localhost}
NGINX_VHOST_PHP_FPM_PORT=${NGINX_VHOST_PHP_FPM_PORT:-9000}
NGINX_VHOST_DOC=${NGINX_VHOST_DOC:-false}
NGINX_VHOST_DOC_SUBFOLDER=${NGINX_VHOST_DOC_SUBFOLDER:-doc}
NGINX_VHOST_DOC_FRONTAL_FILE=${NGINX_VHOST_DOC_FRONTAL_FILE:-index.html}
NGINX_VHOST_DOC_VERSIONS=${NGINX_VHOST_DOC_VERSIONS:-v1}

# Checking Nginx Vhost PHP Configuration
if [ "${NGINX_VHOST_PHP_FPM}" != "true" ] && [ "${NGINX_VHOST_PHP_FPM}" != "false" ]; then
    echo "ERROR: "
    echo "  Variable NGINX_VHOST_PHP_FPM isn't valid ! (Values accepted : true/false)"
    exit 1
fi

# Checking Nginx Vhost Doc Configuration
if [ "${NGINX_VHOST_DOC}" != "true" ] && [ "${NGINX_VHOST_DOC}" != "false" ]; then
    echo "ERROR: "
    echo "  Variable NGINX_VHOST_DOC isn't valid ! (Values accepted : true/false)"
    exit 1
fi

# Load config nginx
sed -i "s|USER_NAME|$USER_NAME|" /etc/nginx/nginx.conf
sed -i "s|NGINX_LOG_ACCESS_PATH|$NGINX_LOG_ACCESS_PATH|" /etc/nginx/nginx.conf
sed -i "s|NGINX_LOG_ERROR_PATH|$NGINX_LOG_ERROR_PATH|" /etc/nginx/nginx.conf

# Load vhost
if [ "${NGINX_VHOST_ROOT}" != "" ]; then
    sed -i "s|NGINX_VHOST_ROOT|/src/$NGINX_VHOST_ROOT|" /etc/nginx/sites-enabled/default.conf
    sed -i "s|NGINX_VHOST_ROOT|/src/$NGINX_VHOST_ROOT|" /etc/nginx/sites-enabled/default-ssl.conf
else
    sed -i "s|NGINX_VHOST_ROOT|/src|" /etc/nginx/sites-enabled/default.conf
    sed -i "s|NGINX_VHOST_ROOT|/src|" /etc/nginx/sites-enabled/default-ssl.conf
fi
sed -i "s|NGINX_VHOST_FRONTAL_FILE|$NGINX_VHOST_FRONTAL_FILE|" /etc/nginx/sites-enabled/default.conf
sed -i "s|NGINX_VHOST_FRONTAL_FILE|$NGINX_VHOST_FRONTAL_FILE|" /etc/nginx/sites-enabled/default-ssl.conf

# Load php vhost configuration
if [ "${NGINX_VHOST_PHP_FPM}" == "true" ]; then
    sed -i "s|NGINX_VHOST_PHP_FPM_HOST:NGINX_VHOST_PHP_FPM_PORT|$NGINX_VHOST_PHP_FPM_HOST:$NGINX_VHOST_PHP_FPM_PORT|g" /etc/nginx/includes/php-fpm.conf
    sed -i "s|#php-fpm:||g" /etc/nginx/sites-enabled/default.conf
    sed -i "s|#php-fpm:||g" /etc/nginx/sites-enabled/default-ssl.conf
fi

# Load doc vhost configuration
if [ "${NGINX_VHOST_DOC}" == "true" ]; then

    NGINX_VHOST_DOC_VERSIONS=`echo ${NGINX_VHOST_DOC_VERSIONS} | sed -e 's/ *, */ /g'`

    for version in ${NGINX_VHOST_DOC_VERSIONS}
    do
        cat >> /etc/nginx/includes/docs.conf <<EOF
location ^~ /${NGINX_VHOST_DOC_SUBFOLDER} {
    alias /src/${NGINX_VHOST_ROOT}/${NGINX_VHOST_DOC_SUBFOLDER};
    index ${NGINX_VHOST_DOC_FRONTAL_FILE};
}
EOF
    done

    sed -i "s|#docs:||g" /etc/nginx/sites-enabled/default.conf

fi

# Load logs permissions
if [ "${NGINX_LOG_ACCESS_PATH}" != "/dev/stdout" ]; then
    if [ ! -f "${NGINX_LOG_ACCESS_PATH}" ]; then
        mkdir -p "$(dirname "$NGINX_LOG_ACCESS_PATH")"
        touch $NGINX_LOG_ACCESS_PATH
    fi

    chown -R $USER_NAME:$USER_NAME "$(dirname "$NGINX_LOG_ACCESS_PATH")"
fi

if [ "${NGINX_LOG_ERROR_PATH}" != "/dev/stdout" ]; then
    if [ ! -f "${NGINX_LOG_ERROR_PATH}" ]; then
        mkdir -p "$(dirname "$NGINX_LOG_ERROR_PATH")"
        touch $NGINX_LOG_ERROR_PATH
    fi

    chown -R $USER_NAME:$USER_NAME "$(dirname "$NGINX_LOG_ERROR_PATH")"
fi

# Start nginx
service nginx start &
