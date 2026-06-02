from flask import Blueprint, render_template, request, jsonify
from datetime import datetime, date
from utils.auth import login_required, role_required

reportes_bp = Blueprint('reportes', __name__)

def get_mysql():
    """Get mysql instance dynamically to avoid import timing issues"""
    from utils.database import mysql
    return mysql

@reportes_bp.route('/reportes')
@login_required
@role_required(['admin', 'auditor', 'profesional'])
def reportes():
    return render_template('reportes.html', now=datetime.now())

@reportes_bp.route('/api/reportes/metricas-principales')
@login_required
def metricas_principales():
    """Endpoint para métricas principales - usa datos del resumen"""
    try:
        mysql = get_mysql()
        desde = request.args.get('desde', date.today().replace(day=1).isoformat())
        hasta = request.args.get('hasta', date.today().isoformat())
        
        cur = mysql.connection.cursor()
        
        # Si el usuario es profesional, limitar por profesional_id
        prof_filter = ''
        params = [desde, hasta]
        if 'profesional' in session.get('user_roles', []):
            prof_id = session.get('persona_id')
            prof_filter = ' AND profesional_id = %s'
            params.append(prof_id)

        # Obtener total de citas
        cur.execute(f"""
            SELECT COUNT(*) as total_citas 
            FROM citas 
            WHERE DATE(fecha_inicio) BETWEEN %s AND %s {prof_filter}
        """, tuple(params))
        result = cur.fetchone()
        total_citas = result['total_citas'] if result else 0
        
        # Obtener citas atendidas (estado_id = 2)
        cur.execute(f"""
            SELECT COUNT(*) as citas_atendidas 
            FROM citas 
            WHERE DATE(fecha_inicio) BETWEEN %s AND %s 
            AND estado_id = 2 {prof_filter}
        """, tuple(params))
        result = cur.fetchone()
        citas_atendidas = result['citas_atendidas'] if result else 0
        
        # Obtener citas no show (estado_id = 4)
        cur.execute(f"""
            SELECT COUNT(*) as citas_noshow 
            FROM citas 
            WHERE DATE(fecha_inicio) BETWEEN %s AND %s 
            AND estado_id = 4 {prof_filter}
        """, tuple(params))
        result = cur.fetchone()
        citas_noshow = result['citas_noshow'] if result else 0
        
        # Calcular adherencia como porcentaje de citas atendidas
        tasa_adherencia = round((citas_atendidas / total_citas * 100) if total_citas > 0 else 0, 2)
        
        cur.close()
        
        # Calcular ocupación promedio
        ocupacion = round((citas_atendidas / total_citas * 100) if total_citas > 0 else 0, 2)
        
        data = {
            'adherencia': tasa_adherencia,
            'sesiones_completadas': citas_atendidas,
            'no_shows': citas_noshow,
            'ocupacion_promedio': ocupacion,
            'trend_adherencia': 2.5,
            'trend_sesiones': 5.1,
            'trend_noshows': -3.2,
            'trend_ocupacion': 1.8
        }
        
        return jsonify(data)
        
    except Exception as e:
        print(f"Error en metricas_principales: {str(e)}")
        return jsonify({'error': str(e)}), 500

@reportes_bp.route('/api/reportes/metricas-detalladas')
@login_required
def metricas_detalladas():
    """Endpoint para métricas detalladas"""
    try:
        mysql = get_mysql()
        desde = request.args.get('desde', date.today().replace(day=1).isoformat())
        hasta = request.args.get('hasta', date.today().isoformat())
        
        cur = mysql.connection.cursor()
        
        # Obtener datos para métricas detalladas
        prof_filter = ''
        params = [desde, hasta]
        if 'profesional' in session.get('user_roles', []):
            prof_id = session.get('persona_id')
            prof_filter = ' AND profesional_id = %s'
            params.append(prof_id)

        cur.execute(f"""
            SELECT 
                COUNT(*) as total_citas,
                SUM(CASE WHEN estado_id = 2 THEN 1 ELSE 0 END) as citas_atendidas,
                SUM(CASE WHEN estado_id = 4 THEN 1 ELSE 0 END) as citas_noshow,
                SUM(CASE WHEN estado_id = 3 THEN 1 ELSE 0 END) as citas_canceladas,
                COUNT(DISTINCT paciente_id) as pacientes_activos
            FROM citas
            WHERE DATE(fecha_inicio) BETWEEN %s AND %s {prof_filter}
        """, tuple(params))
        
        datos = cur.fetchone()
        cur.close()
        
        total_citas = datos['total_citas'] if datos else 0
        citas_atendidas = datos['citas_atendidas'] if datos else 0
        citas_noshow = datos['citas_noshow'] if datos else 0
        citas_canceladas = datos['citas_canceladas'] if datos else 0
        pacientes_activos = datos['pacientes_activos'] if datos else 0
        
        # Calcular adherencia
        adherencia_promedio = round((citas_atendidas / total_citas * 100) if total_citas > 0 else 0, 1)
        
        # Calcular tasa de cancelación
        tasa_cancelacion = round((citas_canceladas / total_citas * 100) if total_citas > 0 else 0, 1)
        
        # Crear métricas detalladas
        metricas = [
            {
                'nombre': 'Pacientes Activos',
                'valor': str(pacientes_activos),
                'porcentaje': min(100, pacientes_activos * 2)
            },
            {
                'nombre': 'Total de Citas',
                'valor': str(total_citas),
                'porcentaje': 100
            },
            {
                'nombre': 'Citas Atendidas',
                'valor': str(citas_atendidas),
                'porcentaje': adherencia_promedio
            },
            {
                'nombre': 'Tasa de Cancelación',
                'valor': f"{tasa_cancelacion}%",
                'porcentaje': tasa_cancelacion
            },
            {
                'nombre': 'No-Shows',
                'valor': str(citas_noshow),
                'porcentaje': round((citas_noshow / total_citas * 100) if total_citas > 0 else 0, 1)
            }
        ]
        
        data = {
            'metricas': metricas
        }
        
        return jsonify(data)
        
    except Exception as e:
        print(f"Error en metricas_detalladas: {str(e)}")
        return jsonify({'error': str(e)}), 500

