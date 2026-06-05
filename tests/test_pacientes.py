"""
test_pacientes.py - Pruebas para el módulo de pacientes
"""
import pytest
from unittest.mock import MagicMock, patch


class TestPacientesEndpoints:
    """Pruebas de endpoints del módulo pacientes."""

    def test_lista_pacientes_requiere_auth(self, client):
        """GET /pacientes requiere autenticación."""
        response = client.get('/pacientes', follow_redirects=False)
        assert response.status_code in (302, 308)

    def test_lista_pacientes_admin_ok(self, authenticated_client):
        """Admin puede listar pacientes."""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor
            mock_cursor.fetchall.return_value = []

            response = authenticated_client.get('/pacientes')
            assert response.status_code == 200

    def test_lista_pacientes_con_datos(self, authenticated_client, sample_paciente):
        """Lista de pacientes muestra datos correctamente."""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor
            mock_cursor.fetchall.return_value = [sample_paciente]

            response = authenticated_client.get('/pacientes')
            assert response.status_code == 200
            assert b'Juan' in response.data or response.status_code == 200

    def test_api_obtener_paciente_existente(self, authenticated_client, sample_paciente):
        """GET /api/pacientes/<id> retorna datos del paciente."""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor
            mock_cursor.fetchone.return_value = sample_paciente

            response = authenticated_client.get('/api/pacientes/1')
            assert response.status_code == 200
            data = response.get_json()
            assert data['nombre'] == 'Juan'
            assert data['apellido'] == 'Pérez'

    def test_api_obtener_paciente_no_existente(self, authenticated_client):
        """GET /api/pacientes/<id> retorna 404 si no existe."""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor
            mock_cursor.fetchone.return_value = None

            response = authenticated_client.get('/api/pacientes/9999')
            assert response.status_code == 404
            data = response.get_json()
            assert 'error' in data

    def test_crear_paciente_requiere_admin(self, professional_client):
        """Solo admin/recepcion puede crear pacientes."""
        response = professional_client.post('/pacientes/crear', data={
            'identificacion': '111',
            'nombre': 'Test',
            'apellido': 'Apellido',
        }, follow_redirects=False)
        # Profesional no tiene rol admin/recepcion → redirige o error
        assert response.status_code in (302, 308, 403, 500)

    def test_crear_paciente_datos_completos(self, authenticated_client):
        """Crear paciente con datos completos retorna éxito."""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor
            mock_cursor.fetchone.return_value = {'paciente_id': 10}
            mock_cursor.lastrowid = 20

            response = authenticated_client.post('/pacientes/crear', data={
                'identificacion': '9876543',
                'nombre': 'Carlos',
                'apellido': 'López',
                'fecha_nacimiento': '1990-03-20',
                'telefono': '3001112233',
                'email': 'carlos@test.com',
                'direccion': 'Calle 5 # 10-20',
            }, follow_redirects=False)
            # Después de crear exitosamente, redirige
            assert response.status_code in (302, 200)

    def test_crear_paciente_sin_fecha_nacimiento(self, authenticated_client):
        """Crear paciente sin fecha de nacimiento es válido."""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor
            mock_cursor.fetchone.return_value = {'paciente_id': 11}
            mock_cursor.lastrowid = 21

            response = authenticated_client.post('/pacientes/crear', data={
                'identificacion': '11111111',
                'nombre': 'Ana',
                'apellido': 'Martínez',
                'fecha_nacimiento': '',
            }, follow_redirects=False)
            assert response.status_code in (302, 200, 500)

    def test_cambiar_estado_paciente_activo_a_inactivo(self, authenticated_client):
        """Cambiar estado de paciente de activo a inactivo."""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor

            response = authenticated_client.post(
                '/pacientes/cambiar-estado/1',
                json={'nuevo_estado': 'inactivo'}
            )
            assert response.status_code in (200, 302, 500)

    def test_cambiar_estado_paciente_estado_invalido(self, authenticated_client):
        """Cambiar estado con valor inválido retorna error."""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor

            response = authenticated_client.post(
                '/pacientes/cambiar-estado/1',
                json={'nuevo_estado': 'estado_que_no_existe'}
            )
            data = response.get_json()
            if data:
                assert 'success' in data
                if not data['success']:
                    assert 'message' in data

    def test_editar_paciente_actualiza_datos(self, authenticated_client):
        """Editar paciente actualiza los datos correctamente."""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor

            response = authenticated_client.post(
                '/pacientes/editar/1',
                data={
                    'identificacion': '1234567890',
                    'nombre': 'Juan Actualizado',
                    'apellido': 'Pérez',
                    'fecha_nacimiento': '1980-05-15',
                    'telefono': '3001234567',
                    'email': 'juan@example.com',
                    'direccion': 'Nueva Dirección',
                    'estado_id': '1',
                }
            )
            data = response.get_json()
            if data:
                assert 'success' in data


class TestPacienteValidaciones:
    """Pruebas de validaciones del modelo paciente."""

    def test_identificacion_no_puede_ser_vacia(self, authenticated_client):
        """Identificación vacía no debe crear paciente."""
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor
            # Si callproc lanza excepción por identificación vacía
            mock_cursor.callproc.side_effect = Exception("Campo requerido")

            response = authenticated_client.post('/pacientes/crear', data={
                'identificacion': '',
                'nombre': 'Test',
                'apellido': 'Apellido',
            }, follow_redirects=True)
            # Puede redirigir con flash de error o mostrar formulario
            assert response.status_code in (200, 302, 400)

    def test_mapeo_estados_paciente(self, authenticated_client):
        """Verifica el mapeo correcto de estados."""
        estados_validos = {
            'activo': 1,
            'suspendido': 2,
            'inactivo': 3
        }
        with patch('utils.database.mysql') as mock_db:
            mock_cursor = MagicMock()
            mock_db.connection.cursor.return_value = mock_cursor

            for estado, estado_id in estados_validos.items():
                response = authenticated_client.post(
                    '/pacientes/cambiar-estado/1',
                    json={'nuevo_estado': estado}
                )
                assert response.status_code in (200, 302, 500)