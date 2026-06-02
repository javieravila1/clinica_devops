from flask import Flask, render_template, request, session, redirect, url_for, flash
import logging
from config import Config

# Install pymysql as MySQLdb
import pymysql
pymysql.install_as_MySQLdb()

# Import database initialization
from utils.database import init_db

# Import utilities
from utils.auth import login_required
from utils.helpers import calcular_edad

# Import blueprints
from utils.pacientes import pacientes_bp
from utils.citas import citas_bp
from utils.sesiones import sesiones_bp
from utils.planes import planes_bp
from utils.reportes import reportes_bp
from utils.dashboard import dashboard_bp
from utils.ordenes import ordenes_bp
from utils.familiares import familiares_bp
from utils.asignaciones import asignaciones_bp
from utils.profesionales import profesionales_bp
from utils.salas import salas_bp

# Initialize Flask app
app = Flask(__name__)
app.config.from_object(Config)

# Initialize database
mysql = init_db(app)

# Register blueprints
app.register_blueprint(pacientes_bp)
app.register_blueprint(citas_bp)
app.register_blueprint(sesiones_bp)
app.register_blueprint(planes_bp)
app.register_blueprint(reportes_bp)
app.register_blueprint(dashboard_bp)
app.register_blueprint(ordenes_bp)
app.register_blueprint(familiares_bp)
app.register_blueprint(asignaciones_bp)
app.register_blueprint(profesionales_bp)
app.register_blueprint(salas_bp)

# Add helper functions to Jinja2 context
@app.context_processor
def utility_processor():
    return dict(calcular_edad=calcular_edad)

# ===== BASIC ROUTES =====
@app.route('/')
def index():
    if 'user_id' in session:
        return redirect(url_for('dashboard.dashboard'))
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        print(f"Intentando login para usuario: {username}")
        
        try:
            from werkzeug.security import check_password_hash

            # First, try to fetch the user record by username
            cur = mysql.connection.cursor()
            # Get user including stored passhash
            cur.execute("SELECT usuario_id, username, email, persona_id, tipo_persona, passhash FROM usuarios WHERE username = %s AND estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'usuario' AND nombre = 'activo')", (username,))
            user = cur.fetchone()
            cur.close()
            print(f"Resultado del login: {user}")

            if user:
                stored = user.get('passhash')
                authenticated = False
                if stored:
                    try:
                        authenticated = check_password_hash(stored, password)
                    except Exception:
                        # fallback for raw bcrypt hashes ($2a$, $2b$, ...)
                        try:
                            if stored.startswith('$2'):
                                import bcrypt
                                authenticated = bcrypt.checkpw(password.encode('utf-8'), stored.encode('utf-8'))
                        except Exception:
                            authenticated = False

                if authenticated:
                    # Successful authentication
                    session['user_id'] = user['usuario_id']
                    session['username'] = user['username']
                    session['email'] = user.get('email', '')
                    session['persona_id'] = user.get('persona_id', None)
                    session['tipo_persona'] = user.get('tipo_persona', '')

                    # Obtener roles del usuario
                    print(f"Obteniendo roles para usuario_id: {user['usuario_id']}")
                    cur = mysql.connection.cursor()
                    cur.callproc('usuarioRoles', [user['usuario_id']])
                    roles_result = cur.fetchall()
                    print(f"Roles obtenidos: {roles_result}")
                    cur.close()

                    session['user_roles'] = [rol['nombre_rol'] for rol in roles_result]
                    print(f"Roles asignados a session: {session['user_roles']}")
                    session.permanent = True

                    # Actualizar último login usando procedimiento si existe
                    try:
                        cur = mysql.connection.cursor()
                        cur.callproc('actualizar_ultimo_login', [user['usuario_id']])
                        mysql.connection.commit()
                        cur.close()
                    except Exception:
                        # ignore if procedure not present
                        pass

                    flash('Inicio de sesión exitoso', 'success')
                    return redirect(url_for('dashboard.dashboard'))
                else:
                    flash('Usuario o contraseña incorrectos', 'error')
            else:
                flash('Usuario o contraseña incorrectos', 'error')

        except Exception as e:
            app.logger.error(f"Error durante el login: {str(e)}")
            flash(f'Error al iniciar sesión: {str(e)}', 'error')
    
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    flash('Sesión cerrada exitosamente', 'success')
    return redirect(url_for('login'))

@app.route('/principal')
@login_required
def principal():
    return render_template('dashboard.html')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
