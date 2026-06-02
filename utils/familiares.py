from flask import Blueprint, render_template, request, jsonify, session, redirect, url_for, flash
from datetime import datetime
from utils.auth import login_required, role_required

familiares_bp = Blueprint('familiares', __name__)

def get_mysql():
    """Get mysql instance dynamically to avoid import timing issues"""
    from utils.database import mysql
    return mysql

@familiares_bp.route('/familiares')
@login_required
@role_required(['admin', 'profesional', 'recepcion'])
def familiares():
    try:
        mysql = get_mysql()
        
        # Obtener familiares con información del paciente
        cur = mysql.connection.cursor()
        cur.callproc('obtener_familiares')
        familiares_list = cur.fetchall()
        cur.close()
        
        # Obtener pacientes activos
        cur = mysql.connection.cursor()
        cur.callproc('obtener_pacientes_activos')
        pacientes = cur.fetchall()
        cur.close()
        
        # Obtener estados
        cur = mysql.connection.cursor()
        cur.callproc('obtener_estados_por_entidad', ['familiar'])
        estados = cur.fetchall()
        cur.close()
        
        return render_template('familiares.html',
                             familiares=familiares_list,
                             pacientes=pacientes,
                             estados=estados,
                             now=datetime.now())
    except Exception as e:
        print(f"Error en familiares: {str(e)}")
        flash(f'Error al obtener familiares: {str(e)}', 'error')
        return render_template('familiares.html',
                             familiares=[],
                             pacientes=[],
                             estados=[],
                             now=datetime.now())

@familiares_bp.route('/familiares/crear', methods=['POST'])
@login_required
@role_required(['admin', 'recepcion'])
def crear_familiar():
    try:
        mysql = get_mysql()
        
        fecha_nacimiento = request.form.get('fecha_nacimiento') or None
        if fecha_nacimiento == '':
            fecha_nacimiento = None
            
        datos = {
            'paciente_id': request.form['paciente_id'],
            'tipo_parentesco': request.form['tipo_parentesco'],
            'nombre': request.form['nombre'],
            'apellido': request.form['apellido'],
            'segundo_apellido': request.form.get('segundo_apellido') or None,
            'fecha_nacimiento': fecha_nacimiento,
            'telefono': request.form.get('telefono') or None,
            'email': request.form.get('email') or None,
            'es_contacto_emergencia': 1 if request.form.get('es_contacto_emergencia') else 0,
            'observaciones': request.form.get('observaciones') or None,
            'usuario_id': session['user_id']
        }
        
        cur = mysql.connection.cursor()
        cur.callproc('familiarCrear', [
            datos['paciente_id'],
            datos['tipo_parentesco'],
            datos['nombre'],
            datos['apellido'],
            datos['segundo_apellido'],
            datos['fecha_nacimiento'],
            datos['telefono'],
            datos['email'],
            datos['es_contacto_emergencia'],
            datos['observaciones'],
            datos['usuario_id']
        ])
        mysql.connection.commit()
        cur.close()
        
        flash('Familiar registrado exitosamente', 'success')
        return redirect(url_for('familiares.familiares'))
        
    except Exception as e:
        print(f"Error al crear familiar: {str(e)}")
        flash(f'Error al registrar familiar: {str(e)}', 'error')
        return redirect(url_for('familiares.familiares'))

@familiares_bp.route('/api/familiares/<int:familiar_id>')
@login_required
def api_obtener_familiar(familiar_id):
    try:
        mysql = get_mysql()
        cur = mysql.connection.cursor()
        cur.callproc('obtener_familiar_por_id', [familiar_id])
        familiar = cur.fetchone()
        cur.close()
        
        if familiar:
            return jsonify(familiar)
        else:
            return jsonify({'error': 'Familiar no encontrado'}), 404
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@familiares_bp.route('/familiares/editar/<int:familiar_id>', methods=['POST'])
@login_required
@role_required(['admin', 'recepcion'])
def editar_familiar(familiar_id):
    try:
        mysql = get_mysql()
        
        fecha_nacimiento = request.form.get('fecha_nacimiento') or None
        if fecha_nacimiento == '':
            fecha_nacimiento = None
            
        datos = {
            'tipo_parentesco': request.form['tipo_parentesco'],
            'nombre': request.form['nombre'],
            'apellido': request.form['apellido'],
            'segundo_apellido': request.form.get('segundo_apellido') or None,
            'fecha_nacimiento': fecha_nacimiento,
            'telefono': request.form.get('telefono') or None,
            'email': request.form.get('email') or None,
            'es_contacto_emergencia': 1 if request.form.get('es_contacto_emergencia') else 0,
            'observaciones': request.form.get('observaciones') or None,
            'estado_id': request.form['estado_id'],
            'usuario_id': session['user_id']
        }
        
        cur = mysql.connection.cursor()
        cur.callproc('familiarActualizar', [
            familiar_id,
            datos['tipo_parentesco'],
            datos['nombre'],
            datos['apellido'],
            datos['segundo_apellido'],
            datos['fecha_nacimiento'],
            datos['telefono'],
            datos['email'],
            datos['es_contacto_emergencia'],
            datos['observaciones'],
            datos['estado_id'],
            datos['usuario_id']
        ])
        mysql.connection.commit()
        cur.close()
        
        return jsonify({
            'success': True,
            'message': 'Familiar actualizado exitosamente'
        })
        
    except Exception as e:
        print(f"Error al actualizar familiar: {str(e)}")
        return jsonify({'success': False, 'message': str(e)}), 500

@familiares_bp.route('/api/familiares/paciente/<int:paciente_id>')
@login_required
def familiares_paciente(paciente_id):
    """Obtener familiares de un paciente específico"""
    try:
        mysql = get_mysql()
        cur = mysql.connection.cursor()
        cur.callproc('obtener_familiares_por_paciente', [paciente_id])
        familiares = cur.fetchall()
        cur.close()
        return jsonify(familiares)
    except Exception as e:
        return jsonify({'error': str(e)}), 500