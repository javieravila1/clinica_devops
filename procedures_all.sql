DELIMITER ;;
CREATE PROCEDURE actualizarProfesional(
    IN p_profesional_id INT,
    IN p_identificacion VARCHAR(20),
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_especialidad VARCHAR(100),
    IN p_horario_inicio TIME,
    IN p_horario_fin TIME,
    IN p_telefono VARCHAR(20),
    IN p_email VARCHAR(100),
    IN p_estado_id INT
)
BEGIN DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    IF NOT EXISTS (SELECT 1 FROM profesionales WHERE profesional_id = p_profesional_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El profesional no existe';
    END IF;
    
    
    IF EXISTS (SELECT 1 FROM profesionales WHERE identificacion = p_identificacion AND profesional_id != p_profesional_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe otro profesional con esta identificación';
    END IF;
    
    
    UPDATE profesionales SET identificacion = p_identificacion,
        nombre = p_nombre,
        apellido = p_apellido,
        especialidad = p_especialidad,
        horario_inicio = p_horario_inicio,
        horario_fin = p_horario_fin,
        telefono = p_telefono,
        email = p_email,
        estado_id = p_estado_id WHERE profesional_id = p_profesional_id;
    
    COMMIT;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE actualizarSala(
    IN p_sala_id INT,
    IN p_nombre VARCHAR(50),
    IN p_descripcion TEXT,
    IN p_capacidad INT,
    IN p_estado_id INT
)
BEGIN DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    IF NOT EXISTS (SELECT 1 FROM salas WHERE sala_id = p_sala_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La sala no existe';
    END IF;
    
    
    IF EXISTS (SELECT 1 FROM salas WHERE nombre = p_nombre AND sala_id != p_sala_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe otra sala con este nombre';
    END IF;
    
    
    UPDATE salas SET nombre = p_nombre,
        descripcion = p_descripcion,
        capacidad = p_capacidad,
        estado_id = p_estado_id WHERE sala_id = p_sala_id;
    
    COMMIT;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE actualizar_ultimo_login(IN p_usuario_id INT)
BEGIN UPDATE usuarios SET ultimo_login = NOW() WHERE usuario_id = p_usuario_id;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE alertasSuspension(
    IN p_umbral INT
)
BEGIN DECLARE v_paciente_id INT;
    DECLARE v_nombre VARCHAR(201);
    DECLARE v_no_shows INT;
    DECLARE done INT DEFAULT FALSE;
    
    DECLARE cur_pacientes CURSOR FOR SELECT p.paciente_id,
        CONCAT(p.nombre, ' ', p.apellido) as nombre,
        COUNT(*) as no_shows FROM pacientes p JOIN citas c ON p.paciente_id = c.paciente_id WHERE c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show')
    AND c.fecha_inicio >= DATE_SUB(NOW(), INTERVAL 30 DAY)
    GROUP BY p.paciente_id HAVING COUNT(*) >= p_umbral;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    CREATE TEMPORARY TABLE tmpTopAlertas (
        paciente_id INT,
        paciente_nombre VARCHAR(201),
        no_shows INT,
        accion VARCHAR(50)
    );
    
    OPEN cur_pacientes;
    
    read_loop: LOOP FETCH cur_pacientes INTO v_paciente_id, v_nombre, v_no_shows;
        IF done THEN LEAVE read_loop;
        END IF;
        
        INSERT INTO tmpTopAlertas (paciente_id, paciente_nombre, no_shows, accion)
        VALUES (v_paciente_id, v_nombre, v_no_shows, 'SUSPENDER');
        
        
        
        
    END LOOP;
    
    CLOSE cur_pacientes;
    
    SELECT * FROM tmpTopAlertas ORDER BY no_shows DESC;
    
    DROP TEMPORARY TABLE tmpTopAlertas;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE asignacionCamaCrear(
    IN p_paciente_id INT,
    IN p_cama_id INT,
    IN p_fecha_ingreso DATETIME,
    IN p_motivo_ingreso TEXT,
    IN p_usuario_id INT
)
BEGIN DECLARE v_estado_ocupada INT;
    DECLARE v_estado_asignacion_activa INT;
    
    
    IF EXISTS (
        SELECT 1 FROM asignaciones_cama WHERE cama_id = p_cama_id AND fecha_egreso IS NULL AND estado_id IN (SELECT estado_id FROM estados WHERE nombre IN ('activa', 'ocupada'))
    ) THEN SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La cama ya está ocupada';
    END IF;
    
    
    SELECT estado_id INTO v_estado_ocupada FROM estados WHERE nombre = 'ocupada' AND tipo_entidad = 'cama'
    LIMIT 1;
    
    SELECT estado_id INTO v_estado_asignacion_activa FROM estados WHERE nombre = 'activa' AND tipo_entidad = 'asignacion'
    LIMIT 1;
    
    
    IF v_estado_ocupada IS NULL THEN SELECT estado_id INTO v_estado_ocupada FROM estados WHERE nombre = 'ocupada' 
        LIMIT 1;
    END IF;
    
    IF v_estado_asignacion_activa IS NULL THEN SELECT estado_id INTO v_estado_asignacion_activa FROM estados WHERE nombre = 'activa' 
        LIMIT 1;
    END IF;
    
    
    INSERT INTO asignaciones_cama (
        paciente_id,
        cama_id,
        fecha_ingreso,
        motivo_ingreso,
        estado_id,
        created_at
    ) VALUES (
        p_paciente_id,
        p_cama_id,
        p_fecha_ingreso,
        p_motivo_ingreso,
        v_estado_asignacion_activa,
        NOW()
    );
    
    
    UPDATE camas SET estado_id = v_estado_ocupada WHERE cama_id = p_cama_id;
    
    SELECT LAST_INSERT_ID() as asignacion_id;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE asignacionCamaEgreso(
    IN p_asignacion_id INT,
    IN p_fecha_egreso DATETIME,
    IN p_motivo_egreso TEXT,
    IN p_usuario_id INT
)
BEGIN DECLARE v_cama_id INT;
    DECLARE v_estado_disponible INT;
    DECLARE v_estado_asignacion_inactiva INT;
    
    
    SELECT cama_id INTO v_cama_id FROM asignaciones_cama WHERE asignacion_id = p_asignacion_id;
    
    
    SELECT estado_id INTO v_estado_disponible FROM estados WHERE nombre = 'disponible' AND tipo_entidad = 'cama'
    LIMIT 1;
    
    SELECT estado_id INTO v_estado_asignacion_inactiva FROM estados WHERE nombre = 'inactiva' AND tipo_entidad = 'asignacion'
    LIMIT 1;
    
    
    IF v_estado_disponible IS NULL THEN SELECT estado_id INTO v_estado_disponible FROM estados WHERE nombre = 'disponible' 
        LIMIT 1;
    END IF;
    
    IF v_estado_asignacion_inactiva IS NULL THEN SELECT estado_id INTO v_estado_asignacion_inactiva FROM estados WHERE nombre = 'inactiva' 
        LIMIT 1;
    END IF;
    
    
    UPDATE asignaciones_cama SET fecha_egreso = p_fecha_egreso,
        motivo_egreso = p_motivo_egreso,
        estado_id = v_estado_asignacion_inactiva WHERE asignacion_id = p_asignacion_id;
    
    
    UPDATE camas SET estado_id = v_estado_disponible WHERE cama_id = v_cama_id;
    
    SELECT ROW_COUNT() as affected_rows;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE asignacionPersonalCrear(
    IN p_paciente_id INT,
    IN p_enfermera_id INT,
    IN p_profesional_id INT,
    IN p_tipo_asignacion ENUM('medico_tratante','enfermera_asignada','especialista'),
    IN p_fecha_asignacion DATE,
    IN p_fecha_fin DATE,
    IN p_es_principal TINYINT,
    IN p_observaciones TEXT,
    IN p_usuario_id INT
)
BEGIN DECLARE v_estado_activa INT;
    
    
    IF p_enfermera_id IS NULL AND p_profesional_id IS NULL THEN SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Debe asignar al menos una enfermera o un profesional';
    END IF;
    
    
    SELECT estado_id INTO v_estado_activa FROM estados WHERE nombre = 'activa' AND tipo_entidad = 'asignacion'
    LIMIT 1;
    
    IF v_estado_activa IS NULL THEN SELECT estado_id INTO v_estado_activa FROM estados WHERE nombre = 'activa' 
        LIMIT 1;
    END IF;
    
    INSERT INTO asignaciones_paciente (
        paciente_id,
        enfermera_id,
        profesional_id,
        tipo_asignacion,
        fecha_asignacion,
        fecha_fin,
        es_principal,
        observaciones,
        estado_id,
        created_at
    ) VALUES (
        p_paciente_id,
        p_enfermera_id,
        p_profesional_id,
        p_tipo_asignacion,
        p_fecha_asignacion,
        p_fecha_fin,
        COALESCE(p_es_principal, 0),
        p_observaciones,
        v_estado_activa,
        NOW()
    );
    
    SELECT LAST_INSERT_ID() as asignacion_id;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE cambiarEstadoProfesional(
    IN p_profesional_id INT,
    IN p_nuevo_estado VARCHAR(50)
)
BEGIN DECLARE v_estado_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_id FROM estados WHERE tipo_entidad = 'profesional' AND nombre = p_nuevo_estado;
    
    IF v_estado_id IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado no válido';
    END IF;
    
    
    UPDATE profesionales SET estado_id = v_estado_id WHERE profesional_id = p_profesional_id;
    
    COMMIT;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE cambiarEstadoSala(
    IN p_sala_id INT,
    IN p_nuevo_estado VARCHAR(50)
)
BEGIN DECLARE v_estado_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_id FROM estados WHERE tipo_entidad = 'sala' AND nombre = p_nuevo_estado;
    
    IF v_estado_id IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado no válido';
    END IF;
    
    
    UPDATE salas SET estado_id = v_estado_id WHERE sala_id = p_sala_id;
    
    COMMIT;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE cambiar_estado_objetivo(
    IN p_objetivo_id INT,
    IN p_nombre_estado VARCHAR(50),
    OUT p_resultado VARCHAR(255)
)
BEGIN DECLARE v_estado_id INT;
    
    
    SELECT estado_id INTO v_estado_id FROM estados WHERE tipo_entidad = 'objetivo' AND nombre = p_nombre_estado;
    
    IF v_estado_id IS NOT NULL THEN UPDATE objetivos_plan SET estado_id = v_estado_id WHERE objetivo_id = p_objetivo_id;
        SET p_resultado = 'OK';
    ELSE SET p_resultado = 'Estado no válido';
    END IF;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE cambiar_estado_paciente(
    IN p_paciente_id INT,
    IN p_estado_id INT,
    IN p_usuario_id INT
)
BEGIN UPDATE pacientes SET estado_id = p_estado_id,
        updated_at = CURRENT_TIMESTAMP WHERE paciente_id = p_paciente_id;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE cierreNoShowAuto(
    IN p_gracia_min INT
)
BEGIN DECLARE v_estado_no_show INT;
    DECLARE v_motivo_olvido INT;
    DECLARE v_cita_id INT;
    DECLARE v_paciente_id INT;
    DECLARE v_fecha_cita DATETIME;
    DECLARE v_minutos_retraso INT;
    DECLARE done INT DEFAULT FALSE;
    
    DECLARE cur_citas CURSOR FOR SELECT c.cita_id, c.paciente_id, c.fecha_inicio,
           TIMESTAMPDIFF(MINUTE, c.fecha_inicio, NOW()) as minutos_retraso FROM citas c WHERE c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'programada')
    AND c.fecha_inicio < DATE_SUB(NOW(), INTERVAL p_gracia_min MINUTE)
    AND NOT EXISTS (SELECT 1 FROM sesiones s WHERE s.cita_id = c.cita_id);
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    
    SELECT estado_id INTO v_estado_no_show FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show';
    SELECT motivo_id INTO v_motivo_olvido FROM motivos_cancelacion WHERE descripcion = 'Olvido' LIMIT 1;
    
    OPEN cur_citas;
    
    read_loop: LOOP FETCH cur_citas INTO v_cita_id, v_paciente_id, v_fecha_cita, v_minutos_retraso;
        IF done THEN LEAVE read_loop;
        END IF;
        
        
        UPDATE citas SET estado_id = v_estado_no_show,
            motivo_cancelacion_id = v_motivo_olvido WHERE cita_id = v_cita_id;
        
        
        INSERT INTO logs_noshow_auto (cita_id, paciente_id, fecha_cita, minutos_retraso)
        VALUES (v_cita_id, v_paciente_id, v_fecha_cita, v_minutos_retraso);
        
    END LOOP;
    
    CLOSE cur_citas;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE citaAgendar(
    IN p_paciente_id INT,
    IN p_profesional_id INT,
    IN p_sala_id INT,
    IN p_inicio DATETIME,
    IN p_fin DATETIME
)
BEGIN DECLARE v_solapamiento INT DEFAULT 0;
    DECLARE v_horario_valido BOOLEAN DEFAULT FALSE;
    DECLARE v_estado_programada INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_programada FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'programada';
    
    
    IF NOT EXISTS (SELECT 1 FROM pacientes WHERE paciente_id = p_paciente_id AND estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'paciente' AND nombre = 'activo')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El paciente no existe o no está activo';
    END IF;
    
    
    IF NOT EXISTS (SELECT 1 FROM profesionales WHERE profesional_id = p_profesional_id AND estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'profesional' AND nombre = 'activo')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El profesional no existe o no está activo';
    END IF;
    
    
    IF NOT EXISTS (SELECT 1 FROM salas WHERE sala_id = p_sala_id AND estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'sala' AND nombre = 'activa')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La sala no existe o no está activa';
    END IF;
    
    
    SELECT COUNT(*) INTO v_solapamiento FROM citas c WHERE c.profesional_id = p_profesional_id AND c.estado_id = v_estado_programada AND c.fecha_inicio < p_fin AND c.fecha_fin > p_inicio;
    
    IF v_solapamiento > 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El profesional tiene una cita solapada';
    END IF;
    
    
    SELECT COUNT(*) INTO v_solapamiento FROM citas c WHERE c.sala_id = p_sala_id AND c.estado_id = v_estado_programada AND c.fecha_inicio < p_fin AND c.fecha_fin > p_inicio;
    
    IF v_solapamiento > 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La sala tiene una cita solapada';
    END IF;
    
    
    IF (CAST(TIME(p_inicio) AS TIME) >= CAST('08:00:00' AS TIME) AND CAST(TIME(p_fin) AS TIME) <= CAST('18:00:00' AS TIME)) THEN SET v_horario_valido = TRUE;
    END IF;
    
    IF NOT v_horario_valido THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Horario fuera del rango de atención (8:00-18:00)';
    END IF;
    
    
    IF p_inicio >= p_fin THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de inicio debe ser anterior a la fecha de fin';
    END IF;
    
    
    INSERT INTO citas (paciente_id, profesional_id, sala_id, fecha_inicio, fecha_fin, estado_id)
    VALUES (p_paciente_id, p_profesional_id, p_sala_id, p_inicio, p_fin, v_estado_programada);
    
    COMMIT;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE citaCancelar(
    IN p_cita_id INT,
    IN p_motivo_id INT,
    IN p_usuario_id INT
)
BEGIN DECLARE v_estado_cancelada INT;
    DECLARE v_estado_no_show INT;
    DECLARE v_cuenta_como_noshow BOOLEAN;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_cancelada FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'cancelada';
    SELECT estado_id INTO v_estado_no_show FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show';
    
    
    SELECT cuenta_como_noshow INTO v_cuenta_como_noshow FROM motivos_cancelacion WHERE motivo_id = p_motivo_id;
    
    
    IF v_cuenta_como_noshow THEN UPDATE citas SET estado_id = v_estado_no_show,
            motivo_cancelacion_id = p_motivo_id WHERE cita_id = p_cita_id;
    ELSE UPDATE citas SET estado_id = v_estado_cancelada,
            motivo_cancelacion_id = p_motivo_id WHERE cita_id = p_cita_id;
    END IF;
    
    COMMIT;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE citaCompletar(
    IN p_cita_id INT,
    IN p_usuario_id INT
)
BEGIN DECLARE v_estado_completada INT;
    DECLARE v_estado_actual INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_completada FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada';
    
    
    SELECT estado_id INTO v_estado_actual FROM citas WHERE cita_id = p_cita_id;
    
    
    IF v_estado_actual IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cita no existe';
    END IF;
    
    
    IF v_estado_actual = v_estado_completada THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cita ya está completada';
    END IF;
    
    
    UPDATE citas SET estado_id = v_estado_completada,
        updated_at = CURRENT_TIMESTAMP WHERE cita_id = p_cita_id;
    
    
    INSERT INTO sesiones (cita_id, notas, fecha_registro, editable_hasta)
    VALUES (p_cita_id, 'Cita completada directamente desde agenda', CURRENT_TIMESTAMP, DATE_ADD(NOW(), INTERVAL 24 HOUR));
    
    COMMIT;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE citaReagendar(
    IN p_cita_id INT,
    IN p_nuevo_inicio DATETIME,
    IN p_nuevo_fin DATETIME,
    IN p_motivo VARCHAR(200),
    IN p_usuario_id INT
)
BEGIN DECLARE v_estado_cancelada INT;
    DECLARE v_estado_programada INT;
    DECLARE v_paciente_id INT;
    DECLARE v_profesional_id INT;
    DECLARE v_sala_id INT;
    DECLARE v_contador_reagendos INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_cancelada FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'cancelada';
    SELECT estado_id INTO v_estado_programada FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'programada';
    
    
    SELECT paciente_id, profesional_id, sala_id INTO v_paciente_id, v_profesional_id, v_sala_id FROM citas WHERE cita_id = p_cita_id;
    
    
    SELECT COUNT(*) INTO v_contador_reagendos FROM citas WHERE paciente_id = v_paciente_id AND es_reagendo = TRUE AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY);
    
    
    IF v_contador_reagendos >= 3 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El paciente ha excedido el límite de reagendos del mes';
    END IF;
    
    
    UPDATE citas SET estado_id = v_estado_cancelada,
        motivo_cancelacion_id = (SELECT motivo_id FROM motivos_cancelacion WHERE descripcion LIKE '%reagendo%' LIMIT 1)
    WHERE cita_id = p_cita_id;
    
    
    INSERT INTO citas (paciente_id, profesional_id, sala_id, fecha_inicio, fecha_fin, estado_id, es_reagendo, cita_original_id)
    VALUES (v_paciente_id, v_profesional_id, v_sala_id, p_nuevo_inicio, p_nuevo_fin, v_estado_programada, TRUE, p_cita_id);
    
    COMMIT;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE crearProfesional(
    IN p_identificacion VARCHAR(20),
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_especialidad VARCHAR(100),
    IN p_horario_inicio TIME,
    IN p_horario_fin TIME,
    IN p_telefono VARCHAR(20),
    IN p_email VARCHAR(100)
)
BEGIN DECLARE v_estado_activo INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_activo FROM estados WHERE tipo_entidad = 'profesional' AND nombre = 'activo';
    
    
    IF p_identificacion IS NULL OR p_nombre IS NULL OR p_apellido IS NULL OR p_especialidad IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Identificación, nombre, apellido y especialidad son obligatorios';
    END IF;
    
    IF EXISTS (SELECT 1 FROM profesionales WHERE identificacion = p_identificacion) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un profesional con esta identificación';
    END IF;
    
    
    INSERT INTO profesionales (
        identificacion, nombre, apellido, especialidad, 
        horario_inicio, horario_fin, telefono, email, estado_id
    ) VALUES (
        p_identificacion, p_nombre, p_apellido, p_especialidad,
        p_horario_inicio, p_horario_fin, p_telefono, p_email, v_estado_activo
    );
    
    COMMIT;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE crearSala(
    IN p_nombre VARCHAR(50),
    IN p_descripcion TEXT,
    IN p_capacidad INT
)
BEGIN DECLARE v_estado_activa INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_activa FROM estados WHERE tipo_entidad = 'sala' AND nombre = 'activa';
    
    
    IF p_nombre IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la sala es obligatorio';
    END IF;
    
    IF EXISTS (SELECT 1 FROM salas WHERE nombre = p_nombre) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una sala con este nombre';
    END IF;
    
    
    INSERT INTO salas (
        nombre, descripcion, capacidad, estado_id
    ) VALUES (
        p_nombre, p_descripcion, p_capacidad, v_estado_activa
    );
    
    COMMIT;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE dashboard_adherencia_pacientes()
BEGIN SELECT p.paciente_id,
        CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
        COUNT(c.cita_id) as total_citas,
        SUM(CASE WHEN c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada') THEN 1 ELSE 0 END) as citas_completadas,
        SUM(CASE WHEN c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show') THEN 1 ELSE 0 END) as citas_no_show,
        CASE WHEN COUNT(c.cita_id) > 0 THEN ROUND((SUM(CASE WHEN c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada') THEN 1 ELSE 0 END) * 100.0 / 
                      COUNT(c.cita_id)), 1)
            ELSE 0 
        END as tasa_adherencia FROM pacientes p LEFT JOIN citas c ON p.paciente_id = c.paciente_id WHERE p.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'paciente' AND nombre = 'activo')
    AND c.fecha_inicio >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY p.paciente_id, p.nombre, p.apellido HAVING total_citas > 0
    ORDER BY tasa_adherencia DESC LIMIT 10;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE dashboard_citas_hoy()
BEGIN SELECT c.cita_id,
        c.fecha_inicio,
        CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
        CONCAT(prof.nombre, ' ', prof.apellido) as profesional_nombre,
        s.nombre as sala_nombre,
        e.nombre as estado_nombre FROM citas c JOIN pacientes p ON c.paciente_id = p.paciente_id JOIN profesionales prof ON c.profesional_id = prof.profesional_id JOIN salas s ON c.sala_id = s.sala_id JOIN estados e ON c.estado_id = e.estado_id WHERE DATE(c.fecha_inicio) = CURDATE()
    ORDER BY c.fecha_inicio;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE dashboard_distribucion_citas()
BEGIN SELECT e.nombre as estado,
        COUNT(*) as cantidad FROM citas c JOIN estados e ON c.estado_id = e.estado_id WHERE MONTH(c.fecha_inicio) = MONTH(CURDATE()) 
    AND YEAR(c.fecha_inicio) = YEAR(CURDATE())
    GROUP BY e.nombre;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE dashboard_estadisticas_generales()
BEGIN SELECT COUNT(*) as pacientes_activos FROM pacientes WHERE estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'paciente' AND nombre = 'activo');
    
    
    SELECT COUNT(*) as citas_hoy FROM citas WHERE DATE(fecha_inicio) = CURDATE();
    
    
    SELECT COUNT(*) as sesiones_mes FROM sesiones WHERE MONTH(fecha_registro) = MONTH(CURDATE()) AND YEAR(fecha_registro) = YEAR(CURDATE());
    
    
    SELECT COALESCE(ROUND(
            (SUM(CASE WHEN estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada') THEN 1 ELSE 0 END) * 100.0 / 
            NULLIF(SUM(CASE WHEN estado_id IN (
                (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada'),
                (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show')
            ) THEN 1 ELSE 0 END), 0)), 1), 0) as tasa_adherencia FROM citas WHERE MONTH(fecha_inicio) = MONTH(CURDATE()) 
    AND YEAR(fecha_inicio) = YEAR(CURDATE());
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE dashboard_estadisticas_mejorado()
BEGIN SELECT COUNT(*) as pacientes_activos FROM pacientes WHERE estado_id = (
        SELECT estado_id FROM estados WHERE tipo_entidad = 'paciente' AND nombre = 'activo'
    );
    
    
    SELECT COUNT(*) as citas_hoy FROM citas WHERE DATE(fecha_inicio) = CURDATE();
    
    
    SELECT COUNT(*) as sesiones_mes FROM sesiones WHERE MONTH(fecha_registro) = MONTH(CURDATE()) 
    AND YEAR(fecha_registro) = YEAR(CURDATE());
    
    
    SELECT COALESCE(ROUND(
            (SUM(CASE WHEN c.estado_id = (
                SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada'
            ) THEN 1 ELSE 0 END) * 100.0 / 
            NULLIF(SUM(CASE WHEN c.estado_id IN (
                (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada'),
                (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show')
            ) THEN 1 ELSE 0 END), 0)),
        2), 0) as tasa_adherencia FROM citas c WHERE c.fecha_inicio >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE dashboard_evolucion_sesiones()
BEGIN SELECT YEAR(fecha_registro) as año,
        MONTH(fecha_registro) as mes,
        COUNT(*) as total_sesiones FROM sesiones WHERE fecha_registro >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    GROUP BY YEAR(fecha_registro), MONTH(fecha_registro)
    ORDER BY año, mes;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE dashboard_progreso_planes()
BEGIN SELECT pt.plan_id,
        CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
        pt.fecha_inicio,
        pt.fecha_fin_estimada,
        (SELECT COUNT(*) FROM objetivos_plan op WHERE op.plan_id = pt.plan_id) as total_objetivos,
        (SELECT COUNT(*) FROM objetivos_plan op WHERE op.plan_id = pt.plan_id AND op.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'objetivo' AND nombre = 'cumplido')) as objetivos_cumplidos FROM planes_terapeuticos pt JOIN pacientes p ON pt.paciente_id = p.paciente_id WHERE pt.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'plan' AND nombre = 'activo')
    ORDER BY pt.fecha_inicio DESC LIMIT 6;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE familiarActualizar(
    IN p_familiar_id INT,
    IN p_tipo_parentesco ENUM('conyuge','hijo','padre','madre','hermano','otro'),
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_segundo_apellido VARCHAR(100),
    IN p_fecha_nacimiento DATE,
    IN p_telefono VARCHAR(20),
    IN p_email VARCHAR(100),
    IN p_es_contacto_emergencia TINYINT,
    IN p_observaciones TEXT,
    IN p_estado_id INT,
    IN p_usuario_id INT
)
BEGIN UPDATE familiares_pacientes SET tipo_parentesco = p_tipo_parentesco,
        nombre = p_nombre,
        apellido = p_apellido,
        segundo_apellido = p_segundo_apellido,
        fecha_nacimiento = p_fecha_nacimiento,
        telefono = p_telefono,
        email = p_email,
        es_contacto_emergencia = p_es_contacto_emergencia,
        observaciones = p_observaciones,
        estado_id = p_estado_id WHERE familiar_id = p_familiar_id;
    
    SELECT ROW_COUNT() as affected_rows;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE familiarCrear(
    IN p_paciente_id INT,
    IN p_tipo_parentesco ENUM('conyuge','hijo','padre','madre','hermano','otro'),
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_segundo_apellido VARCHAR(100),
    IN p_fecha_nacimiento DATE,
    IN p_telefono VARCHAR(20),
    IN p_email VARCHAR(100),
    IN p_es_contacto_emergencia TINYINT,
    IN p_observaciones TEXT,
    IN p_usuario_id INT
)
BEGIN DECLARE v_estado_activo INT;
    
    
    SELECT estado_id INTO v_estado_activo FROM estados WHERE nombre = 'activo' AND tipo_entidad = 'familiar';
    
    IF v_estado_activo IS NULL THEN SELECT estado_id INTO v_estado_activo FROM estados WHERE nombre = 'activo' 
        LIMIT 1;
    END IF;
    
    INSERT INTO familiares_pacientes (
        paciente_id,
        tipo_parentesco,
        nombre,
        apellido,
        segundo_apellido,
        fecha_nacimiento,
        telefono,
        email,
        es_contacto_emergencia,
        observaciones,
        estado_id,
        created_at
    ) VALUES (
        p_paciente_id,
        p_tipo_parentesco,
        p_nombre,
        p_apellido,
        p_segundo_apellido,
        p_fecha_nacimiento,
        p_telefono,
        p_email,
        COALESCE(p_es_contacto_emergencia, 0),
        p_observaciones,
        v_estado_activo,
        NOW()
    );
    
    SELECT LAST_INSERT_ID() as familiar_id;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE kpiCapacidadUtilizada(
    IN p_dia_semana INT
)
BEGIN CREATE TEMPORARY TABLE tmpCapacidad (
        sala_id INT,
        sala_nombre VARCHAR(50),
        franja_horaria VARCHAR(20),
        citas_programadas INT,
        porcentaje_ocupacion DECIMAL(5,2)
    );
    
    INSERT INTO tmpCapacidad SELECT s.sala_id,
        s.nombre as sala_nombre,
        CONCAT(LPAD(h.hora, 2, '0'), ':00-', LPAD(h.hora+1, 2, '0'), ':00') as franja_horaria,
        COUNT(c.cita_id) as citas_programadas,
        ROUND((COUNT(c.cita_id) * 100.0 / 1), 2) as porcentaje_ocupacion FROM salas s CROSS JOIN (SELECT 8 as hora UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 
                UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16) h LEFT JOIN citas c ON s.sala_id = c.sala_id AND HOUR(c.fecha_inicio) = h.hora AND DAYOFWEEK(c.fecha_inicio) = p_dia_semana AND c.estado_id IN (
            SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre IN ('programada', 'confirmada')
        )
    GROUP BY s.sala_id, s.nombre, h.hora;
    
    SELECT * FROM tmpCapacidad ORDER BY sala_id, franja_horaria;
    
    DROP TEMPORARY TABLE tmpCapacidad;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE login(
    IN p_username VARCHAR(50),
    IN p_passhash VARCHAR(255)
)
BEGIN SELECT u.usuario_id,
        u.username,
        u.email,
        u.persona_id,
        u.tipo_persona,
        u.estado_id,
        u.ultimo_login FROM usuarios u WHERE u.username = p_username AND u.passhash = p_passhash AND u.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'usuario' AND nombre = 'activo');
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtenerProfesionales(IN p_mostrar_todos BOOLEAN)
BEGIN IF p_mostrar_todos THEN SELECT p.*, e.nombre as estado_nombre FROM profesionales p JOIN estados e ON p.estado_id = e.estado_id ORDER BY p.nombre, p.apellido;
    ELSE SELECT p.*, e.nombre as estado_nombre FROM profesionales p JOIN estados e ON p.estado_id = e.estado_id WHERE p.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'profesional' AND nombre = 'activo')
        ORDER BY p.nombre, p.apellido;
    END IF;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtenerProfesionalPorId(IN p_profesional_id INT)
BEGIN SELECT p.*, e.nombre as estado_nombre FROM profesionales p JOIN estados e ON p.estado_id = e.estado_id WHERE p.profesional_id = p_profesional_id;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtenerSalaPorId(IN p_sala_id INT)
BEGIN SELECT s.*, e.nombre as estado_nombre FROM salas s JOIN estados e ON s.estado_id = e.estado_id WHERE s.sala_id = p_sala_id;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtenerSalas(IN p_mostrar_todas BOOLEAN)
BEGIN IF p_mostrar_todas THEN SELECT s.*, e.nombre as estado_nombre FROM salas s JOIN estados e ON s.estado_id = e.estado_id ORDER BY s.nombre;
    ELSE SELECT s.*, e.nombre as estado_nombre FROM salas s JOIN estados e ON s.estado_id = e.estado_id WHERE s.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'sala' AND nombre = 'activa')
        ORDER BY s.nombre;
    END IF;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_administracion_medicamentos()
BEGIN SELECT am.*, p.nombre as paciente_nombre, p.apellido as paciente_apellido,
           m.nombre_comercial as medicamento,
           e.nombre as enfermera_nombre, e.apellido as enfermera_apellido FROM administracion_medicamentos am JOIN pacientes p ON am.paciente_id = p.paciente_id JOIN medicamentos m ON am.medicamento_id = m.medicamento_id JOIN enfermeras e ON am.enfermera_id = e.enfermera_id ORDER BY am.fecha_hora_programada DESC LIMIT 50;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_asignaciones_cama()
BEGIN SELECT ac.*, p.nombre as paciente_nombre, p.apellido as paciente_apellido,
           c.numero_cama, h.numero_habitacion as habitacion_nombre,
           e.nombre as estado_nombre FROM asignaciones_cama ac JOIN pacientes p ON ac.paciente_id = p.paciente_id JOIN camas c ON ac.cama_id = c.cama_id JOIN habitaciones h ON c.habitacion_id = h.habitacion_id JOIN estados e ON ac.estado_id = e.estado_id ORDER BY ac.fecha_ingreso DESC;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_asignaciones_cama_paciente(
    IN p_paciente_id INT
)
BEGIN SELECT ac.asignacion_id,
        ac.cama_id,
        c.numero_cama,
        h.numero_habitacion,
        h.tipo_habitacion,
        ac.fecha_ingreso,
        ac.fecha_egreso,
        ac.motivo_ingreso,
        ac.motivo_egreso,
        e.nombre as estado_nombre,
        ac.created_at,
        DATEDIFF(COALESCE(ac.fecha_egreso, NOW()), ac.fecha_ingreso) as dias_estancia FROM asignaciones_cama ac JOIN camas c ON ac.cama_id = c.cama_id JOIN habitaciones h ON c.habitacion_id = h.habitacion_id JOIN estados e ON ac.estado_id = e.estado_id WHERE ac.paciente_id = p_paciente_id ORDER BY ac.fecha_ingreso DESC;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_asignaciones_personal()
BEGIN SELECT ap.*, p.nombre as paciente_nombre, p.apellido as paciente_apellido,
           COALESCE(enf.nombre, prof.nombre) as asignado_nombre,
           COALESCE(enf.apellido, prof.apellido) as asignado_apellido,
           e.nombre as estado_nombre FROM asignaciones_paciente ap JOIN pacientes p ON ap.paciente_id = p.paciente_id LEFT JOIN enfermeras enf ON ap.enfermera_id = enf.enfermera_id LEFT JOIN profesionales prof ON ap.profesional_id = prof.profesional_id JOIN estados e ON ap.estado_id = e.estado_id ORDER BY ap.fecha_asignacion DESC;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_asignaciones_personal_paciente(
    IN p_paciente_id INT
)
BEGIN SELECT ap.asignacion_id,
        ap.paciente_id,
        CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
        ap.enfermera_id,
        CONCAT(e.nombre, ' ', e.apellido) as enfermera_nombre,
        ap.profesional_id,
        CONCAT(prof.nombre, ' ', prof.apellido) as profesional_nombre,
        ap.tipo_asignacion,
        ap.fecha_asignacion,
        ap.fecha_fin,
        ap.es_principal,
        ap.observaciones,
        est.nombre as estado_nombre,
        ap.created_at FROM asignaciones_paciente ap JOIN pacientes p ON ap.paciente_id = p.paciente_id LEFT JOIN enfermeras e ON ap.enfermera_id = e.enfermera_id LEFT JOIN profesionales prof ON ap.profesional_id = prof.profesional_id JOIN estados est ON ap.estado_id = est.estado_id WHERE ap.paciente_id = p_paciente_id ORDER BY ap.fecha_asignacion DESC;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_asignacion_cama_detalle(IN p_asignacion_id INT)
BEGIN SELECT ac.asignacion_id,
           ac.paciente_id,
           p.nombre as paciente_nombre,
           p.apellido as paciente_apellido,
           ac.cama_id,
           c.numero_cama,
           c.habitacion_id,
           h.numero_habitacion as habitacion_nombre,
           h.tipo_habitacion,
           ac.fecha_ingreso,
           ac.fecha_egreso,
           ac.motivo_ingreso,
           ac.motivo_egreso,
           ac.estado_id,
           e.nombre as estado_nombre,
           ac.created_at,
           DATEDIFF(COALESCE(ac.fecha_egreso, NOW()), ac.fecha_ingreso) as dias_estancia FROM asignaciones_cama ac JOIN pacientes p ON ac.paciente_id = p.paciente_id JOIN camas c ON ac.cama_id = c.cama_id JOIN habitaciones h ON c.habitacion_id = h.habitacion_id JOIN estados e ON ac.estado_id = e.estado_id WHERE ac.asignacion_id = p_asignacion_id;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_asignacion_personal_detalle(IN p_asignacion_id INT)
BEGIN SELECT ap.asignacion_id,
           ap.paciente_id,
           p.nombre as paciente_nombre,
           p.apellido as paciente_apellido,
           ap.enfermera_id,
           CASE WHEN ap.enfermera_id IS NOT NULL THEN CONCAT(enf.nombre, ' ', enf.apellido)
               ELSE NULL END as enfermera_nombre,
           ap.profesional_id,
           CASE WHEN ap.profesional_id IS NOT NULL THEN CONCAT(prof.nombre, ' ', prof.apellido)
               ELSE NULL END as profesional_nombre,
           COALESCE(enf.nombre, prof.nombre) as asignado_nombre,
           COALESCE(enf.apellido, prof.apellido) as asignado_apellido,
           ap.tipo_asignacion,
           ap.fecha_asignacion,
           ap.fecha_fin,
           ap.es_principal,
           ap.observaciones,
           ap.estado_id,
           e.nombre as estado_nombre,
           ap.created_at FROM asignaciones_paciente ap JOIN pacientes p ON ap.paciente_id = p.paciente_id LEFT JOIN enfermeras enf ON ap.enfermera_id = enf.enfermera_id LEFT JOIN profesionales prof ON ap.profesional_id = prof.profesional_id JOIN estados e ON ap.estado_id = e.estado_id WHERE ap.asignacion_id = p_asignacion_id;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_camas_disponibles()
BEGIN SELECT c.*, h.numero_habitacion as habitacion_nombre, e.nombre as estado_nombre FROM camas c JOIN habitaciones h ON c.habitacion_id = h.habitacion_id JOIN estados e ON c.estado_id = e.estado_id WHERE c.estado_id = 1;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_citas_hoy()
BEGIN SELECT c.cita_id,
        c.fecha_inicio,
        c.fecha_fin,
        p.paciente_id,
        p.nombre as paciente_nombre, 
        p.apellido as paciente_apellido,
        prof.profesional_id,
        prof.nombre as profesional_nombre,
        prof.apellido as profesional_apellido,
        s.sala_id,
        s.nombre as sala_nombre,
        e.nombre as estado_nombre FROM citas c JOIN pacientes p ON c.paciente_id = p.paciente_id JOIN profesionales prof ON c.profesional_id = prof.profesional_id JOIN salas s ON c.sala_id = s.sala_id JOIN estados e ON c.estado_id = e.estado_id WHERE DATE(c.fecha_inicio) = CURDATE()
    ORDER BY c.fecha_inicio;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_citas_pendientes()
BEGIN SELECT c.cita_id, 
        CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
        c.fecha_inicio, 
        CONCAT(prof.nombre, ' ', prof.apellido) as profesional_nombre,
        e.nombre as estado_nombre,
        s.nombre as sala_nombre FROM citas c JOIN pacientes p ON c.paciente_id = p.paciente_id JOIN profesionales prof ON c.profesional_id = prof.profesional_id JOIN estados e ON c.estado_id = e.estado_id JOIN salas s ON c.sala_id = s.sala_id WHERE c.estado_id IN (
        SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre IN ('programada', 'confirmada')
    )
    AND NOT EXISTS (SELECT 1 FROM sesiones WHERE cita_id = c.cita_id)
    AND (
        DATE(c.fecha_inicio) = CURDATE()
        OR c.fecha_inicio < NOW()
        OR c.fecha_inicio BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 2 HOUR)
    )
    ORDER BY CASE WHEN DATE(c.fecha_inicio) = CURDATE() THEN 1
            WHEN c.fecha_inicio < NOW() THEN 2
            ELSE 3
        END,
        c.fecha_inicio ASC;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_cita_por_id(IN p_cita_id INT)
BEGIN SELECT c.*, 
           CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
           CONCAT(prof.nombre, ' ', prof.apellido) as profesional_nombre,
           s.nombre as sala_nombre,
           e.nombre as estado_nombre FROM citas c JOIN pacientes p ON c.paciente_id = p.paciente_id JOIN profesionales prof ON c.profesional_id = prof.profesional_id JOIN salas s ON c.sala_id = s.sala_id JOIN estados e ON c.estado_id = e.estado_id WHERE c.cita_id = p_cita_id;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_datos_planes_completo()
BEGIN SELECT * FROM progresoPorPlan;
    
    
    SELECT paciente_id, nombre, apellido FROM pacientes WHERE estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'paciente' AND nombre = 'activo');
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_enfermeras_activas()
BEGIN SELECT e.*, est.nombre as estado_nombre FROM enfermeras e JOIN estados est ON e.estado_id = est.estado_id WHERE e.estado_id = 1;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_escalas_activas()
BEGIN SELECT escala_id, nombre FROM escalas_clinicas WHERE estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'escala' AND nombre = 'activa');
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_estados_por_entidad(IN tipo_entidad_param VARCHAR(50))
BEGIN SELECT estado_id, nombre FROM estados WHERE tipo_entidad = tipo_entidad_param;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_familiares()
BEGIN SELECT f.*, p.nombre as paciente_nombre, p.apellido as paciente_apellido,
           e.nombre as estado_nombre FROM familiares_pacientes f JOIN pacientes p ON f.paciente_id = p.paciente_id JOIN estados e ON f.estado_id = e.estado_id ORDER BY f.created_at DESC;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_familiares_por_paciente(
    IN p_paciente_id INT
)
BEGIN SELECT f.familiar_id,
        f.tipo_parentesco,
        f.nombre,
        f.apellido,
        f.segundo_apellido,
        CONCAT(f.nombre, ' ', f.apellido, 
               COALESCE(CONCAT(' ', f.segundo_apellido), '')) as nombre_completo,
        f.fecha_nacimiento,
        f.telefono,
        f.email,
        f.es_contacto_emergencia,
        f.observaciones,
        e.nombre as estado_nombre,
        f.created_at FROM familiares_pacientes f JOIN estados e ON f.estado_id = e.estado_id WHERE f.paciente_id = p_paciente_id ORDER BY f.es_contacto_emergencia DESC, f.created_at DESC;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_familiar_por_id(
    IN p_familiar_id INT
)
BEGIN SELECT f.familiar_id,
        f.paciente_id,
        CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
        f.tipo_parentesco,
        f.nombre,
        f.apellido,
        f.segundo_apellido,
        f.fecha_nacimiento,
        f.telefono,
        f.email,
        f.es_contacto_emergencia,
        f.observaciones,
        f.estado_id,
        e.nombre as estado_nombre,
        f.created_at FROM familiares_pacientes f JOIN pacientes p ON f.paciente_id = p.paciente_id JOIN estados e ON f.estado_id = e.estado_id WHERE f.familiar_id = p_familiar_id;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_motivos_cancelacion_activos()
