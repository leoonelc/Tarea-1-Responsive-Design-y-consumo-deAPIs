-- SIGAT FLODECOL - Base completa desde cero (computadoras + catálogos + programas/licencias + relaciones)
DROP DATABASE IF EXISTS sigat_flodecol;
CREATE DATABASE sigat_flodecol CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE sigat_flodecol;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';
SET time_zone = '+00:00';

CREATE TABLE departamentos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  UNIQUE KEY uq_departamentos_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
CREATE TABLE responsables (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  UNIQUE KEY uq_responsables_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
CREATE TABLE ubicaciones (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(180) NOT NULL,
  UNIQUE KEY uq_ubicaciones_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
CREATE TABLE tipos_dispositivo (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL,
  UNIQUE KEY uq_tipos_dispositivo_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
CREATE TABLE programas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  UNIQUE KEY uq_programas_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
CREATE TABLE licencias (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  UNIQUE KEY uq_licencias_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
CREATE TABLE equipos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(30) NOT NULL,
  nombre VARCHAR(150) NOT NULL,
  marca VARCHAR(120) DEFAULT NULL,
  modelo VARCHAR(120) DEFAULT NULL,
  serie VARCHAR(120) DEFAULT NULL,
  id_departamento INT DEFAULT NULL,
  responsable_id INT DEFAULT NULL,
  ubicacion_antigua_id INT DEFAULT NULL,
  ubicacion_actual_id INT DEFAULT NULL,
  tipo_dispositivo_id INT DEFAULT NULL,
  nombre_dispositivo VARCHAR(150) DEFAULT NULL,
  accesorios TEXT DEFAULT NULL,
  credencial_hash VARCHAR(255) DEFAULT NULL,
  comentarios TEXT DEFAULT NULL,
  estado_equipo VARCHAR(60) DEFAULT NULL,
  estado ENUM('Activo','Dado de baja') DEFAULT 'Activo',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_equipos_codigo (codigo),
  KEY idx_equipos_dept (id_departamento),
  KEY idx_equipos_resp (responsable_id),
  KEY idx_equipos_tipo (tipo_dispositivo_id),
  CONSTRAINT fk_equipo_departamento FOREIGN KEY (id_departamento) REFERENCES departamentos(id),
  CONSTRAINT fk_equipos_responsable FOREIGN KEY (responsable_id) REFERENCES responsables(id),
  CONSTRAINT fk_equipos_ubic_ant FOREIGN KEY (ubicacion_antigua_id) REFERENCES ubicaciones(id),
  CONSTRAINT fk_equipos_ubic_act FOREIGN KEY (ubicacion_actual_id) REFERENCES ubicaciones(id),
  CONSTRAINT fk_equipos_tipo FOREIGN KEY (tipo_dispositivo_id) REFERENCES tipos_dispositivo(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
CREATE TABLE equipos_detalle_pc (
  equipo_id INT NOT NULL,
  monitor_arquitectura VARCHAR(120) DEFAULT NULL,
  modelo_monitor VARCHAR(120) DEFAULT NULL,
  serial_monitor VARCHAR(255) DEFAULT NULL,
  procesador VARCHAR(180) DEFAULT NULL,
  almacenamiento VARCHAR(120) DEFAULT NULL,
  memoria VARCHAR(80) DEFAULT NULL,
  sistema_operativo VARCHAR(120) DEFAULT NULL,
  PRIMARY KEY (equipo_id),
  CONSTRAINT fk_detalle_pc_equipo FOREIGN KEY (equipo_id) REFERENCES equipos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
CREATE TABLE equipo_red (
  equipo_id INT NOT NULL,
  ip VARCHAR(45) DEFAULT NULL,
  mac VARCHAR(30) DEFAULT NULL,
  asignacion VARCHAR(40) DEFAULT NULL,
  PRIMARY KEY (equipo_id),
  CONSTRAINT fk_red_equipo FOREIGN KEY (equipo_id) REFERENCES equipos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
CREATE TABLE equipo_programa (
  equipo_id INT NOT NULL,
  programa_id INT NOT NULL,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  version VARCHAR(60) DEFAULT NULL,
  PRIMARY KEY (equipo_id, programa_id),
  KEY idx_equipo_programa_programa (programa_id),
  CONSTRAINT fk_equipo_programa_equipo FOREIGN KEY (equipo_id) REFERENCES equipos(id) ON DELETE CASCADE,
  CONSTRAINT fk_equipo_programa_programa FOREIGN KEY (programa_id) REFERENCES programas(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
CREATE TABLE equipo_licencia (
  equipo_id INT NOT NULL,
  licencia_id INT NOT NULL,
  clave VARCHAR(220) DEFAULT NULL,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (equipo_id, licencia_id),
  KEY idx_equipo_licencia_licencia (licencia_id),
  CONSTRAINT fk_equipo_licencia_equipo FOREIGN KEY (equipo_id) REFERENCES equipos(id) ON DELETE CASCADE,
  CONSTRAINT fk_equipo_licencia_licencia FOREIGN KEY (licencia_id) REFERENCES licencias(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
CREATE TABLE mantenimiento (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_equipo INT NOT NULL,
  fecha DATE NOT NULL,
  tipo VARCHAR(50) DEFAULT NULL,
  descripcion VARCHAR(200) DEFAULT NULL,
  costo DECIMAL(10,2) DEFAULT NULL,
  KEY idx_mantenimiento_equipo (id_equipo),
  CONSTRAINT fk_mantenimiento_equipo FOREIGN KEY (id_equipo) REFERENCES equipos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
CREATE TABLE computadoras (
  id INT AUTO_INCREMENT PRIMARY KEY,
  numero INT DEFAULT NULL,
  codigo VARCHAR(30) NOT NULL,
  id_departamento INT DEFAULT NULL,
  responsable_id INT DEFAULT NULL,
  ubicacion_antigua_id INT DEFAULT NULL,
  ubicacion_actual_id INT DEFAULT NULL,
  tipo_dispositivo_id INT DEFAULT NULL,
  nombre_dispositivo VARCHAR(150) DEFAULT NULL,
  accesorios TEXT DEFAULT NULL,
  credencial_hash VARCHAR(255) DEFAULT NULL,
  estado_equipo VARCHAR(60) DEFAULT NULL,
  comentarios TEXT DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_computadoras_codigo (codigo),
  CONSTRAINT fk_pc_departamento FOREIGN KEY (id_departamento) REFERENCES departamentos(id),
  CONSTRAINT fk_pc_responsable FOREIGN KEY (responsable_id) REFERENCES responsables(id),
  CONSTRAINT fk_pc_ubic_ant FOREIGN KEY (ubicacion_antigua_id) REFERENCES ubicaciones(id),
  CONSTRAINT fk_pc_ubic_act FOREIGN KEY (ubicacion_actual_id) REFERENCES ubicaciones(id),
  CONSTRAINT fk_pc_tipo FOREIGN KEY (tipo_dispositivo_id) REFERENCES tipos_dispositivo(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
CREATE TABLE computadoras_detalle (
  computadora_id INT NOT NULL,
  monitor_arquitectura VARCHAR(120) DEFAULT NULL,
  modelo_monitor VARCHAR(120) DEFAULT NULL,
  serial_monitor VARCHAR(255) DEFAULT NULL,
  marca_equipo VARCHAR(120) DEFAULT NULL,
  modelo_equipo VARCHAR(120) DEFAULT NULL,
  serial_equipo VARCHAR(120) DEFAULT NULL,
  procesador VARCHAR(180) DEFAULT NULL,
  almacenamiento VARCHAR(120) DEFAULT NULL,
  memoria VARCHAR(80) DEFAULT NULL,
  sistema_operativo VARCHAR(120) DEFAULT NULL,
  PRIMARY KEY (computadora_id),
  CONSTRAINT fk_pc_detalle FOREIGN KEY (computadora_id) REFERENCES computadoras(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
CREATE TABLE computadoras_red (
  computadora_id INT NOT NULL,
  ip VARCHAR(45) DEFAULT NULL,
  mac VARCHAR(30) DEFAULT NULL,
  asignacion VARCHAR(40) DEFAULT NULL,
  PRIMARY KEY (computadora_id),
  CONSTRAINT fk_pc_red FOREIGN KEY (computadora_id) REFERENCES computadoras(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =========================
-- DATOS (CATÁLOGOS)
-- =========================
INSERT INTO departamentos (nombre) VALUES
('Administración'),
('Bodega'),
('Contabilidad'),
('Departamento Medico'),
('Gerencia'),
('Postcosecha'),
('Producción'),
('Sistemas')
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

INSERT INTO responsables (nombre) VALUES
('Alejandra  Cortez'),
('Alison Rodriguez'),
('Carlos Páramo'),
('Carmita Ortega'),
('Cristina Puchaicela'),
('Dayana Pineda'),
('Diego Moran'),
('Eddy Benavides'),
('Fabian Sanchez'),
('Gabriela Pineda'),
('Genesis Aguirre'),
('Jessica Elizalde'),
('Jhoe Cadena'),
('Jonny Garay'),
('Katherine  Tutillo'),
('Liliana Yanchaguano'),
('Marcela Guaman'),
('Maribel Pineda'),
('Maritza Tituaña'),
('Miguel Ortega'),
('Milena Martinez'),
('Mishelle Morejon'),
('Nancy Flores'),
('Nelly  Rodriguez'),
('Orlando Tupiza'),
('Paul Barahona'),
('Richard Artos'),
('Ruben'),
('Sabrina Ramirez'),
('Santiago Montesdeoca'),
('Selena Altamirano'),
('Vannesa Galarza')
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

INSERT INTO ubicaciones (nombre) VALUES
('Departamento Medico - Alison Rodriguez'),
('Josefina'),
('Nueva'),
('OTON 2'),
('Oton - Bodega'),
('Oton - Empaque'),
('Oton - Etiquetado'),
('Oton - Gerencia'),
('Oton - Oficina'),
('PRODUCCION OTON FERNANDA ARMIJOS'),
('Usado por Santiago Terán PRODUCCIÓN')
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

INSERT INTO tipos_dispositivo (nombre) VALUES
('Computadora escritorio'),
('Dispositivo móvil'),
('Herramienta'),
('Impresora'),
('Laboratorio'),
('Laptop'),
('Periférico'),
('Radio')
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

INSERT INTO programas (nombre) VALUES
('Adobe Acrobat DC'),
('Microsoft Office LTSC Professional Plus 2021'),
('Microsoft Office hogar y empresas 2024'),
('Microsoft Office LTSC Professional Plus 2019'),
('Microsoft Office LTSC Professional Plus 2013'),
('Nero'),
('Skype'),
('WhatsApp'),
('AnyDesk'),
('Bartender 10.1'),
('Zebra'),
('Team Viewer'),
('Nitro Pro'),
('Chrome Google'),
('Opera'),
('Adobe Reader X'),
('WinRAR'),
('Zoom')
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

INSERT INTO licencias (nombre) VALUES
('OFFICE'),
('KASPERSKY'),
('WINDOWS')
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);


-- =========================
-- DATOS (COMPUTADORAS) -> equipos + detalle + red + programas + licencias
-- credencial_hash = SHA2(valor,256) (sin guardar texto plano)
-- =========================
INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('POST-PC-001',
'Computadora',
'Computadora escritorio -Ensamblado generico',
'BIOSTAR Group  H510MH 2.1',
NULL,
(SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Orlando Tupiza' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'Bascula',
'NINGUNO',
SHA2('CAMARAS2025',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-001' LIMIT 1),
 '1 Monitor',
 'LG',
 '102NTZN9E269',
 '11th Gen Intel(R) Core(TM) i5-11400',
 '220 GB',
 '16.0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-001' LIMIT 1),
 '192168150226',
 'F4-B5-20-41-BD-1F',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-001' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-001' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-001' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Nero' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-001' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-001' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-001' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-001' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-001' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Zoom' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-001' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-001' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='KASPERSKY' LIMIT 1),
 'TWFPJ-Q56WY-P8HDZ-EKM9S',
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-001' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(1,
 'POST-PC-001',
 (SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Orlando Tupiza' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'Bascula',
 'NINGUNO',
 SHA2('CAMARAS2025',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-001' LIMIT 1),
 '1 Monitor',
 'LG',
 '102NTZN9E269',
 'Computadora escritorio -Ensamblado generico',
 'BIOSTAR Group  H510MH 2.1',
 NULL,
 '11th Gen Intel(R) Core(TM) i5-11400',
 '220 GB',
 '16.0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-001' LIMIT 1),
 '192168150226',
 'F4-B5-20-41-BD-1F',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('POST-PC-002',
'Computadora',
'DELL',
'ALLIEN',
NULL,
(SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Santiago Montesdeoca' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
'DESKTOP-45ND9LR',
'NINGUNO',
SHA2('SANTIPOST2025',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-002' LIMIT 1),
 '1 Monitor',
 'Ninguno',
 'Ninguno',
 '12th Gen Intel(R) Core(TM) i9-12900H',
 '953,50 GB / 1 TB',
 '16,0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-002' LIMIT 1),
 '192.168.150.91',
 '64-4E-D7-17-B6-08',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-002' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-002' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-002' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Nero' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-002' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-002' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-002' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-002' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-002' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Zoom' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-002' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-002' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(2,
 'POST-PC-002',
 (SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Santiago Montesdeoca' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
 'DESKTOP-45ND9LR',
 'NINGUNO',
 SHA2('SANTIPOST2025',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-002' LIMIT 1),
 '1 Monitor',
 'Ninguno',
 'Ninguno',
 'DELL',
 'ALLIEN',
 NULL,
 '12th Gen Intel(R) Core(TM) i9-12900H',
 '953,50 GB / 1 TB',
 '16,0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-002' LIMIT 1),
 '192.168.150.91',
 '64-4E-D7-17-B6-08',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('POST-PC-003',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Genesis Aguirre' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Departamento Medico - Alison Rodriguez' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'Procesos',
'NINGUNO',
SHA2('20225',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-003' LIMIT 1),
 '1 Monitor',
 'LG',
 '211NDCR9J699',
 'Intel(R) Core(TM) i3-3240 CPU',
 '222 GB',
 '8,00 GB',
 'Windows 10 Home')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-003' LIMIT 1),
 '192.168.150.218',
 '9C-53-22-86-6D-24',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-003' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-003' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-003' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-003' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-003' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Nitro Pro' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-003' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-003' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WinRAR' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-003' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-003' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(3,
 'POST-PC-003',
 (SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Genesis Aguirre' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Departamento Medico - Alison Rodriguez' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'Procesos',
 'NINGUNO',
 SHA2('20225',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-003' LIMIT 1),
 '1 Monitor',
 'LG',
 '211NDCR9J699',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Core(TM) i3-3240 CPU',
 '222 GB',
 '8,00 GB',
 'Windows 10 Home')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-003' LIMIT 1),
 '192.168.150.218',
 '9C-53-22-86-6D-24',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('POST-PC-004',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Gabriela Pineda' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'GabrielaPostcosecha',
'NINGUNO',
SHA2('FLODECOL2025',256),
'Estable y fluido',
'NUEVO -ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-004' LIMIT 1),
 '1 Monitor',
 'LG',
 '409NTDVBS762',
 'Intel(R) Core(TM) i5-10400 CPU',
 '931,50 GB / 1 TB',
 '16,0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-004' LIMIT 1),
 '192.168.150.19',
 'CC-28-AA-33-06-6F',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-004' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-004' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office hogar y empresas 2024' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-004' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-004' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Bartender 10.1' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-004' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Zebra' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-004' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-004' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Zoom' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-004' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-004' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='KASPERSKY' LIMIT 1),
 'SHZW3-6FEFC-WTS7X-N11MY',
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-004' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(4,
 'POST-PC-004',
 (SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Gabriela Pineda' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'GabrielaPostcosecha',
 'NINGUNO',
 SHA2('FLODECOL2025',256),
 'NUEVO -ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-004' LIMIT 1),
 '1 Monitor',
 'LG',
 '409NTDVBS762',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Core(TM) i5-10400 CPU',
 '931,50 GB / 1 TB',
 '16,0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-004' LIMIT 1),
 '192.168.150.19',
 'CC-28-AA-33-06-6F',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('POST-PC-005',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Eddy Benavides' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'ETIQUETAS',
'NINGUNO',
SHA2('EMPAQUE2025',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-005' LIMIT 1),
 '2 Monitores',
 'SAMSUNG - LG',
 '805NT PC30792 / 029GHCKF601671B',
 'Intel(R) Core(TM) i7-8700 CPU',
 '894,25GB / 1TB',
 '32,0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-005' LIMIT 1),
 '192168150241',
 '30-9C-23-AB-6E-C7',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-005' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-005' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-005' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Nero' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-005' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-005' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-005' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Bartender 10.1' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-005' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Zebra' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-005' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Team Viewer' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-005' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-005' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Zoom' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-005' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-005' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(5,
 'POST-PC-005',
 (SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Eddy Benavides' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'ETIQUETAS',
 'NINGUNO',
 SHA2('EMPAQUE2025',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-005' LIMIT 1),
 '2 Monitores',
 'SAMSUNG - LG',
 '805NT PC30792 / 029GHCKF601671B',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Core(TM) i7-8700 CPU',
 '894,25GB / 1TB',
 '32,0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-005' LIMIT 1),
 '192168150241',
 '30-9C-23-AB-6E-C7',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('POST-PC-006',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Eddy Benavides' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Empaque' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Empaque' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'FRIOMASTER',
'NINGUNO',
SHA2('1182',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-006' LIMIT 1),
 '1 Monitor',
 'LG',
 '102NTZN9E269',
 'Intel(R) Celeron(R) CPU J3455',
 '111 GB',
 '4,00 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-006' LIMIT 1),
 '192.168.150.8',
 '94-C6-91-A0-33-47',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-006' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-006' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2019' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-006' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-006' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-006' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-006' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Bartender 10.1' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-006' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Zebra' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-006' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-006' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-006' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(6,
 'POST-PC-006',
 (SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Eddy Benavides' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Empaque' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Empaque' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'FRIOMASTER',
 'NINGUNO',
 SHA2('1182',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-006' LIMIT 1),
 '1 Monitor',
 'LG',
 '102NTZN9E269',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Celeron(R) CPU J3455',
 '111 GB',
 '4,00 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-006' LIMIT 1),
 '192.168.150.8',
 '94-C6-91-A0-33-47',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('POST-PC-007',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Eddy Benavides' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Empaque' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Empaque' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'CF1',
'NINGUNO',
SHA2('CF12025',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-007' LIMIT 1),
 '2 Monitor',
 'LG',
 'ZWZ8H4LD304176E',
 'Intel(R) Core(TM) i5-10400 CPU',
 '501 GB',
 '16,0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-007' LIMIT 1),
 '192.168.1.223',
 '30-16-9D-39-DF-29',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-007' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-007' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-007' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-007' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-007' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-007' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(7,
 'POST-PC-007',
 (SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Eddy Benavides' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Empaque' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Empaque' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'CF1',
 'NINGUNO',
 SHA2('CF12025',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-007' LIMIT 1),
 '2 Monitor',
 'LG',
 'ZWZ8H4LD304176E',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Core(TM) i5-10400 CPU',
 '501 GB',
 '16,0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-007' LIMIT 1),
 '192.168.1.223',
 '30-16-9D-39-DF-29',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('POST-PC-008',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Eddy Benavides' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Empaque' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Empaque' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'ESTACION3',
'NINGUNO',
SHA2('FLODECOL2025',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-008' LIMIT 1),
 '1 Monitor',
 'LG',
 '805NTXRFG954',
 'Intel(R) Celeron(R) CPU J3455',
 '119.3',
 '4,00 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-008' LIMIT 1),
 '192.168.1.35',
 '38-DE-AD-18-0F-6F',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-008' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-008' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-008' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-008' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Bartender 10.1' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-008' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Zebra' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-008' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Team Viewer' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-008' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-008' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-008' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(8,
 'POST-PC-008',
 (SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Eddy Benavides' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Empaque' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Empaque' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'ESTACION3',
 'NINGUNO',
 SHA2('FLODECOL2025',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-008' LIMIT 1),
 '1 Monitor',
 'LG',
 '805NTXRFG954',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Celeron(R) CPU J3455',
 '119.3',
 '4,00 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-008' LIMIT 1),
 '192.168.1.35',
 '38-DE-AD-18-0F-6F',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('POST-PC-009',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Eddy Benavides' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Empaque' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Empaque' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'ESTACION2',
'NINGUNO',
SHA2('FLODECOL2025',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-009' LIMIT 1),
 '1 Monitor',
 'LG',
 '805NTFAFG955',
 'Intel(R) Celeron(R) CPU J3455',
 '117.3',
 '4,00 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-009' LIMIT 1),
 '192168150194',
 '94-C6-91-A0-32-03',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-009' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-009' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-009' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-009' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Bartender 10.1' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-009' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Zebra' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-009' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Team Viewer' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-009' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-009' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-009' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(9,
 'POST-PC-009',
 (SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Eddy Benavides' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Empaque' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Empaque' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'ESTACION2',
 'NINGUNO',
 SHA2('FLODECOL2025',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-009' LIMIT 1),
 '1 Monitor',
 'LG',
 '805NTFAFG955',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Celeron(R) CPU J3455',
 '117.3',
 '4,00 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-009' LIMIT 1),
 '192168150194',
 '94-C6-91-A0-32-03',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('POST-PC-010',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Maribel Pineda' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Etiquetado' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Etiquetado' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'ETIQUETAS2',
'NINGUNO',
SHA2('FLODECOL2025+',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-010' LIMIT 1),
 '1 Monitor',
 'ASUS',
 'HCLMTF101551',
 'Intel(R) Celeron(R) CPU J3454',
 '292 GB',
 '16,0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-010' LIMIT 1),
 '192168150160',
 '40-A8-F0-A3-F0-A8',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-010' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-010' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Nero' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-010' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-010' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-010' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Bartender 10.1' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-010' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-010' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-010' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(10,
 'POST-PC-010',
 (SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Maribel Pineda' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Etiquetado' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Etiquetado' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'ETIQUETAS2',
 'NINGUNO',
 SHA2('FLODECOL2025+',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-010' LIMIT 1),
 '1 Monitor',
 'ASUS',
 'HCLMTF101551',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Celeron(R) CPU J3454',
 '292 GB',
 '16,0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-010' LIMIT 1),
 '192168150160',
 '40-A8-F0-A3-F0-A8',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('POST-PC-011',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Maribel Pineda' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Etiquetado' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Etiquetado' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'ETIQUETAS1',
'NINGUNO',
SHA2('FLODECOL2025+',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-011' LIMIT 1),
 '1 Monitor',
 'ASUS',
 'HCLMTF101558',
 'Intel(R) Celeron(R) CPU J3455',
 '111 GB',
 '4,00 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-011' LIMIT 1),
 '192168150170',
 '94-C6-91-A0-31-A4',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-011' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-011' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Nero' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-011' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-011' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-011' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Bartender 10.1' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-011' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-011' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-011' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(11,
 'POST-PC-011',
 (SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Maribel Pineda' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Etiquetado' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Etiquetado' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'ETIQUETAS1',
 'NINGUNO',
 SHA2('FLODECOL2025+',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-011' LIMIT 1),
 '1 Monitor',
 'ASUS',
 'HCLMTF101558',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Celeron(R) CPU J3455',
 '111 GB',
 '4,00 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-011' LIMIT 1),
 '192168150170',
 '94-C6-91-A0-31-A4',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('POST-PC-012',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Maribel Pineda' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'SUPERVISORA',
'NINGUNO',
SHA2('Maribel2025',256),
'Estable y fluido',
'NUEVO -ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-012' LIMIT 1),
 '1 Monitor',
 'LG',
 '005NDFV7K539',
 'Intel(R) Core(TM) i5-10400 CPU @ 2.90GHz   2.90 GHz',
 '292 GB',
 '16 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-012' LIMIT 1),
 '192168150149',
 '94-DE-80-8B-AE-4D',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-012' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-012' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-012' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Nero' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-012' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-012' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-012' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-012' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Zoom' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-012' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-012' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(12,
 'POST-PC-012',
 (SELECT id FROM departamentos WHERE nombre='Postcosecha' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Maribel Pineda' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'SUPERVISORA',
 'NINGUNO',
 SHA2('Maribel2025',256),
 'NUEVO -ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-012' LIMIT 1),
 '1 Monitor',
 'LG',
 '005NDFV7K539',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Core(TM) i5-10400 CPU @ 2.90GHz   2.90 GHz',
 '292 GB',
 '16 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-012' LIMIT 1),
 '192168150149',
 '94-DE-80-8B-AE-4D',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('MED-PC-013',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Departamento Medico' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Jessica Elizalde' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'Enfermeria',
'NINGUNO',
SHA2('202310',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-013' LIMIT 1),
 '1 Monitor',
 'AOC',
 'DTLD41A009447',
 'Intel(R) Core(TM) i3-7100 CPU',
 '500 GB',
 '12,0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-013' LIMIT 1),
 '192.168.1.120',
 '40-ED-00-DE-8B-22',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-013' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-013' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-013' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Nero' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-013' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-013' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-013' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-013' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Nitro Pro' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-013' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-013' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WinRAR' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-013' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-013' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='KASPERSKY' LIMIT 1),
 'W8J34-NYBSN-VYAC-RN5DS',
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-013' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(13,
 'MED-PC-013',
 (SELECT id FROM departamentos WHERE nombre='Departamento Medico' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Jessica Elizalde' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'Enfermeria',
 'NINGUNO',
 SHA2('202310',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='MED-PC-013' LIMIT 1),
 '1 Monitor',
 'AOC',
 'DTLD41A009447',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Core(TM) i3-7100 CPU',
 '500 GB',
 '12,0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='MED-PC-013' LIMIT 1),
 '192.168.1.120',
 '40-ED-00-DE-8B-22',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('MED-PC-014',
'Computadora',
'HP',
'RTL 8822CE',
'CND3223W2Q',
(SELECT id FROM departamentos WHERE nombre='Departamento Medico' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Alison Rodriguez' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Usado por Santiago Terán PRODUCCIÓN' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
'DEP-MEDICO',
'NINGUNO',
SHA2('202310',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-014' LIMIT 1),
 'Ninguno',
 'Ninguno',
 'Ninguno',
 '11th Gen Intel(R) Core(TM) i5-1135G7',
 '250 GB',
 '16.0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-014' LIMIT 1),
 '192.168.150.253',
 'BC-0F-F3-5D-AD-B8',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-014' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-014' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-014' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-014' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-014' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-014' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-014' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='KASPERSKY' LIMIT 1),
 'H4SJU-VRDB3-7DTTU-3GU2A',
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='MED-PC-014' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(14,
 'MED-PC-014',
 (SELECT id FROM departamentos WHERE nombre='Departamento Medico' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Alison Rodriguez' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Usado por Santiago Terán PRODUCCIÓN' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
 'DEP-MEDICO',
 'NINGUNO',
 SHA2('202310',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='MED-PC-014' LIMIT 1),
 'Ninguno',
 'Ninguno',
 'Ninguno',
 'HP',
 'RTL 8822CE',
 'CND3223W2Q',
 '11th Gen Intel(R) Core(TM) i5-1135G7',
 '250 GB',
 '16.0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='MED-PC-014' LIMIT 1),
 '192.168.150.253',
 'BC-0F-F3-5D-AD-B8',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('PRO-PC-015',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Producción' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Milena Martinez' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='PRODUCCION OTON FERNANDA ARMIJOS' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='OTON 2' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'DESKTOP-0SDRQ5R',
'NINGUNO',
SHA2('FLODECOL2025+',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-015' LIMIT 1),
 '1 Monitor',
 'LG',
 '210NTAB8F128',
 'Intel(R) Core(TM) i3-10105 CPU',
 '500 GB',
 '16,0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-015' LIMIT 1),
 '192.168.150.38',
 'F4-B5-20-4E-5D-90',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-015' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-015' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-015' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-015' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-015' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-015' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-015' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Zoom' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-015' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-015' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(15,
 'PRO-PC-015',
 (SELECT id FROM departamentos WHERE nombre='Producción' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Milena Martinez' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='PRODUCCION OTON FERNANDA ARMIJOS' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='OTON 2' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'DESKTOP-0SDRQ5R',
 'NINGUNO',
 SHA2('FLODECOL2025+',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='PRO-PC-015' LIMIT 1),
 '1 Monitor',
 'LG',
 '210NTAB8F128',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Core(TM) i3-10105 CPU',
 '500 GB',
 '16,0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='PRO-PC-015' LIMIT 1),
 '192.168.150.38',
 'F4-B5-20-4E-5D-90',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('PRO-PC-016',
'Computadora',
'DELL',
'INSPIRON 3530',
'G91K594',
(SELECT id FROM departamentos WHERE nombre='Producción' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Richard Artos' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
NULL,
'FUNDA PROTECTORA',
NULL,
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-016' LIMIT 1),
 'Ninguno',
 'Ninguno',
 'Ninguno',
 'Intel(R) Core(TM) i5-1035G1 CPU',
 '250 GB',
 '8,0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-016' LIMIT 1),
 '192.168.150.32',
 NULL,
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-016' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-016' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office hogar y empresas 2024' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-016' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-016' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-016' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WinRAR' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-016' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-016' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='KASPERSKY' LIMIT 1),
 'W5XQW-C5X8R-B4ZNE-5N75R',
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-016' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(16,
 'PRO-PC-016',
 (SELECT id FROM departamentos WHERE nombre='Producción' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Richard Artos' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
 NULL,
 'FUNDA PROTECTORA',
 NULL,
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='PRO-PC-016' LIMIT 1),
 'Ninguno',
 'Ninguno',
 'Ninguno',
 'DELL',
 'INSPIRON 3530',
 'G91K594',
 'Intel(R) Core(TM) i5-1035G1 CPU',
 '250 GB',
 '8,0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='PRO-PC-016' LIMIT 1),
 '192.168.150.32',
 NULL,
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('PRO-PC-017',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Producción' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Ruben' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'RIEGO-PC',
'NINGUNO',
SHA2('S/N',256),
'Estable y fluido',
'EXCEPCIÓN',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-017' LIMIT 1),
 '1 Monitor',
 'LG',
 'S0196HA003276',
 'Intel(R) Core(TM) i5-4460 CPU',
 '1.7 TB',
 '16,0 GB',
 'Windows 7 Ultimate')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-017' LIMIT 1),
 '192.168.150.199',
 'FC-77-74-A6-89-93',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-017' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-017' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2013' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-017' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-017' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-017' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Team Viewer' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-017' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Nitro Pro' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-017' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-017' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WinRAR' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-017' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-017' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(17,
 'PRO-PC-017',
 (SELECT id FROM departamentos WHERE nombre='Producción' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Ruben' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'RIEGO-PC',
 'NINGUNO',
 SHA2('S/N',256),
 'EXCEPCIÓN',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='PRO-PC-017' LIMIT 1),
 '1 Monitor',
 'LG',
 'S0196HA003276',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Core(TM) i5-4460 CPU',
 '1.7 TB',
 '16,0 GB',
 'Windows 7 Ultimate')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='PRO-PC-017' LIMIT 1),
 '192.168.150.199',
 'FC-77-74-A6-89-93',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('PRO-PC-018',
'Computadora',
'DELL',
'INSPIRON 5593',
'8RQW943',
(SELECT id FROM departamentos WHERE nombre='Producción' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Carlos Páramo' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
'CARLOS',
'NINGUNO',
SHA2('3264',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-018' LIMIT 1),
 'Ninguno',
 'Ninguno',
 'Ninguno',
 'Intel(R) Core(TM) i7-1065G7 CPU @ 1.30GHz',
 '462 GB (SSD M.2)',
 '8 GB',
 'Windows 11 Enterprice')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-018' LIMIT 1),
 '192168150156',
 NULL,
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-018' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-018' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-018' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-018' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-018' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-018' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-018' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-018' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='KASPERSKY' LIMIT 1),
 'PGK57-828ZH-PGHMC-AHPDV',
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-018' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(18,
 'PRO-PC-018',
 (SELECT id FROM departamentos WHERE nombre='Producción' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Carlos Páramo' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
 'CARLOS',
 'NINGUNO',
 SHA2('3264',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='PRO-PC-018' LIMIT 1),
 'Ninguno',
 'Ninguno',
 'Ninguno',
 'DELL',
 'INSPIRON 5593',
 '8RQW943',
 'Intel(R) Core(TM) i7-1065G7 CPU @ 1.30GHz',
 '462 GB (SSD M.2)',
 '8 GB',
 'Windows 11 Enterprice')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='PRO-PC-018' LIMIT 1),
 '192168150156',
 NULL,
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('PRO-PC-019',
'Computadora',
'Computadora escritorio -Ensamblado generico',
'ASUSTeK COMPUTER INC.  PRIME H310M-E R2.0',
'190551513310186',
(SELECT id FROM departamentos WHERE nombre='Producción' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Maritza Tituaña' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'PRODUCCION',
'NINGUNO',
SHA2('PRODUCCION2025',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-019' LIMIT 1),
 '1 Monitor',
 'LG',
 'ZZNLH4ZM401713V',
 'Intel(R) Core(TM) i5-9400 CPU',
 '1,5 TB',
 '8,00 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-019' LIMIT 1),
 '192.168.150.45',
 '04-D9-F5-36-24-96',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-019' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-019' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2019' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-019' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-019' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Team Viewer' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-019' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-019' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WinRAR' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-019' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-019' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='KASPERSKY' LIMIT 1),
 'K8YRB-J4XK5-NUQVU-7B7PQ',
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-019' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(19,
 'PRO-PC-019',
 (SELECT id FROM departamentos WHERE nombre='Producción' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Maritza Tituaña' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'PRODUCCION',
 'NINGUNO',
 SHA2('PRODUCCION2025',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='PRO-PC-019' LIMIT 1),
 '1 Monitor',
 'LG',
 'ZZNLH4ZM401713V',
 'Computadora escritorio -Ensamblado generico',
 'ASUSTeK COMPUTER INC.  PRIME H310M-E R2.0',
 '190551513310186',
 'Intel(R) Core(TM) i5-9400 CPU',
 '1,5 TB',
 '8,00 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='PRO-PC-019' LIMIT 1),
 '192.168.150.45',
 '04-D9-F5-36-24-96',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('PRO-PC-020',
'Computadora',
'DELL',
'DELL INSPIRON 15- 3535',
'HGD41C4',
(SELECT id FROM departamentos WHERE nombre='Producción' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Cristina Puchaicela' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Nueva' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Josefina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
'TECNICO JOSEFINA',
'MOCHILA',
SHA2('JOSEFINA2025',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-020' LIMIT 1),
 'Ninguno',
 'Ninguno',
 'Ninguno',
 'AMD Ryzen 5 7530U Processor (Processeur Ryzen 5 7530U d AMD)',
 '1TB',
 '8,00 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-020' LIMIT 1),
 'Dinamico',
 '04-D9-F5-36-24-96',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-020' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office hogar y empresas 2024' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-020' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-020' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Team Viewer' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-020' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-020' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WinRAR' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-020' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='PRO-PC-020' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(20,
 'PRO-PC-020',
 (SELECT id FROM departamentos WHERE nombre='Producción' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Cristina Puchaicela' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Nueva' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Josefina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
 'TECNICO JOSEFINA',
 'MOCHILA',
 SHA2('JOSEFINA2025',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='PRO-PC-020' LIMIT 1),
 'Ninguno',
 'Ninguno',
 'Ninguno',
 'DELL',
 'DELL INSPIRON 15- 3535',
 'HGD41C4',
 'AMD Ryzen 5 7530U Processor (Processeur Ryzen 5 7530U d AMD)',
 '1TB',
 '8,00 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='PRO-PC-020' LIMIT 1),
 'Dinamico',
 '04-D9-F5-36-24-96',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('ADM-PC-021',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Nelly  Rodriguez' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'COMPRAS',
'NINGUNO',
SHA2('2310',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-021' LIMIT 1),
 '1 Monitor',
 'LG',
 'ZZNLH4ZM400388P',
 'Intel(R) Core(TM) i7-6700 CPU',
 '1,5 TB',
 '16.0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-021' LIMIT 1),
 '192.168.150.15',
 '40-8D-5C-73-DF-97',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-021' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-021' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-021' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-021' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-021' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-021' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WinRAR' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-021' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-021' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(21,
 'ADM-PC-021',
 (SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Nelly  Rodriguez' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'COMPRAS',
 'NINGUNO',
 SHA2('2310',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-021' LIMIT 1),
 '1 Monitor',
 'LG',
 'ZZNLH4ZM400388P',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Core(TM) i7-6700 CPU',
 '1,5 TB',
 '16.0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-021' LIMIT 1),
 '192.168.150.15',
 '40-8D-5C-73-DF-97',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('ADM-PC-022',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Carmita Ortega' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'CARMITA',
'NINGUNO',
SHA2('CARMITA2025',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-022' LIMIT 1),
 '1 Monitor',
 'LG',
 '805UXTC4R193',
 'Intel(R) Core(TM) i5-9400 CPU',
 '1,5 TB',
 '8.00 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-022' LIMIT 1),
 '192.168.150.52',
 '04-D9-F5-5F-C5-AB',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-022' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-022' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-022' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-022' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-022' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-022' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Team Viewer' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-022' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-022' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Zoom' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-022' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-022' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='KASPERSKY' LIMIT 1),
 'WDWKX-11AD3-XVR5V-XEFR8',
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-022' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(22,
 'ADM-PC-022',
 (SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Carmita Ortega' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'CARMITA',
 'NINGUNO',
 SHA2('CARMITA2025',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-022' LIMIT 1),
 '1 Monitor',
 'LG',
 '805UXTC4R193',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Core(TM) i5-9400 CPU',
 '1,5 TB',
 '8.00 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-022' LIMIT 1),
 '192.168.150.52',
 '04-D9-F5-5F-C5-AB',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('ADM-PC-023',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Katherine  Tutillo' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'DESKTOP-280UKVD',
'NINGUNO',
SHA2('KATY2024',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-023' LIMIT 1),
 '1 Monitor',
 'LG',
 '3CQ647127W',
 'Intel(R) Core(TM) i7-9700 CPU',
 '233 GB',
 '16.0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-023' LIMIT 1),
 '192.168.150.8',
 'A8-A1-59-56-BC-BA',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-023' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-023' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-023' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-023' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-023' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-023' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Team Viewer' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-023' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-023' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Zoom' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-023' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-023' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='KASPERSKY' LIMIT 1),
 'GD1AR-BMYXN-Q2ZNZ-2NQNN',
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-023' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(23,
 'ADM-PC-023',
 (SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Katherine  Tutillo' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'DESKTOP-280UKVD',
 'NINGUNO',
 SHA2('KATY2024',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-023' LIMIT 1),
 '1 Monitor',
 'LG',
 '3CQ647127W',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Core(TM) i7-9700 CPU',
 '233 GB',
 '16.0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-023' LIMIT 1),
 '192.168.150.8',
 'A8-A1-59-56-BC-BA',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('ADM-PC-024',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Liliana Yanchaguano' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'RRHH',
'NINGUNO',
SHA2('2001',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-024' LIMIT 1),
 '1 Monitor',
 'LG',
 '006UXWE1V881',
 'Intel(R) Core(TM) i5-3470 CPU',
 '1,5 TB',
 '10.0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-024' LIMIT 1),
 '192.168.150.5',
 '4C-72-B9-24-A3-A7',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-024' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-024' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-024' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-024' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-024' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-024' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Team Viewer' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-024' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-024' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Zoom' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-024' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-024' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='KASPERSKY' LIMIT 1),
 '7SCHF-BG397-XUB8K-RWSNY',
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-024' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(24,
 'ADM-PC-024',
 (SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Liliana Yanchaguano' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'RRHH',
 'NINGUNO',
 SHA2('2001',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-024' LIMIT 1),
 '1 Monitor',
 'LG',
 '006UXWE1V881',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Core(TM) i5-3470 CPU',
 '1,5 TB',
 '10.0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-024' LIMIT 1),
 '192.168.150.5',
 '4C-72-B9-24-A3-A7',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('ADM-PC-025',
'Computadora',
'HP',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Miguel Ortega' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
'DESKTOP-CDDNUV6',
'NINGUNO',
SHA2('MIGUEL1976',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-025' LIMIT 1),
 'ACTUALIZADO',
 'Ninguno',
 'Ninguno',
 '11th Gen Intel(R) Core(TM) i5-1135G7',
 '476.9 GB',
 '16.0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-025' LIMIT 1),
 NULL,
 'BC-0F-F3-5D-AE-FF',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-025' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-025' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-025' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-025' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-025' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-025' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(25,
 'ADM-PC-025',
 (SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Miguel Ortega' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
 'DESKTOP-CDDNUV6',
 'NINGUNO',
 SHA2('MIGUEL1976',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-025' LIMIT 1),
 'ACTUALIZADO',
 'Ninguno',
 'Ninguno',
 'HP',
 NULL,
 NULL,
 '11th Gen Intel(R) Core(TM) i5-1135G7',
 '476.9 GB',
 '16.0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-025' LIMIT 1),
 NULL,
 'BC-0F-F3-5D-AE-FF',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('ADM-PC-026',
'Computadora',
'LENOVO',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Selena Altamirano' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
'DESKTOP-CDDNUV6',
'NINGUNO',
SHA2('Ninguna',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-026' LIMIT 1),
 'Ninguno',
 'LG',
 'Ninguno',
 'Intel(R) Core(TM) i7 @ 1.8GHz',
 '256 GB (SSD M.2)',
 '8 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-026' LIMIT 1),
 '192.168.150.56',
 NULL,
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-026' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-026' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-026' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-026' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-026' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-026' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-026' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-026' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(26,
 'ADM-PC-026',
 (SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Selena Altamirano' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
 'DESKTOP-CDDNUV6',
 'NINGUNO',
 SHA2('Ninguna',256),
 'ACTUALIZADO',
 'ROBADA')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-026' LIMIT 1),
 'Ninguno',
 'LG',
 'Ninguno',
 'LENOVO',
 NULL,
 NULL,
 'Intel(R) Core(TM) i7 @ 1.8GHz',
 '256 GB (SSD M.2)',
 '8 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-026' LIMIT 1),
 '192.168.150.56',
 NULL,
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('ADM-PC-027',
'Computadora',
'DELL',
'INSPIRON 3530',
'FMFJ594',
(SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Fabian Sanchez' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
'VENTAS',
'FUNDA PROTECTORA',
SHA2('FOSV',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-027' LIMIT 1),
 'Ninguno',
 'LG',
 NULL,
 'Intel(R) Core(TM) i5-5200U @ 2.20GHz',
 '500 GB (SSD SATA)',
 '10.0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-027' LIMIT 1),
 '192.168.150.78',
 NULL,
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-027' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-027' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-027' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-027' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-027' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-027' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-027' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-027' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(27,
 'ADM-PC-027',
 (SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Fabian Sanchez' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
 'VENTAS',
 'FUNDA PROTECTORA',
 SHA2('FOSV',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-027' LIMIT 1),
 'Ninguno',
 'LG',
 NULL,
 'DELL',
 'INSPIRON 3530',
 'FMFJ594',
 'Intel(R) Core(TM) i5-5200U @ 2.20GHz',
 '500 GB (SSD SATA)',
 '10.0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-027' LIMIT 1),
 '192.168.150.78',
 NULL,
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('ADM-PC-028',
'Computadora',
'DELL',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Nancy Flores' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
'DESKTOP-CDDNUV6',
'NINGUNO',
SHA2('1996',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-028' LIMIT 1),
 'Ninguno',
 'LG',
 'Ninguno',
 'Intel(R) Core(TM) i7 (10ª Gen)',
 '256 GB (SSD M.2)',
 '8 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-028' LIMIT 1),
 '192.168.150.79',
 NULL,
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-028' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-028' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-028' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-028' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-028' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-028' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-028' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-028' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(28,
 'ADM-PC-028',
 (SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Nancy Flores' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
 'DESKTOP-CDDNUV6',
 'NINGUNO',
 SHA2('1996',256),
 'ACTUALIZADO',
 'ROBADA')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-028' LIMIT 1),
 'Ninguno',
 'LG',
 'Ninguno',
 'DELL',
 NULL,
 NULL,
 'Intel(R) Core(TM) i7 (10ª Gen)',
 '256 GB (SSD M.2)',
 '8 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-028' LIMIT 1),
 '192.168.150.79',
 NULL,
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('ADM-PC-029',
'Computadora',
'DELL',
'DELL INSPIRON  3530',
'7ZQH594',
(SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Jonny Garay' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
'DESKTOP-CDDNUV6',
'FUNDA PROTECTORA',
SHA2('Ironhenrt2323',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-029' LIMIT 1),
 'Ninguno',
 'LG',
 'Ninguno',
 '13th Gen Intel(R) Core(TM) i5-1235U   1.30 GHz',
 '1TB + 500GB',
 '16.0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-029' LIMIT 1),
 '192.168.150.32',
 NULL,
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-029' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-029' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-029' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-029' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-029' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-029' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-029' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-029' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(29,
 'ADM-PC-029',
 (SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Jonny Garay' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
 'DESKTOP-CDDNUV6',
 'FUNDA PROTECTORA',
 SHA2('Ironhenrt2323',256),
 'ACTUALIZADO',
 'ROBADA')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-029' LIMIT 1),
 'Ninguno',
 'LG',
 'Ninguno',
 'DELL',
 'DELL INSPIRON  3530',
 '7ZQH594',
 '13th Gen Intel(R) Core(TM) i5-1235U   1.30 GHz',
 '1TB + 500GB',
 '16.0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-029' LIMIT 1),
 '192.168.150.32',
 NULL,
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('ADM-PC-034',
'Computadora',
'DELL',
'INSPIRON 3220',
'J7PB754',
(SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Marcela Guaman' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
'TRABAJO-SOCIAL',
'NINGUNO',
SHA2('1989',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-034' LIMIT 1),
 'Ninguno',
 'Ninguno',
 'Ninguno',
 '12th Gen Intel(R) Core(TM) i5-1235U   1.30 GHz',
 '477 GB',
 '16,0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-034' LIMIT 1),
 '192.168.150.68',
 NULL,
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-034' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-034' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Nero' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-034' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-034' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-034' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Nitro Pro' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-034' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Reader X' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-034' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Zoom' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-034' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-034' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='KASPERSKY' LIMIT 1),
 'QB4KB-VDJ23-NBU9D-YMY75',
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-034' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(30,
 'ADM-PC-034',
 (SELECT id FROM departamentos WHERE nombre='Administración' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Marcela Guaman' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
 'TRABAJO-SOCIAL',
 'NINGUNO',
 SHA2('1989',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-034' LIMIT 1),
 'Ninguno',
 'Ninguno',
 'Ninguno',
 'DELL',
 'INSPIRON 3220',
 'J7PB754',
 '12th Gen Intel(R) Core(TM) i5-1235U   1.30 GHz',
 '477 GB',
 '16,0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-034' LIMIT 1),
 '192.168.150.68',
 NULL,
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('ADM-PC-035',
'Computadora',
'AZUS',
'ASUS VIVOBOOK 16X OLED',
'S2N0CX03305507A',
(SELECT id FROM departamentos WHERE nombre='Contabilidad' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Alejandra  Cortez' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
'Alejandra',
'MOCHILA',
SHA2('ALEJANDRA2025',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-035' LIMIT 1),
 'ACTUALIZADO',
 'ViewSonic',
 'X6A2343A0531',
 'Intel(R) Core(TM) i7-1065G7',
 '1 TB',
 '16.0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-035' LIMIT 1),
 NULL,
 NULL,
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-035' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-035' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-035' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-035' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-035' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Team Viewer' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-035' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Nitro Pro' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-035' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Reader X' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-035' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='KASPERSKY' LIMIT 1),
 'NF2PQ-MZ933-DFMJ8-J7J2T',
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(31,
 'ADM-PC-035',
 (SELECT id FROM departamentos WHERE nombre='Contabilidad' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Alejandra  Cortez' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
 'Alejandra',
 'MOCHILA',
 SHA2('ALEJANDRA2025',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-035' LIMIT 1),
 'ACTUALIZADO',
 'ViewSonic',
 'X6A2343A0531',
 'AZUS',
 'ASUS VIVOBOOK 16X OLED',
 'S2N0CX03305507A',
 'Intel(R) Core(TM) i7-1065G7',
 '1 TB',
 '16.0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-035' LIMIT 1),
 NULL,
 NULL,
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('ADM-PC-036',
'Computadora',
'DELL',
'DELL INSPIRON',
'298R943',
(SELECT id FROM departamentos WHERE nombre='Contabilidad' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Mishelle Morejon' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
'GESTION 1',
'NINGUNO',
SHA2('GESTION2025',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-036' LIMIT 1),
 NULL,
 NULL,
 NULL,
 'Intel(R) Core(TM) i7-1065G7',
 '1 TB',
 '16.0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-036' LIMIT 1),
 '192.168.150.7',
 '5C-92-5E-D6-ED-D6',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-036' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-036' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-036' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-036' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-036' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Team Viewer' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-036' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Nitro Pro' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-036' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Reader X' LIMIT 1),
 1);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(32,
 'ADM-PC-036',
 (SELECT id FROM departamentos WHERE nombre='Contabilidad' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Mishelle Morejon' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
 'GESTION 1',
 'NINGUNO',
 SHA2('GESTION2025',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-036' LIMIT 1),
 NULL,
 NULL,
 NULL,
 'DELL',
 'DELL INSPIRON',
 '298R943',
 'Intel(R) Core(TM) i7-1065G7',
 '1 TB',
 '16.0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-036' LIMIT 1),
 '192.168.150.7',
 '5C-92-5E-D6-ED-D6',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('CONTA-PC-033',
'Computadora',
NULL,
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Contabilidad' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Sabrina Ramirez' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'RESPALDOSERVER',
'NINGUNO',
SHA2('SDRL2025',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-033' LIMIT 1),
 '1 Monitor',
 'ViewSonic',
 'X6A2343A0013',
 '11th Gen Intel(R) Core(TM) i5-11400',
 '1 TB',
 '16.0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-033' LIMIT 1),
 '192.168.150.156',
 'F4-B5-20-41-BD-1D',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-033' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-033' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-033' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-033' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-033' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-033' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-033' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WinRAR' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-033' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-033' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='KASPERSKY' LIMIT 1),
 'VFHA8-TACYM-959WC-8PHED',
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-033' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(33,
 'CONTA-PC-033',
 (SELECT id FROM departamentos WHERE nombre='Contabilidad' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Sabrina Ramirez' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'RESPALDOSERVER',
 'NINGUNO',
 SHA2('SDRL2025',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='CONTA-PC-033' LIMIT 1),
 '1 Monitor',
 'ViewSonic',
 'X6A2343A0013',
 NULL,
 NULL,
 NULL,
 '11th Gen Intel(R) Core(TM) i5-11400',
 '1 TB',
 '16.0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='CONTA-PC-033' LIMIT 1),
 '192.168.150.156',
 'F4-B5-20-41-BD-1D',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('CONTA-PC-034',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Contabilidad' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Vannesa Galarza' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'DESKTOP-E6TB91O',
'NINGUNO',
SHA2('VANE2025',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-034' LIMIT 1),
 '1 Monitor',
 'ViewSonic',
 'X6A2343A0530',
 '12th Gen Intel(R) Core(TM) i5-12400',
 '465 GB',
 '8.00 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-034' LIMIT 1),
 '192.168.150.77',
 'E8-9C-25-C7-20-29',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-034' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-034' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-034' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-034' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-034' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-034' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-034' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WinRAR' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-034' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-034' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='KASPERSKY' LIMIT 1),
 'WDR67-UFCDR-HJH9Q-CPSKS',
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='CONTA-PC-034' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(34,
 'CONTA-PC-034',
 (SELECT id FROM departamentos WHERE nombre='Contabilidad' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Vannesa Galarza' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'DESKTOP-E6TB91O',
 'NINGUNO',
 SHA2('VANE2025',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='CONTA-PC-034' LIMIT 1),
 '1 Monitor',
 'ViewSonic',
 'X6A2343A0530',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 '12th Gen Intel(R) Core(TM) i5-12400',
 '465 GB',
 '8.00 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='CONTA-PC-034' LIMIT 1),
 '192.168.150.77',
 'E8-9C-25-C7-20-29',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('SIS-PC-035',
'Computadora',
'DELL',
'DELL',
'65H3963',
(SELECT id FROM departamentos WHERE nombre='Sistemas' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Jhoe Cadena' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
'SISTEMAS',
'NINGUNO',
SHA2('SISTEMAS2001',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='SIS-PC-035' LIMIT 1),
 '1 Monitor',
 'Ninguno',
 'Ninguno',
 '11th Gen Intel(R) Core(TM) i7-1165G7 @ 2.80GHz   2.80 GHz',
 '465 GB',
 '12.0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='SIS-PC-035' LIMIT 1),
 '192.168.150.218',
 NULL,
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='SIS-PC-035' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2019' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='SIS-PC-035' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='SIS-PC-035' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='SIS-PC-035' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Bartender 10.1' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='SIS-PC-035' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Zebra' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='SIS-PC-035' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Team Viewer' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='SIS-PC-035' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='SIS-PC-035' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Reader X' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='SIS-PC-035' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WinRAR' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='SIS-PC-035' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='SIS-PC-035' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(35,
 'SIS-PC-035',
 (SELECT id FROM departamentos WHERE nombre='Sistemas' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Jhoe Cadena' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
 'SISTEMAS',
 'NINGUNO',
 SHA2('SISTEMAS2001',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='SIS-PC-035' LIMIT 1),
 '1 Monitor',
 'Ninguno',
 'Ninguno',
 'DELL',
 'DELL',
 '65H3963',
 '11th Gen Intel(R) Core(TM) i7-1165G7 @ 2.80GHz   2.80 GHz',
 '465 GB',
 '12.0 GB',
 'Windows 11 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='SIS-PC-035' LIMIT 1),
 '192.168.150.218',
 NULL,
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('ADM-PC-040',
'Computadora',
'DELL',
'DELL INSPIRON',
NULL,
(SELECT id FROM departamentos WHERE nombre='Contabilidad' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Dayana Pineda' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
'CORDINACIÓN',
'NINGUNO',
SHA2('FLODECOL2025',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-040' LIMIT 1),
 'ACTUALIZADO',
 'Ninguno',
 'Ninguno',
 'Intel(R) Core(TM) i7-1065G7',
 '1 TB',
 '16.0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-040' LIMIT 1),
 '192.168.150.7',
 '5C-92-5E-D6-ED-D6',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-040' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-040' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2021' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-040' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-040' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-040' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Team Viewer' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-040' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Nitro Pro' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='ADM-PC-040' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Reader X' LIMIT 1),
 1);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(36,
 'ADM-PC-040',
 (SELECT id FROM departamentos WHERE nombre='Contabilidad' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Dayana Pineda' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Oficina' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Laptop' LIMIT 1),
 'CORDINACIÓN',
 'NINGUNO',
 SHA2('FLODECOL2025',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-040' LIMIT 1),
 'ACTUALIZADO',
 'Ninguno',
 'Ninguno',
 'DELL',
 'DELL INSPIRON',
 NULL,
 'Intel(R) Core(TM) i7-1065G7',
 '1 TB',
 '16.0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='ADM-PC-040' LIMIT 1),
 '192.168.150.7',
 '5C-92-5E-D6-ED-D6',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('POST-PC-037',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Bodega' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Diego Moran' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Bodega' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Bodega' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'BODEGA1',
'NINGUNO',
SHA2('BODEGA2025+',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-037' LIMIT 1),
 '1 Monitor',
 'LG',
 '803UXJX29380',
 'Intel(R) Core(TM)2 Duo CPU     E7500',
 '465.5 GB',
 '4.00 GB',
 'Windows 10 Home')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-037' LIMIT 1),
 '192.168.150.31',
 '70-71-BC-9E-82-AD',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-037' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-037' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2013' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-037' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-037' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-037' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='AnyDesk' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-037' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-037' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WinRAR' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-037' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Zoom' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-037' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-037' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='KASPERSKY' LIMIT 1),
 'W8J34-NYBSN-VYA5C-RN5DS',
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-037' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(37,
 'POST-PC-037',
 (SELECT id FROM departamentos WHERE nombre='Bodega' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Diego Moran' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Bodega' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Bodega' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'BODEGA1',
 'NINGUNO',
 SHA2('BODEGA2025+',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-037' LIMIT 1),
 '1 Monitor',
 'LG',
 '803UXJX29380',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Core(TM)2 Duo CPU     E7500',
 '465.5 GB',
 '4.00 GB',
 'Windows 10 Home')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-037' LIMIT 1),
 '192.168.150.31',
 '70-71-BC-9E-82-AD',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('POST-PC-038',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Bodega' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Diego Moran' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Bodega' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Bodega' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'PERSONAL',
'NINGUNO',
SHA2('FLODECOL2025*',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-038' LIMIT 1),
 '1 Monitor',
 'LG',
 'CBGG97A280829',
 'Intel(R) Celeron(R) CPU N3450',
 '222.3 GB',
 '8.00 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-038' LIMIT 1),
 '192.168.150.209',
 '00-E0-4C-07-01-B3',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-038' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-038' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2013' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-038' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-038' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-038' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(38,
 'POST-PC-038',
 (SELECT id FROM departamentos WHERE nombre='Bodega' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Diego Moran' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Bodega' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Bodega' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'PERSONAL',
 'NINGUNO',
 SHA2('FLODECOL2025*',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-038' LIMIT 1),
 '1 Monitor',
 'LG',
 'CBGG97A280829',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Celeron(R) CPU N3450',
 '222.3 GB',
 '8.00 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-038' LIMIT 1),
 '192.168.150.209',
 '00-E0-4C-07-01-B3',
 'Dinamico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('POST-PC-039',
'Computadora',
'Computadora escritorio -Ensamblado generico',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Bodega' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Diego Moran' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Bodega' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Bodega' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'BODEGA_OTON',
'NINGUNO',
SHA2('120921',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-039' LIMIT 1),
 '1 Monitor',
 'LG',
 'YC5RH9LB300373R',
 'Intel(R) Pentium(R) CPU G2030',
 '223.56 GB',
 '8.00 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-039' LIMIT 1),
 '192.168.150.6',
 '7C-05-07-AD-47-EE',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-039' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-039' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Microsoft Office LTSC Professional Plus 2013' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-039' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Chrome Google' LIMIT 1),
 1);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-039' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='OFFICE' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='POST-PC-039' LIMIT 1),
 (SELECT id FROM licencias WHERE nombre='WINDOWS' LIMIT 1),
 NULL,
 1)
ON DUPLICATE KEY UPDATE
  clave=VALUES(clave),
  activo=VALUES(activo);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(39,
 'POST-PC-039',
 (SELECT id FROM departamentos WHERE nombre='Bodega' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Diego Moran' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Bodega' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Bodega' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'BODEGA_OTON',
 'NINGUNO',
 SHA2('120921',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-039' LIMIT 1),
 '1 Monitor',
 'LG',
 'YC5RH9LB300373R',
 'Computadora escritorio -Ensamblado generico',
 NULL,
 NULL,
 'Intel(R) Pentium(R) CPU G2030',
 '223.56 GB',
 '8.00 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='POST-PC-039' LIMIT 1),
 '192.168.150.6',
 '7C-05-07-AD-47-EE',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT INTO equipos
(codigo, nombre, marca, modelo, serie, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, comentarios, estado_equipo, estado)
VALUES
('GRN-PC-040',
'Computadora',
'HP',
NULL,
NULL,
(SELECT id FROM departamentos WHERE nombre='Gerencia' LIMIT 1),
(SELECT id FROM responsables WHERE nombre='Paul Barahona' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Gerencia' LIMIT 1),
(SELECT id FROM ubicaciones WHERE nombre='Oton - Gerencia' LIMIT 1),
(SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
'DESKTOP-G1NV7NO',
'NINGUNO',
SHA2('polo1975',256),
'Estable y fluido',
'ACTUALIZADO',
'Activo')
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  marca=VALUES(marca),
  modelo=VALUES(modelo),
  serie=VALUES(serie),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  comentarios=VALUES(comentarios),
  estado_equipo=VALUES(estado_equipo),
  estado=VALUES(estado);

INSERT INTO equipos_detalle_pc
(equipo_id, monitor_arquitectura, modelo_monitor, serial_monitor, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM equipos WHERE codigo='GRN-PC-040' LIMIT 1),
 'Ninguno',
 'Ninguno',
 'Ninguno',
 'Intel(R) Core(TM) i7-7700T CPU',
 '1 TB',
 '16,0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO equipo_red
(equipo_id, ip, mac, asignacion)
VALUES
((SELECT id FROM equipos WHERE codigo='GRN-PC-040' LIMIT 1),
 '192.168.150.60',
 '3C-52-82-CE-E4-7C',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='GRN-PC-040' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Acrobat DC' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='GRN-PC-040' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Nero' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='GRN-PC-040' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Skype' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='GRN-PC-040' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='WhatsApp' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='GRN-PC-040' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Zebra' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='GRN-PC-040' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Team Viewer' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='GRN-PC-040' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Nitro Pro' LIMIT 1),
 1);

INSERT IGNORE INTO equipo_programa (equipo_id, programa_id, activo)
VALUES
((SELECT id FROM equipos WHERE codigo='GRN-PC-040' LIMIT 1),
 (SELECT id FROM programas WHERE nombre='Adobe Reader X' LIMIT 1),
 1);

INSERT INTO computadoras
(numero, codigo, id_departamento, responsable_id, ubicacion_antigua_id, ubicacion_actual_id, tipo_dispositivo_id, nombre_dispositivo, accesorios, credencial_hash, estado_equipo, comentarios)
VALUES
(40,
 'GRN-PC-040',
 (SELECT id FROM departamentos WHERE nombre='Gerencia' LIMIT 1),
 (SELECT id FROM responsables WHERE nombre='Paul Barahona' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Gerencia' LIMIT 1),
 (SELECT id FROM ubicaciones WHERE nombre='Oton - Gerencia' LIMIT 1),
 (SELECT id FROM tipos_dispositivo WHERE nombre='Computadora escritorio' LIMIT 1),
 'DESKTOP-G1NV7NO',
 'NINGUNO',
 SHA2('polo1975',256),
 'ACTUALIZADO',
 'Operativa y en buen estado')
ON DUPLICATE KEY UPDATE
  numero=VALUES(numero),
  id_departamento=VALUES(id_departamento),
  responsable_id=VALUES(responsable_id),
  ubicacion_antigua_id=VALUES(ubicacion_antigua_id),
  ubicacion_actual_id=VALUES(ubicacion_actual_id),
  tipo_dispositivo_id=VALUES(tipo_dispositivo_id),
  nombre_dispositivo=VALUES(nombre_dispositivo),
  accesorios=VALUES(accesorios),
  credencial_hash=VALUES(credencial_hash),
  estado_equipo=VALUES(estado_equipo),
  comentarios=VALUES(comentarios);

INSERT INTO computadoras_detalle
(computadora_id, monitor_arquitectura, modelo_monitor, serial_monitor, marca_equipo, modelo_equipo, serial_equipo, procesador, almacenamiento, memoria, sistema_operativo)
VALUES
((SELECT id FROM computadoras WHERE codigo='GRN-PC-040' LIMIT 1),
 'Ninguno',
 'Ninguno',
 'Ninguno',
 'HP',
 NULL,
 NULL,
 'Intel(R) Core(TM) i7-7700T CPU',
 '1 TB',
 '16,0 GB',
 'Windows 10 Pro')
ON DUPLICATE KEY UPDATE
  monitor_arquitectura=VALUES(monitor_arquitectura),
  modelo_monitor=VALUES(modelo_monitor),
  serial_monitor=VALUES(serial_monitor),
  marca_equipo=VALUES(marca_equipo),
  modelo_equipo=VALUES(modelo_equipo),
  serial_equipo=VALUES(serial_equipo),
  procesador=VALUES(procesador),
  almacenamiento=VALUES(almacenamiento),
  memoria=VALUES(memoria),
  sistema_operativo=VALUES(sistema_operativo);

INSERT INTO computadoras_red
(computadora_id, ip, mac, asignacion)
VALUES
((SELECT id FROM computadoras WHERE codigo='GRN-PC-040' LIMIT 1),
 '192.168.150.60',
 '3C-52-82-CE-E4-7C',
 'Estatico')
ON DUPLICATE KEY UPDATE
  ip=VALUES(ip),
  mac=VALUES(mac),
  asignacion=VALUES(asignacion);
