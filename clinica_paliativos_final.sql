/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-12.0.2-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: clinica_paliativos
-- ------------------------------------------------------
-- Server version	12.0.2-MariaDB-ubu2404

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `administracion_medicamentos`
--

DROP TABLE IF EXISTS `administracion_medicamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `administracion_medicamentos` (
  `administracion_id` int(11) NOT NULL AUTO_INCREMENT,
  `paciente_id` int(11) NOT NULL,
  `medicamento_id` int(11) NOT NULL,
  `orden_medica_id` int(11) DEFAULT NULL,
  `dosis` varchar(100) NOT NULL,
  `via_administracion` varchar(50) NOT NULL,
  `fecha_hora_administracion` datetime NOT NULL,
  `fecha_hora_programada` datetime NOT NULL,
  `enfermera_id` int(11) NOT NULL,
  `estado_administracion` enum('pendiente','administrado','omitido','rechazado') NOT NULL,
  `observaciones` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`administracion_id`),
  KEY `paciente_id` (`paciente_id`),
  KEY `medicamento_id` (`medicamento_id`),
  KEY `orden_medica_id` (`orden_medica_id`),
  KEY `enfermera_id` (`enfermera_id`),
  CONSTRAINT `administracion_medicamentos_ibfk_1` FOREIGN KEY (`paciente_id`) REFERENCES `pacientes` (`paciente_id`),
  CONSTRAINT `administracion_medicamentos_ibfk_2` FOREIGN KEY (`medicamento_id`) REFERENCES `medicamentos` (`medicamento_id`),
  CONSTRAINT `administracion_medicamentos_ibfk_3` FOREIGN KEY (`orden_medica_id`) REFERENCES `ordenes_medicas` (`orden_id`),
  CONSTRAINT `administracion_medicamentos_ibfk_4` FOREIGN KEY (`enfermera_id`) REFERENCES `enfermeras` (`enfermera_id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `administracion_medicamentos`
--

