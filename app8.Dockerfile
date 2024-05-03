FROM php:8.2-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Install packages
RUN apt-get update \
    && \
    # apt Debian packages
    apt-get install -y --no-install-recommends \
        apt-utils \
        autoconf \
        ca-certificates \
        curl \
        g++ \
        libonig-dev \
        libbz2-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libpq-dev \
        libssl-dev \
        libicu-dev \
        libmagickwand-dev \
        libzip-dev \
		libxml2-dev \
		gnupg \
        unzip \
        zip \
    && \
    # pecl PHP extensions
    pecl install \
        imagick \
		xdebug \
        redis \
    && \
    # Configure PHP extensions
    docker-php-ext-configure \
        gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && \
    # Install PHP extensions
    docker-php-ext-install \
        bcmath \
        bz2 \
        exif \
        ftp \
        gettext \
        gd \
        iconv \
        intl \
        mbstring \
        opcache \
        pdo \
		pdo_mysql \
        shmop \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        zip \
    && \
    # Enable PHP extensions
    docker-php-ext-enable \
        imagick \
		xdebug \
        redis \
    # Clean apt repo caches that don't need to be part of the image
    && \
    apt-get clean \
    && \
    # Clean out directories that don't need to be part of the image
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
	
# Copy the `zzz-docker-php.ini` file into place for php
COPY zzz-docker-php.ini /usr/local/etc/php/conf.d/

# Copy the `zzz-docker-php-fpm.conf` file into place for php-fpm
COPY zzz-docker-php-fpm.conf /usr/local/etc/php-fpm.d/

# Get nodeJS
RUN mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
     | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    NODE_MAJOR=21; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
     > /etc/apt/sources.list.d/nodesource.list; \
    apt-get update; \
    apt-get install nodejs -y

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

USER $user
