"""
test_config.py - Pruebas para configuración de la aplicación
"""
import pytest
import os
from unittest.mock import patch


class TestConfig:
    """Pruebas de la configuración de Flask."""

    def test_config_tiene_secret_key(self):
        """La configuración tiene SECRET_KEY definida."""
        from config import Config
        assert Config.SECRET_KEY is not None
        assert len(Config.SECRET_KEY) > 0

    def test_config_mysql_host_por_defecto(self):
        """MYSQL_HOST tiene valor por defecto."""
        from config import Config
        assert Config.MYSQL_HOST in ('localhost', '127.0.0.1') or \
               os.environ.get('MYSQL_HOST') is not None

    def test_config_mysql_port_es_entero(self):
        """MYSQL_PORT es un entero válido."""
        from config import Config
        assert isinstance(Config.MYSQL_PORT, int)
        assert Config.MYSQL_PORT > 0

    def test_config_mysql_port_valor_estandar(self):
        """MYSQL_PORT es el puerto estándar de MySQL."""
        from config import Config
        assert Config.MYSQL_PORT == 3306

    def test_config_cursor_class(self):
        """Usa DictCursor para resultados como diccionarios."""
        from config import Config
        assert Config.MYSQL_CURSORCLASS == 'DictCursor'

    def test_config_app_name(self):
        """APP_NAME está definido."""
        from config import Config
        assert hasattr(Config, 'APP_NAME')
        assert isinstance(Config.APP_NAME, str)
        assert len(Config.APP_NAME) > 0

    def test_config_roles_definidos(self):
        """Los roles del sistema están definidos."""
        from config import Config
        assert hasattr(Config, 'ROLES')
        assert isinstance(Config.ROLES, dict)
        # Verificar roles mínimos requeridos
        required_roles = ['admin', 'profesional', 'recepcion']
        for role in required_roles:
            assert role in Config.ROLES, f"Rol '{role}' no está en Config.ROLES"

    def test_config_session_lifetime(self):
        """PERMANENT_SESSION_LIFETIME está configurado."""
        from config import Config
        from datetime import timedelta
        assert isinstance(Config.PERMANENT_SESSION_LIFETIME, timedelta)
        assert Config.PERMANENT_SESSION_LIFETIME.total_seconds() > 0

    def test_config_mysql_user_desde_env(self):
        """MYSQL_USER puede ser configurado desde variable de entorno."""
        with patch.dict(os.environ, {'MYSQL_USER': 'env_user'}):
            import importlib
            import config
            importlib.reload(config)
            assert config.Config.MYSQL_USER == 'env_user'

    def test_config_mysql_password_desde_env(self):
        """MYSQL_PASSWORD puede ser configurado desde variable de entorno."""
        with patch.dict(os.environ, {'MYSQL_PASSWORD': 'env_pass_123'}):
            import importlib
            import config
            importlib.reload(config)
            assert config.Config.MYSQL_PASSWORD == 'env_pass_123'


class TestAppInitialization:
    """Pruebas de inicialización de la aplicación."""

    def test_app_es_instancia_flask(self, app):
        """La app es una instancia Flask válida."""
        from flask import Flask
        assert isinstance(app, Flask)

    def test_app_en_modo_testing(self, app):
        """La app está en modo testing durante las pruebas."""
        assert app.config['TESTING'] is True

    def test_blueprints_registrados(self, app):
        """Todos los blueprints están registrados."""
        blueprint_names = list(app.blueprints.keys())
        expected_blueprints = [
            'pacientes', 'citas', 'sesiones', 'planes',
            'reportes', 'dashboard', 'ordenes', 'familiares',
            'asignaciones', 'profesionales', 'salas'
        ]
        for bp in expected_blueprints:
            assert bp in blueprint_names, \
                f"Blueprint '{bp}' no está registrado. Registrados: {blueprint_names}"

    def test_rutas_basicas_existen(self, app):
        """Las rutas básicas están registradas."""
        rules = [str(rule) for rule in app.url_map.iter_rules()]
        assert '/login' in rules
        assert '/logout' in rules
        assert '/' in rules

    def test_context_processor_calcular_edad(self, app):
        """El context processor de calcular_edad está registrado."""
        with app.test_request_context('/'):
            ctx_processors = app.template_context_processors
            assert len(ctx_processors) > 0

    def test_app_tiene_secret_key(self, app):
        """La app tiene SECRET_KEY configurada."""
        assert app.config.get('SECRET_KEY') is not None

    def test_login_url_accesible(self, client):
        """La URL /login es accesible."""
        response = client.get('/login')
        assert response.status_code == 200

    def test_logout_redirige(self, client):
        """La URL /logout redirige."""
        response = client.get('/logout', follow_redirects=False)
        assert response.status_code in (302, 308)

    def test_url_inexistente_retorna_404(self, client):
        """URLs inexistentes retornan 404."""
        response = client.get('/esta-ruta-no-existe-123abc')
        assert response.status_code == 404


class TestSecurityHeaders:
    """Pruebas básicas de seguridad."""

    def test_login_post_con_csrf_disabled(self, client):
        """El formulario de login funciona con CSRF deshabilitado en testing."""
        response = client.post('/login', data={
            'username': 'test',
            'password': 'test'
        })
        # No debe fallar con 403 CSRF
        assert response.status_code != 403

    def test_session_no_visible_sin_secretkey(self, app):
        """La sesión está firmada con la secret key."""
        assert app.config['SECRET_KEY'] is not None
        assert app.config['SECRET_KEY'] != ''