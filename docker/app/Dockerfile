# Use PHP 8.3 with FPM (FastCGI Process Manager) on Alpine Linux
FROM php:8.3-fpm-alpine


# Arguments that can be pasados durante el build (coinciden con el host)
ARG user
ARG uid
ARG group
ARG gid


# Environment variables
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV user=${user:-app} group=${group:-app}

RUN apk add --no-cache \
    libpng-dev \
    libzip-dev \
    libxml2-dev \
    jpeg-dev \
    freetype-dev \
    icu-dev \
    oniguruma-dev \
    curl \
    git \
    unzip \
    supervisor \
    # --- AÑADIR NODE.JS Y NPM ---
    nodejs \
    npm \
    bash \
    linux-headers \
    # --- FIN DE ADICIÓN ---
    && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo \
        pdo_mysql \
        mysqli \
        mbstring \
        exif \
        pcntl \
        bcmath \
        zip \
        soap \
        xml \
        intl \

    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apk del .build-deps


## Configuración básica de Xdebug
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Install Composer (PHP dependency manager) globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set the working directory inside the container
WORKDIR /var/www/html



# Copiar y dar permisos al entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Usar root para todo
USER root

# Expose port 9000 (default port for PHP-FPM)
EXPOSE 9000

# Usar entrypoint personalizado
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]