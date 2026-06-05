from flask import Blueprint, render_template, request, jsonify, session
from datetime import datetime
from utils.auth import login_required
from utils.helpers import ejecutar_procedimiento, ejecutar_procedimiento_multiple

dashboard_bp = Blueprint('dashboard', __name__)

@dashboard_bp.route('/dashboard')
@login_required
def dashboard():
    try:
        # Check if user is a patient
        is_patient = 'paciente' in session.get('user_roles', [])
        paciente_id = session.get('persona_id') if is_patient else None
        
        if is_patient and paciente_id:
            # Get patient-specific statistics
            return render_patient_dashboard(paciente_id)
        else:
            # Get general statistics for admin/professional users
            return render_general_dashboard()
                             
    except Exception as e:
        print(f"Error en dashboard: {str(e)}")
        from flask import flash
        flash(f'Error al cargar dashboard: {str(e)}', 'error')
        return render_template('dashboard.html', 
                             pacientes_activos=0,
                             citas_hoy=0,
                             citas_pendientes=0,
                             sesiones_mes=0,
                             tasa_adherencia=0,
                             citas=[],
                             is_patient=False,
                             now=datetime.now())

def render_general_dashboard():
    """Render dashboard for admin/professional users"""
    try:
        # Obtener estadísticas usando la función helper múltiple
        resultados_stats = ejecutar_procedimiento_multiple('dashboard_estadisticas_generales')
        
        print("=== DEBUG: Estructura de resultados_stats ===")  # Debug
        for i, resultado in enumerate(resultados_stats):
            print(f"Resultado {i}: {resultado}")
        
        # Obtener citas de hoy
        citas_hoy_list = ejecutar_procedimiento('obtener_citas_hoy')

        # Si el usuario es profesional, filtrar las estadísticas por su persona_id
        if 'profesional' in session.get('user_roles', []):
            prof_id = session.get('persona_id')
            # Filtrar citas
            citas_hoy_list = [c for c in (citas_hoy_list or []) if c.get('profesional_id') == prof_id]
            # Para estadísticas numéricas más precisas, obtener directamente desde la DB
            from utils.database import mysql
            cur = mysql.connection.cursor()
            # Pacientes activos: número de pacientes distintos atendidos por el profesional
            cur.execute("SELECT COUNT(DISTINCT paciente_id) as pacientes_activos FROM citas WHERE profesional_id = %s", (prof_id,))
            row = cur.fetchone()
            pacientes_activos = row['pacientes_activos'] if row else 0
            # Sesiones en el mes
            cur.execute("SELECT COUNT(*) as sesiones_mes FROM sesiones s JOIN citas c ON s.cita_id = c.cita_id WHERE c.profesional_id = %s AND MONTH(c.fecha_inicio) = MONTH(CURDATE()) AND YEAR(c.fecha_inicio) = YEAR(CURDATE())", (prof_id,))
            row = cur.fetchone()
            sesiones_mes = row['sesiones_mes'] if row else 0
            # Tasa de adherencia: citas atendidas / total citas para el profesional (último mes)
            cur.execute("SELECT SUM(CASE WHEN c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad='cita' AND nombre='completada') THEN 1 ELSE 0 END) as atendidas, COUNT(*) as totales FROM citas c WHERE c.profesional_id = %s AND DATE(c.fecha_inicio) = CURDATE()", (prof_id,))
            row = cur.fetchone()
            try:
                atendidas = int(row.get('atendidas', 0)) if row else 0
                totales = int(row.get('totales', 0)) if row else 0
                tasa_adherencia = round((atendidas / totales * 100) if totales > 0 else 0, 2)
            except Exception:
                tasa_adherencia = 0
            cur.close()
        
        # Procesar resultados del dashboard con manejo seguro
        pacientes_activos = 0
        citas_hoy = 0
        sesiones_mes = 0
        tasa_adherencia = 0
        
        if resultados_stats and len(resultados_stats) >= 4:
            # Procesar cada resultado
            if resultados_stats[0] and len(resultados_stats[0]) > 0:
                pacientes_activos = resultados_stats[0][0].get('pacientes_activos', 0) or 0
            
            if resultados_stats[1] and len(resultados_stats[1]) > 0:
                citas_hoy = resultados_stats[1][0].get('citas_hoy', 0) or 0
            
            if resultados_stats[2] and len(resultados_stats[2]) > 0:
                sesiones_mes = resultados_stats[2][0].get('sesiones_mes', 0) or 0
            
            if resultados_stats[3] and len(resultados_stats[3]) > 0:
                tasa_adherencia = resultados_stats[3][0].get('tasa_adherencia', 0) or 0
        
        # Calcular citas pendientes para hoy
        citas_pendientes = len([c for c in (citas_hoy_list or []) if c.get('estado_nombre') in ['programada', 'confirmada']]) if citas_hoy_list else 0
        
        return render_template('dashboard.html', 
                             pacientes_activos=pacientes_activos,
                             citas_hoy=citas_hoy,
                             citas_pendientes=citas_pendientes,
                             sesiones_mes=sesiones_mes,
                             tasa_adherencia=tasa_adherencia,
                             citas=citas_hoy_list,
                             is_patient=False,
                             now=datetime.now())
    except Exception as e:
        print(f"Error en render_general_dashboard: {str(e)}")
        raise

