FROM wordpress:php8.1

RUN pecl install xdebug \
 && docker-php-ext-enable xdebug