@reportes_bp.route('/api/reportes/insights')
@login_required
def insights():
    """Endpoint para insights"""
    try:
        mysql = get_mysql()
        desde = request.args.get('desde', date.today().replace(day=1).isoformat())
        hasta = request.args.get('hasta', date.today().isoformat())
        
        cur = mysql.connection.cursor()
        
        # Obtener datos para insights - profesionales con mejor desempeño
        # Insights: si es profesional, devolver su propio desempeño
        if 'profesional' in session.get('user_roles', []):
            prof_id = session.get('persona_id')
            cur.execute("""
                SELECT 
                    CONCAT(p.nombre, ' ', p.apellido) as profesional,
                    COUNT(*) as total_citas,
                    SUM(CASE WHEN c.estado_id = 2 THEN 1 ELSE 0 END) as citas_atendidas,
                    ROUND((SUM(CASE WHEN c.estado_id = 2 THEN 1 ELSE 0 END) / COUNT(*) * 100), 1) as tasa_adherencia
                FROM citas c
                JOIN profesionales p ON c.profesional_id = p.profesional_id
                WHERE DATE(c.fecha_inicio) BETWEEN %s AND %s AND c.profesional_id = %s
                GROUP BY p.profesional_id, p.nombre
                LIMIT 1
            """, (desde, hasta, prof_id))
            mejor_profesional = cur.fetchone()
        else:
            cur.execute("""
                SELECT 
                    p.nombre as profesional,
                    COUNT(*) as total_citas,
                    SUM(CASE WHEN c.estado_id = 2 THEN 1 ELSE 0 END) as citas_atendidas,
                    ROUND((SUM(CASE WHEN c.estado_id = 2 THEN 1 ELSE 0 END) / COUNT(*) * 100), 1) as tasa_adherencia
                FROM citas c
                JOIN profesionales p ON c.profesional_id = p.profesional_id
                WHERE DATE(c.fecha_inicio) BETWEEN %s AND %s
                GROUP BY p.profesional_id, p.nombre
                HAVING COUNT(*) > 0
                ORDER BY tasa_adherencia DESC
                LIMIT 1
            """, (desde, hasta))
        
        mejor_profesional = cur.fetchone()
        
        # Obtener datos de salas con menor ocupación
        cur.execute("""
            SELECT 
                s.nombre as sala,
                COUNT(*) as total_citas,
                ROUND((COUNT(*) / (
                    SELECT COUNT(*) 
                    FROM citas 
                    WHERE DATE(fecha_inicio) BETWEEN %s AND %s
                ) * 100), 1) as porcentaje_uso
            FROM citas c
            JOIN salas s ON c.sala_id = s.sala_id
            WHERE DATE(c.fecha_inicio) BETWEEN %s AND %s
            GROUP BY s.sala_id, s.nombre
            ORDER BY porcentaje_uso ASC
            LIMIT 1
        """, (desde, hasta, desde, hasta))
        
        sala_menor_uso = cur.fetchone()
        
        cur.close()
        
        # Generar insights basados en los datos
        if mejor_profesional:
            mejor_desc = f"{mejor_profesional['profesional']} - Tasa de adherencia: {mejor_profesional['tasa_adherencia']}%"
            mejor_trend = f"+{mejor_profesional['tasa_adherencia']}%"
        else:
            mejor_desc = "Sin datos suficientes para análisis"
            mejor_trend = "N/A"
        
        if sala_menor_uso:
            mejora_desc = f"Optimizar {sala_menor_uso['sala']} - Ocupación: {sala_menor_uso['porcentaje_uso']}%"
            mejora_rec = "Revisar disponibilidad de horarios"
        else:
            mejora_desc = "Todas las salas tienen uso óptimo"
            mejora_rec = "Mantener el ritmo actual"
        
        data = {
            'mejor_desempeno': {
                'descripcion': mejor_desc,
                'trend': mejor_trend
            },
            'area_mejora': {
                'descripcion': mejora_desc,
                'recomendacion': mejora_rec
            }
        }
        
        return jsonify(data)
        
    except Exception as e:
        print(f"Error en insights: {str(e)}")
        return jsonify({'error': str(e)}), 500