BEGIN SELECT motivo_id, descripcion FROM motivos_cancelacion WHERE estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'motivo' AND nombre = 'activo');
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_objetivos_plan(IN p_plan_id INT)
BEGIN SELECT op.*, e.nombre as estado_nombre FROM objetivos_plan op JOIN estados e ON op.estado_id = e.estado_id WHERE op.plan_id = p_plan_id ORDER BY op.fecha_creacion DESC;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_ordenes_medicas()
BEGIN SELECT om.orden_id,
        om.paciente_id,
        CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
        om.profesional_id,
        CONCAT(prof.nombre, ' ', prof.apellido) as profesional_nombre,
        om.tipo_orden,
        om.descripcion,
        om.medicamento_id,
        COALESCE(m.nombre_comercial, 'N/A') as medicamento_nombre,
        om.dosis,
        om.frecuencia,
        om.duracion,
        om.fecha_orden,
        om.fecha_inicio,
        om.fecha_fin,
        om.estado_id,
        e.nombre as estado_nombre,
        om.observaciones,
        om.created_at FROM ordenes_medicas om JOIN pacientes p ON om.paciente_id = p.paciente_id JOIN profesionales prof ON om.profesional_id = prof.profesional_id LEFT JOIN medicamentos m ON om.medicamento_id = m.medicamento_id JOIN estados e ON om.estado_id = e.estado_id ORDER BY om.fecha_orden DESC;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_ordenes_por_paciente(
    IN p_paciente_id INT
)
BEGIN SELECT om.orden_id,
        om.tipo_orden,
        om.descripcion,
        CONCAT(prof.nombre, ' ', prof.apellido) as profesional_nombre,
        COALESCE(m.nombre_comercial, 'N/A') as medicamento_nombre,
        om.dosis,
        om.frecuencia,
        om.duracion,
        om.fecha_orden,
        om.fecha_inicio,
        om.fecha_fin,
        e.nombre as estado_nombre,
        om.observaciones FROM ordenes_medicas om JOIN profesionales prof ON om.profesional_id = prof.profesional_id LEFT JOIN medicamentos m ON om.medicamento_id = m.medicamento_id JOIN estados e ON om.estado_id = e.estado_id WHERE om.paciente_id = p_paciente_id ORDER BY om.fecha_orden DESC;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_orden_por_id(
    IN p_orden_id INT
)
BEGIN SELECT om.orden_id,
        om.paciente_id,
        CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
        om.profesional_id,
        CONCAT(prof.nombre, ' ', prof.apellido) as profesional_nombre,
        om.tipo_orden,
        om.descripcion,
        om.medicamento_id,
        COALESCE(m.nombre_comercial, 'N/A') as medicamento_nombre,
        om.dosis,
        om.frecuencia,
        om.duracion,
        om.fecha_orden,
        om.fecha_inicio,
        om.fecha_fin,
        om.estado_id,
        e.nombre as estado_nombre,
        om.observaciones,
        om.created_at FROM ordenes_medicas om JOIN pacientes p ON om.paciente_id = p.paciente_id JOIN profesionales prof ON om.profesional_id = prof.profesional_id LEFT JOIN medicamentos m ON om.medicamento_id = m.medicamento_id JOIN estados e ON om.estado_id = e.estado_id WHERE om.orden_id = p_orden_id;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_pacientes_activos()