LOCK TABLES `administracion_medicamentos` WRITE;
/*!40000 ALTER TABLE `administracion_medicamentos` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `administracion_medicamentos` VALUES
(17,1,1,1,'500 mg','oral','2025-01-10 08:00:00','2025-01-10 08:00:00',1,'administrado','Sin novedad','2025-11-24 02:53:44'),
(18,1,2,1,'1 tableta','oral','2025-01-10 20:00:00','2025-01-10 20:00:00',2,'administrado','Paciente tolera bien','2025-11-24 02:53:44'),
(19,2,1,1,'500 mg','oral','2025-01-10 08:15:00','2025-01-10 08:00:00',3,'pendiente','Medicamento aún no entregado por farmacia','2025-11-24 02:53:44'),
(20,2,3,1,'10 ml','intravenosa','2025-01-10 14:30:00','2025-01-10 14:00:00',4,'administrado','Administrado con leve retraso','2025-11-24 02:53:44'),
(21,3,4,1,'250 mg','intramuscular','2025-01-11 09:10:00','2025-01-11 09:00:00',1,'omitido','Orden suspendida al momento de administración','2025-11-24 02:53:44'),
(22,3,2,1,'1 tableta','oral','2025-01-11 21:00:00','2025-01-11 21:00:00',5,'administrado','Sin efectos adversos','2025-11-24 02:53:44'),
(23,4,3,1,'5 ml','intravenosa','2025-01-10 16:05:00','2025-01-10 16:00:00',2,'rechazado','Paciente rechazó el medicamento','2025-11-24 02:53:44'),
(24,4,1,1,'500 mg','oral','2025-01-11 08:00:00','2025-01-11 08:00:00',3,'administrado','Sin novedad','2025-11-24 02:53:44');
/*!40000 ALTER TABLE `administracion_medicamentos` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `asignaciones_cama`
--

DROP TABLE IF EXISTS `asignaciones_cama`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `asignaciones_cama` (
  `asignacion_id` int(11) NOT NULL AUTO_INCREMENT,
  `paciente_id` int(11) NOT NULL,
  `cama_id` int(11) NOT NULL,
  `fecha_ingreso` datetime NOT NULL,
  `fecha_egreso` datetime DEFAULT NULL,
  `motivo_ingreso` text DEFAULT NULL,
  `motivo_egreso` text DEFAULT NULL,
  `estado_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`asignacion_id`),
  KEY `paciente_id` (`paciente_id`),
  KEY `cama_id` (`cama_id`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `asignaciones_cama_ibfk_1` FOREIGN KEY (`paciente_id`) REFERENCES `pacientes` (`paciente_id`),
  CONSTRAINT `asignaciones_cama_ibfk_2` FOREIGN KEY (`cama_id`) REFERENCES `camas` (`cama_id`),
  CONSTRAINT `asignaciones_cama_ibfk_3` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignaciones_cama`
--

LOCK TABLES `asignaciones_cama` WRITE;
/*!40000 ALTER TABLE `asignaciones_cama` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `asignaciones_cama` VALUES
(1,4,5,'1986-12-05 23:31:00','1984-10-16 09:36:00','Recusandae Maxime e','Modi nulla dolor rer',52,'2025-11-24 02:42:25');
/*!40000 ALTER TABLE `asignaciones_cama` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `asignaciones_paciente`
--

DROP TABLE IF EXISTS `asignaciones_paciente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `asignaciones_paciente` (
  `asignacion_id` int(11) NOT NULL AUTO_INCREMENT,
  `paciente_id` int(11) NOT NULL,
  `profesional_id` int(11) DEFAULT NULL,
  `enfermera_id` int(11) DEFAULT NULL,
  `tipo_asignacion` enum('medico_tratante','enfermera_asignada','especialista') NOT NULL,
  `fecha_asignacion` date NOT NULL,
  `fecha_fin` date DEFAULT NULL,
  `es_principal` tinyint(1) DEFAULT 0,
  `observaciones` text DEFAULT NULL,
  `estado_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`asignacion_id`),
  KEY `paciente_id` (`paciente_id`),
  KEY `profesional_id` (`profesional_id`),
  KEY `enfermera_id` (`enfermera_id`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `asignaciones_paciente_ibfk_1` FOREIGN KEY (`paciente_id`) REFERENCES `pacientes` (`paciente_id`),
  CONSTRAINT `asignaciones_paciente_ibfk_2` FOREIGN KEY (`profesional_id`) REFERENCES `profesionales` (`profesional_id`),
  CONSTRAINT `asignaciones_paciente_ibfk_3` FOREIGN KEY (`enfermera_id`) REFERENCES `enfermeras` (`enfermera_id`),
  CONSTRAINT `asignaciones_paciente_ibfk_4` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignaciones_paciente`
--

LOCK TABLES `asignaciones_paciente` WRITE;
/*!40000 ALTER TABLE `asignaciones_paciente` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `asignaciones_paciente` VALUES
(1,1,3,1,'especialista','1994-03-28','2008-10-24',0,'Soluta cupiditate ul',51,'2025-11-24 02:47:46'),
(2,3,2,3,'especialista','2025-02-22',NULL,1,NULL,51,'2025-11-24 03:33:24');
/*!40000 ALTER TABLE `asignaciones_paciente` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `auditoria_citas`
--

DROP TABLE IF EXISTS `auditoria_citas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `auditoria_citas` (
  `auditoria_id` int(11) NOT NULL AUTO_INCREMENT,
  `cita_id` int(11) DEFAULT NULL,
  `accion` enum('INSERT','UPDATE','DELETE') DEFAULT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `fecha_auditoria` timestamp NOT NULL DEFAULT current_timestamp(),
  `valores_anteriores` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`valores_anteriores`)),
  `valores_nuevos` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`valores_nuevos`)),
  `ip_address` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`auditoria_id`),
  KEY `cita_id` (`cita_id`),
  KEY `idx_auditoria_citas_fecha` (`fecha_auditoria`),
  CONSTRAINT `auditoria_citas_ibfk_1` FOREIGN KEY (`cita_id`) REFERENCES `citas` (`cita_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria_citas`
--

LOCK TABLES `auditoria_citas` WRITE;
/*!40000 ALTER TABLE `auditoria_citas` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `auditoria_citas` VALUES
(1,1,'INSERT',NULL,'2025-10-30 22:27:11',NULL,'{\"paciente_id\": 1, \"profesional_id\": 1, \"sala_id\": 1, \"fecha_inicio\": \"2025-10-30 17:00:00\", \"fecha_fin\": \"2025-10-30 18:00:00\", \"estado_id\": 15}',NULL),
(2,1,'UPDATE',NULL,'2025-10-30 22:28:55','{\"estado_id\": 15, \"fecha_inicio\": \"2025-10-30 17:00:00\", \"fecha_fin\": \"2025-10-30 18:00:00\"}','{\"estado_id\": 19, \"fecha_inicio\": \"2025-10-30 17:00:00\", \"fecha_fin\": \"2025-10-30 18:00:00\"}',NULL),
(3,2,'INSERT',NULL,'2025-10-30 22:29:29',NULL,'{\"paciente_id\": 1, \"profesional_id\": 3, \"sala_id\": 3, \"fecha_inicio\": \"2025-10-30 17:00:00\", \"fecha_fin\": \"2025-10-30 18:00:00\", \"estado_id\": 15}',NULL),
(5,2,'UPDATE',NULL,'2025-10-30 23:06:40','{\"estado_id\": 15, \"fecha_inicio\": \"2025-10-30 17:00:00\", \"fecha_fin\": \"2025-10-30 18:00:00\"}','{\"estado_id\": 17, \"fecha_inicio\": \"2025-10-30 17:00:00\", \"fecha_fin\": \"2025-10-30 18:00:00\"}',NULL),
(6,3,'INSERT',NULL,'2025-10-31 00:07:48',NULL,'{\"paciente_id\": 1, \"profesional_id\": 3, \"sala_id\": 3, \"fecha_inicio\": \"2025-10-31 09:07:00\", \"fecha_fin\": \"2025-10-31 10:07:00\", \"estado_id\": 15}',NULL),
(7,3,'UPDATE',NULL,'2025-10-31 00:20:56','{\"estado_id\": 15, \"fecha_inicio\": \"2025-10-31 09:07:00\", \"fecha_fin\": \"2025-10-31 10:07:00\"}','{\"estado_id\": 17, \"fecha_inicio\": \"2025-10-31 09:07:00\", \"fecha_fin\": \"2025-10-31 10:07:00\"}',NULL),
(8,4,'INSERT',NULL,'2025-10-31 01:17:42',NULL,'{\"paciente_id\": 2, \"profesional_id\": 1, \"sala_id\": 1, \"fecha_inicio\": \"2025-10-31 09:17:00\", \"fecha_fin\": \"2025-10-31 10:17:00\", \"estado_id\": 15}',NULL),
(9,4,'UPDATE',NULL,'2025-10-31 01:22:15','{\"estado_id\": 15, \"fecha_inicio\": \"2025-10-31 09:17:00\", \"fecha_fin\": \"2025-10-31 10:17:00\"}','{\"estado_id\": 17, \"fecha_inicio\": \"2025-10-31 09:17:00\", \"fecha_fin\": \"2025-10-31 10:17:00\"}',NULL),
(10,5,'INSERT',NULL,'2025-11-01 03:05:29',NULL,'{\"paciente_id\": 3, \"profesional_id\": 2, \"sala_id\": 2, \"fecha_inicio\": \"2025-11-01 09:05:00\", \"fecha_fin\": \"2025-11-01 11:05:00\", \"estado_id\": 15}',NULL),
(11,5,'UPDATE',NULL,'2025-11-06 14:32:42','{\"estado_id\": 15, \"fecha_inicio\": \"2025-11-01 09:05:00\", \"fecha_fin\": \"2025-11-01 11:05:00\"}','{\"estado_id\": 17, \"fecha_inicio\": \"2025-11-01 09:05:00\", \"fecha_fin\": \"2025-11-01 11:05:00\"}',NULL),
(12,6,'INSERT',NULL,'2025-11-24 04:00:55',NULL,'{\"paciente_id\": 3, \"profesional_id\": 1, \"sala_id\": 2, \"fecha_inicio\": \"2025-11-23 08:00:00\", \"fecha_fin\": \"2025-11-23 09:00:00\", \"estado_id\": 15}',NULL),
(13,7,'INSERT',NULL,'2025-11-24 05:02:58',NULL,'{\"paciente_id\": 2, \"profesional_id\": 2, \"sala_id\": 1, \"fecha_inicio\": \"2025-11-24 08:02:00\", \"fecha_fin\": \"2025-11-24 09:02:00\", \"estado_id\": 15}',NULL),
(14,8,'INSERT',NULL,'2025-11-24 18:03:20',NULL,'{\"paciente_id\": 10, \"profesional_id\": 2, \"sala_id\": 2, \"fecha_inicio\": \"2025-11-24 14:02:00\", \"fecha_fin\": \"2025-11-24 17:02:00\", \"estado_id\": 15}',NULL);
/*!40000 ALTER TABLE `auditoria_citas` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `auditoria_pacientes`
--

DROP TABLE IF EXISTS `auditoria_pacientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `auditoria_pacientes` (
  `auditoria_id` int(11) NOT NULL AUTO_INCREMENT,
  `paciente_id` int(11) DEFAULT NULL,
  `accion` enum('INSERT','UPDATE','DELETE') DEFAULT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `fecha_auditoria` timestamp NOT NULL DEFAULT current_timestamp(),
  `campo_afectado` varchar(50) DEFAULT NULL,
  `valor_anterior` text DEFAULT NULL,
  `valor_nuevo` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`auditoria_id`),
  KEY `paciente_id` (`paciente_id`),
  KEY `idx_auditoria_pacientes_fecha` (`fecha_auditoria`),
  CONSTRAINT `auditoria_pacientes_ibfk_1` FOREIGN KEY (`paciente_id`) REFERENCES `pacientes` (`paciente_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria_pacientes`
--

LOCK TABLES `auditoria_pacientes` WRITE;
/*!40000 ALTER TABLE `auditoria_pacientes` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `auditoria_pacientes` VALUES
(1,1,'INSERT',1,'2025-10-30 22:12:39','TODOS',NULL,NULL,NULL),
(2,2,'INSERT',1,'2025-10-31 01:00:32','TODOS',NULL,NULL,NULL),
(3,3,'INSERT',1,'2025-10-31 15:49:34','TODOS',NULL,NULL,NULL),
(4,2,'UPDATE',1,'2025-10-31 17:14:49',NULL,'{\"identificacion\": \"1066872259\", \"nombre\": \"LUIS JOSE\", \"apellido\": \"PEREZ MEZA\", \"telefono\": \"3103690094\", \"email\": \"luisjoseperezmeza123@gmail.com\", \"estado_id\": 1}','{\"identificacion\": \"1066872259\", \"nombre\": \"LUIS JOSE\", \"apellido\": \"PEREZ MEZA\", \"telefono\": \"31036900965\", \"email\": \"luisjoseperezmeza123@gmail.com\", \"estado_id\": 1}',NULL),
(5,2,'UPDATE',1,'2025-10-31 18:00:02',NULL,'{\"identificacion\": \"1066872259\", \"nombre\": \"LUIS JOSE\", \"apellido\": \"PEREZ MEZA\", \"telefono\": \"31036900965\", \"email\": \"luisjoseperezmeza123@gmail.com\", \"estado_id\": 1}','{\"identificacion\": \"1066872259\", \"nombre\": \"LUIS JOSE\", \"apellido\": \"PEREZ MEZA\", \"telefono\": \"3042342311\", \"email\": \"luisjoseperezmeza123@gmail.com\", \"estado_id\": 1}',NULL),
(6,4,'INSERT',1,'2025-11-20 14:57:32','TODOS',NULL,NULL,NULL),
(7,5,'INSERT',1,'2025-11-24 17:00:49','TODOS',NULL,NULL,NULL),
(8,6,'INSERT',1,'2025-11-24 17:10:31','TODOS',NULL,NULL,NULL),
(9,7,'INSERT',1,'2025-11-24 17:17:27','TODOS',NULL,NULL,NULL),
(10,8,'INSERT',1,'2025-11-24 17:18:49','TODOS',NULL,NULL,NULL),
(11,9,'INSERT',1,'2025-11-24 17:31:55','TODOS',NULL,NULL,NULL),
(12,10,'INSERT',1,'2025-11-24 17:40:20','TODOS',NULL,NULL,NULL);
/*!40000 ALTER TABLE `auditoria_pacientes` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `auditoria_sesiones`
--

DROP TABLE IF EXISTS `auditoria_sesiones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `auditoria_sesiones` (
  `auditoria_id` int(11) NOT NULL AUTO_INCREMENT,
  `sesion_id` int(11) DEFAULT NULL,
  `accion` enum('INSERT','UPDATE','DELETE') DEFAULT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `fecha_auditoria` timestamp NOT NULL DEFAULT current_timestamp(),
  `valores_anteriores` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`valores_anteriores`)),
  `valores_nuevos` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`valores_nuevos`)),
  `ip_address` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`auditoria_id`),
  KEY `sesion_id` (`sesion_id`),
  CONSTRAINT `auditoria_sesiones_ibfk_1` FOREIGN KEY (`sesion_id`) REFERENCES `sesiones` (`sesion_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria_sesiones`
--

LOCK TABLES `auditoria_sesiones` WRITE;
/*!40000 ALTER TABLE `auditoria_sesiones` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `auditoria_sesiones` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `camas`
--

DROP TABLE IF EXISTS `camas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `camas` (
  `cama_id` int(11) NOT NULL AUTO_INCREMENT,
  `habitacion_id` int(11) NOT NULL,
  `numero_cama` varchar(10) NOT NULL,
  `tipo_cama` enum('normal','UCI','pediatrica','especial') NOT NULL,
  `descripcion` text DEFAULT NULL,
  `estado_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`cama_id`),
  KEY `habitacion_id` (`habitacion_id`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `camas_ibfk_1` FOREIGN KEY (`habitacion_id`) REFERENCES `habitaciones` (`habitacion_id`),
  CONSTRAINT `camas_ibfk_2` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `camas`
--

LOCK TABLES `camas` WRITE;
/*!40000 ALTER TABLE `camas` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `camas` VALUES
(1,1,'C1','normal','Cama individual normal',1,'2025-11-24 02:42:08'),
(2,1,'C2','UCI','Cama especial para UCI',2,'2025-11-24 02:42:08'),
(3,2,'C1','normal','Cama para habitación compartida',1,'2025-11-24 02:42:08'),
(4,2,'C2','normal','Cama para habitación compartida',3,'2025-11-24 02:42:08'),
(5,3,'C1','UCI','Cama de cuidados intensivos',40,'2025-11-24 02:42:08'),
(6,4,'C1','especial','Cama para aislamiento con equipos de monitoreo',2,'2025-11-24 02:42:08'),
(7,5,'C1','normal','Cama de habitación individual para pacientes especiales',4,'2025-11-24 02:42:08');
/*!40000 ALTER TABLE `camas` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Temporary table structure for view `cargaHorariaSala`
--

DROP TABLE IF EXISTS `cargaHorariaSala`;
/*!50001 DROP VIEW IF EXISTS `cargaHorariaSala`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `cargaHorariaSala` AS SELECT
 1 AS `sala_id`,
  1 AS `sala_nombre`,
  1 AS `fecha`,
  1 AS `hora`,
  1 AS `citas_programadas`,
  1 AS `porcentaje_ocupacion` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `citas`
--

DROP TABLE IF EXISTS `citas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `citas` (
  `cita_id` int(11) NOT NULL AUTO_INCREMENT,
  `paciente_id` int(11) NOT NULL,
  `profesional_id` int(11) NOT NULL,
  `sala_id` int(11) NOT NULL,
  `fecha_inicio` datetime NOT NULL,
  `fecha_fin` datetime NOT NULL,
  `estado_id` int(11) NOT NULL,
  `motivo_cancelacion_id` int(11) DEFAULT NULL,
  `es_reagendo` tinyint(1) DEFAULT 0,
  `cita_original_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`cita_id`),
  KEY `motivo_cancelacion_id` (`motivo_cancelacion_id`),
  KEY `cita_original_id` (`cita_original_id`),
  KEY `idx_citas_paciente_fecha` (`paciente_id`,`fecha_inicio`),
  KEY `idx_citas_profesional_fecha` (`profesional_id`,`fecha_inicio`),
  KEY `idx_citas_sala_fecha` (`sala_id`,`fecha_inicio`),
  KEY `idx_citas_estado_fecha` (`estado_id`,`fecha_inicio`),
  KEY `idx_citas_reagendos` (`es_reagendo`),
  KEY `idx_citas_fecha_inicio` (`fecha_inicio`),
  CONSTRAINT `citas_ibfk_1` FOREIGN KEY (`paciente_id`) REFERENCES `pacientes` (`paciente_id`),
  CONSTRAINT `citas_ibfk_2` FOREIGN KEY (`profesional_id`) REFERENCES `profesionales` (`profesional_id`),
  CONSTRAINT `citas_ibfk_3` FOREIGN KEY (`sala_id`) REFERENCES `salas` (`sala_id`),
  CONSTRAINT `citas_ibfk_4` FOREIGN KEY (`motivo_cancelacion_id`) REFERENCES `motivos_cancelacion` (`motivo_id`),
  CONSTRAINT `citas_ibfk_5` FOREIGN KEY (`cita_original_id`) REFERENCES `citas` (`cita_id`),
  CONSTRAINT `citas_ibfk_6` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `citas`
--

LOCK TABLES `citas` WRITE;
/*!40000 ALTER TABLE `citas` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `citas` VALUES
(1,1,1,1,'2025-10-30 17:00:00','2025-10-30 18:00:00',19,4,0,NULL,'2025-10-30 22:27:11','2025-10-30 22:28:55'),
(2,1,3,3,'2025-10-30 17:00:00','2025-10-30 18:00:00',17,NULL,0,NULL,'2025-10-30 22:29:29','2025-10-30 23:06:40'),
(3,1,3,3,'2025-10-31 09:07:00','2025-10-31 10:07:00',17,NULL,0,NULL,'2025-10-31 00:07:48','2025-10-31 00:20:56'),
(4,2,1,1,'2025-10-31 09:17:00','2025-10-31 10:17:00',17,NULL,0,NULL,'2025-10-31 01:17:42','2025-10-31 01:22:15'),
(5,3,2,2,'2025-11-01 09:05:00','2025-11-01 11:05:00',17,NULL,0,NULL,'2025-11-01 03:05:29','2025-11-06 14:32:42'),
(6,3,1,2,'2025-11-23 08:00:00','2025-11-23 09:00:00',15,NULL,0,NULL,'2025-11-24 04:00:55','2025-11-24 04:00:55'),
(7,2,2,1,'2025-11-24 08:02:00','2025-11-24 09:02:00',15,NULL,0,NULL,'2025-11-24 05:02:58','2025-11-24 05:02:58'),
(8,10,2,2,'2025-11-24 14:02:00','2025-11-24 17:02:00',15,NULL,0,NULL,'2025-11-24 18:03:20','2025-11-24 18:03:20');
/*!40000 ALTER TABLE `citas` ENABLE KEYS */;
UNLOCK TABLES;
commit;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`paliativos_user`@`localhost`*/ /*!50003 TRIGGER citaNoSolapada_BEFORE_INSERT
BEFORE INSERT ON citas
FOR EACH ROW
BEGIN
    DECLARE v_solapamiento INT DEFAULT 0;
    DECLARE v_estado_programada INT;
    
    
    SELECT estado_id INTO v_estado_programada 
    FROM estados 
    WHERE tipo_entidad = 'cita' AND nombre = 'programada';
    
    
    IF NEW.estado_id = v_estado_programada THEN
        SELECT COUNT(*) INTO v_solapamiento
        FROM citas c
        WHERE c.profesional_id = NEW.profesional_id
          AND c.estado_id = v_estado_programada
          AND c.cita_id != COALESCE(NEW.cita_id, -1)
          AND c.fecha_inicio < NEW.fecha_fin
          AND c.fecha_fin > NEW.fecha_inicio;
        
        IF v_solapamiento > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solapamiento detectado con otra cita del profesional';
        END IF;
        
        
        SELECT COUNT(*) INTO v_solapamiento
        FROM citas c
        WHERE c.sala_id = NEW.sala_id
          AND c.estado_id = v_estado_programada
          AND c.cita_id != COALESCE(NEW.cita_id, -1)
          AND c.fecha_inicio < NEW.fecha_fin
          AND c.fecha_fin > NEW.fecha_inicio;
        
        IF v_solapamiento > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solapamiento detectado con otra cita en la sala';
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`paliativos_user`@`localhost`*/ /*!50003 TRIGGER validarHorarioClinica_BEFORE_INSERT
BEFORE INSERT ON citas
FOR EACH ROW
BEGIN
    DECLARE v_horario_valido BOOLEAN DEFAULT FALSE;
    
    
    IF TIME(NEW.fecha_inicio) >= '08:00:00' AND TIME(NEW.fecha_fin) <= '18:00:00' THEN
        SET v_horario_valido = TRUE;
    END IF;
    
    IF NOT v_horario_valido THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Horario fuera del rango de atención (8:00-18:00)';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`paliativos_user`@`localhost`*/ /*!50003 TRIGGER citaAuditoria_AFTER_INSERT
AFTER INSERT ON citas
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_citas (cita_id, accion, valores_nuevos)
    VALUES (NEW.cita_id, 'INSERT', 
            JSON_OBJECT(
                'paciente_id', NEW.paciente_id,
                'profesional_id', NEW.profesional_id,
                'sala_id', NEW.sala_id,
                'fecha_inicio', NEW.fecha_inicio,
                'fecha_fin', NEW.fecha_fin,
                'estado_id', NEW.estado_id
            ));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`paliativos_user`@`localhost`*/ /*!50003 TRIGGER citaAuditoria_AFTER_UPDATE
AFTER UPDATE ON citas
FOR EACH ROW
BEGIN
    IF OLD.estado_id != NEW.estado_id OR 
       OLD.fecha_inicio != NEW.fecha_inicio OR
       OLD.fecha_fin != NEW.fecha_fin THEN
        
        INSERT INTO auditoria_citas (cita_id, accion, valores_anteriores, valores_nuevos)
        VALUES (NEW.cita_id, 'UPDATE',
                JSON_OBJECT(
                    'estado_id', OLD.estado_id,
                    'fecha_inicio', OLD.fecha_inicio,
                    'fecha_fin', OLD.fecha_fin
                ),
                JSON_OBJECT(
                    'estado_id', NEW.estado_id,
                    'fecha_inicio', NEW.fecha_inicio,
                    'fecha_fin', NEW.fecha_fin
                ));
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`paliativos_user`@`localhost`*/ /*!50003 TRIGGER pacienteSuspensionNoshow_AFTER_UPDATE_CITA
AFTER UPDATE ON citas
FOR EACH ROW
BEGIN
    DECLARE v_estado_no_show INT;
    DECLARE v_estado_suspendido INT;
    DECLARE v_no_shows_30dias INT;
    DECLARE v_umbral_suspension INT;
    
    
    IF NEW.estado_id != OLD.estado_id AND 
       NEW.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show') THEN
        
        
        SELECT estado_id INTO v_estado_suspendido FROM estados WHERE tipo_entidad = 'paciente' AND nombre = 'suspendido';
        
        
        SELECT umbral_suspension INTO v_umbral_suspension
        FROM politicas_noshow
        WHERE estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'politica' AND nombre = 'activa')
        LIMIT 1;
        
        
        SELECT COUNT(*) INTO v_no_shows_30dias
        FROM citas
        WHERE paciente_id = NEW.paciente_id
        AND estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show')
        AND fecha_inicio >= DATE_SUB(NOW(), INTERVAL 30 DAY);
        
        
        IF v_no_shows_30dias >= v_umbral_suspension THEN
            UPDATE pacientes 
            SET estado_id = v_estado_suspendido,
                suspension_hasta = DATE_ADD(NOW(), INTERVAL 7 DAY)
            WHERE paciente_id = NEW.paciente_id;
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary table structure for view `citasHoy`
--

DROP TABLE IF EXISTS `citasHoy`;
/*!50001 DROP VIEW IF EXISTS `citasHoy`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `citasHoy` AS SELECT
 1 AS `cita_id`,
  1 AS `paciente`,
  1 AS `profesional`,
  1 AS `sala`,
  1 AS `fecha_inicio`,
  1 AS `fecha_fin`,
  1 AS `estado` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `enfermedades_pacientes`
--

DROP TABLE IF EXISTS `enfermedades_pacientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `enfermedades_pacientes` (
  `enfermedad_id` int(11) NOT NULL AUTO_INCREMENT,
  `paciente_id` int(11) NOT NULL,
  `codigo_cie10` varchar(10) DEFAULT NULL,
  `nombre_enfermedad` varchar(255) NOT NULL,
  `tipo_enfermedad` enum('aguda','cronica','hereditaria','otra') NOT NULL,
  `fecha_diagnostico` date NOT NULL,
  `tratamiento_actual` text DEFAULT NULL,
  `es_principal` tinyint(1) DEFAULT 0,
  `observaciones` text DEFAULT NULL,
  `estado_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`enfermedad_id`),
  KEY `paciente_id` (`paciente_id`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `enfermedades_pacientes_ibfk_1` FOREIGN KEY (`paciente_id`) REFERENCES `pacientes` (`paciente_id`),
  CONSTRAINT `enfermedades_pacientes_ibfk_2` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enfermedades_pacientes`
--

LOCK TABLES `enfermedades_pacientes` WRITE;
/*!40000 ALTER TABLE `enfermedades_pacientes` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `enfermedades_pacientes` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `enfermeras`
--

DROP TABLE IF EXISTS `enfermeras`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `enfermeras` (
  `enfermera_id` int(11) NOT NULL AUTO_INCREMENT,
  `identificacion` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `segundo_apellido` varchar(100) DEFAULT NULL,
  `especialidad` varchar(100) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `estado_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`enfermera_id`),
  UNIQUE KEY `identificacion` (`identificacion`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `enfermeras_ibfk_1` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enfermeras`
--

LOCK TABLES `enfermeras` WRITE;
/*!40000 ALTER TABLE `enfermeras` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `enfermeras` VALUES
(1,'1234567890','Ana','González','Martínez','Pediatría','3001234567','ana.gonzalez@email.com',1,'2025-11-24 02:43:30'),
(2,'2345678901','Luis','Ramírez','Hernández','Emergencias','3002345678','luis.ramirez@email.com',2,'2025-11-24 02:43:30'),
(3,'3456789012','Marta','Fernández','Sánchez','UCI','3003456789','marta.fernandez@email.com',1,'2025-11-24 02:43:30'),
(4,'4567890123','Carlos','Pérez','Gómez','Geriatría','3004567890','carlos.perez@email.com',1,'2025-11-24 02:43:30'),
(5,'5678901234','Laura','Díaz','López','Cirugía','3005678901','laura.diaz@email.com',3,'2025-11-24 02:43:30');
/*!40000 ALTER TABLE `enfermeras` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `escalas_clinicas`
--

DROP TABLE IF EXISTS `escalas_clinicas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `escalas_clinicas` (
  `escala_id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `rango_min` decimal(5,2) NOT NULL,
  `rango_max` decimal(5,2) NOT NULL,
  `interpretacion` text DEFAULT NULL,
  `estado_id` int(11) NOT NULL,
  PRIMARY KEY (`escala_id`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `escalas_clinicas_ibfk_1` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `escalas_clinicas`
--

LOCK TABLES `escalas_clinicas` WRITE;
/*!40000 ALTER TABLE `escalas_clinicas` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `escalas_clinicas` VALUES
(1,'Escala de Dolor','Evalúa intensidad del dolor',0.00,10.00,'0: Sin dolor, 10: Dolor máximo',20),
(2,'Calidad de Vida','Evalúa calidad de vida general',0.00,100.00,'0: Muy pobre, 100: Excelente',20),
(3,'Ansiedad','Nivel de ansiedad',0.00,21.00,'0-7: Normal, 8-10: Leve, 11-14: Moderado, 15-21: Severo',20);
/*!40000 ALTER TABLE `escalas_clinicas` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `estados`
--

DROP TABLE IF EXISTS `estados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `estados` (
  `estado_id` int(11) NOT NULL AUTO_INCREMENT,
  `tipo_entidad` varchar(100) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `orden` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`estado_id`),
  UNIQUE KEY `unique_estado_entidad` (`tipo_entidad`,`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estados`
--

LOCK TABLES `estados` WRITE;
/*!40000 ALTER TABLE `estados` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `estados` VALUES
(1,'paciente','activo','Paciente activo en tratamiento',1,'2025-10-30 16:17:36'),
(2,'paciente','suspendido','Paciente suspendido temporalmente',2,'2025-10-30 16:17:36'),
(3,'paciente','inactivo','Paciente inactivo',3,'2025-10-30 16:17:36'),
(4,'profesional','activo','Profesional activo',1,'2025-10-30 16:17:36'),
(5,'profesional','inactivo','Profesional inactivo',2,'2025-10-30 16:17:36'),
(6,'sala','activa','Sala disponible',1,'2025-10-30 16:17:36'),
(7,'sala','inactiva','Sala no disponible',2,'2025-10-30 16:17:36'),
(8,'sala','mantenimiento','Sala en mantenimiento',3,'2025-10-30 16:17:36'),
(9,'plan','activo','Plan en ejecución',1,'2025-10-30 16:17:36'),
(10,'plan','completado','Plan finalizado exitosamente',2,'2025-10-30 16:17:36'),
(11,'plan','cancelado','Plan cancelado',3,'2025-10-30 16:17:36'),
(12,'objetivo','pendiente','Objetivo pendiente',1,'2025-10-30 16:17:36'),
(13,'objetivo','en_progreso','Objetivo en progreso',2,'2025-10-30 16:17:36'),
(14,'objetivo','cumplido','Objetivo cumplido',3,'2025-10-30 16:17:36'),
(15,'cita','programada','Cita programada',1,'2025-10-30 16:17:36'),
(16,'cita','confirmada','Cita confirmada',2,'2025-10-30 16:17:36'),
(17,'cita','completada','Cita completada',3,'2025-10-30 16:17:36'),
(18,'cita','cancelada','Cita cancelada',4,'2025-10-30 16:17:36'),
(19,'cita','no_show','Paciente no se presentó',5,'2025-10-30 16:17:36'),
(20,'escala','activa','Escala activa',1,'2025-10-30 16:17:36'),
(21,'escala','inactiva','Escala inactiva',2,'2025-10-30 16:17:36'),
(22,'motivo','activo','Motivo activo',1,'2025-10-30 16:17:36'),
(23,'motivo','inactivo','Motivo inactivo',2,'2025-10-30 16:17:36'),
(24,'politica','activa','Política activa',1,'2025-10-30 16:17:36'),
(25,'politica','inactiva','Política inactiva',2,'2025-10-30 16:17:36'),
(26,'usuario','activo','Usuario activo',1,'2025-10-30 16:17:36'),
(27,'usuario','inactivo','Usuario inactivo',2,'2025-10-30 16:17:36'),
(28,'usuario','bloqueado','Usuario bloqueado',3,'2025-10-30 16:17:36'),
(29,'rol','activo','Rol activo',1,'2025-10-30 16:17:36'),
(30,'rol','inactivo','Rol inactivo',2,'2025-10-30 16:17:36'),
(31,'orden','pendiente','Orden pendiente de ejecución',1,'2025-11-20 15:15:44'),
(32,'orden','en_progreso','Orden en progreso',2,'2025-11-20 15:15:44'),
(33,'orden','completada','Orden completada',3,'2025-11-20 15:15:44'),
(34,'orden','cancelada','Orden cancelada',4,'2025-11-20 15:15:44'),
(35,'enfermera','activa','Enfermera activa',1,'2025-11-20 15:18:45'),
(36,'enfermera','inactiva','Enfermera inactiva',2,'2025-11-20 15:18:45'),
(37,'habitacion','disponible','Habitación disponible',1,'2025-11-20 15:18:45'),
(38,'habitacion','ocupada','Habitación ocupada',2,'2025-11-20 15:18:45'),
(39,'habitacion','mantenimiento','Habitación en mantenimiento',3,'2025-11-20 15:18:45'),
(40,'cama','disponible','Cama disponible',1,'2025-11-20 15:18:45'),
(41,'cama','ocupada','Cama ocupada',2,'2025-11-20 15:18:45'),
(42,'cama','mantenimiento','Cama en mantenimiento',3,'2025-11-20 15:18:45'),
(43,'medicamento','activo','Medicamento activo',1,'2025-11-20 15:18:45'),
(44,'medicamento','inactivo','Medicamento inactivo',2,'2025-11-20 15:18:45'),
(45,'telefono','activo','Teléfono activo',1,'2025-11-20 15:18:45'),
(46,'telefono','inactivo','Teléfono inactivo',2,'2025-11-20 15:18:45'),
(47,'familiar','activo','Familiar activo',1,'2025-11-20 15:18:45'),
(48,'familiar','inactivo','Familiar inactivo',2,'2025-11-20 15:18:45'),
(49,'enfermedad','activa','Enfermedad activa',1,'2025-11-20 15:18:45'),
(50,'enfermedad','inactiva','Enfermedad inactiva',2,'2025-11-20 15:18:45'),
(51,'asignacion','activa','Asignación activa',1,'2025-11-20 15:18:45'),
(52,'asignacion','inactiva','Asignación inactiva',2,'2025-11-20 15:18:45'),
(53,'turno','programado','Turno programado',1,'2025-11-20 15:18:45'),
(54,'turno','en_curso','Turno en curso',2,'2025-11-20 15:18:45'),
(55,'turno','completado','Turno completado',3,'2025-11-20 15:18:45'),
(56,'turno','cancelado','Turno cancelado',4,'2025-11-20 15:18:45');
/*!40000 ALTER TABLE `estados` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `familiares_pacientes`
--

DROP TABLE IF EXISTS `familiares_pacientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `familiares_pacientes` (
  `familiar_id` int(11) NOT NULL AUTO_INCREMENT,
  `paciente_id` int(11) NOT NULL,
  `tipo_parentesco` enum('conyuge','hijo','padre','madre','hermano','otro') NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `segundo_apellido` varchar(100) DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `es_contacto_emergencia` tinyint(1) DEFAULT 0,
  `observaciones` text DEFAULT NULL,
  `estado_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`familiar_id`),
  KEY `paciente_id` (`paciente_id`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `familiares_pacientes_ibfk_1` FOREIGN KEY (`paciente_id`) REFERENCES `pacientes` (`paciente_id`),
  CONSTRAINT `familiares_pacientes_ibfk_2` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `familiares_pacientes`
--

LOCK TABLES `familiares_pacientes` WRITE;
/*!40000 ALTER TABLE `familiares_pacientes` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `familiares_pacientes` VALUES
(1,2,'padre','Aspernatur quas ea b','Voluptatem Tenetur ','Quis occaecat non pr','1985-10-08','+1 (169) 747-7126','mihuw@mailinator.com',1,'Voluptatem Ullamco ',47,'2025-11-24 02:26:55'),
(2,1,'madre','Error quae minus mod','Accusamus iure offic','Sunt blanditiis est','1996-11-21','+1 (842) 972-4518','jecosafi@mailinator.com',0,'Tenetur incidunt qu',47,'2025-11-24 03:09:52');
/*!40000 ALTER TABLE `familiares_pacientes` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `habitaciones`
--

DROP TABLE IF EXISTS `habitaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `habitaciones` (
  `habitacion_id` int(11) NOT NULL AUTO_INCREMENT,
  `numero_habitacion` varchar(10) NOT NULL,
  `tipo_habitacion` enum('individual','compartida','UCI','aislamiento') NOT NULL,
  `capacidad` int(11) DEFAULT 1,
  `descripcion` text DEFAULT NULL,
  `estado_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`habitacion_id`),
  UNIQUE KEY `numero_habitacion` (`numero_habitacion`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `habitaciones_ibfk_1` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `habitaciones`
--

LOCK TABLES `habitaciones` WRITE;
/*!40000 ALTER TABLE `habitaciones` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `habitaciones` VALUES
(1,'101','individual',1,'Habitación individual con cama y baño privado',1,'2025-11-24 02:42:01'),
(2,'102','compartida',2,'Habitación compartida para dos personas',2,'2025-11-24 02:42:01'),
(3,'103','UCI',1,'Habitación de cuidados intensivos con monitoreo continuo',3,'2025-11-24 02:42:01'),
(4,'104','aislamiento',1,'Habitación de aislamiento para pacientes con enfermedades contagiosas',4,'2025-11-24 02:42:01'),
(5,'105','individual',1,'Habitación para pacientes con necesidades especiales',2,'2025-11-24 02:42:01');
/*!40000 ALTER TABLE `habitaciones` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `logs_noshow_auto`
--

DROP TABLE IF EXISTS `logs_noshow_auto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `logs_noshow_auto` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `cita_id` int(11) DEFAULT NULL,
  `paciente_id` int(11) DEFAULT NULL,
  `fecha_cita` datetime DEFAULT NULL,
  `fecha_marcado` timestamp NOT NULL DEFAULT current_timestamp(),
  `minutos_retraso` int(11) DEFAULT NULL,
  PRIMARY KEY (`log_id`),
  KEY `cita_id` (`cita_id`),
  KEY `paciente_id` (`paciente_id`),
  CONSTRAINT `logs_noshow_auto_ibfk_1` FOREIGN KEY (`cita_id`) REFERENCES `citas` (`cita_id`),
  CONSTRAINT `logs_noshow_auto_ibfk_2` FOREIGN KEY (`paciente_id`) REFERENCES `pacientes` (`paciente_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logs_noshow_auto`
--

LOCK TABLES `logs_noshow_auto` WRITE;
/*!40000 ALTER TABLE `logs_noshow_auto` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `logs_noshow_auto` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `medicamentos`
--

DROP TABLE IF EXISTS `medicamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `medicamentos` (
  `medicamento_id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_comercial` varchar(255) NOT NULL,
  `nombre_generico` varchar(255) NOT NULL,
  `presentacion` varchar(100) NOT NULL,
  `concentracion` varchar(100) DEFAULT NULL,
  `via_administracion` enum('oral','intravenosa','intramuscular','subcutanea','topica','otra') NOT NULL,
  `estado_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`medicamento_id`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `medicamentos_ibfk_1` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medicamentos`
--

LOCK TABLES `medicamentos` WRITE;
/*!40000 ALTER TABLE `medicamentos` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `medicamentos` VALUES
(1,'Tempra','Paracetamol','Tabletas','500 mg','oral',1,'2025-11-24 02:57:00'),
(2,'Ibuprofeno MK','Ibuprofeno','Tabletas','400 mg','oral',1,'2025-11-24 02:57:00'),
(3,'Amoxican','Amoxicilina','Cápsulas','500 mg','oral',1,'2025-11-24 02:57:00'),
(4,'Ketorolac','Ketorolaco','Solución inyectable','30 mg/1 ml','intramuscular',1,'2025-11-24 02:57:00'),
(5,'Omeprazol','Omeprazol','Viales','40 mg','intravenosa',1,'2025-11-24 02:57:00'),
(6,'Insulina NPH','Insulina','Frasco ámpula','100 UI/ml','subcutanea',1,'2025-11-24 02:57:00'),
(7,'Clotrimazol','Clotrimazol','Crema','1%','topica',1,'2025-11-24 02:57:00'),
(8,'Metoclopramida','Metoclopramida','Solución inyectable','10 mg/2 ml','intravenosa',1,'2025-11-24 02:57:00'),
(9,'Suero Fisiológico','Cloruro de Sodio 0.9%','Bolsa 500 ml','0.9%','intravenosa',1,'2025-11-24 02:57:00'),
(10,'Diclofenaco','Diclofenaco sódico','Solución inyectable','75 mg/3 ml','intramuscular',1,'2025-11-24 02:57:00'),
(11,'Lidocaína','Lidocaína','Gel','2%','topica',1,'2025-11-24 02:57:00'),
(12,'Salbutamol','Salbutamol','Inhalador','100 mcg','otra',1,'2025-11-24 02:57:00'),
(13,'Acetaminofén Jarabe','Paracetamol','Jarabe 120 ml','120 mg/5 ml','oral',1,'2025-11-24 02:57:00'),
(14,'Dexametasona','Dexametasona','Solución inyectable','8 mg/2 ml','intravenosa',1,'2025-11-24 02:57:00'),
(15,'Enoxaparina','Enoxaparina','Jeringa prellenada','40 mg','subcutanea',1,'2025-11-24 02:57:00');
/*!40000 ALTER TABLE `medicamentos` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `motivos_cancelacion`
--

DROP TABLE IF EXISTS `motivos_cancelacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `motivos_cancelacion` (
  `motivo_id` int(11) NOT NULL AUTO_INCREMENT,
  `tipo` enum('cancelacion','reagendo') NOT NULL,
  `descripcion` varchar(200) NOT NULL,
  `cuenta_como_noshow` tinyint(1) DEFAULT 0,
  `estado_id` int(11) NOT NULL,
  PRIMARY KEY (`motivo_id`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `motivos_cancelacion_ibfk_1` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `motivos_cancelacion`
--

LOCK TABLES `motivos_cancelacion` WRITE;
/*!40000 ALTER TABLE `motivos_cancelacion` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `motivos_cancelacion` VALUES
(1,'cancelacion','Enfermedad del paciente',0,22),
(2,'cancelacion','Emergencia familiar',0,22),
(3,'cancelacion','Problemas de transporte',1,22),
(4,'cancelacion','Olvido',1,22),
(5,'reagendo','Cambio de horario solicitado por paciente',0,22),
(6,'reagendo','Reagendación por disponibilidad del profesional',0,22);
/*!40000 ALTER TABLE `motivos_cancelacion` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Temporary table structure for view `noShowPorProfesionalMes`
--

DROP TABLE IF EXISTS `noShowPorProfesionalMes`;
/*!50001 DROP VIEW IF EXISTS `noShowPorProfesionalMes`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `noShowPorProfesionalMes` AS SELECT
 1 AS `profesional_id`,
  1 AS `profesional_nombre`,
  1 AS `año`,
  1 AS `mes`,
  1 AS `total_citas`,
  1 AS `no_shows`,
  1 AS `porcentaje_no_show` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `objetivos_plan`
--

DROP TABLE IF EXISTS `objetivos_plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `objetivos_plan` (
  `objetivo_id` int(11) NOT NULL AUTO_INCREMENT,
  `plan_id` int(11) NOT NULL,
  `descripcion` text NOT NULL,
  `escala_id` int(11) DEFAULT NULL,
  `meta_puntaje` decimal(5,2) DEFAULT NULL,
  `peso` decimal(3,2) DEFAULT 1.00,
  `estado_id` int(11) NOT NULL,
  `fecha_cumplimiento` date DEFAULT NULL,
  PRIMARY KEY (`objetivo_id`),
  KEY `plan_id` (`plan_id`),
  KEY `escala_id` (`escala_id`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `objetivos_plan_ibfk_1` FOREIGN KEY (`plan_id`) REFERENCES `planes_terapeuticos` (`plan_id`),
  CONSTRAINT `objetivos_plan_ibfk_2` FOREIGN KEY (`escala_id`) REFERENCES `escalas_clinicas` (`escala_id`),
  CONSTRAINT `objetivos_plan_ibfk_3` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `objetivos_plan`
--

LOCK TABLES `objetivos_plan` WRITE;
/*!40000 ALTER TABLE `objetivos_plan` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `objetivos_plan` VALUES
(1,1,'Quitar el dolor',NULL,NULL,1.00,12,NULL),
(2,2,'Bajar de peso',NULL,NULL,1.00,12,NULL),
(3,2,'Quitar el dolor',NULL,NULL,1.00,12,NULL);
/*!40000 ALTER TABLE `objetivos_plan` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `ordenes_medicas`
--

DROP TABLE IF EXISTS `ordenes_medicas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ordenes_medicas` (
  `orden_id` int(11) NOT NULL AUTO_INCREMENT,
  `paciente_id` int(11) NOT NULL,
  `profesional_id` int(11) NOT NULL,
  `tipo_orden` enum('medicamento','procedimiento','examen','terapia') NOT NULL,
  `descripcion` text NOT NULL,
  `medicamento_id` int(11) DEFAULT NULL,
  `dosis` varchar(100) DEFAULT NULL,
  `frecuencia` varchar(100) DEFAULT NULL,
  `duracion` varchar(100) DEFAULT NULL,
  `fecha_orden` datetime NOT NULL DEFAULT current_timestamp(),
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date DEFAULT NULL,
  `estado_id` int(11) NOT NULL,
  `observaciones` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`orden_id`),
  KEY `paciente_id` (`paciente_id`),
  KEY `profesional_id` (`profesional_id`),
  KEY `medicamento_id` (`medicamento_id`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `ordenes_medicas_ibfk_1` FOREIGN KEY (`paciente_id`) REFERENCES `pacientes` (`paciente_id`),
  CONSTRAINT `ordenes_medicas_ibfk_2` FOREIGN KEY (`profesional_id`) REFERENCES `profesionales` (`profesional_id`),
  CONSTRAINT `ordenes_medicas_ibfk_3` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ordenes_medicas`
--

LOCK TABLES `ordenes_medicas` WRITE;
/*!40000 ALTER TABLE `ordenes_medicas` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `ordenes_medicas` VALUES
(1,2,2,'medicamento','Incididunt nulla pra',NULL,NULL,NULL,NULL,'2025-11-24 02:27:10','2015-09-08','2002-01-13',31,'Tempore repudiandae','2025-11-24 02:27:10'),
(2,2,1,'terapia','Se realizara terapia fisiologica',NULL,NULL,NULL,NULL,'2025-11-24 03:36:06','2026-02-02',NULL,31,'Mucho moco','2025-11-24 03:36:06');
/*!40000 ALTER TABLE `ordenes_medicas` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `pacientes`
--

DROP TABLE IF EXISTS `pacientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pacientes` (
  `paciente_id` int(11) NOT NULL AUTO_INCREMENT,
  `identificacion` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `segundo_apellido` varchar(100) DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `direccion` text DEFAULT NULL,
  `fecha_alta` date NOT NULL,
  `estado_id` int(11) NOT NULL,
  `suspension_hasta` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `tipo_direccion` enum('casa','trabajo','otro') DEFAULT 'casa',
  `direccion_calle` varchar(255) DEFAULT NULL,
  `direccion_numero` varchar(20) DEFAULT NULL,
  `direccion_piso` varchar(10) DEFAULT NULL,
  `direccion_depto` varchar(10) DEFAULT NULL,
  `direccion_ciudad` varchar(100) DEFAULT NULL,
  `direccion_provincia` varchar(100) DEFAULT NULL,
  `direccion_codigo_postal` varchar(20) DEFAULT NULL,
  `direccion_pais` varchar(50) DEFAULT 'Argentina',
  PRIMARY KEY (`paciente_id`),
  UNIQUE KEY `identificacion` (`identificacion`),
  KEY `idx_pacientes_identificacion` (`identificacion`),
  KEY `idx_pacientes_estado` (`estado_id`),
  KEY `idx_pacientes_nombre_apellido` (`nombre`,`apellido`),
  CONSTRAINT `pacientes_ibfk_1` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pacientes`
--

LOCK TABLES `pacientes` WRITE;
/*!40000 ALTER TABLE `pacientes` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `pacientes` VALUES
(1,'1066866495','ALFREDO JOSÉ','PEREZ MEZA',NULL,'2004-12-28','3103690094','alfredojoseperezmeza124@gmail.com','Cr19 22a-35\r\nEl cesar','2025-10-30',1,NULL,'2025-10-30 22:12:39','2025-10-30 23:34:37','casa',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Argentina'),
(2,'1066872259','LUIS JOSE','PEREZ MEZA',NULL,'2007-07-27','3042342311','luisjoseperezmeza123@gmail.com','Cr19 22a-35\r\nEl cesar','2025-10-31',1,NULL,'2025-10-31 01:00:32','2025-10-31 19:42:06','casa',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Argentina'),
(3,'1098382911','JUAN CARLOS','MENDOZA',NULL,'2002-02-22','8119899478','carlos@gmail.com','Cr19 22a-35\r\nEl cesar','2025-10-31',1,NULL,'2025-10-31 15:49:34','2025-10-31 15:49:34','casa',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Argentina'),
(10,'Eos duis placeat sa','TEST1','APELLIDO1',NULL,'1995-02-20','+1 (829) 285-9592','ruluv@mailinator.com','Dolore ad quis repel','2025-11-24',1,NULL,'2025-11-24 17:40:20','2025-11-24 17:40:20','casa',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Argentina');
/*!40000 ALTER TABLE `pacientes` ENABLE KEYS */;
UNLOCK TABLES;
commit;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`paliativos_user`@`localhost`*/ /*!50003 TRIGGER normalizaNombrePaciente_BEFORE_INSERT
BEFORE INSERT ON pacientes
FOR EACH ROW
BEGIN
    SET NEW.nombre = UPPER(TRIM(NEW.nombre));
    SET NEW.apellido = UPPER(TRIM(NEW.apellido));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary table structure for view `pacientesActivos`
--

DROP TABLE IF EXISTS `pacientesActivos`;
/*!50001 DROP VIEW IF EXISTS `pacientesActivos`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `pacientesActivos` AS SELECT
 1 AS `paciente_id`,
  1 AS `identificacion`,
  1 AS `nombre_completo`,
  1 AS `telefono`,
  1 AS `email`,
  1 AS `fecha_alta`,
  1 AS `planes_activos` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `planes_terapeuticos`
--

DROP TABLE IF EXISTS `planes_terapeuticos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `planes_terapeuticos` (
  `plan_id` int(11) NOT NULL AUTO_INCREMENT,
  `paciente_id` int(11) NOT NULL,
  `diagnostico_principal` text DEFAULT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin_estimada` date DEFAULT NULL,
  `estado_id` int(11) NOT NULL,
  `fecha_cierre` date DEFAULT NULL,
  `motivo_cierre` varchar(200) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`plan_id`),
  KEY `idx_planes_paciente` (`paciente_id`),
  KEY `idx_planes_estado` (`estado_id`),
  CONSTRAINT `planes_terapeuticos_ibfk_1` FOREIGN KEY (`paciente_id`) REFERENCES `pacientes` (`paciente_id`),
  CONSTRAINT `planes_terapeuticos_ibfk_2` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `planes_terapeuticos`
--

LOCK TABLES `planes_terapeuticos` WRITE;
/*!40000 ALTER TABLE `planes_terapeuticos` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `planes_terapeuticos` VALUES
(1,1,'Dolor de estomago','2025-10-30','2025-12-30',9,NULL,NULL,'2025-10-30 22:14:02'),
(2,1,'Dolor de estomago','2025-10-30','2025-12-30',9,NULL,NULL,'2025-10-30 23:07:44');
/*!40000 ALTER TABLE `planes_terapeuticos` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `politicas_noshow`
--

DROP TABLE IF EXISTS `politicas_noshow`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `politicas_noshow` (
  `politica_id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `max_reagendos_mes` int(11) DEFAULT 3,
  `tiempo_minimo_cancelacion_min` int(11) DEFAULT 120,
  `gracia_noshow_min` int(11) DEFAULT 15,
  `umbral_suspension` int(11) DEFAULT 3,
  `periodo_consideracion_dias` int(11) DEFAULT 30,
  `estado_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`politica_id`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `politicas_noshow_ibfk_1` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `politicas_noshow`
--

LOCK TABLES `politicas_noshow` WRITE;
/*!40000 ALTER TABLE `politicas_noshow` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `politicas_noshow` VALUES
(1,'Política Estándar','Política general de no-show y reagendos',3,120,15,3,30,24,'2025-10-30 16:17:36');
/*!40000 ALTER TABLE `politicas_noshow` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `profesionales`
--

DROP TABLE IF EXISTS `profesionales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `profesionales` (
  `profesional_id` int(11) NOT NULL AUTO_INCREMENT,
  `identificacion` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `segundo_apellido` varchar(100) DEFAULT NULL,
  `especialidad` varchar(100) NOT NULL,
  `horario_inicio` time NOT NULL,
  `horario_fin` time NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `estado_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`profesional_id`),
  UNIQUE KEY `identificacion` (`identificacion`),
  KEY `idx_profesionales_identificacion` (`identificacion`),
  KEY `idx_profesionales_estado` (`estado_id`),
  KEY `idx_profesionales_especialidad` (`especialidad`),
  CONSTRAINT `profesionales_ibfk_1` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profesionales`
--

LOCK TABLES `profesionales` WRITE;
/*!40000 ALTER TABLE `profesionales` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `profesionales` VALUES
(1,'MED123','Ana','García',NULL,'Oncología','08:00:00','16:00:00','555-0101','ana.garcia@clinica.com',4,'2025-10-30 16:17:36'),
(2,'MED124','Carlos','López',NULL,'Psicología','09:00:00','17:00:00','555-0102','carlos.lopez@clinica.com',4,'2025-10-30 16:17:36'),
(3,'MED125','María','Rodríguez',NULL,'Fisioterapia','10:00:00','18:00:00','555-0103','maria.rodriguez@clinica.com',5,'2025-10-30 16:17:36'),
(4,'1231231','pepito','Perez',NULL,'Psicología','11:16:00','23:16:00','2342423424','doctor@paliativos.com',5,'2025-11-24 05:16:25');
/*!40000 ALTER TABLE `profesionales` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Temporary table structure for view `progresoPorPlan`
--

DROP TABLE IF EXISTS `progresoPorPlan`;
/*!50001 DROP VIEW IF EXISTS `progresoPorPlan`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `progresoPorPlan` AS SELECT
 1 AS `plan_id`,
  1 AS `paciente`,
  1 AS `fecha_inicio`,
  1 AS `fecha_fin_estimada`,
  1 AS `total_objetivos`,
  1 AS `objetivos_cumplidos`,
  1 AS `porcentaje_completado`,
  1 AS `estado` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `puntajes_sesion`
--

DROP TABLE IF EXISTS `puntajes_sesion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `puntajes_sesion` (
  `puntaje_id` int(11) NOT NULL AUTO_INCREMENT,
  `sesion_id` int(11) NOT NULL,
  `escala_id` int(11) NOT NULL,
  `puntaje` decimal(5,2) NOT NULL,
  `observaciones` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`puntaje_id`),
  UNIQUE KEY `unique_sesion_escala` (`sesion_id`,`escala_id`),
  KEY `escala_id` (`escala_id`),
  CONSTRAINT `puntajes_sesion_ibfk_1` FOREIGN KEY (`sesion_id`) REFERENCES `sesiones` (`sesion_id`),
  CONSTRAINT `puntajes_sesion_ibfk_2` FOREIGN KEY (`escala_id`) REFERENCES `escalas_clinicas` (`escala_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `puntajes_sesion`
--

LOCK TABLES `puntajes_sesion` WRITE;
/*!40000 ALTER TABLE `puntajes_sesion` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `puntajes_sesion` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `rol_id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `permisos` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`permisos`)),
  `estado_id` int(11) NOT NULL,
  PRIMARY KEY (`rol_id`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `roles_ibfk_1` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `roles` VALUES
(1,'admin','Administrador del sistema','{\"all\": true}',29),
(2,'profesional','Profesional de salud','{\"read_patients\": true, \"manage_sessions\": true, \"view_reports\": true}',29),
(3,'recepcion','Personal de recepción','{\"manage_patients\": true, \"manage_appointments\": true}',29),
(4,'auditor','Auditor','{\"view_reports\": true}',29),
(5,'paciente','Paciente','{\"view_own_data\": true}',29);
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `salas`
--

DROP TABLE IF EXISTS `salas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `salas` (
  `sala_id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `capacidad` int(11) DEFAULT 1,
  `estado_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`sala_id`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `salas_ibfk_1` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salas`
--

LOCK TABLES `salas` WRITE;
/*!40000 ALTER TABLE `salas` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `salas` VALUES
(1,'Sala 1','Sala de terapia individual',1,6,'2025-10-30 16:17:36'),
(2,'Sala 2','Sala de terapia grupal',2,6,'2025-10-30 16:17:36'),
(3,'Sala 3','Sala de relajación',4,6,'2025-10-30 16:17:36'),
(4,'Sala 4','Sala de ultima tecnologia',3,6,'2025-11-24 05:13:11');
/*!40000 ALTER TABLE `salas` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `sesion_escalas`
--

DROP TABLE IF EXISTS `sesion_escalas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sesion_escalas` (
  `sesion_escala_id` int(11) NOT NULL AUTO_INCREMENT,
  `sesion_id` int(11) NOT NULL,
  `escala_id` int(11) NOT NULL,
  `puntaje` decimal(5,2) NOT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`sesion_escala_id`),
  KEY `sesion_id` (`sesion_id`),
  KEY `escala_id` (`escala_id`),
  CONSTRAINT `sesion_escalas_ibfk_1` FOREIGN KEY (`sesion_id`) REFERENCES `sesiones` (`sesion_id`),
  CONSTRAINT `sesion_escalas_ibfk_2` FOREIGN KEY (`escala_id`) REFERENCES `escalas_clinicas` (`escala_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sesion_escalas`
--

LOCK TABLES `sesion_escalas` WRITE;
/*!40000 ALTER TABLE `sesion_escalas` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `sesion_escalas` VALUES
(1,17,1,1.00,'2025-10-31 01:22:15'),
(2,18,2,10.00,'2025-11-06 14:32:42');
/*!40000 ALTER TABLE `sesion_escalas` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `sesiones`
--

DROP TABLE IF EXISTS `sesiones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sesiones` (
  `sesion_id` int(11) NOT NULL AUTO_INCREMENT,
  `cita_id` int(11) NOT NULL,
  `notas` text DEFAULT NULL,
  `tecnica_utilizada` varchar(200) DEFAULT NULL,
  `duracion_real_min` int(11) DEFAULT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `editable_hasta` datetime DEFAULT NULL,
  `facturada` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`sesion_id`),
  UNIQUE KEY `cita_id` (`cita_id`),
  KEY `idx_sesiones_cita` (`cita_id`),
  KEY `idx_sesiones_fecha_registro` (`fecha_registro`),
  CONSTRAINT `sesiones_ibfk_1` FOREIGN KEY (`cita_id`) REFERENCES `citas` (`cita_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sesiones`
--

LOCK TABLES `sesiones` WRITE;
/*!40000 ALTER TABLE `sesiones` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `sesiones` VALUES
(13,2,'awdawdawd','',60,'2025-10-30 23:06:40',NULL,0),
(14,3,'Se hizo movilidad del tren superior e inferior','Terapia fisiologica',30,'2025-10-31 00:20:55',NULL,0),
(17,4,'NOSE','Terapia fisiologica',30,'2025-10-31 01:22:15',NULL,0),
(18,5,'','Masajes fisicos',70,'2025-11-06 14:32:42',NULL,0);
/*!40000 ALTER TABLE `sesiones` ENABLE KEYS */;
UNLOCK TABLES;
commit;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`paliativos_user`@`localhost`*/ /*!50003 TRIGGER sesionBloqueoEdicion_BEFORE_UPDATE
BEFORE UPDATE ON sesiones
FOR EACH ROW
BEGIN
    DECLARE v_rol_especial INT DEFAULT 0;
    
    
    IF NEW.editable_hasta < NOW() THEN
        
        
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La sesión no puede ser editada después del tiempo permitido';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `telefonos_pacientes`
--

DROP TABLE IF EXISTS `telefonos_pacientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `telefonos_pacientes` (
  `telefono_id` int(11) NOT NULL AUTO_INCREMENT,
  `paciente_id` int(11) NOT NULL,
  `tipo_telefono` enum('celular','casa','trabajo','emergencia') NOT NULL,
  `numero` varchar(20) NOT NULL,
  `es_principal` tinyint(1) DEFAULT 0,
  `estado_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`telefono_id`),
  KEY `paciente_id` (`paciente_id`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `telefonos_pacientes_ibfk_1` FOREIGN KEY (`paciente_id`) REFERENCES `pacientes` (`paciente_id`),
  CONSTRAINT `telefonos_pacientes_ibfk_2` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `telefonos_pacientes`
--

LOCK TABLES `telefonos_pacientes` WRITE;
/*!40000 ALTER TABLE `telefonos_pacientes` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `telefonos_pacientes` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `telefonos_profesionales`
--

DROP TABLE IF EXISTS `telefonos_profesionales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `telefonos_profesionales` (
  `telefono_id` int(11) NOT NULL AUTO_INCREMENT,
  `profesional_id` int(11) NOT NULL,
  `tipo_telefono` enum('celular','casa','trabajo','consultorio') NOT NULL,
  `numero` varchar(20) NOT NULL,
  `es_principal` tinyint(1) DEFAULT 0,
  `estado_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`telefono_id`),
  KEY `profesional_id` (`profesional_id`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `telefonos_profesionales_ibfk_1` FOREIGN KEY (`profesional_id`) REFERENCES `profesionales` (`profesional_id`),
  CONSTRAINT `telefonos_profesionales_ibfk_2` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `telefonos_profesionales`
--

LOCK TABLES `telefonos_profesionales` WRITE;
/*!40000 ALTER TABLE `telefonos_profesionales` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `telefonos_profesionales` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `turnos_enfermeras`
--

DROP TABLE IF EXISTS `turnos_enfermeras`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `turnos_enfermeras` (
  `turno_id` int(11) NOT NULL AUTO_INCREMENT,
  `enfermera_id` int(11) NOT NULL,
  `fecha_turno` date NOT NULL,
  `hora_inicio` time NOT NULL,
  `hora_fin` time NOT NULL,
  `tipo_turno` enum('mañana','tarde','noche','completo') NOT NULL,
  `zona_asignada` varchar(100) DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `estado_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`turno_id`),
  KEY `enfermera_id` (`enfermera_id`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `turnos_enfermeras_ibfk_1` FOREIGN KEY (`enfermera_id`) REFERENCES `enfermeras` (`enfermera_id`),
  CONSTRAINT `turnos_enfermeras_ibfk_2` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `turnos_enfermeras`
--

LOCK TABLES `turnos_enfermeras` WRITE;
/*!40000 ALTER TABLE `turnos_enfermeras` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `turnos_enfermeras` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `usuario_roles`
--

DROP TABLE IF EXISTS `usuario_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario_roles` (
  `usuario_id` int(11) NOT NULL,
  `rol_id` int(11) NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`usuario_id`,`rol_id`),
  KEY `rol_id` (`rol_id`),
  CONSTRAINT `usuario_roles_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`usuario_id`),
  CONSTRAINT `usuario_roles_ibfk_2` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`rol_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario_roles`
--

LOCK TABLES `usuario_roles` WRITE;
/*!40000 ALTER TABLE `usuario_roles` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `usuario_roles` VALUES
(1,1,'2025-10-30 16:17:36'),
(2,2,'2025-10-31 01:40:43'),
(3,5,'2025-10-31 01:42:42'),
(9,5,'2025-11-24 17:40:20');
/*!40000 ALTER TABLE `usuario_roles` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `usuario_id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `passhash` varchar(255) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `persona_id` int(11) DEFAULT NULL,
  `tipo_persona` enum('paciente','profesional','admin','recepcion','auditor') DEFAULT NULL,
  `estado_id` int(11) NOT NULL,
  `ultimo_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`usuario_id`),
  UNIQUE KEY `username` (`username`),
  KEY `estado_id` (`estado_id`),
  CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`estado_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `usuarios` VALUES
(1,'admin','$2a$10$K29MC4VLANEiqGOK8Aw9V.JUgyS.cFhoFz.oO2Irn7yo7xGLGiIS.','admin@clinica.com',NULL,'admin',26,'2025-11-24 17:33:37','2025-10-30 16:17:36'),
(2,'Juan','$2a$10$K29MC4VLANEiqGOK8Aw9V.JUgyS.cFhoFz.oO2Irn7yo7xGLGiIS.','profesional@clinica.com',NULL,'profesional',26,'2025-11-24 06:08:27','2025-10-31 01:39:28'),
(3,'Alfredo','$2a$10$K29MC4VLANEiqGOK8Aw9V.JUgyS.cFhoFz.oO2Irn7yo7xGLGiIS.','alfredo@clinica.com',NULL,'paciente',26,'2025-11-24 06:22:52','2025-10-31 01:42:35'),
(9,'tapellido1','$2a$10$K29MC4VLANEiqGOK8Aw9V.JUgyS.cFhoFz.oO2Irn7yo7xGLGiIS.','ruluv@mailinator.com',10,'paciente',26,'2025-11-24 17:56:09','2025-11-24 17:40:20');/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping events for database 'clinica_paliativos'
--

--
-- Dumping routines for database 'clinica_paliativos'
--
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `actualizarProfesional` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `actualizarProfesional`(
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
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    IF NOT EXISTS (SELECT 1 FROM profesionales WHERE profesional_id = p_profesional_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El profesional no existe';
    END IF;
    
    
    IF EXISTS (SELECT 1 FROM profesionales WHERE identificacion = p_identificacion AND profesional_id != p_profesional_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe otro profesional con esta identificación';
    END IF;
    
    
    UPDATE profesionales 
    SET identificacion = p_identificacion,
        nombre = p_nombre,
        apellido = p_apellido,
        especialidad = p_especialidad,
        horario_inicio = p_horario_inicio,
        horario_fin = p_horario_fin,
        telefono = p_telefono,
        email = p_email,
        estado_id = p_estado_id
    WHERE profesional_id = p_profesional_id;
    
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `actualizarSala` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `actualizarSala`(
    IN p_sala_id INT,
    IN p_nombre VARCHAR(50),
    IN p_descripcion TEXT,
    IN p_capacidad INT,
    IN p_estado_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    IF NOT EXISTS (SELECT 1 FROM salas WHERE sala_id = p_sala_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La sala no existe';
    END IF;
    
    
    IF EXISTS (SELECT 1 FROM salas WHERE nombre = p_nombre AND sala_id != p_sala_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe otra sala con este nombre';
    END IF;
    
    
    UPDATE salas 
    SET nombre = p_nombre,
        descripcion = p_descripcion,
        capacidad = p_capacidad,
        estado_id = p_estado_id
    WHERE sala_id = p_sala_id;
    
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `actualizar_ultimo_login` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `actualizar_ultimo_login`(IN p_usuario_id INT)
BEGIN
    UPDATE usuarios SET ultimo_login = NOW() WHERE usuario_id = p_usuario_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `alertasSuspension` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `alertasSuspension`(
    IN p_umbral INT
)
BEGIN
    DECLARE v_paciente_id INT;
    DECLARE v_nombre VARCHAR(201);
    DECLARE v_no_shows INT;
    DECLARE done INT DEFAULT FALSE;
    
    DECLARE cur_pacientes CURSOR FOR
    SELECT 
        p.paciente_id,
        CONCAT(p.nombre, ' ', p.apellido) as nombre,
        COUNT(*) as no_shows
    FROM pacientes p
    JOIN citas c ON p.paciente_id = c.paciente_id
    WHERE c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show')
    AND c.fecha_inicio >= DATE_SUB(NOW(), INTERVAL 30 DAY)
    GROUP BY p.paciente_id
    HAVING COUNT(*) >= p_umbral;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    CREATE TEMPORARY TABLE tmpTopAlertas (
        paciente_id INT,
        paciente_nombre VARCHAR(201),
        no_shows INT,
        accion VARCHAR(50)
    );
    
    OPEN cur_pacientes;
    
    read_loop: LOOP
        FETCH cur_pacientes INTO v_paciente_id, v_nombre, v_no_shows;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        INSERT INTO tmpTopAlertas (paciente_id, paciente_nombre, no_shows, accion)
        VALUES (v_paciente_id, v_nombre, v_no_shows, 'SUSPENDER');
        
        
        
        
    END LOOP;
    
    CLOSE cur_pacientes;
    
    SELECT * FROM tmpTopAlertas ORDER BY no_shows DESC;
    
    DROP TEMPORARY TABLE tmpTopAlertas;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `asignacionCamaCrear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `asignacionCamaCrear`(
    IN p_paciente_id INT,
    IN p_cama_id INT,
    IN p_fecha_ingreso DATETIME,
    IN p_motivo_ingreso TEXT,
    IN p_usuario_id INT
)
BEGIN
    DECLARE v_estado_ocupada INT;
    DECLARE v_estado_asignacion_activa INT;
    
    
    IF EXISTS (
        SELECT 1 FROM asignaciones_cama 
        WHERE cama_id = p_cama_id 
        AND fecha_egreso IS NULL
        AND estado_id IN (SELECT estado_id FROM estados WHERE nombre IN ('activa', 'ocupada'))
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La cama ya está ocupada';
    END IF;
    
    
    SELECT estado_id INTO v_estado_ocupada 
    FROM estados 
    WHERE nombre = 'ocupada' AND tipo_entidad = 'cama'
    LIMIT 1;
    
    SELECT estado_id INTO v_estado_asignacion_activa 
    FROM estados 
    WHERE nombre = 'activa' AND tipo_entidad = 'asignacion'
    LIMIT 1;
    
    
    IF v_estado_ocupada IS NULL THEN
        SELECT estado_id INTO v_estado_ocupada 
        FROM estados 
        WHERE nombre = 'ocupada' 
        LIMIT 1;
    END IF;
    
    IF v_estado_asignacion_activa IS NULL THEN
        SELECT estado_id INTO v_estado_asignacion_activa 
        FROM estados 
        WHERE nombre = 'activa' 
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
    
    
    UPDATE camas 
    SET estado_id = v_estado_ocupada 
    WHERE cama_id = p_cama_id;
    
    SELECT LAST_INSERT_ID() as asignacion_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `asignacionCamaEgreso` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `asignacionCamaEgreso`(
    IN p_asignacion_id INT,
    IN p_fecha_egreso DATETIME,
    IN p_motivo_egreso TEXT,
    IN p_usuario_id INT
)
BEGIN
    DECLARE v_cama_id INT;
    DECLARE v_estado_disponible INT;
    DECLARE v_estado_asignacion_inactiva INT;
    
    
    SELECT cama_id INTO v_cama_id 
    FROM asignaciones_cama 
    WHERE asignacion_id = p_asignacion_id;
    
    
    SELECT estado_id INTO v_estado_disponible 
    FROM estados 
    WHERE nombre = 'disponible' AND tipo_entidad = 'cama'
    LIMIT 1;
    
    SELECT estado_id INTO v_estado_asignacion_inactiva 
    FROM estados 
    WHERE nombre = 'inactiva' AND tipo_entidad = 'asignacion'
    LIMIT 1;
    
    
    IF v_estado_disponible IS NULL THEN
        SELECT estado_id INTO v_estado_disponible 
        FROM estados 
        WHERE nombre = 'disponible' 
        LIMIT 1;
    END IF;
    
    IF v_estado_asignacion_inactiva IS NULL THEN
        SELECT estado_id INTO v_estado_asignacion_inactiva 
        FROM estados 
        WHERE nombre = 'inactiva' 
        LIMIT 1;
    END IF;
    
    
    UPDATE asignaciones_cama
    SET 
        fecha_egreso = p_fecha_egreso,
        motivo_egreso = p_motivo_egreso,
        estado_id = v_estado_asignacion_inactiva
    WHERE asignacion_id = p_asignacion_id;
    
    
    UPDATE camas 
    SET estado_id = v_estado_disponible 
    WHERE cama_id = v_cama_id;
    
    SELECT ROW_COUNT() as affected_rows;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `asignacionPersonalCrear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `asignacionPersonalCrear`(
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
BEGIN
    DECLARE v_estado_activa INT;
    
    
    IF p_enfermera_id IS NULL AND p_profesional_id IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Debe asignar al menos una enfermera o un profesional';
    END IF;
    
    
    SELECT estado_id INTO v_estado_activa 
    FROM estados 
    WHERE nombre = 'activa' AND tipo_entidad = 'asignacion'
    LIMIT 1;
    
    IF v_estado_activa IS NULL THEN
        SELECT estado_id INTO v_estado_activa 
        FROM estados 
        WHERE nombre = 'activa' 
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
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `cambiarEstadoProfesional` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `cambiarEstadoProfesional`(
    IN p_profesional_id INT,
    IN p_nuevo_estado VARCHAR(50)
)
BEGIN
    DECLARE v_estado_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_id
    FROM estados 
    WHERE tipo_entidad = 'profesional' AND nombre = p_nuevo_estado;
    
    IF v_estado_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado no válido';
    END IF;
    
    
    UPDATE profesionales 
    SET estado_id = v_estado_id
    WHERE profesional_id = p_profesional_id;
    
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `cambiarEstadoSala` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `cambiarEstadoSala`(
    IN p_sala_id INT,
    IN p_nuevo_estado VARCHAR(50)
)
BEGIN
    DECLARE v_estado_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_id
    FROM estados 
    WHERE tipo_entidad = 'sala' AND nombre = p_nuevo_estado;
    
    IF v_estado_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado no válido';
    END IF;
    
    
    UPDATE salas 
    SET estado_id = v_estado_id
    WHERE sala_id = p_sala_id;
    
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `cambiar_estado_objetivo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `cambiar_estado_objetivo`(
    IN p_objetivo_id INT,
    IN p_nombre_estado VARCHAR(50),
    OUT p_resultado VARCHAR(255)
)
BEGIN
    DECLARE v_estado_id INT;
    
    
    SELECT estado_id INTO v_estado_id 
    FROM estados 
    WHERE tipo_entidad = 'objetivo' AND nombre = p_nombre_estado;
    
    IF v_estado_id IS NOT NULL THEN
        UPDATE objetivos_plan SET estado_id = v_estado_id WHERE objetivo_id = p_objetivo_id;
        SET p_resultado = 'OK';
    ELSE
        SET p_resultado = 'Estado no válido';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `cambiar_estado_paciente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `cambiar_estado_paciente`(
    IN p_paciente_id INT,
    IN p_estado_id INT,
    IN p_usuario_id INT
)
BEGIN
    UPDATE pacientes 
    SET estado_id = p_estado_id,
        updated_at = CURRENT_TIMESTAMP
    WHERE paciente_id = p_paciente_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `cierreNoShowAuto` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `cierreNoShowAuto`(
    IN p_gracia_min INT
)
BEGIN
    DECLARE v_estado_no_show INT;
    DECLARE v_motivo_olvido INT;
    DECLARE v_cita_id INT;
    DECLARE v_paciente_id INT;
    DECLARE v_fecha_cita DATETIME;
    DECLARE v_minutos_retraso INT;
    DECLARE done INT DEFAULT FALSE;
    
    DECLARE cur_citas CURSOR FOR
    SELECT c.cita_id, c.paciente_id, c.fecha_inicio,
           TIMESTAMPDIFF(MINUTE, c.fecha_inicio, NOW()) as minutos_retraso
    FROM citas c
    WHERE c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'programada')
    AND c.fecha_inicio < DATE_SUB(NOW(), INTERVAL p_gracia_min MINUTE)
    AND NOT EXISTS (SELECT 1 FROM sesiones s WHERE s.cita_id = c.cita_id);
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    
    SELECT estado_id INTO v_estado_no_show FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show';
    SELECT motivo_id INTO v_motivo_olvido FROM motivos_cancelacion WHERE descripcion = 'Olvido' LIMIT 1;
    
    OPEN cur_citas;
    
    read_loop: LOOP
        FETCH cur_citas INTO v_cita_id, v_paciente_id, v_fecha_cita, v_minutos_retraso;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        
        UPDATE citas 
        SET estado_id = v_estado_no_show,
            motivo_cancelacion_id = v_motivo_olvido
        WHERE cita_id = v_cita_id;
        
        
        INSERT INTO logs_noshow_auto (cita_id, paciente_id, fecha_cita, minutos_retraso)
        VALUES (v_cita_id, v_paciente_id, v_fecha_cita, v_minutos_retraso);
        
    END LOOP;
    
    CLOSE cur_citas;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `citaAgendar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `citaAgendar`(
    IN p_paciente_id INT,
    IN p_profesional_id INT,
    IN p_sala_id INT,
    IN p_inicio DATETIME,
    IN p_fin DATETIME
)
BEGIN
    DECLARE v_solapamiento INT DEFAULT 0;
    DECLARE v_horario_valido BOOLEAN DEFAULT FALSE;
    DECLARE v_estado_programada INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_programada 
    FROM estados 
    WHERE tipo_entidad = 'cita' AND nombre = 'programada';
    
    
    IF NOT EXISTS (SELECT 1 FROM pacientes WHERE paciente_id = p_paciente_id AND estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'paciente' AND nombre = 'activo')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El paciente no existe o no está activo';
    END IF;
    
    
    IF NOT EXISTS (SELECT 1 FROM profesionales WHERE profesional_id = p_profesional_id AND estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'profesional' AND nombre = 'activo')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El profesional no existe o no está activo';
    END IF;
    
    
    IF NOT EXISTS (SELECT 1 FROM salas WHERE sala_id = p_sala_id AND estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'sala' AND nombre = 'activa')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La sala no existe o no está activa';
    END IF;
    
    
    SELECT COUNT(*) INTO v_solapamiento
    FROM citas c
    WHERE c.profesional_id = p_profesional_id
      AND c.estado_id = v_estado_programada
      AND c.fecha_inicio < p_fin
      AND c.fecha_fin > p_inicio;
    
    IF v_solapamiento > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El profesional tiene una cita solapada';
    END IF;
    
    
    SELECT COUNT(*) INTO v_solapamiento
    FROM citas c
    WHERE c.sala_id = p_sala_id
      AND c.estado_id = v_estado_programada
      AND c.fecha_inicio < p_fin
      AND c.fecha_fin > p_inicio;
    
    IF v_solapamiento > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La sala tiene una cita solapada';
    END IF;
    
    
    IF (CAST(TIME(p_inicio) AS TIME) >= CAST('08:00:00' AS TIME) AND 
        CAST(TIME(p_fin) AS TIME) <= CAST('18:00:00' AS TIME)) THEN
        SET v_horario_valido = TRUE;
    END IF;
    
    IF NOT v_horario_valido THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Horario fuera del rango de atención (8:00-18:00)';
    END IF;
    
    
    IF p_inicio >= p_fin THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de inicio debe ser anterior a la fecha de fin';
    END IF;
    
    
    INSERT INTO citas (paciente_id, profesional_id, sala_id, fecha_inicio, fecha_fin, estado_id)
    VALUES (p_paciente_id, p_profesional_id, p_sala_id, p_inicio, p_fin, v_estado_programada);
    
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `citaCancelar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `citaCancelar`(
    IN p_cita_id INT,
    IN p_motivo_id INT,
    IN p_usuario_id INT
)
BEGIN
    DECLARE v_estado_cancelada INT;
    DECLARE v_estado_no_show INT;
    DECLARE v_cuenta_como_noshow BOOLEAN;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_cancelada FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'cancelada';
    SELECT estado_id INTO v_estado_no_show FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show';
    
    
    SELECT cuenta_como_noshow INTO v_cuenta_como_noshow
    FROM motivos_cancelacion
    WHERE motivo_id = p_motivo_id;
    
    
    IF v_cuenta_como_noshow THEN
        UPDATE citas 
        SET estado_id = v_estado_no_show,
            motivo_cancelacion_id = p_motivo_id
        WHERE cita_id = p_cita_id;
    ELSE
        UPDATE citas 
        SET estado_id = v_estado_cancelada,
            motivo_cancelacion_id = p_motivo_id
        WHERE cita_id = p_cita_id;
    END IF;
    
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `citaCompletar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `citaCompletar`(
    IN p_cita_id INT,
    IN p_usuario_id INT
)
BEGIN
    DECLARE v_estado_completada INT;
    DECLARE v_estado_actual INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_completada 
    FROM estados 
    WHERE tipo_entidad = 'cita' AND nombre = 'completada';
    
    
    SELECT estado_id INTO v_estado_actual
    FROM citas 
    WHERE cita_id = p_cita_id;
    
    
    IF v_estado_actual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cita no existe';
    END IF;
    
    
    IF v_estado_actual = v_estado_completada THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cita ya está completada';
    END IF;
    
    
    UPDATE citas 
    SET estado_id = v_estado_completada,
        updated_at = CURRENT_TIMESTAMP
    WHERE cita_id = p_cita_id;
    
    
    INSERT INTO sesiones (cita_id, notas, fecha_registro, editable_hasta)
    VALUES (p_cita_id, 'Cita completada directamente desde agenda', CURRENT_TIMESTAMP, DATE_ADD(NOW(), INTERVAL 24 HOUR));
    
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `citaReagendar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `citaReagendar`(
    IN p_cita_id INT,
    IN p_nuevo_inicio DATETIME,
    IN p_nuevo_fin DATETIME,
    IN p_motivo VARCHAR(200),
    IN p_usuario_id INT
)
BEGIN
    DECLARE v_estado_cancelada INT;
    DECLARE v_estado_programada INT;
    DECLARE v_paciente_id INT;
    DECLARE v_profesional_id INT;
    DECLARE v_sala_id INT;
    DECLARE v_contador_reagendos INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_cancelada FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'cancelada';
    SELECT estado_id INTO v_estado_programada FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'programada';
    
    
    SELECT paciente_id, profesional_id, sala_id 
    INTO v_paciente_id, v_profesional_id, v_sala_id
    FROM citas WHERE cita_id = p_cita_id;
    
    
    SELECT COUNT(*) INTO v_contador_reagendos
    FROM citas 
    WHERE paciente_id = v_paciente_id 
    AND es_reagendo = TRUE
    AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY);
    
    
    IF v_contador_reagendos >= 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El paciente ha excedido el límite de reagendos del mes';
    END IF;
    
    
    UPDATE citas 
    SET estado_id = v_estado_cancelada,
        motivo_cancelacion_id = (SELECT motivo_id FROM motivos_cancelacion WHERE descripcion LIKE '%reagendo%' LIMIT 1)
    WHERE cita_id = p_cita_id;
    
    
    INSERT INTO citas (paciente_id, profesional_id, sala_id, fecha_inicio, fecha_fin, estado_id, es_reagendo, cita_original_id)
    VALUES (v_paciente_id, v_profesional_id, v_sala_id, p_nuevo_inicio, p_nuevo_fin, v_estado_programada, TRUE, p_cita_id);
    
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `crearProfesional` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `crearProfesional`(
    IN p_identificacion VARCHAR(20),
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_especialidad VARCHAR(100),
    IN p_horario_inicio TIME,
    IN p_horario_fin TIME,
    IN p_telefono VARCHAR(20),
    IN p_email VARCHAR(100)
)
BEGIN
    DECLARE v_estado_activo INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_activo 
    FROM estados 
    WHERE tipo_entidad = 'profesional' AND nombre = 'activo';
    
    
    IF p_identificacion IS NULL OR p_nombre IS NULL OR p_apellido IS NULL OR p_especialidad IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Identificación, nombre, apellido y especialidad son obligatorios';
    END IF;
    
    IF EXISTS (SELECT 1 FROM profesionales WHERE identificacion = p_identificacion) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un profesional con esta identificación';
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
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `crearSala` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `crearSala`(
    IN p_nombre VARCHAR(50),
    IN p_descripcion TEXT,
    IN p_capacidad INT
)
BEGIN
    DECLARE v_estado_activa INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_activa 
    FROM estados 
    WHERE tipo_entidad = 'sala' AND nombre = 'activa';
    
    
    IF p_nombre IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la sala es obligatorio';
    END IF;
    
    IF EXISTS (SELECT 1 FROM salas WHERE nombre = p_nombre) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una sala con este nombre';
    END IF;
    
    
    INSERT INTO salas (
        nombre, descripcion, capacidad, estado_id
    ) VALUES (
        p_nombre, p_descripcion, p_capacidad, v_estado_activa
    );
    
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `dashboard_adherencia_pacientes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `dashboard_adherencia_pacientes`()
BEGIN
    SELECT 
        p.paciente_id,
        CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
        COUNT(c.cita_id) as total_citas,
        SUM(CASE WHEN c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada') THEN 1 ELSE 0 END) as citas_completadas,
        SUM(CASE WHEN c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show') THEN 1 ELSE 0 END) as citas_no_show,
        CASE 
            WHEN COUNT(c.cita_id) > 0 THEN
                ROUND((SUM(CASE WHEN c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada') THEN 1 ELSE 0 END) * 100.0 / 
                      COUNT(c.cita_id)), 1)
            ELSE 0 
        END as tasa_adherencia
    FROM pacientes p
    LEFT JOIN citas c ON p.paciente_id = c.paciente_id
    WHERE p.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'paciente' AND nombre = 'activo')
    AND c.fecha_inicio >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY p.paciente_id, p.nombre, p.apellido
    HAVING total_citas > 0
    ORDER BY tasa_adherencia DESC
    LIMIT 10;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `dashboard_citas_hoy` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `dashboard_citas_hoy`()
BEGIN
    SELECT 
        c.cita_id,
        c.fecha_inicio,
        CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
        CONCAT(prof.nombre, ' ', prof.apellido) as profesional_nombre,
        s.nombre as sala_nombre,
        e.nombre as estado_nombre
    FROM citas c
    JOIN pacientes p ON c.paciente_id = p.paciente_id
    JOIN profesionales prof ON c.profesional_id = prof.profesional_id
    JOIN salas s ON c.sala_id = s.sala_id
    JOIN estados e ON c.estado_id = e.estado_id
    WHERE DATE(c.fecha_inicio) = CURDATE()
    ORDER BY c.fecha_inicio;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `dashboard_distribucion_citas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `dashboard_distribucion_citas`()
BEGIN
    SELECT 
        e.nombre as estado,
        COUNT(*) as cantidad
    FROM citas c
    JOIN estados e ON c.estado_id = e.estado_id
    WHERE MONTH(c.fecha_inicio) = MONTH(CURDATE()) 
    AND YEAR(c.fecha_inicio) = YEAR(CURDATE())
    GROUP BY e.nombre;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `dashboard_estadisticas_generales` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `dashboard_estadisticas_generales`()
BEGIN
    
    SELECT COUNT(*) as pacientes_activos
    FROM pacientes 
    WHERE estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'paciente' AND nombre = 'activo');
    
    
    SELECT COUNT(*) as citas_hoy
    FROM citas 
    WHERE DATE(fecha_inicio) = CURDATE();
    
    
    SELECT COUNT(*) as sesiones_mes
    FROM sesiones 
    WHERE MONTH(fecha_registro) = MONTH(CURDATE()) AND YEAR(fecha_registro) = YEAR(CURDATE());
    
    
    SELECT 
        COALESCE(ROUND(
            (SUM(CASE WHEN estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada') THEN 1 ELSE 0 END) * 100.0 / 
            NULLIF(SUM(CASE WHEN estado_id IN (
                (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada'),
                (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show')
            ) THEN 1 ELSE 0 END), 0)), 1), 0) as tasa_adherencia
    FROM citas 
    WHERE MONTH(fecha_inicio) = MONTH(CURDATE()) 
    AND YEAR(fecha_inicio) = YEAR(CURDATE());
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `dashboard_estadisticas_mejorado` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `dashboard_estadisticas_mejorado`()
BEGIN
    
    SELECT 
        COUNT(*) as pacientes_activos
    FROM pacientes 
    WHERE estado_id = (
        SELECT estado_id FROM estados 
        WHERE tipo_entidad = 'paciente' AND nombre = 'activo'
    );
    
    
    SELECT 
        COUNT(*) as citas_hoy
    FROM citas 
    WHERE DATE(fecha_inicio) = CURDATE();
    
    
    SELECT 
        COUNT(*) as sesiones_mes
    FROM sesiones 
    WHERE MONTH(fecha_registro) = MONTH(CURDATE()) 
    AND YEAR(fecha_registro) = YEAR(CURDATE());
    
    
    SELECT 
        COALESCE(ROUND(
            (SUM(CASE WHEN c.estado_id = (
                SELECT estado_id FROM estados 
                WHERE tipo_entidad = 'cita' AND nombre = 'completada'
            ) THEN 1 ELSE 0 END) * 100.0 / 
            NULLIF(SUM(CASE WHEN c.estado_id IN (
                (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada'),
                (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show')
            ) THEN 1 ELSE 0 END), 0)),
        2), 0) as tasa_adherencia
    FROM citas c
    WHERE c.fecha_inicio >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `dashboard_evolucion_sesiones` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `dashboard_evolucion_sesiones`()
BEGIN
    SELECT 
        YEAR(fecha_registro) as año,
        MONTH(fecha_registro) as mes,
        COUNT(*) as total_sesiones
    FROM sesiones 
    WHERE fecha_registro >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    GROUP BY YEAR(fecha_registro), MONTH(fecha_registro)
    ORDER BY año, mes;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `dashboard_progreso_planes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `dashboard_progreso_planes`()
BEGIN
    SELECT 
        pt.plan_id,
        CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
        pt.fecha_inicio,
        pt.fecha_fin_estimada,
        (SELECT COUNT(*) FROM objetivos_plan op WHERE op.plan_id = pt.plan_id) as total_objetivos,
        (SELECT COUNT(*) FROM objetivos_plan op WHERE op.plan_id = pt.plan_id 
         AND op.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'objetivo' AND nombre = 'cumplido')) as objetivos_cumplidos
    FROM planes_terapeuticos pt
    JOIN pacientes p ON pt.paciente_id = p.paciente_id
    WHERE pt.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'plan' AND nombre = 'activo')
    ORDER BY pt.fecha_inicio DESC
    LIMIT 6;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `familiarActualizar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `familiarActualizar`(
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
BEGIN
    UPDATE familiares_pacientes
    SET 
        tipo_parentesco = p_tipo_parentesco,
        nombre = p_nombre,
        apellido = p_apellido,
        segundo_apellido = p_segundo_apellido,
        fecha_nacimiento = p_fecha_nacimiento,
        telefono = p_telefono,
        email = p_email,
        es_contacto_emergencia = p_es_contacto_emergencia,
        observaciones = p_observaciones,
        estado_id = p_estado_id
    WHERE familiar_id = p_familiar_id;
    
    SELECT ROW_COUNT() as affected_rows;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `familiarCrear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `familiarCrear`(
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
BEGIN
    DECLARE v_estado_activo INT;
    
    
    SELECT estado_id INTO v_estado_activo 
    FROM estados 
    WHERE nombre = 'activo' AND tipo_entidad = 'familiar';
    
    IF v_estado_activo IS NULL THEN
        SELECT estado_id INTO v_estado_activo 
        FROM estados 
        WHERE nombre = 'activo' 
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
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `kpiCapacidadUtilizada` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `kpiCapacidadUtilizada`(
    IN p_dia_semana INT
)
BEGIN
    CREATE TEMPORARY TABLE tmpCapacidad (
        sala_id INT,
        sala_nombre VARCHAR(50),
        franja_horaria VARCHAR(20),
        citas_programadas INT,
        porcentaje_ocupacion DECIMAL(5,2)
    );
    
    INSERT INTO tmpCapacidad
    SELECT 
        s.sala_id,
        s.nombre as sala_nombre,
        CONCAT(LPAD(h.hora, 2, '0'), ':00-', LPAD(h.hora+1, 2, '0'), ':00') as franja_horaria,
        COUNT(c.cita_id) as citas_programadas,
        ROUND((COUNT(c.cita_id) * 100.0 / 1), 2) as porcentaje_ocupacion
    FROM salas s
    CROSS JOIN (SELECT 8 as hora UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 
                UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16) h
    LEFT JOIN citas c ON s.sala_id = c.sala_id 
        AND HOUR(c.fecha_inicio) = h.hora
        AND DAYOFWEEK(c.fecha_inicio) = p_dia_semana
        AND c.estado_id IN (
            SELECT estado_id FROM estados 
            WHERE tipo_entidad = 'cita' AND nombre IN ('programada', 'confirmada')
        )
    GROUP BY s.sala_id, s.nombre, h.hora;
    
    SELECT * FROM tmpCapacidad ORDER BY sala_id, franja_horaria;
    
    DROP TEMPORARY TABLE tmpCapacidad;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `login` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`%` PROCEDURE `login`(
    IN p_username VARCHAR(50),
    IN p_passhash VARCHAR(255)
)
BEGIN
    SELECT 
        u.usuario_id,
        u.username,
        u.email,
        u.persona_id,
        u.tipo_persona,
        u.estado_id,
        u.ultimo_login
    FROM usuarios u
    WHERE u.username = p_username 
    AND u.passhash = p_passhash
    AND u.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'usuario' AND nombre = 'activo');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtenerProfesionales` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtenerProfesionales`(IN p_mostrar_todos BOOLEAN)
BEGIN
    IF p_mostrar_todos THEN
        SELECT p.*, e.nombre as estado_nombre 
        FROM profesionales p 
        JOIN estados e ON p.estado_id = e.estado_id 
        ORDER BY p.nombre, p.apellido;
    ELSE
        SELECT p.*, e.nombre as estado_nombre 
        FROM profesionales p 
        JOIN estados e ON p.estado_id = e.estado_id 
        WHERE p.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'profesional' AND nombre = 'activo')
        ORDER BY p.nombre, p.apellido;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtenerProfesionalPorId` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtenerProfesionalPorId`(IN p_profesional_id INT)
BEGIN
    SELECT p.*, e.nombre as estado_nombre 
    FROM profesionales p 
    JOIN estados e ON p.estado_id = e.estado_id 
    WHERE p.profesional_id = p_profesional_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtenerSalaPorId` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtenerSalaPorId`(IN p_sala_id INT)
BEGIN
    SELECT s.*, e.nombre as estado_nombre 
    FROM salas s 
    JOIN estados e ON s.estado_id = e.estado_id 
    WHERE s.sala_id = p_sala_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtenerSalas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtenerSalas`(IN p_mostrar_todas BOOLEAN)
BEGIN
    IF p_mostrar_todas THEN
        SELECT s.*, e.nombre as estado_nombre 
        FROM salas s 
        JOIN estados e ON s.estado_id = e.estado_id 
        ORDER BY s.nombre;
    ELSE
        SELECT s.*, e.nombre as estado_nombre 
        FROM salas s 
        JOIN estados e ON s.estado_id = e.estado_id 
        WHERE s.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'sala' AND nombre = 'activa')
        ORDER BY s.nombre;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_administracion_medicamentos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_administracion_medicamentos`()
BEGIN
    SELECT am.*, p.nombre as paciente_nombre, p.apellido as paciente_apellido,
           m.nombre_comercial as medicamento,
           e.nombre as enfermera_nombre, e.apellido as enfermera_apellido
    FROM administracion_medicamentos am
    JOIN pacientes p ON am.paciente_id = p.paciente_id
    JOIN medicamentos m ON am.medicamento_id = m.medicamento_id
    JOIN enfermeras e ON am.enfermera_id = e.enfermera_id
    ORDER BY am.fecha_hora_programada DESC
    LIMIT 50;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_asignaciones_cama` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_asignaciones_cama`()
BEGIN
    SELECT ac.*, p.nombre as paciente_nombre, p.apellido as paciente_apellido,
           c.numero_cama, h.numero_habitacion as habitacion_nombre,
           e.nombre as estado_nombre
    FROM asignaciones_cama ac
    JOIN pacientes p ON ac.paciente_id = p.paciente_id
    JOIN camas c ON ac.cama_id = c.cama_id
    JOIN habitaciones h ON c.habitacion_id = h.habitacion_id
    JOIN estados e ON ac.estado_id = e.estado_id
    ORDER BY ac.fecha_ingreso DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_asignaciones_cama_paciente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_asignaciones_cama_paciente`(
    IN p_paciente_id INT
)
BEGIN
    SELECT 
        ac.asignacion_id,
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
        DATEDIFF(COALESCE(ac.fecha_egreso, NOW()), ac.fecha_ingreso) as dias_estancia
    FROM asignaciones_cama ac
    JOIN camas c ON ac.cama_id = c.cama_id
    JOIN habitaciones h ON c.habitacion_id = h.habitacion_id
    JOIN estados e ON ac.estado_id = e.estado_id
    WHERE ac.paciente_id = p_paciente_id
    ORDER BY ac.fecha_ingreso DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_asignaciones_personal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_asignaciones_personal`()
BEGIN
    SELECT ap.*, p.nombre as paciente_nombre, p.apellido as paciente_apellido,
           COALESCE(enf.nombre, prof.nombre) as asignado_nombre,
           COALESCE(enf.apellido, prof.apellido) as asignado_apellido,
           e.nombre as estado_nombre
    FROM asignaciones_paciente ap
    JOIN pacientes p ON ap.paciente_id = p.paciente_id
    LEFT JOIN enfermeras enf ON ap.enfermera_id = enf.enfermera_id
    LEFT JOIN profesionales prof ON ap.profesional_id = prof.profesional_id
    JOIN estados e ON ap.estado_id = e.estado_id
    ORDER BY ap.fecha_asignacion DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_asignaciones_personal_paciente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_asignaciones_personal_paciente`(
    IN p_paciente_id INT
)
BEGIN
    SELECT 
        ap.asignacion_id,
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
        ap.created_at
    FROM asignaciones_paciente ap
    JOIN pacientes p ON ap.paciente_id = p.paciente_id
    LEFT JOIN enfermeras e ON ap.enfermera_id = e.enfermera_id
    LEFT JOIN profesionales prof ON ap.profesional_id = prof.profesional_id
    JOIN estados est ON ap.estado_id = est.estado_id
    WHERE ap.paciente_id = p_paciente_id
    ORDER BY ap.fecha_asignacion DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_asignacion_cama_detalle` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_asignacion_cama_detalle`(IN p_asignacion_id INT)
BEGIN
    SELECT ac.asignacion_id,
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
           DATEDIFF(COALESCE(ac.fecha_egreso, NOW()), ac.fecha_ingreso) as dias_estancia
    FROM asignaciones_cama ac
    JOIN pacientes p ON ac.paciente_id = p.paciente_id
    JOIN camas c ON ac.cama_id = c.cama_id
    JOIN habitaciones h ON c.habitacion_id = h.habitacion_id
    JOIN estados e ON ac.estado_id = e.estado_id
    WHERE ac.asignacion_id = p_asignacion_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_asignacion_personal_detalle` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_asignacion_personal_detalle`(IN p_asignacion_id INT)
BEGIN
    SELECT ap.asignacion_id,
           ap.paciente_id,
           p.nombre as paciente_nombre,
           p.apellido as paciente_apellido,
           ap.enfermera_id,
           CASE 
               WHEN ap.enfermera_id IS NOT NULL 
               THEN CONCAT(enf.nombre, ' ', enf.apellido)
               ELSE NULL 
           END as enfermera_nombre,
           ap.profesional_id,
           CASE 
               WHEN ap.profesional_id IS NOT NULL 
               THEN CONCAT(prof.nombre, ' ', prof.apellido)
               ELSE NULL 
           END as profesional_nombre,
           COALESCE(enf.nombre, prof.nombre) as asignado_nombre,
           COALESCE(enf.apellido, prof.apellido) as asignado_apellido,
           ap.tipo_asignacion,
           ap.fecha_asignacion,
           ap.fecha_fin,
           ap.es_principal,
           ap.observaciones,
           ap.estado_id,
           e.nombre as estado_nombre,
           ap.created_at
    FROM asignaciones_paciente ap
    JOIN pacientes p ON ap.paciente_id = p.paciente_id
    LEFT JOIN enfermeras enf ON ap.enfermera_id = enf.enfermera_id
    LEFT JOIN profesionales prof ON ap.profesional_id = prof.profesional_id
    JOIN estados e ON ap.estado_id = e.estado_id
    WHERE ap.asignacion_id = p_asignacion_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_camas_disponibles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_camas_disponibles`()
BEGIN
    SELECT c.*, h.numero_habitacion as habitacion_nombre, e.nombre as estado_nombre
    FROM camas c
    JOIN habitaciones h ON c.habitacion_id = h.habitacion_id
    JOIN estados e ON c.estado_id = e.estado_id
    WHERE c.estado_id = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_citas_hoy` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_citas_hoy`()
BEGIN
    SELECT 
        c.cita_id,
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
        e.nombre as estado_nombre
    FROM citas c
    JOIN pacientes p ON c.paciente_id = p.paciente_id
    JOIN profesionales prof ON c.profesional_id = prof.profesional_id
    JOIN salas s ON c.sala_id = s.sala_id
    JOIN estados e ON c.estado_id = e.estado_id
    WHERE DATE(c.fecha_inicio) = CURDATE()
    ORDER BY c.fecha_inicio;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_citas_pendientes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_citas_pendientes`()
BEGIN
    SELECT 
        c.cita_id, 
        CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
        c.fecha_inicio, 
        CONCAT(prof.nombre, ' ', prof.apellido) as profesional_nombre,
        e.nombre as estado_nombre,
        s.nombre as sala_nombre
    FROM citas c
    JOIN pacientes p ON c.paciente_id = p.paciente_id
    JOIN profesionales prof ON c.profesional_id = prof.profesional_id
    JOIN estados e ON c.estado_id = e.estado_id
    JOIN salas s ON c.sala_id = s.sala_id
    WHERE c.estado_id IN (
        SELECT estado_id FROM estados 
        WHERE tipo_entidad = 'cita' AND nombre IN ('programada', 'confirmada')
    )
    AND NOT EXISTS (SELECT 1 FROM sesiones WHERE cita_id = c.cita_id)
    AND (
        DATE(c.fecha_inicio) = CURDATE()
        OR c.fecha_inicio < NOW()
        OR c.fecha_inicio BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 2 HOUR)
    )
    ORDER BY 
        CASE 
            WHEN DATE(c.fecha_inicio) = CURDATE() THEN 1
            WHEN c.fecha_inicio < NOW() THEN 2
            ELSE 3
        END,
        c.fecha_inicio ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_cita_por_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_cita_por_id`(IN p_cita_id INT)
BEGIN
    SELECT c.*, 
           CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
           CONCAT(prof.nombre, ' ', prof.apellido) as profesional_nombre,
           s.nombre as sala_nombre,
           e.nombre as estado_nombre
    FROM citas c
    JOIN pacientes p ON c.paciente_id = p.paciente_id
    JOIN profesionales prof ON c.profesional_id = prof.profesional_id
    JOIN salas s ON c.sala_id = s.sala_id
    JOIN estados e ON c.estado_id = e.estado_id
    WHERE c.cita_id = p_cita_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_datos_planes_completo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_datos_planes_completo`()
BEGIN
    
    SELECT * FROM progresoPorPlan;
    
    
    SELECT paciente_id, nombre, apellido 
    FROM pacientes 
    WHERE estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'paciente' AND nombre = 'activo');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_enfermeras_activas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_enfermeras_activas`()
BEGIN
    SELECT e.*, est.nombre as estado_nombre
    FROM enfermeras e
    JOIN estados est ON e.estado_id = est.estado_id
    WHERE e.estado_id = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_escalas_activas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_escalas_activas`()
BEGIN
    SELECT escala_id, nombre 
    FROM escalas_clinicas 
    WHERE estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'escala' AND nombre = 'activa');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_estados_por_entidad` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_estados_por_entidad`(IN tipo_entidad_param VARCHAR(50))
BEGIN
    SELECT estado_id, nombre 
    FROM estados 
    WHERE tipo_entidad = tipo_entidad_param;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_familiares` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_familiares`()
BEGIN
    SELECT f.*, p.nombre as paciente_nombre, p.apellido as paciente_apellido,
           e.nombre as estado_nombre
    FROM familiares_pacientes f
    JOIN pacientes p ON f.paciente_id = p.paciente_id
    JOIN estados e ON f.estado_id = e.estado_id
    ORDER BY f.created_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_familiares_por_paciente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_familiares_por_paciente`(
    IN p_paciente_id INT
)
BEGIN
    SELECT 
        f.familiar_id,
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
        f.created_at
    FROM familiares_pacientes f
    JOIN estados e ON f.estado_id = e.estado_id
    WHERE f.paciente_id = p_paciente_id
    ORDER BY f.es_contacto_emergencia DESC, f.created_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_familiar_por_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_familiar_por_id`(
    IN p_familiar_id INT
)
BEGIN
    SELECT 
        f.familiar_id,
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
        f.created_at
    FROM familiares_pacientes f
    JOIN pacientes p ON f.paciente_id = p.paciente_id
    JOIN estados e ON f.estado_id = e.estado_id
    WHERE f.familiar_id = p_familiar_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_motivos_cancelacion_activos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_motivos_cancelacion_activos`()
BEGIN
    SELECT motivo_id, descripcion 
    FROM motivos_cancelacion 
    WHERE estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'motivo' AND nombre = 'activo');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_objetivos_plan` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_objetivos_plan`(IN p_plan_id INT)
BEGIN
    SELECT op.*, e.nombre as estado_nombre
    FROM objetivos_plan op
    JOIN estados e ON op.estado_id = e.estado_id
    WHERE op.plan_id = p_plan_id
    ORDER BY op.fecha_creacion DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_ordenes_medicas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_ordenes_medicas`()
BEGIN
    SELECT 
        om.orden_id,
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
        om.created_at
    FROM ordenes_medicas om
    JOIN pacientes p ON om.paciente_id = p.paciente_id
    JOIN profesionales prof ON om.profesional_id = prof.profesional_id
    LEFT JOIN medicamentos m ON om.medicamento_id = m.medicamento_id
    JOIN estados e ON om.estado_id = e.estado_id
    ORDER BY om.fecha_orden DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_ordenes_por_paciente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_ordenes_por_paciente`(
    IN p_paciente_id INT
)
BEGIN
    SELECT 
        om.orden_id,
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
        om.observaciones
    FROM ordenes_medicas om
    JOIN profesionales prof ON om.profesional_id = prof.profesional_id
    LEFT JOIN medicamentos m ON om.medicamento_id = m.medicamento_id
    JOIN estados e ON om.estado_id = e.estado_id
    WHERE om.paciente_id = p_paciente_id
    ORDER BY om.fecha_orden DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_orden_por_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_orden_por_id`(
    IN p_orden_id INT
)
BEGIN
    SELECT 
        om.orden_id,
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
        om.created_at
    FROM ordenes_medicas om
    JOIN pacientes p ON om.paciente_id = p.paciente_id
    JOIN profesionales prof ON om.profesional_id = prof.profesional_id
    LEFT JOIN medicamentos m ON om.medicamento_id = m.medicamento_id
    JOIN estados e ON om.estado_id = e.estado_id
    WHERE om.orden_id = p_orden_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_pacientes_activos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_pacientes_activos`()
BEGIN
    SELECT paciente_id, nombre, apellido 
    FROM pacientes 
    WHERE estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'paciente' AND nombre = 'activo');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_pacientes_estados` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_pacientes_estados`()
BEGIN
    SELECT p.*, e.nombre as estado_nombre, u.username, u.passhash
    FROM pacientes p 
    JOIN estados e ON p.estado_id = e.estado_id 
    LEFT JOIN usuarios u ON u.persona_id = p.paciente_id AND u.tipo_persona = 'paciente'
    ORDER BY p.paciente_id DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_paciente_por_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_paciente_por_id`(IN p_paciente_id INT)
BEGIN
    SELECT p.*, e.nombre as estado_nombre, u.username, u.passhash
    FROM pacientes p 
    JOIN estados e ON p.estado_id = e.estado_id 
    LEFT JOIN usuarios u ON u.persona_id = p.paciente_id AND u.tipo_persona = 'paciente'
    WHERE p.paciente_id = p_paciente_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_planes_progreso` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_planes_progreso`()
BEGIN
    SELECT * FROM progresoPorPlan;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_plan_por_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_plan_por_id`(IN p_plan_id INT)
BEGIN
    SELECT pt.*, 
           CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
           e.nombre as estado_nombre
    FROM planes_terapeuticos pt
    JOIN pacientes p ON pt.paciente_id = p.paciente_id
    JOIN estados e ON pt.estado_id = e.estado_id
    WHERE pt.plan_id = p_plan_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_profesionales_activos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_profesionales_activos`()
BEGIN
    SELECT profesional_id, nombre, apellido 
    FROM profesionales 
    WHERE estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'profesional' AND nombre = 'activo');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_salas_activas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_salas_activas`()
BEGIN
    SELECT sala_id, nombre 
    FROM salas 
    WHERE estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'sala' AND nombre = 'activa');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_sesiones_detalladas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_sesiones_detalladas`()
BEGIN
    SELECT s.sesion_id, c.cita_id, 
           CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre, 
           CONCAT(prof.nombre, ' ', prof.apellido) as profesional_nombre, 
           s.fecha_registro, s.notas, s.tecnica_utilizada
    FROM sesiones s
    JOIN citas c ON s.cita_id = c.cita_id
    JOIN pacientes p ON c.paciente_id = p.paciente_id
    JOIN profesionales prof ON c.profesional_id = prof.profesional_id
    ORDER BY s.fecha_registro DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `obtener_sesion_por_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `obtener_sesion_por_id`(IN p_sesion_id INT)
BEGIN
    SELECT s.*, 
           CONCAT(p.nombre, ' ', p.apellido) as paciente_nombre,
           CONCAT(prof.nombre, ' ', prof.apellido) as profesional_nombre,
           c.fecha_inicio
    FROM sesiones s
    JOIN citas c ON s.cita_id = c.cita_id
    JOIN pacientes p ON c.paciente_id = p.paciente_id
    JOIN profesionales prof ON c.profesional_id = prof.profesional_id
    WHERE s.sesion_id = p_sesion_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `ordenActualizar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `ordenActualizar`(
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
BEGIN
    UPDATE ordenes_medicas
    SET 
        descripcion = p_descripcion,
        dosis = p_dosis,
        frecuencia = p_frecuencia,
        duracion = p_duracion,
        fecha_fin = p_fecha_fin,
        estado_id = p_estado_id,
        observaciones = p_observaciones
    WHERE orden_id = p_orden_id;
    
    SELECT ROW_COUNT() as affected_rows;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `ordenCrear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `ordenCrear`(
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
BEGIN
    DECLARE v_estado_pendiente INT;
    
    
    SELECT estado_id INTO v_estado_pendiente 
    FROM estados 
    WHERE nombre = 'pendiente' AND tipo_entidad = 'orden';
    
    IF v_estado_pendiente IS NULL THEN
        SELECT estado_id INTO v_estado_pendiente 
        FROM estados 
        WHERE nombre = 'pendiente' 
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
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `pacienteActualizar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `pacienteActualizar`(
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
BEGIN
    DECLARE v_old_val JSON;
    DECLARE v_new_val JSON;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
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
    ) INTO v_old_val
    FROM pacientes 
    WHERE paciente_id = p_paciente_id;
    
    
    UPDATE pacientes 
    SET identificacion = p_identificacion,
        nombre = p_nombre,
        apellido = p_apellido,
        fecha_nacimiento = p_fecha_nacimiento,
        telefono = p_telefono,
        email = p_email,
        direccion = p_direccion,
        estado_id = p_estado_id,
        updated_at = CURRENT_TIMESTAMP
    WHERE paciente_id = p_paciente_id;
    
    
    SELECT JSON_OBJECT(
        'identificacion', identificacion,
        'nombre', nombre,
        'apellido', apellido,
        'telefono', telefono,
        'email', email,
        'estado_id', estado_id
    ) INTO v_new_val
    FROM pacientes 
    WHERE paciente_id = p_paciente_id;
    
    
    INSERT INTO auditoria_pacientes (paciente_id, accion, usuario_id, valor_anterior, valor_nuevo)
    VALUES (p_paciente_id, 'UPDATE', p_usuario_id, v_old_val, v_new_val);
    
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `pacienteCrear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`%` PROCEDURE `pacienteCrear`(
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
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
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
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `planCrear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `planCrear`(
    IN p_paciente_id INT,
    IN p_diagnostico_principal TEXT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin_estimada DATE,
    IN p_objetivos JSON,
    IN p_usuario_id INT
)
BEGIN
    DECLARE v_plan_id INT;
    DECLARE v_estado_activo INT;
    DECLARE v_objetivo_count INT DEFAULT 0;
    DECLARE v_objetivo_desc TEXT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_activo 
    FROM estados 
    WHERE tipo_entidad = 'plan' AND nombre = 'activo';
    
    
    IF NOT EXISTS (SELECT 1 FROM pacientes WHERE paciente_id = p_paciente_id AND estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'paciente' AND nombre = 'activo')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El paciente no existe o no está activo';
    END IF;
    
    
    INSERT INTO planes_terapeuticos (paciente_id, diagnostico_principal, fecha_inicio, fecha_fin_estimada, estado_id)
    VALUES (p_paciente_id, p_diagnostico_principal, p_fecha_inicio, p_fecha_fin_estimada, v_estado_activo);
    
    SET v_plan_id = LAST_INSERT_ID();
    
    
    IF p_objetivos IS NOT NULL THEN
        SET v_objetivo_count = JSON_LENGTH(p_objetivos);
        
        WHILE v_objetivo_count > 0 DO
            SET v_objetivo_count = v_objetivo_count - 1;
            SET v_objetivo_desc = JSON_UNQUOTE(JSON_EXTRACT(p_objetivos, CONCAT('$[', v_objetivo_count, ']')));
            
            IF v_objetivo_desc IS NOT NULL AND v_objetivo_desc != '' THEN
                INSERT INTO objetivos_plan (plan_id, descripcion, estado_id)
                VALUES (v_plan_id, v_objetivo_desc, (SELECT estado_id FROM estados WHERE tipo_entidad = 'objetivo' AND nombre = 'pendiente'));
            END IF;
        END WHILE;
    END IF;
    
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `profesionalCrear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `profesionalCrear`(
    IN p_identificacion VARCHAR(20),
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_especialidad VARCHAR(100),
    IN p_horario_inicio TIME,
    IN p_horario_fin TIME,
    IN p_telefono VARCHAR(20),
    IN p_email VARCHAR(100)
)
BEGIN
    DECLARE v_estado_activo INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    SELECT estado_id INTO v_estado_activo 
    FROM estados 
    WHERE tipo_entidad = 'profesional' AND nombre = 'activo';
    
    
    IF p_identificacion IS NULL OR p_nombre IS NULL OR p_apellido IS NULL OR p_especialidad IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Identificación, nombre, apellido y especialidad son obligatorios';
    END IF;
    
    IF EXISTS (SELECT 1 FROM profesionales WHERE identificacion = p_identificacion) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un profesional con esta identificación';
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
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `registrar_sesion_completa` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `registrar_sesion_completa`(
    IN p_cita_id INT,
    IN p_notas TEXT,
    IN p_tecnica_utilizada VARCHAR(255),
    IN p_duracion_real_min INT,
    IN p_usuario_id INT,
    IN p_puntajes_json JSON
)
BEGIN
    DECLARE v_sesion_id INT;
    DECLARE v_plan_id INT;
    DECLARE v_paciente_id INT;
    DECLARE v_total_objetivos INT;
    DECLARE v_objetivos_cumplidos INT;
    DECLARE i INT DEFAULT 0;
    DECLARE v_escala_id INT;
    DECLARE v_puntaje DECIMAL(5,2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    
    INSERT INTO sesiones (cita_id, notas, tecnica_utilizada, duracion_real_min, fecha_registro)
    VALUES (p_cita_id, p_notas, p_tecnica_utilizada, p_duracion_real_min, NOW());
    
    SET v_sesion_id = LAST_INSERT_ID();
    
    
    IF p_puntajes_json IS NOT NULL AND JSON_LENGTH(p_puntajes_json) > 0 THEN
        WHILE i < JSON_LENGTH(p_puntajes_json) DO
            SET v_escala_id = JSON_UNQUOTE(JSON_EXTRACT(p_puntajes_json, CONCAT('$[', i, '].escala_id')));
            SET v_puntaje = JSON_UNQUOTE(JSON_EXTRACT(p_puntajes_json, CONCAT('$[', i, '].puntaje')));
            
            INSERT INTO sesion_escalas (sesion_id, escala_id, puntaje)
            VALUES (v_sesion_id, v_escala_id, v_puntaje);
            
            SET i = i + 1;
        END WHILE;
    END IF;
    
    
    SELECT pt.plan_id, c.paciente_id INTO v_plan_id, v_paciente_id
    FROM planes_terapeuticos pt
    JOIN citas c ON pt.paciente_id = c.paciente_id
    WHERE c.cita_id = p_cita_id
    AND pt.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'plan' AND nombre = 'activo')
    LIMIT 1;
    
    
    IF v_plan_id IS NOT NULL THEN
        SELECT 
            COUNT(*) as total,
            SUM(CASE WHEN estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'objetivo' AND nombre = 'cumplido') THEN 1 ELSE 0 END) as cumplidos
        INTO v_total_objetivos, v_objetivos_cumplidos
        FROM objetivos_plan
        WHERE plan_id = v_plan_id;
        
        IF v_total_objetivos > 0 AND v_objetivos_cumplidos = v_total_objetivos THEN
            UPDATE planes_terapeuticos 
            SET estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'plan' AND nombre = 'completado'),
                fecha_cierre = CURDATE(),
                motivo_cierre = 'Metas cumplidas - Cierre automático'
            WHERE plan_id = v_plan_id;
        END IF;
    END IF;
    
    
    UPDATE citas 
    SET estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada')
    WHERE cita_id = p_cita_id;
    
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `registrar_sesion_con_cierre_plan` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `registrar_sesion_con_cierre_plan`(
    IN p_cita_id INT,
    IN p_notas TEXT,
    IN p_tecnica_utilizada VARCHAR(255),
    IN p_duracion_real_min INT,
    IN p_puntajes JSON,
    IN p_usuario_id INT
)
BEGIN
    DECLARE v_plan_id INT;
    DECLARE v_objetivos_total INT;
    DECLARE v_objetivos_cumplidos INT;
    DECLARE v_estado_completado INT;
    
    
    INSERT INTO sesiones (cita_id, notas, tecnica_utilizada, duracion_real_min, fecha_registro, usuario_registro)
    VALUES (p_cita_id, p_notas, p_tecnica_utilizada, p_duracion_real_min, NOW(), p_usuario_id);
    
    
    SELECT pt.plan_id INTO v_plan_id
    FROM planes_terapeuticos pt
    JOIN citas c ON pt.paciente_id = c.paciente_id
    WHERE c.cita_id = p_cita_id
    AND pt.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'plan' AND nombre = 'activo')
    LIMIT 1;
    
    IF v_plan_id IS NOT NULL THEN
        SELECT 
            COUNT(*),
            SUM(CASE WHEN estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'objetivo' AND nombre = 'cumplido') THEN 1 ELSE 0 END)
        INTO v_objetivos_total, v_objetivos_cumplidos
        FROM objetivos_plan
        WHERE plan_id = v_plan_id;
        
        IF v_objetivos_total > 0 AND v_objetivos_cumplidos = v_objetivos_total THEN
            SELECT estado_id INTO v_estado_completado 
            FROM estados 
            WHERE tipo_entidad = 'plan' AND nombre = 'completado';
            
            UPDATE planes_terapeuticos 
            SET estado_id = v_estado_completado,
                fecha_cierre = CURDATE(),
                motivo_cierre = 'Metas cumplidas - Cierre automático'
            WHERE plan_id = v_plan_id;
        END IF;
    END IF;
    
    
    UPDATE citas 
    SET estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada')
    WHERE cita_id = p_cita_id;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `reporteAdherencia` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `reporteAdherencia`(
    IN p_desde DATE,
    IN p_hasta DATE
)
BEGIN
    
    CREATE TEMPORARY TABLE tmpAdherencia (
        paciente_id INT,
        paciente_nombre VARCHAR(201),
        total_citas INT,
        asistidas INT,
        no_shows INT,
        canceladas INT,
        tasa_adherencia DECIMAL(5,2)
    );
    
    INSERT INTO tmpAdherencia
    SELECT 
        p.paciente_id,
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
        2) as tasa_adherencia
    FROM pacientes p
    LEFT JOIN citas c ON p.paciente_id = c.paciente_id
    WHERE c.fecha_inicio BETWEEN p_desde AND p_hasta
    GROUP BY p.paciente_id, p.nombre, p.apellido;
    
    SELECT * FROM tmpAdherencia ORDER BY tasa_adherencia DESC;
    
    DROP TEMPORARY TABLE tmpAdherencia;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `reporteNoShow` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `reporteNoShow`(
    IN p_desde DATE,
    IN p_hasta DATE,
    IN p_por_profesional BOOLEAN
)
BEGIN
    CREATE TEMPORARY TABLE tmpNoShow (
        profesional_id INT,
        profesional_nombre VARCHAR(201),
        motivo VARCHAR(200),
        cantidad INT
    );
    
    IF p_por_profesional THEN
        INSERT INTO tmpNoShow
        SELECT 
            prof.profesional_id,
            CONCAT(prof.nombre, ' ', prof.apellido) as profesional_nombre,
            COALESCE(mc.descripcion, 'Sin motivo específico') as motivo,
            COUNT(*) as cantidad
        FROM citas c
        JOIN profesionales prof ON c.profesional_id = prof.profesional_id
        LEFT JOIN motivos_cancelacion mc ON c.motivo_cancelacion_id = mc.motivo_id
        WHERE c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show')
        AND c.fecha_inicio BETWEEN p_desde AND p_hasta
        GROUP BY prof.profesional_id, mc.descripcion;
    ELSE
        INSERT INTO tmpNoShow
        SELECT 
            NULL as profesional_id,
            'Todos' as profesional_nombre,
            COALESCE(mc.descripcion, 'Sin motivo específico') as motivo,
            COUNT(*) as cantidad
        FROM citas c
        LEFT JOIN motivos_cancelacion mc ON c.motivo_cancelacion_id = mc.motivo_id
        WHERE c.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'no_show')
        AND c.fecha_inicio BETWEEN p_desde AND p_hasta
        GROUP BY mc.descripcion;
    END IF;
    
    SELECT * FROM tmpNoShow ORDER BY cantidad DESC;
    
    DROP TEMPORARY TABLE tmpNoShow;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `sesionRegistrar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`paliativos_user`@`localhost` PROCEDURE `sesionRegistrar`(
    IN p_cita_id INT,
    IN p_notas TEXT,
    IN p_tecnica_utilizada VARCHAR(255),
    IN p_duracion_real_min INT,
    IN p_puntajes JSON,
    IN p_usuario_id INT
)
BEGIN
    DECLARE v_plan_id INT;
    DECLARE v_objetivos_total INT;
    DECLARE v_objetivos_cumplidos INT;
    DECLARE v_estado_completado INT;

    
    INSERT INTO sesiones (cita_id, notas, tecnica_utilizada, duracion_real_min, fecha_registro, usuario_registro)
    VALUES (p_cita_id, p_notas, p_tecnica_utilizada, p_duracion_real_min, NOW(), p_usuario_id);

    
    SELECT pt.plan_id INTO v_plan_id
    FROM planes_terapeuticos pt
    JOIN citas c ON pt.paciente_id = c.paciente_id
    WHERE c.cita_id = p_cita_id
    AND pt.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'plan' AND nombre = 'activo')
    LIMIT 1;
    
    IF v_plan_id IS NOT NULL THEN
        SELECT 
            COUNT(*),
            SUM(CASE WHEN estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'objetivo' AND nombre = 'cumplido') THEN 1 ELSE 0 END)
        INTO v_objetivos_total, v_objetivos_cumplidos
        FROM objetivos_plan
        WHERE plan_id = v_plan_id;
        
        IF v_objetivos_total > 0 AND v_objetivos_cumplidos = v_objetivos_total THEN
            SELECT estado_id INTO v_estado_completado 
            FROM estados 
            WHERE tipo_entidad = 'plan' AND nombre = 'completado';
            
            UPDATE planes_terapeuticos 
            SET estado_id = v_estado_completado,
                fecha_cierre = CURDATE(),
                motivo_cierre = 'Metas cumplidas - Cierre automático'
            WHERE plan_id = v_plan_id;
        END IF;
    END IF;

    
    UPDATE citas 
    SET estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'cita' AND nombre = 'completada')
    WHERE cita_id = p_cita_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */;
