FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    curl \
    libonig-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    nodejs \
    npm \
    nano \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN npm i -g yarn -y

COPY . /var/www/html

COPY .env.example /var/www/html/.env

WORKDIR /var/www/html

RUN chmod -R 775 . && chown -R www-data:www-data .

RUN composer install

RUN php artisan key:generate \
    && php artisan config:clear \
    && php artisan config:cache \
    && php artisan storage:link

COPY package.json yarn.lock ./

RUN yarn config set network-timeout 100000 -g && yarn install && yarn build

USER www-data

EXPOSE 9000

CMD [ "php-fpm" ]