@reportes_bp.route('/api/reportes/adherencia')
@login_required
def reportes_adherencia():
    """Ruta en plural para adherencia"""
    try:
        mysql = get_mysql()
        desde = request.args.get('desde', date.today().replace(day=1).isoformat())
        hasta = request.args.get('hasta', date.today().isoformat())
        
        cur = mysql.connection.cursor()
        
        # Query directo usando la estructura real
        cur.execute("""
            SELECT 
                pac.nombre as paciente_nombre,
                COUNT(*) as total_citas,
                SUM(CASE WHEN c.estado_id = 2 THEN 1 ELSE 0 END) as citas_atendidas,
                ROUND((SUM(CASE WHEN c.estado_id = 2 THEN 1 ELSE 0 END) / COUNT(*) * 100), 1) as tasa_adherencia
            FROM citas c
            JOIN pacientes pac ON c.paciente_id = pac.paciente_id
            WHERE DATE(c.fecha_inicio) BETWEEN %s AND %s
            GROUP BY pac.paciente_id, pac.nombre
            HAVING COUNT(*) >= 3
            ORDER BY tasa_adherencia DESC
            LIMIT 10
        """, (desde, hasta))
        resultados = cur.fetchall()
        
        cur.close()
        
        # Procesar datos para Highcharts
        categorias = []
        tasas_adherencia = []
        
        for row in resultados:
            if row.get('paciente_nombre') and row.get('tasa_adherencia') is not None:
                categorias.append(row['paciente_nombre'])
                tasas_adherencia.append(float(row['tasa_adherencia']))
        
        # Si no hay datos, devolver estructura vacía
        if not categorias:
            return jsonify({
                'categorias': ['Sin datos'],
                'series': [{
                    'name': 'Tasa de Adherencia (%)',
                    'data': [0]
                }]
            })
        
        data = {
            'categorias': categorias,
            'series': [{
                'name': 'Tasa de Adherencia (%)',
                'data': tasas_adherencia
            }]
        }
        
        return jsonify(data)
        
    except Exception as e:
        print(f"Error en reportes_adherencia: {str(e)}")
        return jsonify({'error': str(e)}), 500

@reportes_bp.route('/api/reporte/noshow')
@login_required
def reporte_noshow():
    """Reporte de no-shows por profesional y motivo"""
    try:
        mysql = get_mysql()
        desde = request.args.get('desde', date.today().replace(day=1).isoformat())
        hasta = request.args.get('hasta', date.today().isoformat())
        
        cur = mysql.connection.cursor()
        
        # Query usando la estructura real
        # Reporte de no-shows: si profesional, limitar a ese profesional
        prof_filter = ''
        params = [desde, hasta]
        if 'profesional' in session.get('user_roles', []):
            prof_id = session.get('persona_id')
            prof_filter = ' AND c.profesional_id = %s'
            params.append(prof_id)

        cur.execute(f"""
            SELECT 
                p.nombre as profesional_nombre,
                COALESCE(mc.descripcion, 'Sin motivo especificado') as motivo,
                COUNT(*) as cantidad
            FROM citas c
            JOIN profesionales p ON c.profesional_id = p.profesional_id
            LEFT JOIN motivos_cancelacion mc ON c.motivo_cancelacion_id = mc.motivo_id
            WHERE DATE(c.fecha_inicio) BETWEEN %s AND %s
            AND c.estado_id = 4 {prof_filter}
            GROUP BY p.profesional_id, p.nombre, mc.motivo_id, mc.descripcion
            ORDER BY p.nombre, cantidad DESC
        """, tuple(params))
        
        resultados = cur.fetchall()
        cur.close()
        
        # Procesar datos para gráfica de barras apiladas
        causas = set()
        datos_por_profesional = {}
        
        # Recopilar todas las causas únicas
        for row in resultados:
            if row['motivo']:
                causas.add(row['motivo'])
        
        causas = list(causas)
        
        # Organizar datos por profesional
        for row in resultados:
            prof_nombre = row['profesional_nombre'] or 'Sin Profesional'
            if prof_nombre not in datos_por_profesional:
                datos_por_profesional[prof_nombre] = {causa: 0 for causa in causas}
            datos_por_profesional[prof_nombre][row['motivo']] = int(row['cantidad'])
        
        # Crear series para Highcharts
        series = []
        for causa in causas:
            serie_data = []
            for profesional in datos_por_profesional:
                serie_data.append(datos_por_profesional[profesional].get(causa, 0))
            
            series.append({
                'name': causa,
                'data': serie_data
            })
        
        data = {
            'categorias': list(datos_por_profesional.keys()),
            'series': series
        }
        
        return jsonify(data)
        
    except Exception as e:
        print(f"Error en reporte_noshow: {str(e)}")
        return jsonify({'error': str(e)}), 500

