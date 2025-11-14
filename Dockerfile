FROM php:8.3-fpm

# 1. Устанавливаем нужные библиотеки
RUN apt-get update && apt-get install -y \
    nano \
    git zip unzip libpq-dev \
    libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_pgsql gd \
    && rm -rf /var/lib/apt/lists/*

# 2. Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 3. Рабочая директория
WORKDIR /var/www/html

# 4. Копируем весь Laravel-проект внутрь образа
COPY . .

# 5. Устанавливаем зависимости и права
RUN composer install --no-dev --optimize-autoloader \
    && php artisan config:clear \
    && php artisan route:clear \
    && php artisan view:clear \
    && chmod -R 777 storage bootstrap/cache

# 6. Запускаем php-fpm
CMD ["php-fpm"]
