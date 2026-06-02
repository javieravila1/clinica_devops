from flask import Blueprint, render_template, request, jsonify, session, redirect, url_for, flash
from datetime import datetime
from utils.auth import login_required, role_required
from werkzeug.security import generate_password_hash
import secrets

pacientes_bp = Blueprint('pacientes', __name__)

def get_mysql():
    """Get mysql instance dynamically to avoid import timing issues"""
    from utils.database import mysql
    return mysql

@pacientes_bp.route('/pacientes')
@login_required
@role_required(['admin', 'profesional', 'recepcion'])
def pacientes():
    try:
        mysql = get_mysql()
        cur = mysql.connection.cursor()
        cur.callproc('obtener_pacientes_estados')
        pacientes_list = cur.fetchall()
        cur.close()

        cur = mysql.connection.cursor()
        cur.callproc('obtener_estados_por_entidad', ['paciente'])
        estados = cur.fetchall()
        cur.close()

        cur = mysql.connection.cursor()
        cur.callproc('obtener_pacientes_activos')
        pacientes_activos = cur.fetchall()
        cur.close()

        # Si el usuario es un profesional, limitar pacientes a los asociados a sus citas
        if session.get('tipo_persona') == 'profesional' and 'profesional' in session.get('user_roles', []):
            prof_id = session.get('persona_id')
            # Obtener pacientes relacionados vía citas
            cur = mysql.connection.cursor()
            pacientes_ids = set()
            try:
                cur.callproc('obtener_pacientes_por_profesional', [prof_id])
                pacientes_prof = cur.fetchall()
                pacientes_ids = {p.get('paciente_id') for p in pacientes_prof}
            except Exception:
                # Fallback: obtener pacientes desde citas
                cur.execute("SELECT DISTINCT paciente_id FROM citas WHERE profesional_id = %s", (prof_id,))
                rows = cur.fetchall()
                pacientes_ids = {r.get('paciente_id') for r in rows}
            cur.close()
            pacientes_list = [p for p in pacientes_list if p.get('paciente_id') in pacientes_ids]
            pacientes_activos = [p for p in pacientes_activos if p.get('paciente_id') in pacientes_ids]

        return render_template('pacientes.html', 
                             pacientes=pacientes_list, 
                             estados=estados,
                             pacientes_activos=pacientes_activos,
                             now=datetime.now())
    except Exception as e:
        flash(f'Error al obtener pacientes: {str(e)}', 'error')
        return render_template('pacientes.html', 
                             pacientes=[], 
                             estados=[],
                             pacientes_activos=[],
                             now=datetime.now())

@pacientes_bp.route('/pacientes/crear', methods=['POST'])
@login_required
@role_required(['admin', 'recepcion'])
def crear_paciente():
    try:
        mysql = get_mysql()
        # Procesar fecha_nacimiento - convertir cadena vacía a None
        fecha_nacimiento = request.form['fecha_nacimiento']
        if fecha_nacimiento == '':
            fecha_nacimiento = None
        
        # Procesar otros campos opcionales
        telefono = request.form.get('telefono', '') or None
        email = request.form.get('email', '') or None
        direccion = request.form.get('direccion', '') or None
        
        datos = {
            'identificacion': request.form['identificacion'],
            'nombre': request.form['nombre'],
            'apellido': request.form['apellido'],
            'fecha_nacimiento': fecha_nacimiento,
            'telefono': telefono,
            'email': email,
            'direccion': direccion,
            'usuario_id': session['user_id']
        }
        
        print(f"DEBUG: Datos a enviar a pacienteCrear: {datos}")
        
        # Crear el paciente usando el procedimiento con OUT parameter
        cur = mysql.connection.cursor()
        
        # Llamar al procedimiento con OUT parameter (se pasa 0 como placeholder para el OUT)
        cur.callproc('pacienteCrear', [
            datos['identificacion'],
            datos['nombre'],
            datos['apellido'],
            datos['fecha_nacimiento'],
            datos['telefono'],
            datos['email'],
            datos['direccion'],
            datos['usuario_id'],
            0  # placeholder para el OUT parameter p_paciente_id
        ])
        
        # Obtener el resultado del OUT parameter
        # El OUT parameter es el último valor en los resultados
        cur.execute("SELECT @_pacienteCrear_8 as paciente_id")
        result = cur.fetchone()
        paciente_id = result['paciente_id']
        
        print(f"DEBUG: Paciente creado con ID: {paciente_id}")
        
        # Crear usuario para el paciente
        # Generar username: primera letra del nombre + apellido + últimos 4 dígitos de identificación
        username = (datos['nombre'][0] + datos['apellido']).lower().replace(' ', '')
        
        # Generar contraseña temporal: usar la identificación del paciente
        temp_password = datos['identificacion'] if datos.get('identificacion') else secrets.token_urlsafe(8)
        passhash = generate_password_hash(temp_password)
        
        # Usar email del paciente si existe, sino crear uno temporal
        user_email = datos['email'] if datos['email'] else f"{username}@paciente.temp"
        
        # Obtener estado activo (asumiendo que es 1)
        estado_activo_id = 26
        
        print(f"DEBUG: Creando usuario - username: {username}, email: {user_email}")
        
        # Insertar usuario
        cur.execute("""
            INSERT INTO usuarios (username, passhash, email, persona_id, tipo_persona, estado_id)
            VALUES (%s, %s, %s, %s, 'paciente', %s)
        """, (username, passhash, user_email, paciente_id, estado_activo_id))
        
        # Obtener el ID del usuario recién creado
        usuario_id = cur.lastrowid
        
        print(f"DEBUG: Usuario creado con ID: {usuario_id}")
        
        # Asignar rol de paciente (rol_id = 5)
        cur.execute("""
            INSERT INTO usuario_roles (usuario_id, rol_id)
            VALUES (%s, 5)
        """, (usuario_id,))
        
        mysql.connection.commit()
        cur.close()
        
        flash(f'Paciente creado exitosamente. Usuario: {username}, Contraseña temporal: {temp_password}', 'success')
        return redirect(url_for('pacientes.pacientes'))
        
    except Exception as e:
        print(f"ERROR al crear paciente: {str(e)}")
        flash(f'Error al crear paciente: {str(e)}', 'error')
        return redirect(url_for('pacientes.pacientes'))

