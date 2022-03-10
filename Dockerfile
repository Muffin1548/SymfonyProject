FROM php:8.1-fpm

WORKDIR /var/www

RUN echo 'deb [trusted=yes] https://repo.symfony.com/apt/ /' | tee /etc/apt/sources.list.d/symfony-cli.list
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -

RUN apt-get update; apt-get install -y nodejs; apt-get install --no-install-recommends --no-install-suggests -y  \
    libc-client-dev \
    libkrb5-dev  \
    libpq-dev  \
    git \
    unzip \
    libzip-dev \
    librabbitmq-dev \
    zip \
    symfony-cli

RUN pecl channel-update pecl.php.net && pecl install xdebug \
    pecl install amqp-1.11.0beta \
    && echo 'zend_extension=xdebug.so' > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo 'extension=amqp.so' > /usr/local/etc/php/conf.d/amqp.ini

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pgsql pdo_pgsql \
    && rm -rf /var/lib/apt/lists/*

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
	&& php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
	&& php -r "unlink('composer-setup.php');"

COPY --chown=www-data:www-data . /var/www/

RUN corepack enable

USER www-data
