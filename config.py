import os
from datetime import timedelta

class Config:
    # Configuración básica de Flask
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'clave_secreta_paliativos_2024'
    PERMANENT_SESSION_LIFETIME = timedelta(minutes=30)
    
    # Configuración de MariaDB
    MYSQL_HOST = os.environ.get('MYSQL_HOST', 'localhost')
    MYSQL_PORT = int(os.environ.get('MYSQL_PORT', 3306))
    MYSQL_USER = os.environ.get('MYSQL_USER', 'paliativos_user')
    MYSQL_PASSWORD = os.environ.get('MYSQL_PASSWORD', '666')
    MYSQL_DB = os.environ.get('MYSQL_DB', 'clinica_paliativos')
    MYSQL_CURSORCLASS = 'DictCursor'
    
    # Configuración de la aplicación
    APP_NAME = 'Clínica de Cuidados Paliativos'
    VERSION = '1.0'
    
    # Roles del sistema
    ROLES = {
        'admin': 'Administrador',
        'profesional': 'Profesional de Salud',
        'recepcion': 'Recepcionista',
        'auditor': 'Auditor',
        'paciente': 'Paciente'
    }