BEGIN SELECT paciente_id, nombre, apellido FROM pacientes WHERE estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'paciente' AND nombre = 'activo');
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_pacientes_estados()
BEGIN SELECT p.*, e.nombre as estado_nombre, u.username, u.passhash FROM pacientes p JOIN estados e ON p.estado_id = e.estado_id LEFT JOIN usuarios u ON u.persona_id = p.paciente_id AND u.tipo_persona = 'paciente'
    ORDER BY p.paciente_id DESC;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_paciente_por_id(IN p_paciente_id INT)
BEGIN SELECT p.*, e.nombre as estado_nombre, u.username, u.passhash FROM pacientes p JOIN estados e ON p.estado_id = e.estado_id LEFT JOIN usuarios u ON u.persona_id = p.paciente_id AND u.tipo_persona = 'paciente'
    WHERE p.paciente_id = p_paciente_id;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_planes_progreso()
BEGIN SELECT * FROM progresoPorPlan;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_plan_por_id(IN p_plan_id INT)
BEGIN SELECT pt.*, 
           CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
           e.nombre as estado_nombre FROM planes_terapeuticos pt JOIN pacientes p ON pt.paciente_id = p.paciente_id JOIN estados e ON pt.estado_id = e.estado_id WHERE pt.plan_id = p_plan_id;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_profesionales_activos()