def render_patient_dashboard(paciente_id):
    """Render dashboard for patient users with their specific data"""
    try:
        from utils.database import mysql
        
        # Get patient-specific citas count for today
        cur = mysql.connection.cursor()
        cur.execute("""
            SELECT COUNT(*) as citas_hoy
            FROM citas c
            WHERE c.paciente_id = %s
            AND DATE(c.fecha_inicio) = CURDATE()
            AND c.estado_id IN (
                SELECT estado_id FROM estados 
                WHERE tipo_entidad = 'cita' 
                AND nombre IN ('programada', 'confirmada')
            )
        """, (paciente_id,))
        result = cur.fetchone()
        citas_hoy = result['citas_hoy'] if result else 0
        
        # Get patient's sessions this month
        cur.execute("""
            SELECT COUNT(*) as sesiones_mes
            FROM sesiones s
            JOIN citas c ON s.cita_id = c.cita_id
            WHERE c.paciente_id = %s
            AND MONTH(c.fecha_inicio) = MONTH(CURDATE())
            AND YEAR(c.fecha_inicio) = YEAR(CURDATE())
        """, (paciente_id,))
        result = cur.fetchone()
        sesiones_mes = result['sesiones_mes'] if result else 0
        
        # Get patient's active plan count
        cur.execute("""
            SELECT COUNT(*) as planes_activos
            FROM planes_terapeuticos pt
            WHERE pt.paciente_id = %s
            AND pt.estado_id = (
                SELECT estado_id FROM estados 
                WHERE tipo_entidad = 'plan' 
                AND nombre = 'activo'
            )
        """, (paciente_id,))
        result = cur.fetchone()
        planes_activos = result['planes_activos'] if result else 0
        
        # Get patient's today appointments
        cur.execute("""
            SELECT 
                c.cita_id,
                c.fecha_inicio as fecha_hora,
                e.nombre as estado_nombre,
                CONCAT(prof.nombre, ' ', prof.apellido) as profesional_nombre
            FROM citas c
            JOIN estados e ON c.estado_id = e.estado_id
            LEFT JOIN profesionales prof ON c.profesional_id = prof.profesional_id
            WHERE c.paciente_id = %s
            AND DATE(c.fecha_inicio) = CURDATE()
            ORDER BY c.fecha_inicio ASC
        """, (paciente_id,))
        citas_list = cur.fetchall()
        cur.close()
        
        # Calculate pending appointments
        citas_pendientes = len([c for c in citas_list if c.get('estado_nombre') in ['programada', 'confirmada']])
        
        return render_template('dashboard.html',
                             pacientes_activos=1,  # The patient themselves
                             citas_hoy=citas_hoy,
                             citas_pendientes=citas_pendientes,
                             sesiones_mes=sesiones_mes,
                             planes_activos=planes_activos,
                             tasa_adherencia=0,  # Can be calculated if needed
                             citas=citas_list,
                             is_patient=True,
                             paciente_id=paciente_id,
                             now=datetime.now())
    except Exception as e:
        print(f"Error en render_patient_dashboard: {str(e)}")
        raise

