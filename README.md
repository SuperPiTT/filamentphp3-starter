# Filament 3 Starter - Laravel + FilamentPHP + Livewire + Docker

Este proyecto es un entorno de desarrollo listo para usar con Laravel, FilamentPHP, Livewire y Docker Compose. Incluye scripts automáticos para instalar dependencias, preparar la base de datos y crear un usuario administrador.

## Características principales
- Laravel 12+ (estructura estándar)
- FilamentPHP 3 instalado y configurado automáticamente
- Livewire instalado automáticamente
- Docker Compose para PHP-FPM, Nginx y MySQL
- Instalación automática de dependencias (composer/npm) al levantar los contenedores
- Migraciones y seeders automáticos
- Usuario admin creado automáticamente (`admin@example.com` / `password`)
- Espera activa a la base de datos antes de ejecutar migraciones

## Requisitos
- Docker y Docker Compose

## Variables de entorno
El archivo `.env` en la raíz controla los nombres de contenedores y credenciales de la base de datos. Ejemplo:

```
USER_NAME=pit
USER_ID=1000
USER_GROUP=pit
USER_GID=1000
CONTAINER_NAME_APP=pit_app
CONTAINER_NAME_WEB=pit_web
CONTAINER_NAME_DB=pit_db
DB_DATABASE=pit
DB_USERNAME=pit
DB_PASSWORD=pit
DB_PRIMARY_ROOT_PASSWORD=pit
APP_PORT=8000
```


El archivo `.env` dentro de `laravel/` controla la configuración de Laravel. **La conexión a la base de datos se configura automáticamente** al levantar el contenedor, usando las variables de entorno definidas en el `.env` de la raíz y el `docker-compose.yml` (por ejemplo: `DB_HOST`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`, `DB_PORT`).

No es necesario editar manualmente el `.env` de Laravel para la base de datos: el script de inicio lo ajusta automáticamente según los valores de entorno del contenedor.

## Primer uso
1. Clona el repositorio y entra en la carpeta del proyecto.
2. Copia `.env.example` a `.env` y ajusta si es necesario.
3. Ejecuta:
   ```sh
   docker compose up --build
   ```
4. Accede a [http://localhost:8000](http://localhost:8000)

## Acceso a Filament
- URL: [http://localhost:8000/admin/login](http://localhost:8000/admin/login)
- Usuario: `admin@example.com`
- Contraseña: `password`

## ¿Qué hace el entrypoint?
- Instala dependencias PHP y JS si no existen
- Espera a que la base de datos esté lista
- Instala Livewire y Filament si no están presentes
- Ejecuta migraciones y seeders
- Crea el usuario admin si no existe

## Comandos útiles
- Levantar contenedores: `docker compose up --build`
- Parar contenedores: `docker compose down`
- Acceder al contenedor app (para ejecutar comandos composer, npm, artisan, etc):
  ```sh
  docker compose exec app sh
  ```

Una vez dentro del contenedor app, puedes ejecutar:

- Instalar dependencias PHP:
  ```sh
  composer install
  ```
- Instalar dependencias JS:
  ```sh
  npm install
  ```
- Ejecutar comandos artisan:
  ```sh
  php artisan <comando>
  ```

## Notas
- Si cambias el .env de Laravel, reinicia los contenedores.
- El usuario admin se crea en cada arranque si no existe.
- Puedes modificar el entrypoint para agregar más lógica de inicialización.

---

Proyecto base para desarrollo ágil con Laravel + Filament + Livewire en Docker.
