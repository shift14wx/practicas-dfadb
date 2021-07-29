-- creando base de datos si no existe
CREATE EXTENSION IF NOT EXISTS dblink;
DO
$$
    BEGIN
        PERFORM dblink_exec('', 'CREATE DATABASE practicas');
    EXCEPTION
        WHEN duplicate_database THEN RAISE NOTICE '%, skipping', SQLERRM USING ERRCODE = SQLSTATE;
    END
$$;
-- TERMINANDO DE CREAR LA BASE DE DATOS SI NO EXISTE

CREATE SCHEMA IF NOT EXISTS practica02;
--drop table ventas;
CREATE TABLE ventas
(
    producto character varying DEFAULT '' :: character varying,
    precio numeric(7,2) DEFAULT 0,
    fecha date
)
WITH (OIDS = false);

/**
  INDICACIONES
  primero el nombre de la tabla en la sentencia "create table",
  segundo las columnas que se crearan.
  tercero los campos como "producto" tiene un tipo "character varyng" que por default tiene '', tambien en el minuto 25:44 de la clase #2
  se nos indico que era una referencia, es lo que esta asignando el keyboard DEFAULT en la declaracion de la columna.
  la columna precio nos indica que solo podra permitirse hasta 2 decimales.
  el IDS hace referencia a indentificador de objetos, que se ocupa para poder indetificar por ejemplo, si tenemos 2 row que son identicas, pero querremos
  borrar la mas antigua, el IODS nos podria ayudar a identificar cual de estas es la mas antigua y poder borrarla
  */

-- CREANDO TABLAS HIJAS

CREATE TABLE ventas_enero() INHERITS (ventas);
CREATE TABLE ventas_febrero() INHERITS (ventas);
CREATE TABLE ventas_marzo() INHERITS (ventas);

-- CREANDO CONSTRAINS

ALTER TABLE ventas_enero ADD CONSTRAINT vtas_enero CHECK ( fecha >= '2021-01-01' :: date AND fecha <= '2021-01-31'::date);
ALTER TABLE ventas_febrero ADD CONSTRAINT vtas_febrero CHECK ( fecha >= '2021-02-01'::date AND fecha <= '2021-02-28'::date);
ALTER TABLE ventas_marzo ADD CONSTRAINT vtas_marzo CHECK ( fecha >= '2021-03-01'::date AND fecha <= '2021-03-31'::date );


/**
  Aqui, solamente creamos como "limitadores" que nos ayudaran a que cuando insertemos datos, estos sean verificados antes de ser ingresados en una tabla
  por ejemplo si insertamos una fecha que sobre pasa en ventas_enero del 2021-01-31, este check saltara para que no sea insertado
  */

-- CREANDO PROCEDURE
CREATE OR REPLACE FUNCTION insertar_ventas()
RETURNS TRIGGER AS $$
    BEGIN
        IF (NEW.fecha >= DATE '2021-01-01' AND NEW.fecha <= DATE '2021-01-31')
            THEN INSERT INTO ventas_enero VALUES (NEW.*);
            ELSEIF (NEW.fecha >= DATE '2021-02-01' AND NEW.fecha <= DATE '2021-02-28')
            THEN INSERT INTO ventas_febrero VALUES (NEW.*);
            ELSEIF (NEW.fecha >= DATE '2021-03-01' AND NEW.fecha <= DATE '2021-03-28')
            THEN INSERT INTO ventas_marzo VALUES (NEW.*);
            ELSE
            RAISE EXCEPTION 'Date out of range. Revise la funcion insertar_ventas';
            END IF;
        RETURN NULL;
    END
    $$
LANGUAGE plpgsql;

--CREANDO EL TRIGGER
CREATE TRIGGER insertar_ventas_trigger
    BEFORE INSERT ON ventas
    FOR EACH ROW EXECUTE PROCEDURE insertar_ventas();

-- INSERTANDO DATOS
insert into ventas (producto, precio, fecha) VALUES ('enero',0.25,'2021-02-01');