BEGIN SELECT profesional_id, nombre, apellido FROM profesionales WHERE estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'profesional' AND nombre = 'activo');
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_salas_activas()
BEGIN SELECT sala_id, nombre FROM salas WHERE estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'sala' AND nombre = 'activa');
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_sesiones_detalladas()
BEGIN SELECT s.sesion_id, c.cita_id, 
           CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre, 
           CONCAT(prof.nombre, ' ', prof.apellido) as profesional_nombre, 
           s.fecha_registro, s.notas, s.tecnica_utilizada FROM sesiones s JOIN citas c ON s.cita_id = c.cita_id JOIN pacientes p ON c.paciente_id = p.paciente_id JOIN profesionales prof ON c.profesional_id = prof.profesional_id ORDER BY s.fecha_registro DESC;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE obtener_sesion_por_id(IN p_sesion_id INT)
BEGIN SELECT s.*, 
           CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
           CONCAT(prof.nombre, ' ', prof.apellido) as profesional_nombre,
           c.fecha_inicio FROM sesiones s JOIN citas c ON s.cita_id = c.cita_id JOIN pacientes p ON c.paciente_id = p.paciente_id JOIN profesionales prof ON c.profesional_id = prof.profesional_id WHERE s.sesion_id = p_sesion_id;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE ordenActualizar(
    IN p_orden_id INT,
    IN p_descripcion TEXT,
    IN p_dosis VARCHAR(100),
    IN p_frecuencia VARCHAR(100),
    IN p_duracion VARCHAR(100),
    IN p_fecha_fin DATE,
    IN p_estado_id INT,
    IN p_observaciones TEXT,
    IN p_usuario_id INT
)
BEGIN UPDATE ordenes_medicas SET descripcion = p_descripcion,
        dosis = p_dosis,
        frecuencia = p_frecuencia,
        duracion = p_duracion,
        fecha_fin = p_fecha_fin,
        estado_id = p_estado_id,
        observaciones = p_observaciones WHERE orden_id = p_orden_id;
    
    SELECT ROW_COUNT() as affected_rows;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE ordenCrear(
    IN p_paciente_id INT,
    IN p_profesional_id INT,
    IN p_tipo_orden ENUM('medicamento','procedimiento','examen','terapia'),
    IN p_descripcion TEXT,
    IN p_medicamento_id INT,
    IN p_dosis VARCHAR(100),
    IN p_frecuencia VARCHAR(100),
    IN p_duracion VARCHAR(100),
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_observaciones TEXT,
    IN p_usuario_id INT
)
BEGIN DECLARE v_estado_pendiente INT;
    
    
    SELECT estado_id INTO v_estado_pendiente FROM estados WHERE nombre = 'pendiente' AND tipo_entidad = 'orden';
    
    IF v_estado_pendiente IS NULL THEN SELECT estado_id INTO v_estado_pendiente FROM estados WHERE nombre = 'pendiente' 
        LIMIT 1;
    END IF;
    
    INSERT INTO ordenes_medicas (
        paciente_id,
        profesional_id,
        tipo_orden,
        descripcion,
        medicamento_id,
        dosis,
        frecuencia,
        duracion,
        fecha_orden,
        fecha_inicio,
        fecha_fin,
        estado_id,
        observaciones,
        created_at
    ) VALUES (
        p_paciente_id,
        p_profesional_id,
        p_tipo_orden,
        p_descripcion,
        p_medicamento_id,
        p_dosis,
        p_frecuencia,
        p_duracion,
        NOW(),
        p_fecha_inicio,
        p_fecha_fin,
        v_estado_pendiente,
        p_observaciones,
        NOW()
    );
    
    SELECT LAST_INSERT_ID() as orden_id;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE pacienteActualizar(
    IN p_paciente_id INT,
    IN p_identificacion VARCHAR(20),
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_fecha_nacimiento DATE,
    IN p_telefono VARCHAR(20),
    IN p_email VARCHAR(100),
    IN p_direccion TEXT,
    IN p_estado_id INT,
    IN p_usuario_id INT
)
BEGIN DECLARE v_old_val JSON;
    DECLARE v_new_val JSON;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT JSON_OBJECT(
        'identificacion', identificacion,
        'nombre', nombre,
        'apellido', apellido,
        'telefono', telefono,
        'email', email,
        'estado_id', estado_id
    ) INTO v_old_val FROM pacientes WHERE paciente_id = p_paciente_id;
    
    
    UPDATE pacientes SET identificacion = p_identificacion,
        nombre = p_nombre,
        apellido = p_apellido,
        fecha_nacimiento = p_fecha_nacimiento,
        telefono = p_telefono,
        email = p_email,
        direccion = p_direccion,
        estado_id = p_estado_id,
        updated_at = CURRENT_TIMESTAMP WHERE paciente_id = p_paciente_id;
    
    
    SELECT JSON_OBJECT(
        'identificacion', identificacion,
        'nombre', nombre,
        'apellido', apellido,
        'telefono', telefono,
        'email', email,
        'estado_id', estado_id
    ) INTO v_new_val FROM pacientes WHERE paciente_id = p_paciente_id;
    
    
    INSERT INTO auditoria_pacientes (paciente_id, accion, usuario_id, valor_anterior, valor_nuevo)
    VALUES (p_paciente_id, 'UPDATE', p_usuario_id, v_old_val, v_new_val);
    
    COMMIT;
