from flask import Blueprint, render_template, request, jsonify, session, redirect, url_for, flash
from datetime import datetime
from utils.auth import login_required, role_required

asignaciones_bp = Blueprint('asignaciones', __name__)

def get_mysql():
    """Get mysql instance dynamically to avoid import timing issues"""
    from utils.database import mysql
    return mysql

@asignaciones_bp.route('/asignaciones')
@login_required
@role_required(['admin', 'profesional', 'recepcion'])
def asignaciones():
    try:
        mysql = get_mysql()
        
        # Obtener asignaciones de cama
        cur = mysql.connection.cursor()
        cur.callproc('obtener_asignaciones_cama')
        asignaciones_cama = cur.fetchall()
        cur.close()
        
        # Obtener asignaciones de paciente (enfermeras y profesionales)
        cur = mysql.connection.cursor()
        cur.callproc('obtener_asignaciones_personal')
        asignaciones_personal = cur.fetchall()
        cur.close()
        
        # Obtener pacientes activos
        cur = mysql.connection.cursor()
        cur.callproc('obtener_pacientes_activos')
        pacientes = cur.fetchall()
        cur.close()
        
        # Obtener camas disponibles
        cur = mysql.connection.cursor()
        cur.callproc('obtener_camas_disponibles')
        camas = cur.fetchall()
        cur.close()
        
        # Obtener enfermeras activas
        cur = mysql.connection.cursor()
        cur.callproc('obtener_enfermeras_activas')
        enfermeras = cur.fetchall()
        cur.close()
        
        # Obtener profesionales activos
        cur = mysql.connection.cursor()
        cur.callproc('obtener_profesionales_activos')
        profesionales = cur.fetchall()
        cur.close()
        
        # Obtener estados
        cur = mysql.connection.cursor()
        cur.callproc('obtener_estados_por_entidad', ['asignacion'])
        estados = cur.fetchall()
        cur.close()
        
        return render_template('asignaciones.html',
                             asignaciones_cama=asignaciones_cama,
                             asignaciones_personal=asignaciones_personal,
                             pacientes=pacientes,
                             camas=camas,
                             enfermeras=enfermeras,
                             profesionales=profesionales,
                             estados=estados,
                             now=datetime.now())
    except Exception as e:
        print(f"Error en asignaciones: {str(e)}")
        flash(f'Error al obtener asignaciones: {str(e)}', 'error')
        return render_template('asignaciones.html',
                             asignaciones_cama=[],
                             asignaciones_personal=[],
                             pacientes=[],
                             camas=[],
                             enfermeras=[],
                             profesionales=[],
                             estados=[],
                             now=datetime.now())

@asignaciones_bp.route('/asignaciones/cama/crear', methods=['POST'])
@login_required
@role_required(['admin', 'recepcion'])
def crear_asignacion_cama():
    try:
        mysql = get_mysql()
        datos = {
            'paciente_id': request.form['paciente_id'],
            'cama_id': request.form['cama_id'],
            'fecha_ingreso': request.form['fecha_ingreso'],
            'motivo_ingreso': request.form.get('motivo_ingreso') or None,
            'usuario_id': session['user_id']
        }
        
        cur = mysql.connection.cursor()
        cur.callproc('asignacionCamaCrear', [
            datos['paciente_id'],
            datos['cama_id'],
            datos['fecha_ingreso'],
            datos['motivo_ingreso'],
            datos['usuario_id']
        ])
        mysql.connection.commit()
        cur.close()
        
        flash('Asignación de cama creada exitosamente', 'success')
        return redirect(url_for('asignaciones.asignaciones'))
        
    except Exception as e:
        print(f"Error al crear asignación de cama: {str(e)}")
        flash(f'Error al crear asignación: {str(e)}', 'error')
        return redirect(url_for('asignaciones.asignaciones'))

@asignaciones_bp.route('/asignaciones/cama/egreso/<int:asignacion_id>', methods=['POST'])
@login_required
@role_required(['admin', 'recepcion'])
def egreso_cama(asignacion_id):
    try:
        mysql = get_mysql()
        datos = {
            'fecha_egreso': request.form['fecha_egreso'],
            'motivo_egreso': request.form.get('motivo_egreso') or None,
            'usuario_id': session['user_id']
        }
        
        cur = mysql.connection.cursor()
        cur.callproc('asignacionCamaEgreso', [
            asignacion_id,
            datos['fecha_egreso'],
            datos['motivo_egreso'],
            datos['usuario_id']
        ])
        mysql.connection.commit()
        cur.close()
        
        return jsonify({
            'success': True,
            'message': 'Egreso registrado exitosamente'
        })
        
    except Exception as e:
        print(f"Error al registrar egreso: {str(e)}")
        return jsonify({'success': False, 'message': str(e)}), 500

