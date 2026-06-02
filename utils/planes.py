from flask import Blueprint, render_template, request, jsonify, session, redirect, url_for, flash
from datetime import datetime
import json
from utils.auth import login_required, role_required

planes_bp = Blueprint('planes', __name__)

def get_mysql():
    """Get mysql instance dynamically to avoid import timing issues"""
    from utils.database import mysql
    return mysql

@planes_bp.route('/planes')
@login_required
@role_required(['admin', 'profesional'])
def planes():
    try:
        mysql = get_mysql()
        cur = mysql.connection.cursor()
        cur.callproc('obtener_datos_planes_completo')
        
        # Obtener el primer conjunto de resultados (planes)
        planes = cur.fetchall()
        
        # Avanzar al siguiente conjunto de resultados
        if cur.nextset():
            pacientes = cur.fetchall()
        else:
            pacientes = []
        
        cur.close()

        return render_template('planes.html', 
                             planes=planes,
                             pacientes=pacientes,
                             now=datetime.now())
    except Exception as e:
        print(f"Error detallado en planes: {str(e)}")
        flash(f'Error al obtener planes: {str(e)}', 'error')
        return render_template('planes.html', 
                             planes=[],
                             pacientes=[],
                             now=datetime.now())

@planes_bp.route('/planes/crear', methods=['POST'])
@login_required
@role_required(['admin', 'profesional'])
def crear_plan():
    try:
        mysql = get_mysql()
        datos = {
            'paciente_id': request.form['paciente_id'],
            'diagnostico_principal': request.form.get('diagnostico_principal', ''),
            'fecha_inicio': request.form['fecha_inicio'],
            'fecha_fin_estimada': request.form.get('fecha_fin_estimada'),
            'objetivos': request.form.getlist('objetivo_descripcion[]'),
            'usuario_id': session['user_id']
        }
        
        cur = mysql.connection.cursor()
        cur.callproc('planCrear', [
            datos['paciente_id'],
            datos['diagnostico_principal'],
            datos['fecha_inicio'],
            datos['fecha_fin_estimada'],
            json.dumps(datos['objetivos']),
            datos['usuario_id']
        ])
        mysql.connection.commit()
        cur.close()
        
        flash('Plan terapéutico creado exitosamente', 'success')
        return redirect(url_for('planes.planes'))
        
    except Exception as e:
        flash(f'Error al crear plan: {str(e)}', 'error')
        return redirect(url_for('planes.planes'))

@planes_bp.route('/planes/editar/<int:plan_id>', methods=['POST'])
@login_required
@role_required(['admin', 'profesional'])
def editar_plan(plan_id):
    try:
        mysql = get_mysql()
        datos = {
            'diagnostico_principal': request.form.get('diagnostico_principal', ''),
            'fecha_fin_estimada': request.form.get('fecha_fin_estimada'),
            'estado_id': request.form.get('estado_id'),
            'usuario_id': session['user_id']
        }
        
        cur = mysql.connection.cursor()
        cur.callproc('planActualizar', [
            plan_id,
            datos['diagnostico_principal'],
            datos['fecha_fin_estimada'],
            datos['estado_id'],
            datos['usuario_id']
        ])
        mysql.connection.commit()
        cur.close()
        
        return jsonify({
            'success': True,
            'message': 'Plan actualizado exitosamente'
        })
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@planes_bp.route('/api/planes/<int:plan_id>')
@login_required
@role_required(['admin', 'profesional'])
def api_obtener_plan(plan_id):
    try:
        mysql = get_mysql()
        cur = mysql.connection.cursor()
        cur.callproc('obtener_plan_por_id', [plan_id])
        plan = cur.fetchone()
        cur.close()
        
        if plan:
            return jsonify(plan)
        else:
            return jsonify({'error': 'Plan no encontrado'}), 404
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@planes_bp.route('/api/planes/<int:plan_id>/objetivos')
@login_required
@role_required(['admin', 'profesional'])
def api_obtener_objetivos_plan(plan_id):
    try:
        mysql = get_mysql()
        cur = mysql.connection.cursor()
        cur.callproc('obtener_objetivos_por_plan', [plan_id])
        objetivos = cur.fetchall()
        cur.close()
        return jsonify(objetivos)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@planes_bp.route('/planes/objetivos/<int:objetivo_id>/estado', methods=['POST'])
@login_required
@role_required(['admin', 'profesional'])
def cambiar_estado_objetivo(objetivo_id):
    try:
        mysql = get_mysql()
        nuevo_estado = request.form.get('estado_id') or request.json.get('estado_id')
        
        cur = mysql.connection.cursor()
        cur.callproc('cambiar_estado_objetivo', [objetivo_id, nuevo_estado, session['user_id']])
        mysql.connection.commit()
        cur.close()
        
        return jsonify({
            'success': True,
            'message': 'Estado del objetivo actualizado exitosamente'
        })
            
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@planes_bp.route('/api/motivos-cancelacion')
@login_required
def obtener_motivos():
    try:
        mysql = get_mysql()
        cur = mysql.connection.cursor()
        cur.callproc('obtener_motivos_cancelacion_activos')
        motivos = cur.fetchall()
        cur.close()
        return jsonify(motivos)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
