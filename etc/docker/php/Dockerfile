FROM ubuntu:20.04

MAINTAINER Houssem Eddine BEN ABDALLAH <benabdallahhoussemedine@gmail.com>

# Install dependencies
ENV DEBIAN_FRONTEND noninteractive

# Set the locale
RUN apt-get clean \
 && apt-get update \
 && apt-get install locales \
 && locale-gen en_US.UTF-8

## Update locales
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install tools software
RUN echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends \
    && echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends \
    && apt-get update -qq \
    && apt-get install -qqy \
        build-essential \
        software-properties-common \
        vim.tiny \
        vim \
        ca-certificates \
        curl \
        acl \
        sudo \
        wget \
        net-tools \
        make \
        unzip \
        git \
        ssh \
        python \
        cron \
        netcat

####################
# Install PHP
####################
ENV PHP_VERSION 8.1

# Install PHP repository
RUN apt-get update -qq \
    && apt-get install --no-install-recommends -qqy software-properties-common \
    && LANG=C.UTF-8 add-apt-repository ppa:ondrej/php -y \
    && add-apt-repository -y ppa:git-core/ppa \
    && apt-get purge -qqy software-properties-common

# Install PHP
RUN apt-get update -qq \
    && apt-get install -qqy \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-cli \
        php-json \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-mysql \
        php-mcrypt \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-sqlite3 \
        php${PHP_VERSION}-ldap \
        php${PHP_VERSION}-opcache \
        php${PHP_VERSION}-soap \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-xmlrpc \
        php${PHP_VERSION}-xsl \
        php${PHP_VERSION}-bz2 \
        php${PHP_VERSION}-apcu \
        php${PHP_VERSION}-redis \
        php${PHP_VERSION}-memcached \
        php${PHP_VERSION}-xdebug \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-imagick

# Configure PHP
RUN mkdir -p /run/php

# Load PHP config
COPY assets/php.ini /etc/php/${PHP_VERSION}/cli/php.ini
COPY assets/php.ini /etc/php/${PHP_VERSION}/fpm/php.ini
COPY assets/php-fpm.conf /etc/php/${PHP_VERSION}/fpm/php-fpm.conf
COPY assets/www.pool.conf /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
COPY assets/20-xdebug.ini /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini
COPY assets/20-xdebug.ini /etc/php/${PHP_VERSION}/fpm/conf.d/20-xdebug.ini

# Fix Binaries PHP
RUN rm -f /usr/bin/php \
    && ln -s /usr/bin/php${PHP_VERSION} /usr/bin/php \
    && ln -s /usr/sbin/php-fpm${PHP_VERSION} /usr/bin/php-fpm

# Load binaries
COPY bin/entrypoint-php.sh /bin/entrypoint-php
RUN chmod +x /bin/entrypoint-php

CMD ["php", "-a"]
