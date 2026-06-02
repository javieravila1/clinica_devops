#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Función para verificar si un paquete está instalado
package_installed() {
    dnf list installed "$1" &>/dev/null
}

# Función para instalar paquetes si no están instalados
install_package() {
    local package=$1
    if package_installed "$package"; then
        print_status "$package ya está instalado"
    else
        print_status "Instalando $package..."
        sudo dnf install -y "$package"
    fi
}

# Verificar si estamos en CentOS 9
if [[ ! -f /etc/redhat-release ]] || ! grep -q "CentOS Stream 9" /etc/redhat-release; then
    print_warning "Este script está diseñado para CentOS 9. Continuando de todos modos..."
fi

# Actualizar sistema
print_status "Actualizando sistema..."
sudo dnf update -y

# Instalar MariaDB
print_status "Instalando MariaDB..."
install_package mariadb-server
install_package mariadb

# Iniciar y habilitar MariaDB
print_status "Configurando MariaDB..."
sudo systemctl enable mariadb
sudo systemctl start mariadb

# Configuración segura de MariaDB
print_status "Ejecutando configuración segura de MariaDB..."
sudo mysql_secure_installation <<EOF

y
y
y
y
y
EOF

# Instalar Python y herramientas de desarrollo
print_status "Instalando Python y herramientas de desarrollo..."
install_package python3
install_package python3-pip
install_package python3-devel
install_package gcc
install_package openldap-devel

# Instalar Git (por si necesitas clonar repositorios)
install_package git

# Crear base de datos y usuario
print_status "Configurando base de datos..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS clinica_paliativos;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'paliativos_user'@'localhost' IDENTIFIED BY 'paliativos_password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON clinica_paliativos.* TO 'paliativos_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Verificar si ya existe el archivo SQL
if [[ ! -f "clinica_paliativos.sql" ]]; then
    print_error "No se encuentra el archivo clinica_paliativos.sql"
    print_status "Por favor, coloca el archivo SQL en el mismo directorio que este script"
    exit 1
fi

# Importar la base de datos
print_status "Importando base de datos..."
sudo mysql clinica_paliativos < clinica_paliativos.sql

# Verificar si la importación fue exitosa
if [[ $? -eq 0 ]]; then
    print_status "Base de datos importada exitosamente"
else
    print_error "Error al importar la base de datos"
    exit 1
fi

# Instalar dependencias de Python
print_status "Instalando dependencias de Python..."

# Crear entorno virtual si no existe
if [[ ! -d "venv" ]]; then
    print_status "Creando entorno virtual..."
    python3 -m venv venv
fi

# Activar entorno virtual
print_status "Activando entorno virtual..."
source venv/bin/activate

# Instalar Flask y dependencias
pip install --upgrade pip

# Instalar paquetes básicos para Flask con MariaDB
pip install flask
pip install mariadb
pip install flask-mysqldb
pip install PyMySQL
pip install SQLAlchemy
pip install Flask-SQLAlchemy
pip install Flask-Login
pip install Flask-WTF
pip install WTForms
pip install email-validator
pip install bcrypt
pip install cryptography

# Verificar instalación de dependencias
print_status "Verificando instalación de dependencias..."
python3 -c "
try:
    import flask
    import mariadb
    print('✓ Todas las dependencias están instaladas correctamente')
except ImportError as e:
    print(f'✗ Error importando dependencias: {e}')
    exit(1)
"

# Crear archivo de configuración básico para Flask si no existe
if [[ ! -f "app.py" ]]; then
    print_status "Creando archivo app.py básico..."
    cat > app.py << 'EOF'
from flask import Flask
import mariadb
import sys

app = Flask(__name__)

# Configuración de la base de datos
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'paliativos_user'
app.config['MYSQL_PASSWORD'] = 'paliativos_password'
app.config['MYSQL_DB'] = 'clinica_paliativos'
app.config['MYSQL_PORT'] = 3306

@app.route('/')
def index():
    try:
        conn = mariadb.connect(
            user=app.config['MYSQL_USER'],
            password=app.config['MYSQL_PASSWORD'],
            host=app.config['MYSQL_HOST'],
            port=app.config['MYSQL_PORT'],
            database=app.config['MYSQL_DB']
        )
        cursor = conn.cursor()
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()
        conn.close()
        return f'Conexión exitosa a la base de datos. Tablas encontradas: {len(tables)}'
    except mariadb.Error as e:
        return f'Error conectando a MariaDB: {e}'

@app.route('/health')
def health():
    return 'OK'

if __name__ == '__main__':
    print("Iniciando aplicación Flask...")
    print("Base de datos: clinica_paliativos")
    print("Usuario: paliativos_user")
    app.run(host='0.0.0.0', port=5000, debug=True)
EOF
    print_status "Archivo app.py creado"
else
    print_status "Archivo app.py ya existe"
fi


# Ejecutar verificación
print_status "Verificando el entorno..."

if [[ $? -eq 0 ]]; then
    print_status "¡Entorno configurado correctamente!"
    
    # Preguntar si quiere ejecutar la aplicación
    read -p "¿Deseas ejecutar la aplicación Flask ahora? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Iniciando aplicación Flask..."
        source venv/bin/activate
        python3 app.py
    else
        print_status "Puedes ejecutar la aplicación manualmente con:"
        echo "source venv/bin/activate && python3 app.py"
    fi
else
    print_error "Hubo problemas con la configuración. Revisa los mensajes anteriores."
    exit 1
fi