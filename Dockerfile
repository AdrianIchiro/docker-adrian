# syntax=docker/dockerfile:1

FROM composer:lts AS deps
WORKDIR /app

RUN --mount=type=bind,source=composer.json,target=composer.json \
    --mount=type=bind,source=composer.lock,target=composer.lock \
    --mount=type=cache,target=/tmp/cache \
    composer install --no-dev --no-interaction

FROM php:8.2-apache AS final

RUN docker-php-ext-install pdo pdo_mysql

# Copy PHP production config
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Copy vendor folder
COPY --from=deps /app/vendor/ /var/www/html/vendor

# Copy app source
COPY ./src /var/www/html

# Set correct permissions
USER www-data

