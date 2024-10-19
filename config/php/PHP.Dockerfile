FROM php:8.2-fpm

RUN apt-get update
RUN apt-get install -y \
        apt-transport-https \
        curl \
        wget \
        git \
        zip \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libjpeg-dev \
        zlib1g-dev \
        libpq-dev \
        libc-client-dev \
        libkrb5-dev \
        libxslt-dev \
        libonig-dev \
        libpq-dev \
        libmagickwand-dev --no-install-recommends \
        libmemcached-dev \
        libzip-dev
RUN docker-php-ext-install -j$(nproc) mbstring mysqli pdo_mysql pdo_pgsql zip \
    && docker-php-ext-configure zip \
    && docker-php-ext-install gd \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) imap \
    && docker-php-ext-install xsl \
    && docker-php-ext-install opcache \
    && docker-php-ext-enable opcache

RUN apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./config/php/php-opcache.ini /usr/local/etc/php/conf.d/zz-nextcloud-opcache.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && apt-get update

ADD ./config/php/php.ini /usr/local/etc/php/conf.d/40-custom.ini

WORKDIR /var/www

CMD php-fpm
