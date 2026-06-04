import pytest
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from unittest.mock import MagicMock, patch

# Mock de la base de datos antes de importar la app
@pytest.fixture(scope='session')
def mock_mysql():
    with patch('utils.database.MySQL') as mock:
        mock_instance = MagicMock()
        mock.return_value = mock_instance
        yield mock_instance

@pytest.fixture
def app(mock_mysql):
    """Crear instancia de Flask para testing"""
    with patch('flask_mysqldb.MySQL') as mock_db:
        mock_conn = MagicMock()
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = []
        mock_cursor.fetchone.return_value = None
        mock_conn.cursor.return_value = mock_cursor
        mock_db.return_value.connection = mock_conn

        os.environ['TESTING'] = 'true'
        os.environ['MYSQL_HOST'] = 'localhost'
        os.environ['MYSQL_USER'] = 'test'
        os.environ['MYSQL_PASSWORD'] = 'test'
        os.environ['MYSQL_DB'] = 'test_db'

        from app import app as flask_app
        flask_app.config.update({
            'TESTING': True,
            'SECRET_KEY': 'test-secret-key',
            'WTF_CSRF_ENABLED': False,
        })
        yield flask_app

@pytest.fixture
def client(app):
    return app.test_client()

@pytest.fixture
def auth_client(client):
    """Cliente con sesión autenticada como admin"""
    with client.session_transaction() as sess:
        sess['user_id'] = 1
        sess['username'] = 'admin'
        sess['user_roles'] = ['admin']
        sess['tipo_persona'] = 'admin'
    return client
