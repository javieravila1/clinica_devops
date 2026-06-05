from datetime import datetime, date

def get_mysql():
    """Get mysql instance dynamically to avoid import timing issues"""
    from utils.database import mysql
    return mysql

def calcular_edad(fecha_nacimiento):
    """Calcula la edad a partir de una fecha de nacimiento"""
    if not fecha_nacimiento:
        return None
    hoy = datetime.now().date()
    nacimiento = fecha_nacimiento if isinstance(fecha_nacimiento, date) else datetime.strptime(str(fecha_nacimiento), '%Y-%m-%d').date()
    edad = hoy.year - nacimiento.year
    if (hoy.month, hoy.day) < (nacimiento.month, nacimiento.day):
        edad -= 1
    return edad

def ejecutar_procedimiento(proc_name, params=None):
    """Ejecuta un procedimiento almacenado que retorna un solo resultado"""
    mysql = get_mysql()
    cur = mysql.connection.cursor()
    try:
        if params:
            cur.callproc(proc_name, params)
        else:
            cur.callproc(proc_name)
        resultado = cur.fetchall()
        return resultado
    except Exception as e:
        raise e
    finally:
        cur.close()

def ejecutar_procedimiento_multiple(proc_name, params=None):
    """Ejecuta un procedimiento almacenado que retorna múltiples resultados"""
    mysql = get_mysql()
    cur = mysql.connection.cursor()
    try:
        if params:
            cur.callproc(proc_name, params)
        else:
            cur.callproc(proc_name)
        
        resultados = []
        primer_resultado = cur.fetchall()
        resultados.append(primer_resultado)
        
        # Intentar obtener más resultados
        while cur.nextset():
            try:
                resultado = cur.fetchall()
                resultados.append(resultado)
            except:
                break
                
        return resultados
    except Exception as e:
        raise e
    finally:
        cur.close()
