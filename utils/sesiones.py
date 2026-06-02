from flask import Blueprint, render_template, request, jsonify, session, redirect, url_for, flash
from datetime import datetime
import json
from utils.auth import login_required, role_required

sesiones_bp = Blueprint('sesiones', __name__)

def get_mysql():
    """Get mysql instance dynamically to avoid import timing issues"""
    from utils.database import mysql
    return mysql

@sesiones_bp.route('/sesiones')
@login_required
@role_required(['admin', 'profesional'])
def sesiones():
    try:
        mysql = get_mysql()
        cur = mysql.connection.cursor()
        cur.callproc('obtener_sesiones_detalladas')
        sesiones_list = cur.fetchall()
        cur.close()
        # Si el usuario es un profesional, filtrar por su persona_id
        if session.get('tipo_persona') == 'profesional' and 'profesional' in session.get('user_roles', []):
            prof_id = session.get('persona_id')
            sesiones_list = [s for s in sesiones_list if s.get('profesional_id') == prof_id]

        return render_template('sesiones.html', 
                             sesiones=sesiones_list,
                             now=datetime.now())
    except Exception as e:
        flash(f'Error al obtener sesiones: {str(e)}', 'error')
        return render_template('sesiones.html', 
                             sesiones=[],
                             now=datetime.now())

@sesiones_bp.route('/sesiones/registrar', methods=['POST'])
@login_required
@role_required(['admin', 'profesional'])
def registrar_sesion():
    try:
        mysql = get_mysql()
        datos = {
            'cita_id': request.form['cita_id'],
            'notas': request.form.get('notas', ''),
            'tecnica_utilizada': request.form.get('tecnica_utilizada', ''),
            'duracion_real_min': request.form.get('duracion_real_min'),
            'usuario_id': session['user_id']
        }
        
        # Procesar puntajes de escalas
        puntajes = []
        i = 0
        while f'escala_id_{i}' in request.form:
            puntajes.append({
                'escala_id': request.form[f'escala_id_{i}'],
                'puntaje': request.form[f'puntaje_{i}']
            })
            i += 1
        
        cur = mysql.connection.cursor()
        
        # Usar procedimiento para registrar sesión completa
        cur.callproc('registrar_sesion_completa', [
            datos['cita_id'],
            datos['notas'],
            datos['tecnica_utilizada'],
            datos['duracion_real_min'],
            datos['usuario_id'],
            json.dumps(puntajes) if puntajes else None
        ])
        mysql.connection.commit()
        cur.close()
        
        flash('Sesión registrada exitosamente', 'success')
        return redirect(url_for('sesiones.sesiones'))
        
    except Exception as e:
        mysql.connection.rollback()
        flash(f'Error al registrar sesión: {str(e)}', 'error')
        return redirect(url_for('sesiones.sesiones'))

@sesiones_bp.route('/api/sesiones/<int:sesion_id>')
@login_required
@role_required(['admin', 'profesional'])
def api_obtener_sesion(sesion_id):
    try:
        mysql = get_mysql()
        cur = mysql.connection.cursor()
        cur.callproc('obtener_sesion_por_id', [sesion_id])
        sesion = cur.fetchone()
        cur.close()
        
        if sesion:
            return jsonify(sesion)
        else:
            return jsonify({'error': 'Sesión no encontrada'}), 404
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@sesiones_bp.route('/api/escalas')
@login_required
def obtener_escalas():
    try:
        mysql = get_mysql()
        cur = mysql.connection.cursor()
        cur.callproc('obtener_escalas_activas')
        escalas = cur.fetchall()
        cur.close()
        return jsonify(escalas)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