@dashboard_bp.route('/api/dashboard/estadisticas-generales')
@login_required
def api_estadisticas_generales():
    """Obtener estadísticas generales usando procedimiento almacenado"""
    try:
        # Check if user is a patient
        is_patient = 'paciente' in session.get('user_roles', [])
        paciente_id = session.get('persona_id') if is_patient else None
        
        if is_patient and paciente_id:
            # Return patient-specific stats
            from utils.database import mysql
            cur = mysql.connection.cursor()
            
            # Citas hoy
            cur.execute("""
                SELECT COUNT(*) as citas_hoy
                FROM citas WHERE paciente_id = %s AND DATE(fecha_inicio) = CURDATE()
            """, (paciente_id,))
            citas_result = cur.fetchone()
            
            # Sesiones este mes
            cur.execute("""
                SELECT COUNT(*) as sesiones_mes
                FROM sesiones s
                JOIN citas c ON s.cita_id = c.cita_id
                WHERE c.paciente_id = %s 
                AND MONTH(c.fecha_inicio) = MONTH(CURDATE()) 
                AND YEAR(c.fecha_inicio) = YEAR(CURDATE())
            """, (paciente_id,))
            sesiones_result = cur.fetchone()
            
            # Planes activos
            cur.execute("""
                SELECT COUNT(*) as planes_activos
                FROM planes_terapeuticos WHERE paciente_id = %s
                AND estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'plan' AND nombre = 'activo')
            """, (paciente_id,))
            planes_result = cur.fetchone()
            
            cur.close()
            
            data = {
                'pacientes_activos': 1,
                'citas_hoy': citas_result['citas_hoy'] if citas_result else 0,
                'sesiones_mes': sesiones_result['sesiones_mes'] if sesiones_result else 0,
                'planes_activos': planes_result['planes_activos'] if planes_result else 0,
                'tasa_adherencia': 0
            }
            
            return jsonify(data)
        
        # If profesional, compute stats scoped to the professional
        if 'profesional' in session.get('user_roles', []):
            prof_id = session.get('persona_id')
            from utils.database import mysql
            cur = mysql.connection.cursor()
            cur.execute("SELECT COUNT(DISTINCT paciente_id) as pacientes_activos FROM citas WHERE profesional_id = %s", (prof_id,))
            pa = cur.fetchone()
            cur.execute("SELECT COUNT(*) as citas_hoy FROM citas WHERE profesional_id = %s AND DATE(fecha_inicio) = CURDATE()", (prof_id,))
            ch = cur.fetchone()
            cur.execute("SELECT COUNT(*) as sesiones_mes FROM sesiones s JOIN citas c ON s.cita_id = c.cita_id WHERE c.profesional_id = %s AND MONTH(c.fecha_inicio) = MONTH(CURDATE()) AND YEAR(c.fecha_inicio) = YEAR(CURDATE())", (prof_id,))
            sm = cur.fetchone()
            cur.close()
            data = {
                'pacientes_activos': pa['pacientes_activos'] if pa else 0,
                'citas_hoy': ch['citas_hoy'] if ch else 0,
                'sesiones_mes': sm['sesiones_mes'] if sm else 0,
                'tasa_adherencia': 0
            }
            return jsonify(data)

        # Return general stats for non-patients
        resultados = ejecutar_procedimiento_multiple('dashboard_estadisticas_generales')
        
        # Procesar resultados
        data = {
            'pacientes_activos': 0,
            'citas_hoy': 0,
            'sesiones_mes': 0,
            'tasa_adherencia': 0
        }
        
        if resultados and len(resultados) >= 4:
            if resultados[0] and len(resultados[0]) > 0:
                data['pacientes_activos'] = resultados[0][0].get('pacientes_activos', 0) or 0
            if resultados[1] and len(resultados[1]) > 0:
                data['citas_hoy'] = resultados[1][0].get('citas_hoy', 0) or 0
            if resultados[2] and len(resultados[2]) > 0:
                data['sesiones_mes'] = resultados[2][0].get('sesiones_mes', 0) or 0
            if resultados[3] and len(resultados[3]) > 0:
                data['tasa_adherencia'] = float(resultados[3][0].get('tasa_adherencia', 0) or 0)
        
        return jsonify(data)
        
    except Exception as e:
        print(f"Error en api_estadisticas_generales: {str(e)}")
        return jsonify({'error': str(e)}), 500

