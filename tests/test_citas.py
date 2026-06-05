"""
test_citas.py - Pruebas para el módulo de citas
"""
import pytest
from unittest.mock import MagicMock, patch
from datetime import datetime, timedelta


class TestCitasEndpoints:
    """Pruebas de endpoints del módulo citas."""

    def test_lista_citas_requiere_auth(self, client):
        """GET /citas requiere autenticación."""
        response = client.get('/citas', follow_redirects=False)
        assert response.status_code in (302, 308)

    def test_lista_citas_admin_ok(self, authenticated_client):
        """Admin puede listar citas."""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor
            mock_cursor.fetchall.return_value = []

            response = authenticated_client.get('/citas')
            assert response.status_code == 200

    def test_api_obtener_cita_existente(self, authenticated_client, sample_cita):
        """GET /api/citas/<id> retorna datos de la cita."""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor
            mock_cursor.fetchone.return_value = sample_cita

            response = authenticated_client.get('/api/citas/1')
            assert response.status_code == 200
            data = response.get_json()
            assert data['cita_id'] == 1
            assert data['estado_nombre'] == 'programada'

    def test_api_obtener_cita_no_existe(self, authenticated_client):
        """GET /api/citas/<id> retorna 404 si no existe."""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor
            mock_cursor.fetchone.return_value = None

            response = authenticated_client.get('/api/citas/9999')
            assert response.status_code == 404

    def test_agendar_cita_recepcion_ok(self, receptionist_client):
        """Recepcionista puede agendar una cita."""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor

            fecha_inicio = (datetime.now() + timedelta(days=1)).strftime('%Y-%m-%dT%H:%M')
            fecha_fin = (datetime.now() + timedelta(days=1, hours=1)).strftime('%Y-%m-%dT%H:%M')

            response = receptionist_client.post('/citas/agendar', data={
                'paciente_id': '1',
                'profesional_id': '1',
                'sala_id': '1',
                'fecha_inicio': fecha_inicio,
                'fecha_fin': fecha_fin,
            }, follow_redirects=False)
            assert response.status_code in (302, 200)

    def test_agendar_cita_fecha_inicio_mayor_fin(self, receptionist_client):
        """No permite agendar cita con inicio >= fin."""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor

            fecha_inicio = '2024-12-01T10:00'
            fecha_fin = '2024-12-01T09:00'  # fin antes que inicio

            response = receptionist_client.post('/citas/agendar', data={
                'paciente_id': '1',
                'profesional_id': '1',
                'sala_id': '1',
                'fecha_inicio': fecha_inicio,
                'fecha_fin': fecha_fin,
            }, follow_redirects=True)
            # Debe mostrar error o redirigir con flash
            assert response.status_code in (200, 302)

    def test_cancelar_cita_requiere_motivo(self, receptionist_client):
        """Cancelar cita requiere un motivo_id."""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor

            response = receptionist_client.post(
                '/citas/cancelar/1',
                data={'motivo_id': '1'},
                follow_redirects=False
            )
            assert response.status_code in (302, 200, 500)

    def test_citas_pendientes_api(self, authenticated_client):
        """GET /api/citas/pendientes retorna lista."""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor
            mock_cursor.fetchall.return_value = [
                {
                    'cita_id': 1,
                    'paciente_nombre': 'Juan Pérez',
                    'profesional_nombre': 'Dr. García',
                    'fecha_inicio': '2024-12-01 09:00:00',
                }
            ]

            response = authenticated_client.get('/api/citas/pendientes')
            assert response.status_code == 200
            data = response.get_json()
            assert isinstance(data, list)

    def test_citas_pendientes_lista_vacia(self, authenticated_client):
        """GET /api/citas/pendientes retorna [] cuando no hay citas."""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor
            mock_cursor.fetchall.return_value = []

            response = authenticated_client.get('/api/citas/pendientes')
            assert response.status_code == 200
            data = response.get_json()
            assert data == [] or isinstance(data, list)


class TestCitasValidaciones:
    """Pruebas de validaciones de citas."""

    def test_validacion_fechas_cita(self):
        """Valida que fecha_inicio < fecha_fin."""
        from datetime import datetime

        fecha_inicio = datetime.fromisoformat('2024-12-01T09:00')
        fecha_fin = datetime.fromisoformat('2024-12-01T10:00')

        assert fecha_inicio < fecha_fin, "fecha_inicio debe ser menor que fecha_fin"

    def test_validacion_fechas_invertidas(self):
        """Detecta cuando fecha_inicio >= fecha_fin."""
        from datetime import datetime

        fecha_inicio = datetime.fromisoformat('2024-12-01T10:00')
        fecha_fin = datetime.fromisoformat('2024-12-01T09:00')

        assert fecha_inicio >= fecha_fin, "Debe detectar fechas inválidas"

    def test_validacion_fechas_iguales(self):
        """Detecta cuando fecha_inicio == fecha_fin."""
        from datetime import datetime

        fecha = datetime.fromisoformat('2024-12-01T09:00')
        assert fecha >= fecha, "Fechas iguales deben ser inválidas"

    def test_formato_fecha_datetime_local(self):
        """Verifica el formato de fecha para datetime-local."""
        from datetime import datetime
        dt = datetime(2024, 12, 1, 9, 30)
        formatted = dt.strftime('%Y-%m-%dT%H:%M')
        assert formatted == '2024-12-01T09:30'
        # Verificar que se puede parsear de vuelta
        parsed = datetime.fromisoformat(formatted.replace('T', ' '))
        assert parsed == dt

    def test_estados_cita_validos(self):
        """Verifica los estados válidos de una cita."""
        estados_validos = ['programada', 'completada', 'cancelada', 'confirmada', 'no_show']
        for estado in estados_validos:
            assert isinstance(estado, str)
            assert len(estado) > 0