"""Pruebas unitarias para el módulo de citas"""
import pytest
from unittest.mock import patch, MagicMock
import json


class TestCitasRutas:
    """Pruebas de rutas del módulo citas"""

    def test_lista_citas_requiere_auth(self, client):
        response = client.get('/citas')
        assert response.status_code == 302

    def test_lista_citas_con_auth(self, auth_client):
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.fetchall.return_value = []
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.get('/citas')
            assert response.status_code == 200

    def test_api_cita_existente(self, auth_client):
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.fetchone.return_value = {
                'cita_id': 1,
                'paciente_nombre': 'JUAN',
                'paciente_apellido': 'PEREZ',
                'profesional_nombre': 'Ana',
                'profesional_apellido': 'García',
                'sala_nombre': 'Sala 1',
                'estado_nombre': 'programada',
                'fecha_inicio': '2025-01-01 09:00:00',
                'fecha_fin': '2025-01-01 10:00:00',
            }
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.get('/api/citas/1')
            assert response.status_code == 200

    def test_api_cita_no_existente(self, auth_client):
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.fetchone.return_value = None
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.get('/api/citas/99999')
            assert response.status_code == 404

    def test_api_citas_pendientes(self, auth_client):
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.fetchall.return_value = []
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.get('/api/citas/pendientes')
            assert response.status_code == 200
            assert isinstance(response.get_json(), list)

    def test_agendar_cita_campos_invalidos(self, auth_client):
        """Agendar cita con fecha inválida debe redirigir con error"""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.callproc.side_effect = Exception("Horario inválido")
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.post('/citas/agendar', data={
                'paciente_id': '1',
                'profesional_id': '1',
                'sala_id': '1',
                'fecha_inicio': '2025-01-01T18:30',
                'fecha_fin': '2025-01-01T10:30',
            }, follow_redirects=True)
            assert response.status_code == 200
