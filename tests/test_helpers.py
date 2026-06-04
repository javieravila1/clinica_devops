"""Pruebas unitarias para utils/helpers.py"""
import pytest
from datetime import date, datetime
from unittest.mock import patch, MagicMock


class TestCalcularEdad:
    """Pruebas para la función calcular_edad"""

    def test_edad_correcta(self):
        from utils.helpers import calcular_edad
        hoy = date.today()
        nacimiento = date(hoy.year - 30, hoy.month, hoy.day)
        assert calcular_edad(nacimiento) == 30

    def test_edad_antes_de_cumpleaños(self):
        from utils.helpers import calcular_edad
        hoy = date.today()
        # Cumpleaños un día después
        import calendar
        day = min(hoy.day + 1, calendar.monthrange(hoy.year - 25, hoy.month)[1])
        nacimiento = date(hoy.year - 25, hoy.month, day)
        edad = calcular_edad(nacimiento)
        assert edad == 24

    def test_edad_con_none(self):
        from utils.helpers import calcular_edad
        assert calcular_edad(None) is None

    def test_edad_con_string(self):
        from utils.helpers import calcular_edad
        edad = calcular_edad('2000-01-01')
        assert isinstance(edad, int)
        assert edad >= 0

    def test_recien_nacido(self):
        from utils.helpers import calcular_edad
        assert calcular_edad(date.today()) == 0

    def test_mayor_de_edad(self):
        from utils.helpers import calcular_edad
        nacimiento = date(2000, 1, 1)
        edad = calcular_edad(nacimiento)
        assert edad >= 18