END ;;
DELIMITER ;


DELIMITER ;;

CREATE PROCEDURE pacienteCrear(
    IN p_identificacion VARCHAR(20),
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_fecha_nacimiento DATE,
    IN p_telefono VARCHAR(20),
    IN p_email VARCHAR(100),
    IN p_direccion TEXT,
    IN p_usuario_id INT,
    OUT p_paciente_id INT
)
BEGIN
    DECLARE v_estado_activo INT;
    DECLARE v_new_paciente_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Obtener el estado activo
    SELECT estado_id INTO v_estado_activo 
    FROM estados 
    WHERE tipo_entidad = 'paciente' AND nombre = 'activo';

    -- Validaciones
    IF p_identificacion IS NULL OR p_nombre IS NULL OR p_apellido IS NULL THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Identificación, nombre y apellido son obligatorios';
    END IF;

    IF EXISTS (SELECT 1 FROM pacientes WHERE identificacion = p_identificacion) THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un paciente con esta identificación';
    END IF;

    -- Insertar el paciente
    INSERT INTO pacientes (
        identificacion, nombre, apellido, fecha_nacimiento,
        telefono, email, direccion, fecha_alta, estado_id
    ) VALUES (
        p_identificacion, p_nombre, p_apellido, p_fecha_nacimiento,
        p_telefono, p_email, p_direccion, CURDATE(), v_estado_activo
    );

    -- Capturar el ID del paciente recién creado
    SET v_new_paciente_id = LAST_INSERT_ID();
    SET p_paciente_id = v_new_paciente_id;

    -- Auditoría
    INSERT INTO auditoria_pacientes (paciente_id, accion, usuario_id, campo_afectado)
    VALUES (v_new_paciente_id, 'INSERT', p_usuario_id, 'TODOS');

    COMMIT;
