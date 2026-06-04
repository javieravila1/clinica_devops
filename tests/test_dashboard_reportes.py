"""Pruebas unitarias para dashboard y reportes"""
import pytest
from unittest.mock import patch, MagicMock


class TestDashboard:

    def test_dashboard_requiere_auth(self, client):
        response = client.get('/dashboard')
        assert response.status_code == 302

    def test_dashboard_con_auth(self, auth_client):
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.fetchall.return_value = []
            mock_cursor.fetchone.return_value = {
                'pacientes_activos': 5,
                'citas_hoy': 3,
                'sesiones_mes': 10,
                'tasa_adherencia': 85.0
            }
            mock_cursor.nextset.return_value = True
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.get('/dashboard')
            assert response.status_code == 200

    def test_api_distribucion_citas(self, auth_client):
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.fetchall.return_value = [
                {'estado': 'programada', 'cantidad': 5},
                {'estado': 'completada', 'cantidad': 8},
            ]
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.get('/api/dashboard/distribucion-citas')
            assert response.status_code == 200
            data = response.get_json()
            assert isinstance(data, list)

    def test_api_evolucion_sesiones(self, auth_client):
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.fetchall.return_value = []
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.get('/api/dashboard/evolucion-sesiones')
            assert response.status_code == 200

    def test_api_adherencia_pacientes(self, auth_client):
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.fetchall.return_value = []
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.get('/api/dashboard/adherencia-pacientes')
            assert response.status_code == 200


class TestReportes:

    def test_reportes_requiere_auth(self, client):
        response = client.get('/reportes')
        assert response.status_code == 302

    def test_reportes_con_auth(self, auth_client):
        response = auth_client.get('/reportes')
        assert response.status_code == 200

    def test_api_metricas_principales(self, auth_client):
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.fetchone.return_value = {
                'total_citas': 20,
                'citas_atendidas': 15,
                'citas_noshow': 3,
                'citas_canceladas': 2
            }
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.get('/api/reportes/metricas-principales')
            assert response.status_code == 200
            data = response.get_json()
            assert 'adherencia' in data

    def test_api_adherencia_reporte(self, auth_client):
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_cursor.fetchall.return_value = []
            mock_db.connection.cursor.return_value = mock_cursor

            response = auth_client.get('/api/reportes/adherencia?desde=2025-01-01&hasta=2025-12-31')
            assert response.status_code == 200