/*!50003 DROP PROCEDURE IF EXISTS `usuarioRoles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE usuarioRoles(
    IN p_usuario_id INT
)
BEGIN
    SELECT  
        r.rol_id,
        r.nombre as nombre_rol,
        r.descripcion,
        r.permisos
    FROM roles r
    JOIN usuario_roles ur ON r.rol_id = ur.rol_id
    WHERE ur.usuario_id = p_usuario_id
    AND r.estado_id = (SELECT estado_id FROM estados WHERE tipo_entidad = 'rol' AND nombre = 'activo');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `cargaHorariaSala`
--

/*!50001 DROP VIEW IF EXISTS `cargaHorariaSala`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb3 */;
/*!50001 SET character_set_results     = utf8mb3 */;
/*!50001 SET collation_connection      = utf8mb3_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`paliativos_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `cargaHorariaSala` AS select `s`.`sala_id` AS `sala_id`,`s`.`nombre` AS `sala_nombre`,cast(`c`.`fecha_inicio` as date) AS `fecha`,hour(`c`.`fecha_inicio`) AS `hora`,count(0) AS `citas_programadas`,round(count(0) * 100.0 / 8,2) AS `porcentaje_ocupacion` from (`salas` `s` left join `citas` `c` on(`s`.`sala_id` = `c`.`sala_id` and cast(`c`.`fecha_inicio` as date) = curdate() and `c`.`estado_id` in (select `estados`.`estado_id` from `estados` where `estados`.`tipo_entidad` = 'cita' and `estados`.`nombre` in ('programada','confirmada')))) group by `s`.`sala_id`,`s`.`nombre`,cast(`c`.`fecha_inicio` as date),hour(`c`.`fecha_inicio`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `citasHoy`
--

/*!50001 DROP VIEW IF EXISTS `citasHoy`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb3 */;
/*!50001 SET character_set_results     = utf8mb3 */;
/*!50001 SET collation_connection      = utf8mb3_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`paliativos_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `citasHoy` AS select `c`.`cita_id` AS `cita_id`,concat(`p`.`nombre`,' ',`p`.`apellido`) AS `paciente`,concat(`prof`.`nombre`,' ',`prof`.`apellido`) AS `profesional`,`s`.`nombre` AS `sala`,`c`.`fecha_inicio` AS `fecha_inicio`,`c`.`fecha_fin` AS `fecha_fin`,`e`.`nombre` AS `estado` from ((((`citas` `c` join `pacientes` `p` on(`c`.`paciente_id` = `p`.`paciente_id`)) join `profesionales` `prof` on(`c`.`profesional_id` = `prof`.`profesional_id`)) join `salas` `s` on(`c`.`sala_id` = `s`.`sala_id`)) join `estados` `e` on(`c`.`estado_id` = `e`.`estado_id`)) where cast(`c`.`fecha_inicio` as date) = curdate() order by `c`.`fecha_inicio` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `noShowPorProfesionalMes`
--

/*!50001 DROP VIEW IF EXISTS `noShowPorProfesionalMes`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb3 */;
/*!50001 SET character_set_results     = utf8mb3 */;
/*!50001 SET collation_connection      = utf8mb3_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`paliativos_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `noShowPorProfesionalMes` AS select `prof`.`profesional_id` AS `profesional_id`,concat(`prof`.`nombre`,' ',`prof`.`apellido`) AS `profesional_nombre`,year(`c`.`fecha_inicio`) AS `año`,month(`c`.`fecha_inicio`) AS `mes`,count(0) AS `total_citas`,sum(case when `c`.`estado_id` = (select `estados`.`estado_id` from `estados` where `estados`.`tipo_entidad` = 'cita' and `estados`.`nombre` = 'no_show') then 1 else 0 end) AS `no_shows`,round(sum(case when `c`.`estado_id` = (select `estados`.`estado_id` from `estados` where `estados`.`tipo_entidad` = 'cita' and `estados`.`nombre` = 'no_show') then 1 else 0 end) * 100.0 / nullif(count(0),0),2) AS `porcentaje_no_show` from (`citas` `c` join `profesionales` `prof` on(`c`.`profesional_id` = `prof`.`profesional_id`)) group by `prof`.`profesional_id`,year(`c`.`fecha_inicio`),month(`c`.`fecha_inicio`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `pacientesActivos`
--

/*!50001 DROP VIEW IF EXISTS `pacientesActivos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb3 */;
/*!50001 SET character_set_results     = utf8mb3 */;
/*!50001 SET collation_connection      = utf8mb3_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`paliativos_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `pacientesActivos` AS select `p`.`paciente_id` AS `paciente_id`,`p`.`identificacion` AS `identificacion`,concat(`p`.`nombre`,' ',`p`.`apellido`) AS `nombre_completo`,`p`.`telefono` AS `telefono`,`p`.`email` AS `email`,`p`.`fecha_alta` AS `fecha_alta`,count(distinct `pt`.`plan_id`) AS `planes_activos` from (`pacientes` `p` left join `planes_terapeuticos` `pt` on(`p`.`paciente_id` = `pt`.`paciente_id` and `pt`.`estado_id` = (select `estados`.`estado_id` from `estados` where `estados`.`tipo_entidad` = 'plan' and `estados`.`nombre` = 'activo'))) where `p`.`estado_id` = (select `estados`.`estado_id` from `estados` where `estados`.`tipo_entidad` = 'paciente' and `estados`.`nombre` = 'activo') group by `p`.`paciente_id`,`p`.`identificacion`,`p`.`nombre`,`p`.`apellido`,`p`.`telefono`,`p`.`email`,`p`.`fecha_alta` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `progresoPorPlan`
--

/*!50001 DROP VIEW IF EXISTS `progresoPorPlan`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb3 */;
/*!50001 SET character_set_results     = utf8mb3 */;
/*!50001 SET collation_connection      = utf8mb3_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`paliativos_user`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `progresoPorPlan` AS select `pt`.`plan_id` AS `plan_id`,concat(`p`.`nombre`,' ',`p`.`apellido`) AS `paciente`,`pt`.`fecha_inicio` AS `fecha_inicio`,`pt`.`fecha_fin_estimada` AS `fecha_fin_estimada`,count(distinct `op`.`objetivo_id`) AS `total_objetivos`,count(distinct case when `op`.`estado_id` = (select `estados`.`estado_id` from `estados` where `estados`.`tipo_entidad` = 'objetivo' and `estados`.`nombre` = 'cumplido') then `op`.`objetivo_id` end) AS `objetivos_cumplidos`,round(count(distinct case when `op`.`estado_id` = (select `estados`.`estado_id` from `estados` where `estados`.`tipo_entidad` = 'objetivo' and `estados`.`nombre` = 'cumplido') then `op`.`objetivo_id` end) * 100.0 / nullif(count(distinct `op`.`objetivo_id`),0),2) AS `porcentaje_completado`,`e`.`nombre` AS `estado` from (((`planes_terapeuticos` `pt` join `pacientes` `p` on(`pt`.`paciente_id` = `p`.`paciente_id`)) left join `objetivos_plan` `op` on(`pt`.`plan_id` = `op`.`plan_id`)) join `estados` `e` on(`pt`.`estado_id` = `e`.`estado_id`)) where `pt`.`estado_id` = (select `estados`.`estado_id` from `estados` where `estados`.`tipo_entidad` = 'plan' and `estados`.`nombre` = 'activo') group by `pt`.`plan_id`,`p`.`paciente_id`,`e`.`nombre` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2025-11-24 19:19:22
