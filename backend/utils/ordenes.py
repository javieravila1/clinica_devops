from flask import Blueprint, render_template, request, jsonify, session, redirect, url_for, flash
from datetime import datetime
from utils.auth import login_required, role_required

ordenes_bp = Blueprint('ordenes', __name__)

def get_mysql():
    """Get mysql instance dynamically to avoid import timing issues"""
    from utils.database import mysql
    return mysql

@ordenes_bp.route('/ordenes')
@login_required
@role_required(['admin', 'profesional'])
def ordenes():
    try:
        mysql = get_mysql()
        
        # Obtener órdenes médicas
        cur = mysql.connection.cursor()
        cur.callproc('obtener_ordenes_medicas')
        ordenes_list = cur.fetchall()
        cur.close()
        
        # Obtener pacientes activos
        cur = mysql.connection.cursor()
        cur.callproc('obtener_pacientes_activos')
        pacientes = cur.fetchall()
        cur.close()
        
        # Obtener profesionales activos
        cur = mysql.connection.cursor()
        cur.callproc('obtener_profesionales_activos')
        profesionales = cur.fetchall()
        cur.close()
        
        # Obtener medicamentos activos
        cur = mysql.connection.cursor()
        cur.execute("SELECT * FROM medicamentos WHERE estado_id = 1")
        medicamentos = cur.fetchall()
        cur.close()
        
        # Obtener estados para órdenes
        cur = mysql.connection.cursor()
        cur.callproc('obtener_estados_por_entidad', ['orden_medica'])
        estados = cur.fetchall()
        cur.close()
        
        return render_template('ordenes.html',
                             ordenes=ordenes_list,
                             pacientes=pacientes,
                             profesionales=profesionales,
                             medicamentos=medicamentos,
                             estados=estados,
                             now=datetime.now())
    except Exception as e:
        print(f"Error en ordenes: {str(e)}")
        flash(f'Error al obtener órdenes: {str(e)}', 'error')
        return render_template('ordenes.html',
                             ordenes=[],
                             pacientes=[],
                             profesionales=[],
                             medicamentos=[],
                             estados=[],
                             now=datetime.now())

@ordenes_bp.route('/ordenes/crear', methods=['POST'])
@login_required
@role_required(['admin', 'profesional'])
def crear_orden():
    try:
        mysql = get_mysql()
        datos = {
            'paciente_id': request.form['paciente_id'],
            'profesional_id': request.form['profesional_id'],
            'tipo_orden': request.form['tipo_orden'],
            'descripcion': request.form['descripcion'],
            'medicamento_id': request.form.get('medicamento_id') or None,
            'dosis': request.form.get('dosis') or None,
            'frecuencia': request.form.get('frecuencia') or None,
            'duracion': request.form.get('duracion') or None,
            'fecha_inicio': request.form['fecha_inicio'],
            'fecha_fin': request.form.get('fecha_fin') or None,
            'observaciones': request.form.get('observaciones') or None,
            'usuario_id': session['user_id']
        }
        
        cur = mysql.connection.cursor()
        cur.callproc('ordenCrear', [
            datos['paciente_id'],
            datos['profesional_id'],
            datos['tipo_orden'],
            datos['descripcion'],
            datos['medicamento_id'],
            datos['dosis'],
            datos['frecuencia'],
            datos['duracion'],
            datos['fecha_inicio'],
            datos['fecha_fin'],
            datos['observaciones'],
            datos['usuario_id']
        ])
        mysql.connection.commit()
        cur.close()
        
        flash('Orden médica creada exitosamente', 'success')
        return redirect(url_for('ordenes.ordenes'))
        
    except Exception as e:
        print(f"Error al crear orden: {str(e)}")
        flash(f'Error al crear orden: {str(e)}', 'error')
        return redirect(url_for('ordenes.ordenes'))

@ordenes_bp.route('/api/ordenes/<int:orden_id>')
@login_required
@role_required(['admin', 'profesional'])
def api_obtener_orden(orden_id):
    try:
        mysql = get_mysql()
        cur = mysql.connection.cursor()
        cur.callproc('obtener_orden_por_id', [orden_id])
        orden = cur.fetchone()
        cur.close()
        
        if orden:
            return jsonify(orden)
        else:
            return jsonify({'error': 'Orden no encontrada'}), 404
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@ordenes_bp.route('/ordenes/editar/<int:orden_id>', methods=['POST'])
@login_required
@role_required(['admin', 'profesional'])
def editar_orden(orden_id):
    try:
        mysql = get_mysql()
        datos = {
            'descripcion': request.form['descripcion'],
            'dosis': request.form.get('dosis') or None,
            'frecuencia': request.form.get('frecuencia') or None,
            'duracion': request.form.get('duracion') or None,
            'fecha_fin': request.form.get('fecha_fin') or None,
            'estado_id': request.form['estado_id'],
            'observaciones': request.form.get('observaciones') or None,
            'usuario_id': session['user_id']
        }
        
        cur = mysql.connection.cursor()
        cur.callproc('ordenActualizar', [
            orden_id,
            datos['descripcion'],
            datos['dosis'],
            datos['frecuencia'],
            datos['duracion'],
            datos['fecha_fin'],
            datos['estado_id'],
            datos['observaciones'],
            datos['usuario_id']
        ])
        mysql.connection.commit()
        cur.close()
        
        return jsonify({
            'success': True,
            'message': 'Orden actualizada exitosamente'
        })
        
    except Exception as e:
        print(f"Error al actualizar orden: {str(e)}")
        return jsonify({'success': False, 'message': str(e)}), 500

@ordenes_bp.route('/api/ordenes/paciente/<int:paciente_id>')
@login_required
def ordenes_paciente(paciente_id):
    """Obtener órdenes de un paciente específico"""
    try:
        mysql = get_mysql()
        cur = mysql.connection.cursor()
        cur.callproc('obtener_ordenes_por_paciente', [paciente_id])
        ordenes = cur.fetchall()
        cur.close()
        return jsonify(ordenes)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
