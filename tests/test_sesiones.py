"""Pruebas unitarias para el módulo de sesiones"""
import pytest
from unittest.mock import patch, MagicMock


class TestSesionesRutas:

    def test_lista_sesiones_requiere_auth(self, client):
        response = client.get('/sesiones')
        assert response.status_code == 302

    def test_lista_sesiones_con_auth(self, auth_client):
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.fetchall.return_value = []
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.get('/sesiones')
            assert response.status_code == 200

    def test_api_sesion_existente(self, auth_client):
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.fetchone.return_value = {
                'sesion_id': 1,
                'paciente_nombre': 'JUAN PEREZ',
                'profesional_nombre': 'Ana García',
                'notas': 'Sesión de prueba',
                'tecnica_utilizada': 'TCC',
                'duracion_real_min': 60,
                'fecha_registro': '2025-01-01 09:00:00',
                'estado_nombre': 'completada',
                'fecha_inicio': '2025-01-01 09:00:00'
            }
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.get('/api/sesiones/1')
            assert response.status_code == 200

    def test_api_sesion_no_existente(self, auth_client):
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.fetchone.return_value = None
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.get('/api/sesiones/99999')
            assert response.status_code == 404

    def test_api_escalas(self, auth_client):
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.fetchall.return_value = [
                {'escala_id': 1, 'nombre': 'Escala de Dolor'},
                {'escala_id': 2, 'nombre': 'Calidad de Vida'},
            ]
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.get('/api/escalas')
            assert response.status_code == 200
            data = response.get_json()
            assert len(data) == 2