@pacientes_bp.route('/api/pacientes/<int:paciente_id>')
@login_required
@role_required(['admin', 'profesional', 'recepcion'])
def api_obtener_paciente(paciente_id):
    try:
        mysql = get_mysql()
        cur = mysql.connection.cursor()
        cur.callproc('obtener_paciente_por_id', [paciente_id])
        paciente = cur.fetchone()
        cur.close()
        
        if paciente:
            return jsonify(paciente)
        else:
            return jsonify({'error': 'Paciente no encontrado'}), 404
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@pacientes_bp.route('/pacientes/editar/<int:paciente_id>', methods=['POST'])
@login_required
@role_required(['admin', 'recepcion'])
def editar_paciente(paciente_id):
    try:
        mysql = get_mysql()
        # Procesar fecha_nacimiento - convertir cadena vacía a None
        fecha_nacimiento = request.form['fecha_nacimiento']
        if fecha_nacimiento == '':
            fecha_nacimiento = None
        
        # Procesar otros campos opcionales - convertir cadenas vacías a None
        telefono = request.form.get('telefono', '')
        if telefono == '':
            telefono = None
            
        email = request.form.get('email', '')
        if email == '':
            email = None
            
        direccion = request.form.get('direccion', '')
        if direccion == '':
            direccion = None
        
        datos = {
            'identificacion': request.form['identificacion'],
            'nombre': request.form['nombre'],
            'apellido': request.form['apellido'],
            'fecha_nacimiento': fecha_nacimiento,
            'telefono': telefono,
            'email': email,
            'direccion': direccion,
            'estado_id': request.form['estado_id'],
            'usuario_id': session['user_id']
        }
        
        print(f"DEBUG: Datos a enviar a pacienteActualizar: {datos}")
        
        # Usar el procedimiento pacienteActualizar
        cur = mysql.connection.cursor()
        cur.callproc('pacienteActualizar', [
            paciente_id,
            datos['identificacion'],
            datos['nombre'],
            datos['apellido'],
            datos['fecha_nacimiento'],
            datos['telefono'],
            datos['email'],
            datos['direccion'],
            datos['estado_id'],
            datos['usuario_id']
        ])
        mysql.connection.commit()
        cur.close()
        
        return jsonify({
            'success': True,
            'message': 'Paciente actualizado exitosamente'
        })
        
    except Exception as e:
        print(f"Error al actualizar paciente: {str(e)}")
        return jsonify({'success': False, 'message': str(e)}), 500

@pacientes_bp.route('/pacientes/cambiar-estado/<int:paciente_id>', methods=['POST'])
@login_required
@role_required(['admin', 'recepcion'])
def cambiar_estado_paciente(paciente_id):
    try:
        mysql = get_mysql()
        # Manejar tanto JSON como FormData
        if request.is_json:
            data = request.get_json()
            nuevo_estado = data.get('nuevo_estado')  # Cambiado de 'estado' a 'nuevo_estado'
        else:
            nuevo_estado = request.form.get('nuevo_estado')  # Cambiado de 'estado' a 'nuevo_estado'
        
        print(f"DEBUG: Cambiando estado del paciente {paciente_id} a {nuevo_estado}")  # Debug
        
        if not nuevo_estado:
            return jsonify({'success': False, 'message': 'Estado no proporcionado'}), 400
        
        # Mapear estado textual a estado_id
        estado_map = {
            'activo': 1,
            'suspendido': 2, 
            'inactivo': 3
        }
        
        estado_id = estado_map.get(nuevo_estado)
        if not estado_id:
            return jsonify({'success': False, 'message': 'Estado inválido'}), 400
        
        print(f"DEBUG: Llamando a cambiar_estado_paciente con estado_id: {estado_id}")  # Debug
        
        cur = mysql.connection.cursor()
        cur.callproc('cambiar_estado_paciente', [paciente_id, estado_id, session['user_id']])
        
        mysql.connection.commit()
        cur.close()
        
        return jsonify({
            'success': True,
            'message': f'Estado del paciente cambiado a {nuevo_estado} exitosamente'
        })
            
    except Exception as e:
        print(f"Error al cambiar estado del paciente: {str(e)}")
        return jsonify({'success': False, 'message': str(e)}), 500