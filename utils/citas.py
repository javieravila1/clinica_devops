from flask import Blueprint, render_template, request, jsonify, session, redirect, url_for, flash
from datetime import datetime
from utils.auth import login_required, role_required

citas_bp = Blueprint('citas', __name__)

def get_mysql():
    """Get mysql instance dynamically to avoid import timing issues"""
    from utils.database import mysql
    return mysql

@citas_bp.route('/citas')
@login_required
@role_required(['admin', 'profesional', 'recepcion'])
def citas():
    try:
        mysql = get_mysql()
        # Usaremos un cursor por cada procedimiento para evitar conflictos
        cur = mysql.connection.cursor()
        cur.callproc('obtener_citas_hoy')
        citas_hoy = cur.fetchall()
        cur.close()

        cur = mysql.connection.cursor()
        cur.callproc('obtener_profesionales_activos')
        profesionales = cur.fetchall()
        cur.close()

        cur = mysql.connection.cursor()
        cur.callproc('obtener_salas_activas')
        salas = cur.fetchall()
        cur.close()

        cur = mysql.connection.cursor()
        cur.callproc('obtener_pacientes_activos')
        pacientes = cur.fetchall()
        cur.close()

        cur = mysql.connection.cursor()
        cur.callproc('obtener_motivos_cancelacion_activos')
        motivos = cur.fetchall()
        cur.close()

        cur = mysql.connection.cursor()
        cur.callproc('obtener_estados_por_entidad', ['cita'])
        estados_cita = cur.fetchall()
        cur.close()
        
        # Si el usuario es un profesional, filtrar por su persona_id
        if session.get('tipo_persona') == 'profesional' and 'profesional' in session.get('user_roles', []):
            prof_id = session.get('persona_id')
            citas_hoy = [c for c in citas_hoy if c.get('profesional_id') == prof_id]
            # Filtrar pacientes para mostrar solo los asociados a las citas del profesional
            paciente_ids = {c.get('paciente_id') for c in citas_hoy}
            pacientes = [p for p in pacientes if p.get('paciente_id') in paciente_ids]
            # Profesionales: mostrar solo al propio profesional en la lista
            profesionales = [p for p in profesionales if p.get('profesional_id') == prof_id]

        return render_template('citas.html', 
                             citas=citas_hoy, 
                             profesionales=profesionales,
                             salas=salas,
                             pacientes=pacientes,
                             motivos=motivos,
                             estados_cita=estados_cita,
                             now=datetime.now())
    except Exception as e:
        print(f"Error en citas: {str(e)}")
        flash(f'Error al obtener citas: {str(e)}', 'error')
        return render_template('citas.html', 
                             citas=[], 
                             profesionales=[],
                             salas=[],
                             pacientes=[],
                             motivos=[],
                             estados_cita=[],
                             now=datetime.now())

@citas_bp.route('/citas/agendar', methods=['POST'])
@login_required
@role_required(['admin', 'recepcion'])
def agendar_cita():
    try:
        mysql = get_mysql()
        datos = {
            'paciente_id': request.form['paciente_id'],
            'profesional_id': request.form['profesional_id'],
            'sala_id': request.form['sala_id'],
            'fecha_inicio': request.form['fecha_inicio'],
            'fecha_fin': request.form['fecha_fin']
        }
        
        # Validaciones adicionales en Python
        fecha_inicio = datetime.fromisoformat(datos['fecha_inicio'].replace('T', ' '))
        fecha_fin = datetime.fromisoformat(datos['fecha_fin'].replace('T', ' '))
        
        if fecha_inicio >= fecha_fin:
            flash('La fecha de inicio debe ser anterior a la fecha de fin', 'error')
            return redirect(url_for('citas.citas'))
        
        cur = mysql.connection.cursor()
        cur.callproc('citaAgendar', [
            datos['paciente_id'],
            datos['profesional_id'],
            datos['sala_id'],
            datos['fecha_inicio'],
            datos['fecha_fin']
        ])
        mysql.connection.commit()
        cur.close()
        
        flash('Cita agendada exitosamente', 'success')
        return redirect(url_for('citas.citas'))
        
    except Exception as e:
        flash(f'Error al agendar cita: {str(e)}', 'error')
        return redirect(url_for('citas.citas'))

@citas_bp.route('/citas/cancelar/<int:cita_id>', methods=['POST'])
@login_required
@role_required(['admin', 'recepcion'])
def cancelar_cita(cita_id):
    try:
        mysql = get_mysql()
        motivo_id = request.form['motivo_id']
        
        cur = mysql.connection.cursor()
        cur.callproc('citaCancelar', [cita_id, motivo_id, session['user_id']])
        mysql.connection.commit()
        cur.close()
        
        flash('Cita cancelada exitosamente', 'success')
        return redirect(url_for('citas.citas'))
        
    except Exception as e:
        flash(f'Error al cancelar cita: {str(e)}', 'error')
        return redirect(url_for('citas.citas'))

@citas_bp.route('/api/citas/<int:cita_id>')
@login_required
@role_required(['admin', 'profesional', 'recepcion'])
def api_obtener_cita(cita_id):
    try:
        mysql = get_mysql()
        cur = mysql.connection.cursor()
        cur.callproc('obtener_cita_por_id', [cita_id])
        cita = cur.fetchone()
        cur.close()
        
        if cita:
            return jsonify(cita)
        else:
            return jsonify({'error': 'Cita no encontrada'}), 404
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@citas_bp.route('/api/citas/pendientes')
@login_required
def citas_pendientes():
    try:
        mysql = get_mysql()
        cur = mysql.connection.cursor()
        cur.callproc('obtener_citas_pendientes')
        citas = cur.fetchall()
        cur.close()
        return jsonify(citas)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
