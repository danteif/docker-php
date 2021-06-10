FROM php:8.0.7-fpm-alpine3.13

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

#INSTALL XDEBUG AND EXT
RUN apk --no-cache add pcre-dev ${PHPIZE_DEPS} \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apk del pcre-dev ${PHPIZE_DEPS} \
    && chmod +x /usr/local/bin/install-php-extensions && sync \
    && install-php-extensions bcmath \
            json \
            sodium \
            mongodb \
            opcache \
            bz2 \
            calendar \
            curl \
            exif \
            fileinfo \
            ftp \
            gd \
            gettext \
            imagick \
            imap \
            intl \
            ldap \
            mcrypt \
            memcached \
            mysqli \
            pdo \
            pdo_mysql \
            pdo_pgsql \
            pdo_sqlite \
            soap \
            sysvsem \
            sysvshm \
            xmlrpc \
            xsl \
            zip \
            xml \
            pgsql \
            sqlite3 \
            redis \
    &&  echo -e "\n xdebug.mode=debug \n xdebug.client_host=localhost \n xdebug.client_port=9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    &&  echo -e "\n xhprof.output_dir='/var/tmp/xhprof'" >> /usr/local/etc/php/conf.d/docker-php-ext-xhprof.ini

#INSTALL MHSENDMAIL (MAILHOG)

RUN apk --no-cache add --virtual .mhsendmail curl go git musl-dev\
    && go get github.com/mailhog/mhsendmail \
    && cp /root/go/bin/mhsendmail /usr/bin/mhsendmail \
    && apk del .mhsendmail


# modify www-data user to have id 1000
RUN apk add \
        --no-cache \
        --repository http://dl-3.alpinelinux.org/alpine/edge/community/ --allow-untrusted \
        --virtual .shadow-deps \
        shadow \
    && usermod -u 1000 www-data \
    && groupmod -g 1000 www-data \
    && apk del .shadow-deps

# fix work iconv library with alphine
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

#bash
RUN apk add --no-cache bash

#Composer

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

#Symfony cli

RUN wget https://get.symfony.com/cli/installer -O - | bash
RUN mv /root/.symfony/bin/symfony /usr/local/bin/symfony

#

EXPOSE 9000

WORKDIR /var/www/

USER www-data
