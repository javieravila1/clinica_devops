"""
conftest.py - Fixtures compartidos para todas las pruebas
Proyecto: Clínica de Cuidados Paliativos
"""
import pytest
from unittest.mock import MagicMock, patch
import sys
import os

# Agregar el directorio raíz del proyecto al path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))


# ─────────────────────────────────────────────
# Fixture: aplicación Flask con config de prueba
# ─────────────────────────────────────────────
@pytest.fixture(scope='session')
def app():
    """
    Crea la aplicación Flask en modo testing.
    Mockea la base de datos para no necesitar MySQL real.
    """
    # Parchear flask_mysqldb antes de importar la app
    mock_mysql_module = MagicMock()
    mock_mysql_instance = MagicMock()
    mock_mysql_module.MySQL.return_value = mock_mysql_instance
    sys.modules['flask_mysqldb'] = mock_mysql_module

    # Parchear pymysql
    mock_pymysql = MagicMock()
    sys.modules['pymysql'] = mock_pymysql

    # Importar y configurar la app
    from app import app as flask_app

    flask_app.config.update({
        'TESTING': True,
        'SECRET_KEY': 'test-secret-key-paliativos-2024',
        'WTF_CSRF_ENABLED': False,
        'MYSQL_HOST': 'localhost',
        'MYSQL_USER': 'test_user',
        'MYSQL_PASSWORD': 'test_pass',
        'MYSQL_DB': 'test_db',
        'PERMANENT_SESSION_LIFETIME': 1800,
    })

    yield flask_app


@pytest.fixture(scope='function')
def client(app):
    """Cliente HTTP para simular requests."""
    return app.test_client()


@pytest.fixture(scope='function')
def runner(app):
    """Runner de comandos CLI de Flask."""
    return app.test_cli_runner()


# ─────────────────────────────────────────────
# Fixture: sesión autenticada como admin
# ─────────────────────────────────────────────
@pytest.fixture(scope='function')
def authenticated_client(client):
    """Cliente con sesión de usuario admin activa."""
    with client.session_transaction() as sess:
        sess['user_id'] = 1
        sess['username'] = 'admin_test'
        sess['email'] = 'admin@test.com'
        sess['persona_id'] = 1
        sess['tipo_persona'] = 'admin'
        sess['user_roles'] = ['admin']
    return client


@pytest.fixture(scope='function')
def professional_client(client):
    """Cliente con sesión de profesional activa."""
    with client.session_transaction() as sess:
        sess['user_id'] = 2
        sess['username'] = 'prof_test'
        sess['email'] = 'prof@test.com'
        sess['persona_id'] = 5
        sess['tipo_persona'] = 'profesional'
        sess['user_roles'] = ['profesional']
    return client


@pytest.fixture(scope='function')
def receptionist_client(client):
    """Cliente con sesión de recepcionista activa."""
    with client.session_transaction() as sess:
        sess['user_id'] = 3
        sess['username'] = 'recep_test'
        sess['email'] = 'recep@test.com'
        sess['persona_id'] = 3
        sess['tipo_persona'] = 'recepcion'
        sess['user_roles'] = ['recepcion']
    return client


# ─────────────────────────────────────────────
# Fixture: mock de MySQL
# ─────────────────────────────────────────────
@pytest.fixture(scope='function')
def mock_mysql():
    """Mock completo de la conexión MySQL."""
    with patch('utils.database.mysql') as mock_db:
        mock_cursor = MagicMock()
        mock_db.connection.cursor.return_value = mock_cursor
        mock_cursor.__enter__ = MagicMock(return_value=mock_cursor)
        mock_cursor.__exit__ = MagicMock(return_value=False)
        yield mock_db, mock_cursor


# ─────────────────────────────────────────────
# Datos de prueba reutilizables
# ─────────────────────────────────────────────
@pytest.fixture(scope='session')
def sample_paciente():
    return {
        'paciente_id': 1,
        'identificacion': '1234567890',
        'nombre': 'Juan',
        'apellido': 'Pérez',
        'fecha_nacimiento': '1980-05-15',
        'telefono': '3001234567',
        'email': 'juan@example.com',
        'direccion': 'Calle 1 # 2-3',
        'estado_id': 1,
        'estado_nombre': 'activo',
        'fecha_alta': '2024-01-15',
    }


@pytest.fixture(scope='session')
def sample_profesional():
    return {
        'profesional_id': 1,
        'identificacion': '9876543210',
        'nombre': 'María',
        'apellido': 'García',
        'especialidad': 'Oncología',
        'horario_inicio': '08:00:00',
        'horario_fin': '17:00:00',
        'telefono': '3109876543',
        'email': 'maria@clinica.com',
        'estado_id': 4,
        'estado_nombre': 'activo',
    }


@pytest.fixture(scope='session')
def sample_cita():
    return {
        'cita_id': 1,
        'paciente_id': 1,
        'profesional_id': 1,
        'sala_id': 1,
        'fecha_inicio': '2024-12-01 09:00:00',
        'fecha_fin': '2024-12-01 10:00:00',
        'estado_id': 1,
        'estado_nombre': 'programada',
        'paciente_nombre': 'Juan',
        'paciente_apellido': 'Pérez',
        'profesional_nombre': 'María',
        'profesional_apellido': 'García',
        'sala_nombre': 'Sala 1',
    }


@pytest.fixture(scope='session')
def sample_user():
    return {
        'usuario_id': 1,
        'username': 'admin',
        'email': 'admin@clinica.com',
        'persona_id': 1,
        'tipo_persona': 'admin',
        'passhash': 'pbkdf2:sha256:600000$hashed_password',
        'estado_id': 26,
    }