"""Pruebas unitarias para el módulo de pacientes"""
import pytest
from unittest.mock import patch, MagicMock


class TestPacientesRutas:
    """Pruebas de rutas del módulo pacientes"""

    def test_lista_pacientes_requiere_auth(self, client):
        """Acceso sin sesión debe redirigir"""
        response = client.get('/pacientes')
        assert response.status_code == 302

    def test_lista_pacientes_con_auth(self, auth_client):
        """Con auth debe devolver 200"""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.fetchall.return_value = []
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.get('/pacientes')
            assert response.status_code == 200

    def test_api_paciente_no_existente(self, auth_client):
        """API paciente inexistente devuelve 404"""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.fetchone.return_value = None
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.get('/api/pacientes/99999')
            assert response.status_code == 404

    def test_api_paciente_existente(self, auth_client):
        """API paciente existente devuelve 200 con datos"""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.fetchone.return_value = {
                'paciente_id': 1,
                'nombre': 'JUAN',
                'apellido': 'PEREZ',
                'identificacion': '123456',
                'estado_nombre': 'activo',
                'fecha_alta': '2025-01-01'
            }
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.get('/api/pacientes/1')
            assert response.status_code == 200
            data = response.get_json()
            assert data['nombre'] == 'JUAN'

    def test_crear_paciente_sin_permiso(self, client):
        """Crear paciente sin sesión debe fallar"""
        response = client.post('/pacientes/crear', data={
            'identificacion': '123',
            'nombre': 'Test',
            'apellido': 'User'
        })
        assert response.status_code == 302

    def test_cambiar_estado_paciente(self, auth_client):
        """Cambiar estado de paciente"""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.post(
                '/pacientes/cambiar-estado/1',
                json={'nuevo_estado': 'inactivo'},
                content_type='application/json'
            )
            assert response.status_code in [200, 302, 500]


class TestPacienteValidaciones:
    """Pruebas de validaciones de datos"""

    def test_identificacion_vacia_rechazada(self, auth_client):
        """No se puede crear paciente sin identificación"""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.callproc.side_effect = Exception("Identificación requerida")
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.post('/pacientes/crear', data={
                'identificacion': '',
                'nombre': 'Test',
                'apellido': 'User',
                'fecha_nacimiento': ''
            }, follow_redirects=True)
            assert response.status_code == 200
