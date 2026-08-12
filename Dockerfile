FROM php:8.4-cli
WORKDIR /app
COPY . .
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN apt-get update && apt-get install -y libzip-dev unzip
RUN composer install --no-interaction
EXPOSE 8000
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
