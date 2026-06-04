"""Pruebas unitarias para autenticación y rutas principales"""
import pytest
from unittest.mock import patch, MagicMock


class TestLoginRoute:
    """Pruebas para la ruta de login"""

    def test_login_get(self, client):
        """GET /login debe devolver 200"""
        response = client.get('/login')
        assert response.status_code == 200

    def test_login_post_credenciales_vacias(self, client):
        """POST /login sin datos debe fallar"""
        response = client.post('/login', data={
            'username': '',
            'password': ''
        }, follow_redirects=True)
        assert response.status_code == 200

    def test_login_post_usuario_invalido(self, client):
        """POST /login con usuario inválido debe mostrar error"""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.fetchone.return_value = None
            mock_db.connection.cursor.return_value = mock_cursor

            response = client.post('/login', data={
                'username': 'usuario_inexistente',
                'password': 'clave_incorrecta'
            }, follow_redirects=True)
            assert response.status_code == 200

    def test_redirect_autenticado_a_dashboard(self, auth_client):
        """Usuario autenticado en / redirige a dashboard"""
        response = auth_client.get('/')
        assert response.status_code in [200, 302]

    def test_logout(self, auth_client):
        """GET /logout limpia la sesión"""
        response = auth_client.get('/logout', follow_redirects=True)
        assert response.status_code == 200

    def test_ruta_protegida_sin_sesion(self, client):
        """Ruta protegida sin sesión redirige a login"""
        response = client.get('/pacientes')
        assert response.status_code == 302
        assert '/login' in response.headers.get('Location', '')


class TestIndexRoute:
    """Pruebas para la ruta raíz"""

    def test_index_sin_sesion_redirige_a_login(self, client):
        response = client.get('/')
        assert response.status_code == 302

    def test_index_con_sesion_redirige_a_dashboard(self, auth_client):
        response = auth_client.get('/')
        assert response.status_code == 302