@dashboard_bp.route('/api/dashboard/distribucion-citas')
@login_required
def api_distribucion_citas():
    """Obtener distribución de citas usando procedimiento almacenado"""
    try:
        # Check if user is a patient
        is_patient = 'paciente' in session.get('user_roles', [])
        paciente_id = session.get('persona_id') if is_patient else None
        
        if is_patient and paciente_id:
            # Get patient-specific distribution
            from utils.database import mysql
            cur = mysql.connection.cursor()
            cur.execute("""
                SELECT e.nombre as estado, COUNT(*) as cantidad
                FROM citas c
                JOIN estados e ON c.estado_id = e.estado_id
                WHERE c.paciente_id = %s
                GROUP BY e.nombre
            """, (paciente_id,))
            resultados = cur.fetchall()
            cur.close()
        else:
            # Get general distribution
            resultados = ejecutar_procedimiento('dashboard_distribucion_citas') or []
        
        # Procesar datos para gráfica de pie
        data = []
        
        for row in resultados:
            try:
                estado = row.get('estado', 'Sin estado')
                cantidad = int(row.get('cantidad', 0))
                data.append({
                    'name': estado,
                    'y': cantidad
                })
            except (KeyError, TypeError, ValueError) as e:
                print(f"Error procesando fila de distribución: {row}, error: {e}")
                continue
        
        # Si no hay datos, devolver datos de ejemplo
        if not data:
            data = [
                {'name': 'Programada', 'y': 5},
                {'name': 'Confirmada', 'y': 3},
                {'name': 'Completada', 'y': 8},
                {'name': 'Cancelada', 'y': 1}
            ]
        
        return jsonify(data)
        
    except Exception as e:
        print(f"Error en api_distribucion_citas: {str(e)}")
        # Devolver datos de ejemplo en caso de error
        return jsonify([
            {'name': 'Programada', 'y': 5},
            {'name': 'Confirmada', 'y': 3},
            {'name': 'Completada', 'y': 8},
            {'name': 'Cancelada', 'y': 1}
        ])

@dashboard_bp.route('/api/dashboard/progreso-planes')
@login_required
def api_progreso_planes():
    """Obtener progreso de planes usando procedimiento almacenado"""
    try:
        resultados = ejecutar_procedimiento('dashboard_progreso_planes') or []
        
        # Procesar datos para gráfica de barras/líneas
        pacientes = []
        progreso = []
        
        for row in resultados:
            try:
                paciente_nombre = row.get('paciente_nombre', 'Paciente')
                progreso_porcentaje = float(row.get('progreso_porcentaje', 0))
                pacientes.append(paciente_nombre)
                progreso.append(progreso_porcentaje)
            except (KeyError, TypeError, ValueError) as e:
                print(f"Error procesando fila de progreso: {row}, error: {e}")
                continue
        
        # Si no hay datos, devolver datos de ejemplo
        if not pacientes:
            pacientes = ['Paciente 1', 'Paciente 2', 'Paciente 3', 'Paciente 4', 'Paciente 5']
            progreso = [75, 60, 90, 45, 80]
        
        data = {
            'pacientes': pacientes,
            'progreso': progreso
        }
        
        return jsonify(data)
        
    except Exception as e:
        print(f"Error en api_progreso_planes: {str(e)}")
        # Devolver datos de ejemplo en caso de error
        return jsonify({
            'pacientes': ['Paciente 1', 'Paciente 2', 'Paciente 3', 'Paciente 4', 'Paciente 5'],
            'progreso': [75, 60, 90, 45, 80]
        })

