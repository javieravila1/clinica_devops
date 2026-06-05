"""
test_helpers.py - Pruebas unitarias para funciones auxiliares
"""
import pytest
from datetime import date, datetime, timedelta
from unittest.mock import MagicMock, patch


class TestCalcularEdad:
    """Pruebas para la función calcular_edad."""

    def test_edad_correcta_adulto(self):
        """Calcula correctamente la edad de un adulto."""
        from utils.helpers import calcular_edad
        fecha = date(1990, 1, 1)
        edad = calcular_edad(fecha)
        expected = datetime.now().year - 1990
        # Ajustar si aún no ha cumplido años este año
        if (datetime.now().month, datetime.now().day) < (1, 1):
            expected -= 1
        assert edad == expected

    def test_edad_recien_nacido(self):
        """Calcula correctamente la edad de un bebé recién nacido."""
        from utils.helpers import calcular_edad
        fecha = date.today()
        edad = calcular_edad(fecha)
        assert edad == 0

    def test_edad_con_fecha_none(self):
        """Retorna None cuando la fecha es None."""
        from utils.helpers import calcular_edad
        resultado = calcular_edad(None)
        assert resultado is None

    def test_edad_con_string_fecha(self):
        """Acepta fechas como strings en formato YYYY-MM-DD."""
        from utils.helpers import calcular_edad
        fecha_str = '1980-06-15'
        edad = calcular_edad(fecha_str)
        assert isinstance(edad, int)
        assert edad > 0

    def test_edad_cumpleanos_hoy(self):
        """Calcula correctamente cuando el cumpleaños es hoy."""
        from utils.helpers import calcular_edad
        hoy = date.today()
        fecha_nacimiento = date(hoy.year - 30, hoy.month, hoy.day)
        edad = calcular_edad(fecha_nacimiento)
        assert edad == 30

    def test_edad_cumpleanos_manana(self):
        """Un año menos si el cumpleaños aún no ha llegado."""
        from utils.helpers import calcular_edad
        hoy = date.today()
        manana = hoy + timedelta(days=1)
        # Nacido hace exactamente 30 años menos 1 día
        fecha_nacimiento = date(hoy.year - 30, manana.month, manana.day)
        edad = calcular_edad(fecha_nacimiento)
        assert edad == 29

    def test_edad_persona_mayor(self):
        """Calcula correctamente para persona mayor de 80 años."""
        from utils.helpers import calcular_edad
        fecha = date(1940, 3, 10)
        edad = calcular_edad(fecha)
        assert edad >= 84

    def test_edad_retorna_entero(self):
        """La función siempre retorna un entero (o None)."""
        from utils.helpers import calcular_edad
        fecha = date(1985, 7, 20)
        resultado = calcular_edad(fecha)
        assert isinstance(resultado, int)


