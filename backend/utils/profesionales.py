from flask import Blueprint, render_template, request, jsonify, session, redirect
from werkzeug.security import generate_password_hash
import secrets
import logging
from MySQLdb.cursors import DictCursor
from datetime import time, timedelta
import json

profesionales_bp = Blueprint('profesionales', __name__, template_folder='templates')

def get_mysql():
    from utils.database import mysql
    return mysql

def convertir_timedelta_a_time(td):
    """Convierte un timedelta a un objeto time"""
    if isinstance(td, timedelta):
        total_seconds = int(td.total_seconds())
        hours = total_seconds // 3600
        minutes = (total_seconds % 3600) // 60
        return time(hour=hours, minute=minutes)
    return td

def procesar_profesionales(profesionales):
    """Procesa la lista de profesionales para convertir timedelta a time"""
    for profesional in profesionales:
        profesional['horario_inicio'] = convertir_timedelta_a_time(profesional.get('horario_inicio'))
        profesional['horario_fin'] = convertir_timedelta_a_time(profesional.get('horario_fin'))
    return profesionales

def serializar_profesional(profesional):
    """Convierte un profesional a un formato serializable para JSON"""
    if profesional:
        # Crear una copia para no modificar el original
        profesional_serializado = profesional.copy()
        
        # Convertir objetos time a string
        if 'horario_inicio' in profesional_serializado and profesional_serializado['horario_inicio']:
            if isinstance(profesional_serializado['horario_inicio'], time):
                profesional_serializado['horario_inicio'] = profesional_serializado['horario_inicio'].strftime('%H:%M:%S')
        
        if 'horario_fin' in profesional_serializado and profesional_serializado['horario_fin']:
            if isinstance(profesional_serializado['horario_fin'], time):
                profesional_serializado['horario_fin'] = profesional_serializado['horario_fin'].strftime('%H:%M:%S')
        
        # Convertir datetime a string si es necesario
        if 'created_at' in profesional_serializado and profesional_serializado['created_at']:
            if hasattr(profesional_serializado['created_at'], 'strftime'):
                profesional_serializado['created_at'] = profesional_serializado['created_at'].strftime('%Y-%m-%d %H:%M:%S')
        
        return profesional_serializado
    return profesional

@profesionales_bp.route('/profesionales')
def profesionales():
    if 'user_id' not in session:
        return redirect('/login')
    
    try:
        mysql = get_mysql()
        cursor = mysql.connection.cursor(DictCursor)
        
        # Llamar al stored procedure usando CALL
        cursor.execute("CALL obtenerProfesionales(%s)", [True])
        profesionales = cursor.fetchall()
        
        # Procesar los profesionales para convertir timedelta a time
        profesionales = procesar_profesionales(profesionales)
        
        cursor.close()
        
        return render_template('profesionales.html', profesionales=profesionales)
        
    except Exception as e:
        logging.error(f"Error al cargar profesionales: {str(e)}")
        return render_template('profesionales.html', profesionales=[])

@profesionales_bp.route('/api/profesionales/<int:profesional_id>')
def obtener_profesional(profesional_id):
    if 'user_id' not in session:
        return jsonify({'error': 'No autorizado'}), 401
    
    try:
        mysql = get_mysql()
        cursor = mysql.connection.cursor(DictCursor)
        
        # Llamar al stored procedure usando CALL
        cursor.execute("CALL obtenerProfesionalPorId(%s)", [profesional_id])
        profesional = cursor.fetchone()
        
        if profesional:
            # Procesar el profesional individual
            profesional['horario_inicio'] = convertir_timedelta_a_time(profesional.get('horario_inicio'))
            profesional['horario_fin'] = convertir_timedelta_a_time(profesional.get('horario_fin'))
            
            # Serializar el profesional para JSON
            profesional_serializado = serializar_profesional(profesional)
        
        cursor.close()
        
        if profesional:
            return jsonify(profesional_serializado)
        else:
            return jsonify({'error': 'Profesional no encontrado'}), 404
            
    except Exception as e:
        logging.error(f"Error al obtener profesional: {str(e)}")
        return jsonify({'error': 'Error del servidor'}), 500