@dashboard_bp.route('/api/dashboard/evolucion-sesiones')
@login_required
def api_evolucion_sesiones():
    """Obtener evolución de sesiones usando procedimiento almacenado"""
    try:
        # Check if user is a patient
        is_patient = 'paciente' in session.get('user_roles', [])
        paciente_id = session.get('persona_id') if is_patient else None
        
        if is_patient and paciente_id:
            # Get patient-specific evolution
            from utils.database import mysql
            cur = mysql.connection.cursor()
            cur.execute("""
                SELECT 
                    DATE_FORMAT(c.fecha_inicio, '%%b %%Y') as mes,
                    COUNT(*) as total_sesiones
                FROM sesiones s
                JOIN citas c ON s.cita_id = c.cita_id
                WHERE c.paciente_id = %s
                AND c.fecha_inicio >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
                GROUP BY DATE_FORMAT(c.fecha_inicio, '%%Y-%%m')
                ORDER BY c.fecha_inicio ASC
            """, (paciente_id,))
            resultados = cur.fetchall()
            cur.close()
        else:
            # Get general evolution
            resultados = ejecutar_procedimiento('dashboard_evolucion_sesiones') or []
        
        # Procesar datos para gráfica de líneas
        meses = []
        totales = []
        
        for row in resultados:
            try:
                mes = row.get('mes', 'Mes')
                total = int(row.get('total_sesiones', 0))
                meses.append(mes)
                totales.append(total)
            except (KeyError, TypeError, ValueError) as e:
                print(f"Error procesando fila de evolución: {row}, error: {e}")
                continue
        
        # Si no hay datos, devolver datos de ejemplo
        if not meses:
            from datetime import datetime, timedelta
            meses = []
            totales = []
            for i in range(6):
                month = datetime.now() - timedelta(days=30*i)
                meses.append(month.strftime('%b %Y'))
                totales.append(20 + i*5)
            meses.reverse()
            totales.reverse()
        
        data = {
            'meses': meses,
            'totales': totales
        }
        
        return jsonify(data)
        
    except Exception as e:
        print(f"Error en api_evolucion_sesiones: {str(e)}")
        # Devolver datos de ejemplo en caso de error
        from datetime import datetime, timedelta
        meses = []
        totales = []
        for i in range(6):
            month = datetime.now() - timedelta(days=30*i)
            meses.append(month.strftime('%b %Y'))
            totales.append(20 + i*5)
        meses.reverse()
        totales.reverse()
        
        return jsonify({
            'meses': meses,
            'totales': totales
        })

@dashboard_bp.route('/api/dashboard/adherencia-pacientes')
@login_required
def api_adherencia_pacientes():
    """Obtener adherencia por paciente usando procedimiento almacenado"""
    try:
        resultados = ejecutar_procedimiento('dashboard_adherencia_pacientes') or []
        
        # Procesar y validar datos
        processed_data = []
        
        for row in resultados:
            try:
                paciente_nombre = row.get('paciente_nombre', 'Paciente')
                tasa_adherencia = float(row.get('tasa_adherencia', 0))
                
                processed_data.append({
                    'paciente_nombre': paciente_nombre,
                    'tasa_adherencia': tasa_adherencia
                })
            except (KeyError, TypeError, ValueError) as e:
                print(f"Error procesando fila de adherencia: {row}, error: {e}")
                continue
        
        # Si no hay datos, devolver datos de ejemplo
        if not processed_data:
            processed_data = [
                {'paciente_nombre': 'Juan Pérez', 'tasa_adherencia': 95.5},
                {'paciente_nombre': 'María García', 'tasa_adherencia': 87.2},
                {'paciente_nombre': 'Carlos López', 'tasa_adherencia': 78.9},
                {'paciente_nombre': 'Ana Martínez', 'tasa_adherencia': 92.1},
                {'paciente_nombre': 'Pedro Rodríguez', 'tasa_adherencia': 84.7}
            ]
        
        return jsonify(processed_data)
        
    except Exception as e:
        print(f"Error en api_adherencia_pacientes: {str(e)}")
        # Devolver datos de ejemplo en caso de error
        return jsonify([
            {'paciente_nombre': 'Juan Pérez', 'tasa_adherencia': 95.5},
            {'paciente_nombre': 'María García', 'tasa_adherencia': 87.2},
            {'paciente_nombre': 'Carlos López', 'tasa_adherencia': 78.9},
            {'paciente_nombre': 'Ana Martínez', 'tasa_adherencia': 92.1},
            {'paciente_nombre': 'Pedro Rodríguez', 'tasa_adherencia': 84.7}
        ])