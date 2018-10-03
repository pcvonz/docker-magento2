FROM alexcheng/apache2-php7:7.1.11

LABEL maintainer="pzimmerman@bargreen.com"
LABEL version="2.2.5"
LABEL description="Magento 2.3, forked from docker-magento2 - alexcheng1982"

ENV MAGENTO_VERSION 2.3
ENV INSTALL_DIR /var/www/html
ENV COMPOSER_HOME /var/www/.composer/

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer
COPY ./auth.json $COMPOSER_HOME

RUN requirements="libpng12-dev libmcrypt-dev libmcrypt4 libcurl3-dev libfreetype6 libjpeg-turbo8 libjpeg-turbo8-dev libpng12-dev libfreetype6-dev libicu-dev libxslt1-dev" \
    && apt-get update \
    && apt-get install -y $requirements \
    && apt-get install -y git \
    && apt-get install -y acl \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install zip \
    && docker-php-ext-install intl \
    && docker-php-ext-install xsl \
    && docker-php-ext-install soap \
    && docker-php-ext-install bcmath \
    && requirementsToRemove="libpng12-dev libmcrypt-dev libcurl3-dev libpng12-dev libfreetype6-dev libjpeg-turbo8-dev" \
    && apt-get purge --auto-remove -y $requirementsToRemove

RUN chsh -s /bin/bash www-data
RUN chown -R www-data:www-data /var/www

RUN chmod g+s /var/www
RUN setfacl -d -m g::rwx /var/www/html

RUN su www-data -c "cd $INSTALL_DIR && git clone -b 2.3-develop https://github.com/magento/magento2.git --depth 1 ."
RUN su www-data -c "cd $INSTALL_DIR && composer install"
RUN su www-data -c "cd $INSTALL_DIR && composer config repositories.magento composer https://repo.magento.com/"  


COPY ./install-magento /usr/local/bin/install-magento
RUN chmod +x /usr/local/bin/install-magento

COPY ./install-venia /usr/local/bin/install-venia
RUN chmod +x /usr/local/bin/install-venia

COPY ./composer.json $INSTALL_DIR 
RUN chown www-data:www-data $INSTALL_DIR/composer.json
RUN a2enmod rewrite
RUN a2enmod ssl

RUN mkdir /etc/apache2/ssl
RUN cd /etc/apache2/ssl && openssl req -subj "/C=US/ST=WA/L=WA/O=Dockertest/OU=IT/CN=local.magento" -x509 -nodes -days 1095 -newkey rsa:2048 -out server.crt -keyout server.key

COPY ./ssl-config.conf /etc/apache2/sites-enabled/ssl-config.conf


RUN echo "memory_limit=2048M" > /usr/local/etc/php/conf.d/memory-limit.ini

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR $INSTALL_DIR

# Add cron job
ADD crontab /etc/cron.d/magento2-cron
RUN chmod 0644 /etc/cron.d/magento2-cron \
    && crontab -u www-data /etc/cron.d/magento2-cron

CMD /usr/sbin/apache2ctl -D FOREGROUND