@profesionales_bp.route('/profesionales/crear', methods=['POST'])
def crear_profesional():
    if 'user_id' not in session:
        return jsonify({'error': 'No autorizado'}), 401
    
    if 'admin' not in session.get('user_roles', []):
        return jsonify({'error': 'No tiene permisos'}), 403
    
    try:
        data = request.get_json()
        
        mysql = get_mysql()
        cursor = mysql.connection.cursor()
        
        # Llamar al stored procedure usando CALL
        cursor.execute("CALL crearProfesional(%s, %s, %s, %s, %s, %s, %s, %s)", [
            data['identificacion'],
            data['nombre'],
            data['apellido'],
            data['especialidad'],
            data['horario_inicio'],
            data['horario_fin'],
            data.get('telefono'),
            data.get('email')
        ])
        mysql.connection.commit()

        # Intentar obtener el profesional creado (por identificacion)
        identificacion = data['identificacion']
        cursor.execute("SELECT profesional_id, nombre, apellido, email FROM profesionales WHERE identificacion = %s ORDER BY profesional_id DESC LIMIT 1", (identificacion,))
        creado = cursor.fetchone()

        username = None
        temp_password = None
        try:
            if creado:
                profesional_id = creado[0] if isinstance(creado, tuple) else creado.get('profesional_id')
                nombre = creado[1] if isinstance(creado, tuple) else creado.get('nombre')
                apellido = creado[2] if isinstance(creado, tuple) else creado.get('apellido')
                email = creado[3] if isinstance(creado, tuple) else creado.get('email')

                # Generar username y contraseña temporal
                username = (nombre[0] + apellido).lower().replace(' ', '') if nombre and apellido else f"prof{profesional_id}"
                temp_password = data.get('identificacion') or secrets.token_urlsafe(8)
                passhash = generate_password_hash(temp_password)

                # Obtener estado activo para usuarios
                cursor.execute("SELECT estado_id FROM estados WHERE tipo_entidad = 'usuario' AND nombre = 'activo' LIMIT 1")
                row = cursor.fetchone()
                estado_activo_id = row[0] if row and isinstance(row, tuple) else (row.get('estado_id') if row else None)

                # Insertar usuario
                cursor.execute("INSERT INTO usuarios (username, passhash, email, persona_id, tipo_persona, estado_id) VALUES (%s, %s, %s, %s, 'profesional', %s)", (username, passhash, email or f"{username}@prof.temp", profesional_id, estado_activo_id))
                usuario_id = cursor.lastrowid

                # Asignar rol 'profesional' buscando rol_id por nombre
                cursor.execute("SELECT rol_id FROM roles WHERE nombre = %s AND estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad='rol' AND nombre='activo') LIMIT 1", ('profesional',))
                rol_row = cursor.fetchone()
                if rol_row:
                    rol_id = rol_row[0] if isinstance(rol_row, tuple) else rol_row.get('rol_id')
                    cursor.execute("INSERT INTO usuario_roles (usuario_id, rol_id) VALUES (%s, %s)", (usuario_id, rol_id))

                mysql.connection.commit()

        except Exception as e:
            logging.error(f"Error creando usuario para profesional: {e}")
            mysql.connection.rollback()

        cursor.close()

        resp = {'success': True, 'message': 'Profesional creado exitosamente'}
        if username and temp_password:
            resp['username'] = username
            resp['temporary_password'] = temp_password

        return jsonify(resp)
        
    except Exception as e:
        logging.error(f"Error al crear profesional: {str(e)}")
        return jsonify({'error': str(e)}), 500

@profesionales_bp.route('/profesionales/editar/<int:profesional_id>', methods=['POST'])
def editar_profesional(profesional_id):
    if 'user_id' not in session:
        return jsonify({'error': 'No autorizado'}), 401
    
    if 'admin' not in session.get('user_roles', []):
        return jsonify({'error': 'No tiene permisos'}), 403
    
    try:
        data = request.form
        
        mysql = get_mysql()
        cursor = mysql.connection.cursor()
        
        # Llamar al stored procedure usando CALL
        cursor.execute("CALL actualizarProfesional(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", [
            profesional_id,
            data['identificacion'],
            data['nombre'],
            data['apellido'],
            data['especialidad'],
            data['horario_inicio'],
            data['horario_fin'],
            data.get('telefono'),
            data.get('email'),
            data['estado_id']
        ])
        
        mysql.connection.commit()
        cursor.close()
        
        return jsonify({'success': True, 'message': 'Profesional actualizado exitosamente'})
        
    except Exception as e:
        logging.error(f"Error al editar profesional: {str(e)}")
        return jsonify({'error': 'Error al actualizar profesional'}), 500

@profesionales_bp.route('/profesionales/cambiar-estado/<int:profesional_id>', methods=['POST'])
def cambiar_estado_profesional(profesional_id):
    if 'user_id' not in session:
        return jsonify({'error': 'No autorizado'}), 401
    
    if 'admin' not in session.get('user_roles', []):
        return jsonify({'error': 'No tiene permisos'}), 403
    
    try:
        data = request.get_json()
        nuevo_estado = data.get('nuevo_estado')
        
        if nuevo_estado not in ['activo', 'inactivo']:
            return jsonify({'error': 'Estado no válido'}), 400
        
        mysql = get_mysql()
        cursor = mysql.connection.cursor()
        
        # Llamar al stored procedure usando CALL
        cursor.execute("CALL cambiarEstadoProfesional(%s, %s)", [profesional_id, nuevo_estado])
        
        mysql.connection.commit()
        cursor.close()
        
        return jsonify({'success': True, 'message': f'Profesional {nuevo_estado} exitosamente'})
        
    except Exception as e:
        logging.error(f"Error al cambiar estado: {str(e)}")
        return jsonify({'error': 'Error del servidor'}), 500