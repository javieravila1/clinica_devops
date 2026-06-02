from flask import Blueprint, render_template, request, jsonify, session, redirect
import logging
from MySQLdb.cursors import DictCursor

salas_bp = Blueprint('salas', __name__, template_folder='templates')

def get_mysql():
    from utils.database import mysql
    return mysql

@salas_bp.route('/salas')
def salas():
    if 'user_id' not in session:
        return redirect('/login')
    
    try:
        mysql = get_mysql()
        cursor = mysql.connection.cursor(DictCursor)
        
        # Llamar al stored procedure usando CALL
        cursor.execute("CALL obtenerSalas(%s)", [True])
        salas = cursor.fetchall()
        
        cursor.close()
        
        return render_template('salas.html', salas=salas)
        
    except Exception as e:
        logging.error(f"Error al cargar salas: {str(e)}")
        return render_template('salas.html', salas=[])

@salas_bp.route('/api/salas/<int:sala_id>')
def obtener_sala(sala_id):
    if 'user_id' not in session:
        return jsonify({'error': 'No autorizado'}), 401
    
    try:
        mysql = get_mysql()
        cursor = mysql.connection.cursor(DictCursor)
        
        # Llamar al stored procedure usando CALL
        cursor.execute("CALL obtenerSalaPorId(%s)", [sala_id])
        sala = cursor.fetchone()
        
        cursor.close()
        
        if sala:
            return jsonify(sala)
        else:
            return jsonify({'error': 'Sala no encontrada'}), 404
            
    except Exception as e:
        logging.error(f"Error al obtener sala: {str(e)}")
        return jsonify({'error': 'Error del servidor'}), 500

@salas_bp.route('/salas/crear', methods=['POST'])
def crear_sala():
    if 'user_id' not in session:
        return jsonify({'error': 'No autorizado'}), 401
    
    if 'admin' not in session.get('user_roles', []):
        return jsonify({'error': 'No tiene permisos'}), 403
    
    try:
        data = request.get_json()
        
        mysql = get_mysql()
        cursor = mysql.connection.cursor()
        
        # Llamar al stored procedure usando CALL
        cursor.execute("CALL crearSala(%s, %s, %s)", [
            data['nombre'],
            data.get('descripcion'),
            data.get('capacidad', 1)
        ])
        
        mysql.connection.commit()
        cursor.close()
        
        return jsonify({'success': True, 'message': 'Sala creada exitosamente'})
        
    except Exception as e:
        logging.error(f"Error al crear sala: {str(e)}")
        return jsonify({'error': str(e)}), 500

@salas_bp.route('/salas/editar/<int:sala_id>', methods=['POST'])
def editar_sala(sala_id):
    if 'user_id' not in session:
        return jsonify({'error': 'No autorizado'}), 401
    
    if 'admin' not in session.get('user_roles', []):
        return jsonify({'error': 'No tiene permisos'}), 403
    
    try:
        data = request.form
        
        mysql = get_mysql()
        cursor = mysql.connection.cursor()
        
        # Llamar al stored procedure usando CALL
        cursor.execute("CALL actualizarSala(%s, %s, %s, %s, %s)", [
            sala_id,
            data['nombre'],
            data.get('descripcion'),
            data.get('capacidad', 1),
            data['estado_id']
        ])
        
        mysql.connection.commit()
        cursor.close()
        
        return jsonify({'success': True, 'message': 'Sala actualizada exitosamente'})
        
    except Exception as e:
        logging.error(f"Error al editar sala: {str(e)}")
        return jsonify({'error': 'Error al actualizar sala'}), 500

@salas_bp.route('/salas/cambiar-estado/<int:sala_id>', methods=['POST'])
def cambiar_estado_sala(sala_id):
    if 'user_id' not in session:
        return jsonify({'error': 'No autorizado'}), 401
    
    if 'admin' not in session.get('user_roles', []):
        return jsonify({'error': 'No tiene permisos'}), 403
    
    try:
        data = request.get_json()
        nuevo_estado = data.get('nuevo_estado')
        
        if nuevo_estado not in ['activa', 'inactiva', 'mantenimiento']:
            return jsonify({'error': 'Estado no válido'}), 400
        
        mysql = get_mysql()
        cursor = mysql.connection.cursor()
        
        # Llamar al stored procedure usando CALL
        cursor.execute("CALL cambiarEstadoSala(%s, %s)", [sala_id, nuevo_estado])
        
        mysql.connection.commit()
        cursor.close()
        
        return jsonify({'success': True, 'message': f'Sala {nuevo_estado} exitosamente'})
        
    except Exception as e:
        logging.error(f"Error al cambiar estado: {str(e)}")
        return jsonify({'error': 'Error del servidor'}), 500