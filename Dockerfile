FROM docker.io/bitpoke/wordpress-runtime:bedrock

RUN pecl install xdebug \
 && docker-php-ext-enable xdebug
