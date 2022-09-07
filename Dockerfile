FROM ubuntu:20.04

MAINTAINER Houssem Eddine BEN ABDALLAH <benabdallahhoussemedine@gmail.com>

ADD . /src
WORKDIR /src

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
    && apt-get update -qq \
    && apt-get install -qqy --fix-missing \
        build-essential \
        software-properties-common \
        vim \
        ca-certificates \
        curl \
        acl \
        sudo \
        wget \
        make \
        unzip \
        git \
        ssh \
        gnupg2

# Install supervisor
RUN apt-get update -qq \
    && apt-get install -qqy supervisor

COPY etc/docker/ubuntu/assets/supervisord.conf /etc/supervisor/supervisord.conf
CMD ["/usr/bin/supervisord", "-n"]

# Install gosu to launch container with right permissions
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture).asc" \
    && gpg --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

# User file
RUN mkdir -p /data/home-files
COPY etc/docker/ubuntu/assets/home/ /data/home-files/

# Load binaries
COPY etc/docker/ubuntu/bin/entrypoint-ubuntu.sh /bin/entrypoint-ubuntu
RUN chmod +x /bin/entrypoint-ubuntu

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
COPY etc/docker/php/assets/php.ini /etc/php/${PHP_VERSION}/cli/php.ini
COPY etc/docker/php/assets/php.ini /etc/php/${PHP_VERSION}/fpm/php.ini
COPY etc/docker/php/assets/php-fpm.conf /etc/php/${PHP_VERSION}/fpm/php-fpm.conf
COPY etc/docker/php/assets/www.pool.conf /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
COPY etc/docker/php/assets/20-xdebug.ini /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini
COPY etc/docker/php/assets/20-xdebug.ini /etc/php/${PHP_VERSION}/fpm/conf.d/20-xdebug.ini

# Fix Binaries PHP
RUN rm -f /usr/bin/php \
    && ln -s /usr/bin/php${PHP_VERSION} /usr/bin/php \
    && ln -s /usr/sbin/php-fpm${PHP_VERSION} /usr/bin/php-fpm

# Load binaries
COPY etc/docker/php/bin/entrypoint-php.sh /bin/entrypoint-php
RUN chmod +x /bin/entrypoint-php

####################
# Install Nginx
####################

RUN apt-get update -qq
RUN curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt install nodejs -y
RUN node -v
RUN npm -v

####################
# Install Nginx
####################
RUN apt-get update -qq \
    && apt-get install -qqy nginx \
    && rm -rf /etc/nginx/sites-available/* /etc/nginx/sites-enabled/*

COPY etc/docker/nginx/assets/nginx.conf /etc/nginx/nginx.conf
COPY etc/docker/nginx/assets/includes /etc/nginx/includes
COPY etc/docker/nginx/assets/vhosts /etc/nginx/sites-enabled

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
   && ln -sf /dev/stderr /var/log/nginx/error.log

# Load binaries
COPY etc/docker/nginx/bin/entrypoint-nginx.sh /bin/entrypoint-nginx
RUN chmod +x /bin/entrypoint-nginx

##############################
###### install composer ######
##############################
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN HASH=`curl -sS https://composer.github.io/installer.sig`
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer

##############################
######## Build env ###########
##############################
RUN composer update --no-dev --optimize-autoloader --prefer-dist
RUN php bin/console assets:install

##############################

COPY etc/docker/entrypoint.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint
RUN mkdir -p /run/sshd
ENTRYPOINT ["/bin/entrypoint"]
EXPOSE 80 443 2222


