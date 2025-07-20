#!/bin/sh


# Instala Laravel si no existe artisan
if [ ! -f /var/www/html/artisan ]; then
    echo "No se encontró artisan. Borrando todo e instalando Laravel..."
    # Borra absolutamente todo, incluyendo archivos y carpetas ocultas
    for item in /var/www/html/* /var/www/html/.[!.]* /var/www/html/..?*; do
        [ -e "$item" ] && rm -rf "$item"
    done
    composer create-project laravel/laravel /var/www/html

    # Configura el archivo .env con los datos de conexión a MariaDB usando variables de entorno
    if [ -f /var/www/html/.env ]; then
        sed -i "s/^DB_CONNECTION=.*/DB_CONNECTION=mysql/" /var/www/html/.env
        sed -i "s/^DB_HOST=.*/DB_HOST=${DB_HOST:-pit_db}/" /var/www/html/.env
        sed -i "s/^DB_PORT=.*/DB_PORT=${DB_PORT:-3306}/" /var/www/html/.env
        sed -i "s/^DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE:-pit}/" /var/www/html/.env
        sed -i "s/^DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME:-pit}/" /var/www/html/.env
        sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD:-pit}/" /var/www/html/.env
    fi
fi

# Cambia el propietario de los archivos montados si es necesario
if [ -d /var/www/html ]; then
    chown -R ${user:-app}:${group:-app} /var/www/html || true
fi

# Instala dependencias PHP si no existe vendor/autoload.php
if [ ! -f /var/www/html/vendor/autoload.php ]; then
    echo "Instalando dependencias PHP..."
    cd /var/www/html && composer install --no-interaction --prefer-dist --optimize-autoloader
fi

# Instala dependencias JS si no existe node_modules
if [ ! -d /var/www/html/node_modules ]; then
    echo "Instalando dependencias JS..."
    cd /var/www/html && npm install
fi



# Espera activa a que la base de datos esté lista
echo "Esperando a que la base de datos esté lista..."
MAX_TRIES=10
TRIES=0
until php -r 'exit(@mysqli_connect(getenv("DB_HOST") ?: "pit_db", getenv("DB_USERNAME") ?: "pit", getenv("DB_PASSWORD") ?: "pit", getenv("DB_DATABASE") ?: "pit", getenv("DB_PORT") ?: 3306) ? 0 : 1);'; do    if [ $TRIES -ge $MAX_TRIES ]; then
        echo "No se pudo conectar a la base de datos tras $MAX_TRIES intentos. Abortando."
        exit 1
    fi
    echo "Esperando base de datos... ($TRIES/$MAX_TRIES)"
    sleep 2
done
echo "Base de datos lista."


# Instala Livewire si no está instalado
if ! grep -q "livewire/livewire" /var/www/html/composer.json; then
    echo "Instalando Livewire..."
    cd /var/www/html && composer require livewire/livewire --no-interaction && php artisan livewire:publish --config
fi

# Instala Filament si no está instalado
if ! grep -q "filament/filament" /var/www/html/composer.json; then
    echo "Instalando FilamentPHP..."
    cd /var/www/html && composer require filament/filament --no-interaction
    php artisan filament:install --panels --no-interaction
    php artisan vendor:publish --tag=filament-config
fi

# Ejecuta migraciones
echo "Ejecutando migraciones de base de datos..."
cd /var/www/html && php artisan migrate:fresh --seed --force

# Crea usuario admin si no existe
echo "Creando usuario admin si no existe..."
cd /var/www/html && php artisan tinker --execute 'if (!App\Models\User::where("email", "admin@example.com")->exists()) { App\Models\User::create(["name" => "Admin", "email" => "admin@example.com", "password" => Illuminate\Support\Facades\Hash::make("password"), "email_verified_at" => now()]); echo "Usuario admin creado.\n"; } else { echo "Usuario admin ya existe.\n"; }'

cd /var/www/html && php artisan key:generate
cd /var/www/html && php artisan storage:link
cd /var/www/html && php artisan optimize:clear



exec "$@"