class TestEjecutarProcedimiento:
    """Pruebas para la función ejecutar_procedimiento."""

    def test_ejecutar_procedimiento_sin_params(self):
        """Ejecuta un SP sin parámetros correctamente."""
        from utils.helpers import ejecutar_procedimiento

        with patch('utils.helpers.get_mysql') as mock_get_mysql:
            mock_mysql = MagicMock()
            mock_cursor = MagicMock()
            mock_get_mysql.return_value = mock_mysql
            mock_mysql.connection.cursor.return_value = mock_cursor
            mock_cursor.fetchall.return_value = [{'id': 1, 'nombre': 'Test'}]

            resultado = ejecutar_procedimiento('mi_procedimiento')

            mock_cursor.callproc.assert_called_once_with('mi_procedimiento')
            assert resultado == [{'id': 1, 'nombre': 'Test'}]

    def test_ejecutar_procedimiento_con_params(self):
        """Ejecuta un SP con parámetros."""
        from utils.helpers import ejecutar_procedimiento

        with patch('utils.helpers.get_mysql') as mock_get_mysql:
            mock_mysql = MagicMock()
            mock_cursor = MagicMock()
            mock_get_mysql.return_value = mock_mysql
            mock_mysql.connection.cursor.return_value = mock_cursor
            mock_cursor.fetchall.return_value = []

            resultado = ejecutar_procedimiento('buscar_paciente', [1])

            mock_cursor.callproc.assert_called_once_with('buscar_paciente', [1])
            assert resultado == []

    def test_ejecutar_procedimiento_cierra_cursor(self):
        """El cursor se cierra siempre, incluso con error."""
        from utils.helpers import ejecutar_procedimiento

        with patch('utils.helpers.get_mysql') as mock_get_mysql:
            mock_mysql = MagicMock()
            mock_cursor = MagicMock()
            mock_get_mysql.return_value = mock_mysql
            mock_mysql.connection.cursor.return_value = mock_cursor
            mock_cursor.callproc.side_effect = Exception("DB Error")

            with pytest.raises(Exception):
                ejecutar_procedimiento('procedimiento_malo')

            mock_cursor.close.assert_called_once()

    def test_ejecutar_procedimiento_retorna_lista_vacia(self):
        """Retorna lista vacía cuando no hay resultados."""
        from utils.helpers import ejecutar_procedimiento

        with patch('utils.helpers.get_mysql') as mock_get_mysql:
            mock_mysql = MagicMock()
            mock_cursor = MagicMock()
            mock_get_mysql.return_value = mock_mysql
            mock_mysql.connection.cursor.return_value = mock_cursor
            mock_cursor.fetchall.return_value = []

            resultado = ejecutar_procedimiento('sp_sin_resultados')
            assert resultado == []
            assert isinstance(resultado, list)


class TestEjecutarProcedimientoMultiple:
    """Pruebas para ejecutar_procedimiento_multiple."""

    def test_retorna_multiples_resultsets(self):
        """Captura múltiples conjuntos de resultados."""
        from utils.helpers import ejecutar_procedimiento_multiple

        with patch('utils.helpers.get_mysql') as mock_get_mysql:
            mock_mysql = MagicMock()
            mock_cursor = MagicMock()
            mock_get_mysql.return_value = mock_mysql
            mock_mysql.connection.cursor.return_value = mock_cursor

            # Primer resultset
            mock_cursor.fetchall.side_effect = [
                [{'dato': 'primero'}],
                [{'dato': 'segundo'}],
            ]
            # nextset() retorna True una vez, luego False
            mock_cursor.nextset.side_effect = [True, False]

            resultado = ejecutar_procedimiento_multiple('sp_multiple')
            assert len(resultado) >= 1

    def test_retorna_al_menos_un_resultset(self):
        """Siempre retorna al menos un resultset."""
        from utils.helpers import ejecutar_procedimiento_multiple

        with patch('utils.helpers.get_mysql') as mock_get_mysql:
            mock_mysql = MagicMock()
            mock_cursor = MagicMock()
            mock_get_mysql.return_value = mock_mysql
            mock_mysql.connection.cursor.return_value = mock_cursor
            mock_cursor.fetchall.return_value = []
            mock_cursor.nextset.return_value = False

            resultado = ejecutar_procedimiento_multiple('sp_simple')
            assert isinstance(resultado, list)
            assert len(resultado) >= 1

    def test_cierra_cursor_tras_multiple(self):
        """El cursor se cierra después de múltiples resultsets."""
        from utils.helpers import ejecutar_procedimiento_multiple

        with patch('utils.helpers.get_mysql') as mock_get_mysql:
            mock_mysql = MagicMock()
            mock_cursor = MagicMock()
            mock_get_mysql.return_value = mock_mysql
            mock_mysql.connection.cursor.return_value = mock_cursor
            mock_cursor.fetchall.return_value = []
            mock_cursor.nextset.return_value = False

            ejecutar_procedimiento_multiple('sp_test')
            mock_cursor.close.assert_called_once()