END ;;

DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE planCrear(
    IN p_paciente_id INT,
    IN p_diagnostico_principal TEXT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin_estimada DATE,
    IN p_objetivos JSON,
    IN p_usuario_id INT
)
BEGIN DECLARE v_plan_id INT;
    DECLARE v_estado_activo INT;
    DECLARE v_objetivo_count INT DEFAULT 0;
    DECLARE v_objetivo_desc TEXT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_activo FROM estados WHERE tipo_entidad = 'plan' AND nombre = 'activo';
    
    
    IF NOT EXISTS (SELECT 1 FROM pacientes WHERE paciente_id = p_paciente_id AND estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'paciente' AND nombre = 'activo')) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El paciente no existe o no está activo';
    END IF;
    
    
    INSERT INTO planes_terapeuticos (paciente_id, diagnostico_principal, fecha_inicio, fecha_fin_estimada, estado_id)
    VALUES (p_paciente_id, p_diagnostico_principal, p_fecha_inicio, p_fecha_fin_estimada, v_estado_activo);
    
    SET v_plan_id = LAST_INSERT_ID();
    
    
    IF p_objetivos IS NOT NULL THEN SET v_objetivo_count = JSON_LENGTH(p_objetivos);
        
        WHILE v_objetivo_count > 0 DO SET v_objetivo_count = v_objetivo_count - 1;
            SET v_objetivo_desc = JSON_UNQUOTE(JSON_EXTRACT(p_objetivos, CONCAT('$[', v_objetivo_count, ']')));
            
            IF v_objetivo_desc IS NOT NULL AND v_objetivo_desc != '' THEN INSERT INTO objetivos_plan (plan_id, descripcion, estado_id)
                VALUES (v_plan_id, v_objetivo_desc, (SELECT estado_id FROM estados WHERE tipo_entidad = 'objetivo' AND nombre = 'pendiente'));
            END IF;
        END WHILE;
    END IF;
    
    COMMIT;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE profesionalCrear(
    IN p_identificacion VARCHAR(20),
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_especialidad VARCHAR(100),
    IN p_horario_inicio TIME,
    IN p_horario_fin TIME,
    IN p_telefono VARCHAR(20),
    IN p_email VARCHAR(100)
)
BEGIN DECLARE v_estado_activo INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_activo FROM estados WHERE tipo_entidad = 'profesional' AND nombre = 'activo';
    
    
    IF p_identificacion IS NULL OR p_nombre IS NULL OR p_apellido IS NULL OR p_especialidad IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Identificación, nombre, apellido y especialidad son obligatorios';
    END IF;
    
    IF EXISTS (SELECT 1 FROM profesionales WHERE identificacion = p_identificacion) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un profesional con esta identificación';
    END IF;
    
    
    INSERT INTO profesionales (
        identificacion, nombre, apellido, especialidad, 
        horario_inicio, horario_fin, telefono, email, estado_id
    ) VALUES (
        p_identificacion, p_nombre, p_apellido, p_especialidad,
        p_horario_inicio, p_horario_fin, p_telefono, p_email, v_estado_activo
    );
    
    COMMIT;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE registrar_sesion_completa(
    IN p_cita_id INT,
    IN p_notas TEXT,
    IN p_tecnica_utilizada VARCHAR(255),
    IN p_duracion_real_min INT,
    IN p_usuario_id INT,
    IN p_puntajes_json JSON
)
BEGIN DECLARE v_sesion_id INT;
    DECLARE v_plan_id INT;
    DECLARE v_paciente_id INT;
    DECLARE v_total_objetivos INT;
    DECLARE v_objetivos_cumplidos INT;
    DECLARE i INT DEFAULT 0;
    DECLARE v_escala_id INT;
    DECLARE v_puntaje DECIMAL(5,2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    INSERT INTO sesiones (cita_id, notas, tecnica_utilizada, duracion_real_min, fecha_registro)
    VALUES (p_cita_id, p_notas, p_tecnica_utilizada, p_duracion_real_min, NOW());
    
    SET v_sesion_id = LAST_INSERT_ID();
    
    
    IF p_puntajes_json IS NOT NULL AND JSON_LENGTH(p_puntajes_json) > 0 THEN WHILE i < JSON_LENGTH(p_puntajes_json) DO SET v_escala_id = JSON_UNQUOTE(JSON_EXTRACT(p_puntajes_json, CONCAT('$[', i, '].escala_id')));
            SET v_puntaje = JSON_UNQUOTE(JSON_EXTRACT(p_puntajes_json, CONCAT('$[', i, '].puntaje')));
            
            INSERT INTO sesion_escalas (sesion_id, escala_id, puntaje)
            VALUES (v_sesion_id, v_escala_id, v_puntaje);
            
            SET i = i + 1;
        END WHILE;
    END IF;
    
    
    SELECT pt.plan_id, c.paciente_id INTO v_plan_id, v_paciente_id FROM planes_terapeuticos pt JOIN citas c ON pt.paciente_id = c.paciente_id WHERE c.cita_id = p_cita_id AND pt.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'plan' AND nombre = 'activo')
    LIMIT 1;
    
    
    IF v_plan_id IS NOT NULL THEN SELECT COUNT(*) as total,
            SUM(CASE WHEN estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'objetivo' AND nombre = 'cumplido') THEN 1 ELSE 0 END) as cumplidos INTO v_total_objetivos, v_objetivos_cumplidos FROM objetivos_plan WHERE plan_id = v_plan_id;
        
        IF v_total_objetivos > 0 AND v_objetivos_cumplidos = v_total_objetivos THEN UPDATE planes_terapeuticos SET estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'plan' AND nombre = 'completado'),
                fecha_cierre = CURDATE(),
                motivo_cierre = 'Metas cumplidas - Cierre automático'
            WHERE plan_id = v_plan_id;
        END IF;
    END IF;
    
    
    UPDATE citas SET estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada')
    WHERE cita_id = p_cita_id;
    
    COMMIT;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE registrar_sesion_con_cierre_plan(
    IN p_cita_id INT,
    IN p_notas TEXT,
    IN p_tecnica_utilizada VARCHAR(255),
    IN p_duracion_real_min INT,
    IN p_puntajes JSON,
    IN p_usuario_id INT
)
BEGIN DECLARE v_plan_id INT;
    DECLARE v_objetivos_total INT;
    DECLARE v_objetivos_cumplidos INT;
    DECLARE v_estado_completado INT;
    
    
    INSERT INTO sesiones (cita_id, notas, tecnica_utilizada, duracion_real_min, fecha_registro, usuario_registro)
    VALUES (p_cita_id, p_notas, p_tecnica_utilizada, p_duracion_real_min, NOW(), p_usuario_id);
    
    
    SELECT pt.plan_id INTO v_plan_id FROM planes_terapeuticos pt JOIN citas c ON pt.paciente_id = c.paciente_id WHERE c.cita_id = p_cita_id AND pt.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'plan' AND nombre = 'activo')
    LIMIT 1;
    
    IF v_plan_id IS NOT NULL THEN SELECT COUNT(*),
            SUM(CASE WHEN estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'objetivo' AND nombre = 'cumplido') THEN 1 ELSE 0 END)
        INTO v_objetivos_total, v_objetivos_cumplidos FROM objetivos_plan WHERE plan_id = v_plan_id;
        
        IF v_objetivos_total > 0 AND v_objetivos_cumplidos = v_objetivos_total THEN SELECT estado_id INTO v_estado_completado FROM estados WHERE tipo_entidad = 'plan' AND nombre = 'completado';
            
            UPDATE planes_terapeuticos SET estado_id = v_estado_completado,
                fecha_cierre = CURDATE(),
                motivo_cierre = 'Metas cumplidas - Cierre automático'
            WHERE plan_id = v_plan_id;
        END IF;
    END IF;
    
    
    UPDATE citas SET estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada')
    WHERE cita_id = p_cita_id;
    
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE reporteAdherencia(
    IN p_desde DATE,
    IN p_hasta DATE
)
BEGIN CREATE TEMPORARY TABLE tmpAdherencia (
        paciente_id INT,
        paciente_nombre VARCHAR(201),
        total_citas INT,
        asistidas INT,
        no_shows INT,
        canceladas INT,
        tasa_adherencia DECIMAL(5,2)
    );
    
    INSERT INTO tmpAdherencia SELECT p.paciente_id,
        CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
        COUNT(c.cita_id) as total_citas,
        SUM(CASE WHEN c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada') THEN 1 ELSE 0 END) as asistidas,
        SUM(CASE WHEN c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show') THEN 1 ELSE 0 END) as no_shows,
        SUM(CASE WHEN c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'cancelada') THEN 1 ELSE 0 END) as canceladas,
        ROUND(
            (SUM(CASE WHEN c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada') THEN 1 ELSE 0 END) * 100.0 / 
            NULLIF(SUM(CASE WHEN c.estado_id IN (
                (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada'),
                (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show')
            ) THEN 1 ELSE 0 END), 0)),
        2) as tasa_adherencia FROM pacientes p LEFT JOIN citas c ON p.paciente_id = c.paciente_id WHERE c.fecha_inicio BETWEEN p_desde AND p_hasta GROUP BY p.paciente_id, p.nombre, p.apellido;
    
    SELECT * FROM tmpAdherencia ORDER BY tasa_adherencia DESC;
    
    DROP TEMPORARY TABLE tmpAdherencia;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE reporteNoShow(
    IN p_desde DATE,
    IN p_hasta DATE,
    IN p_por_profesional BOOLEAN
)
BEGIN CREATE TEMPORARY TABLE tmpNoShow (
        profesional_id INT,
        profesional_nombre VARCHAR(201),
        motivo VARCHAR(200),
        cantidad INT
    );
    
    IF p_por_profesional THEN INSERT INTO tmpNoShow SELECT prof.profesional_id,
            CONCAT(prof.nombre, ' ', prof.apellido) as profesional_nombre,
            COALESCE(mc.descripcion, 'Sin motivo específico') as motivo,
            COUNT(*) as cantidad FROM citas c JOIN profesionales prof ON c.profesional_id = prof.profesional_id LEFT JOIN motivos_cancelacion mc ON c.motivo_cancelacion_id = mc.motivo_id WHERE c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show')
        AND c.fecha_inicio BETWEEN p_desde AND p_hasta GROUP BY prof.profesional_id, mc.descripcion;
    ELSE INSERT INTO tmpNoShow SELECT NULL as profesional_id,
            'Todos' as profesional_nombre,
            COALESCE(mc.descripcion, 'Sin motivo específico') as motivo,
            COUNT(*) as cantidad FROM citas c LEFT JOIN motivos_cancelacion mc ON c.motivo_cancelacion_id = mc.motivo_id WHERE c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show')
        AND c.fecha_inicio BETWEEN p_desde AND p_hasta GROUP BY mc.descripcion;
    END IF;
    
    SELECT * FROM tmpNoShow ORDER BY cantidad DESC;
    
    DROP TEMPORARY TABLE tmpNoShow;
END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE sesionRegistrar(
    IN p_cita_id INT,
    IN p_notas TEXT,
    IN p_tecnica_utilizada VARCHAR(255),
    IN p_duracion_real_min INT,
    IN p_puntajes JSON,
    IN p_usuario_id INT
)
BEGIN DECLARE v_plan_id INT;
    DECLARE v_objetivos_total INT;
    DECLARE v_objetivos_cumplidos INT;
    DECLARE v_estado_completado INT;

    
    INSERT INTO sesiones (cita_id, notas, tecnica_utilizada, duracion_real_min, fecha_registro, usuario_registro)
    VALUES (p_cita_id, p_notas, p_tecnica_utilizada, p_duracion_real_min, NOW(), p_usuario_id);

    
    SELECT pt.plan_id INTO v_plan_id FROM planes_terapeuticos pt JOIN citas c ON pt.paciente_id = c.paciente_id WHERE c.cita_id = p_cita_id AND pt.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'plan' AND nombre = 'activo')
    LIMIT 1;
    
    IF v_plan_id IS NOT NULL THEN SELECT COUNT(*),
            SUM(CASE WHEN estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'objetivo' AND nombre = 'cumplido') THEN 1 ELSE 0 END)
        INTO v_objetivos_total, v_objetivos_cumplidos FROM objetivos_plan WHERE plan_id = v_plan_id;
        
        IF v_objetivos_total > 0 AND v_objetivos_cumplidos = v_objetivos_total THEN SELECT estado_id INTO v_estado_completado FROM estados WHERE tipo_entidad = 'plan' AND nombre = 'completado';
            
            UPDATE planes_terapeuticos SET estado_id = v_estado_completado,
                fecha_cierre = CURDATE(),
                motivo_cierre = 'Metas cumplidas - Cierre automático'
            WHERE plan_id = v_plan_id;
        END IF;
    END IF;

    
    UPDATE citas SET estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada')
    WHERE cita_id = p_cita_id;

END ;;
DELIMITER ;


DELIMITER ;;
CREATE PROCEDURE usuarioRoles(
    IN p_usuario_id INT
)
BEGIN SELECT r.rol_id,
        r.nombre as nombre_rol,
        r.descripcion,
        r.permisos FROM roles r JOIN usuario_roles ur ON r.rol_id = ur.rol_id WHERE ur.usuario_id = p_usuario_id AND r.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'rol' AND nombre = 'activo');
END ;;
DELIMITER ;

