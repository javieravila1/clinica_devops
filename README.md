# Proyecto Clínica Paliativos

Dockerización del backend Flask y la base de datos MySQL.

## Uso con Docker

1. Construir y levantar los contenedores:

```bash
docker compose up --build
```

2. Abrir la aplicación en:

```text
http://localhost:5000
```

3. La base de datos MySQL estará disponible en el puerto `3306`.

## Notas

- El archivo `clinica_paliativos_final.sql` se monta en el contenedor MySQL y se ejecuta durante la inicialización.
- El servicio `web` usa `MYSQL_HOST=db` para conectarse al servicio de base de datos de Docker Compose.