@asignaciones_bp.route('/asignaciones/personal/crear', methods=['POST'])
@login_required
@role_required(['admin', 'profesional'])
def crear_asignacion_personal():
    try:
        mysql = get_mysql()
        
        enfermera_id = request.form.get('enfermera_id') or None
        profesional_id = request.form.get('profesional_id') or None
        
        # Determinar tipo de asignación basado en quién se está asignando
        if enfermera_id and profesional_id:
            tipo_asignacion = 'especialista'  # Si ambos están asignados
        elif enfermera_id:
            tipo_asignacion = 'enfermera_asignada'
        elif profesional_id:
            tipo_asignacion = 'medico_tratante'
        else:
            tipo_asignacion = None  # El stored procedure manejará el error
        
        datos = {
            'paciente_id': request.form['paciente_id'],
            'enfermera_id': enfermera_id,
            'profesional_id': profesional_id,
            'tipo_asignacion': tipo_asignacion,
            'fecha_asignacion': request.form['fecha_asignacion'],
            'fecha_fin': request.form.get('fecha_fin_asignacion') or None,
            'es_principal': request.form.get('es_principal', 0),  # Default 0 si no viene
            'observaciones': request.form.get('observaciones') or None,
            'usuario_id': session['user_id']
        }
        
        cur = mysql.connection.cursor()
        cur.callproc('asignacionPersonalCrear', [
            datos['paciente_id'],
            datos['enfermera_id'],
            datos['profesional_id'],
            datos['tipo_asignacion'],
            datos['fecha_asignacion'],
            datos['fecha_fin'],
            datos['es_principal'],
            datos['observaciones'],
            datos['usuario_id']
        ])
        mysql.connection.commit()
        cur.close()
        
        flash('Asignación de personal creada exitosamente', 'success')
        return redirect(url_for('asignaciones.asignaciones'))
        
    except Exception as e:
        print(f"Error al crear asignación de personal: {str(e)}")
        flash(f'Error al crear asignación: {str(e)}', 'error')
        return redirect(url_for('asignaciones.asignaciones'))

@asignaciones_bp.route('/api/asignaciones/paciente/<int:paciente_id>')
@login_required
def asignaciones_paciente(paciente_id):
    """Obtener todas las asignaciones de un paciente"""
    try:
        mysql = get_mysql()
        
        # Asignaciones de cama
        cur = mysql.connection.cursor()
        cur.callproc('obtener_asignaciones_cama_paciente', [paciente_id])
        camas = cur.fetchall()
        cur.close()
        
        # Asignaciones de personal
        cur = mysql.connection.cursor()
        cur.callproc('obtener_asignaciones_personal_paciente', [paciente_id])
        personal = cur.fetchall()
        cur.close()
        
        return jsonify({
            'camas': camas,
            'personal': personal
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@asignaciones_bp.route('/api/asignaciones/cama/<int:asignacion_id>')
@login_required
def asignacion_cama_detalle(asignacion_id):
    """Obtener detalles de una asignación de cama específica"""
    try:
        mysql = get_mysql()
        cur = mysql.connection.cursor()
        cur.callproc('obtener_asignacion_cama_detalle', [asignacion_id])
        asignacion = cur.fetchone()
        cur.close()
        
        if not asignacion:
            return jsonify({'error': 'Asignación no encontrada'}), 404
        
        return jsonify(asignacion)
    except Exception as e:
        print(f"Error al obtener asignación de cama: {str(e)}")
        return jsonify({'error': str(e)}), 500

@asignaciones_bp.route('/api/asignaciones/personal/<int:asignacion_id>')
@login_required
def asignacion_personal_detalle(asignacion_id):
    """Obtener detalles de una asignación de personal específica"""
    try:
        mysql = get_mysql()
        cur = mysql.connection.cursor()
        cur.callproc('obtener_asignacion_personal_detalle', [asignacion_id])
        asignacion = cur.fetchone()
        cur.close()
        
        if not asignacion:
            return jsonify({'error': 'Asignación no encontrada'}), 404
        
        return jsonify(asignacion)
    except Exception as e:
        print(f"Error al obtener asignación de personal: {str(e)}")
        return jsonify({'error': str(e)}), 500

@asignaciones_bp.route('/api/administracion-medicamentos')
@login_required
@role_required(['admin', 'profesional', 'recepcion'])
def administracion_medicamentos():
    """Obtener administración de medicamentos"""
    try:
        mysql = get_mysql()
        cur = mysql.connection.cursor()
        cur.callproc('obtener_administracion_medicamentos')
        administraciones = cur.fetchall()
        cur.close()
        return jsonify(administraciones)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Blueprint para familiares
familiares_bp = Blueprint('familiares', __name__)

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