@reportes_bp.route('/api/reporte/capacidad')
@login_required
def reporte_capacidad():
    """Reporte de capacidad por sala y franja horaria"""
    try:
        mysql = get_mysql()
        dia_semana = request.args.get('dia_semana', datetime.today().weekday() + 1)
        
        cur = mysql.connection.cursor()
        
        # Query usando la estructura real
        cur.execute("""
            SELECT 
                s.nombre as sala_nombre,
                CONCAT(
                    LPAD(HOUR(c.fecha_inicio), 2, '0'), ':00', 
                    ' - ', 
                    LPAD(HOUR(c.fecha_inicio) + 1, 2, '0'), ':00'
                ) as franja_horaria,
                COUNT(*) as citas_programadas,
                ROUND((COUNT(*) / 4 * 100), 1) as porcentaje_ocupacion
            FROM citas c
            JOIN salas s ON c.sala_id = s.sala_id
            WHERE DAYOFWEEK(c.fecha_inicio) = %s
            GROUP BY s.sala_id, s.nombre, HOUR(c.fecha_inicio)
            ORDER BY s.nombre, HOUR(c.fecha_inicio)
        """, (dia_semana,))
        
        resultados = cur.fetchall()
        cur.close()
        
        # Procesar datos para heatmap
        salas = []
        franjas = []
        
        # Recopilar salas y franjas únicas
        for row in resultados:
            if row['sala_nombre'] and row['sala_nombre'] not in salas:
                salas.append(row['sala_nombre'])
            if row['franja_horaria'] and row['franja_horaria'] not in franjas:
                franjas.append(row['franja_horaria'])
        
        # Ordenar franjas horarias
        franjas.sort()
        
        # Crear datos para heatmap
        data = []
        for i, sala in enumerate(salas):
            for j, franja in enumerate(franjas):
                item = next((r for r in resultados 
                           if r['sala_nombre'] == sala and r['franja_horaria'] == franja), None)
                ocupacion = float(item['porcentaje_ocupacion']) if item else 0.0
                data.append([i, j, ocupacion])
        
        return jsonify({
            'salas': salas,
            'franjas': franjas,
            'data': data
        })
        
    except Exception as e:
        print(f"Error en reporte_capacidad: {str(e)}")
        return jsonify({'error': str(e)}), 500

@reportes_bp.route('/api/reporte/resumen')
@login_required
def reporte_resumen():
    """Resumen general de citas"""
    try:
        mysql = get_mysql()
        desde = request.args.get('desde', date.today().replace(day=1).isoformat())
        hasta = request.args.get('hasta', date.today().isoformat())
        
        cur = mysql.connection.cursor()
        
        # Obtener resumen usando la estructura real
        cur.execute("""
            SELECT 
                COUNT(*) as total_citas,
                SUM(CASE WHEN estado_id = 2 THEN 1 ELSE 0 END) as citas_atendidas,
                SUM(CASE WHEN estado_id = 4 THEN 1 ELSE 0 END) as citas_noshow,
                SUM(CASE WHEN estado_id = 3 THEN 1 ELSE 0 END) as citas_canceladas
            FROM citas
            WHERE DATE(fecha_inicio) BETWEEN %s AND %s
        """, (desde, hasta))
        
        resultado = cur.fetchone()
        cur.close()
        
        total_citas = resultado['total_citas'] if resultado else 0
        citas_atendidas = resultado['citas_atendidas'] if resultado else 0
        citas_noshow = resultado['citas_noshow'] if resultado else 0
        
        # Calcular tasas
        tasa_adherencia = round((citas_atendidas / total_citas * 100) if total_citas > 0 else 0, 2)
        tasa_asistencia = tasa_adherencia
        
        data = {
            'total_citas': total_citas,
            'citas_atendidas': citas_atendidas,
            'citas_noshow': citas_noshow,
            'tasa_adherencia_promedio': tasa_adherencia,
            'tasa_asistencia': tasa_asistencia
        }
        
        return jsonify(data)
        
    except Exception as e:
        print(f"Error en reporte_resumen: {str(e)}")
        return jsonify({'error': str(e)}), 500
