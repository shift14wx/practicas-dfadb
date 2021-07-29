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

/**
  -------------------------------------------------------------------------------------------------------------------------------
  CUIDADO! CORRE HASTA AQUI Y CONECTATE A LA BASE DE DATOS PRACTICAS PARA CONTINUAR
  -------------------------------------------------------------------------------------------------------------------------------
  */

CREATE SCHEMA IF NOT EXISTS practica01;

/**
  -------------------------------------------------------------------------------------------------------------------------------
  CUIDADO! CORRE HASTA AQUI Y CONECTATE A LA BASE DE DATOS PRACTICAS EN EL ESCHAMA RECIEN CREADO "practica01"
  -------------------------------------------------------------------------------------------------------------------------------
  */
--CREANDO TYPES

DO
$$
    BEGIN
        IF NOT EXISTS(SELECT 1 FROM pg_type WHERE typname = 'my_type') THEN
           -- DROP TYPE coordenada;
            CREATE TYPE coordenada AS
            (
                latitud  FLOAT,
                longitud FLOAT
            );
        END IF;
        --more types here...
    END
$$;

DO
$$
    BEGIN
        IF NOT EXISTS(SELECT 1 FROM pg_type WHERE typname = 'my_type') THEN
            --DROP TYPE direccion;
            CREATE TYPE direccion AS
            (
                calle     VARCHAR(50),
                numero   VARCHAR(10),
                sector    VARCHAR(50),
                poblacion VARCHAR(50),
                block     VARCHAR(10),
                depto     VARCHAR(10),
                piso      INT,
                ciudad    VARCHAR(20),
                posicion  coordenada
            );
        END IF;
        --more types here...
    END
$$;

-- CREANDO TABLAS

--DROP TABLE usuarios;

CREATE TABLE usuarios
(
    id_usuario          SERIAL NOT NULL PRIMARY KEY,
    nombre              VARCHAR(50),
    email               VARCHAR(100),
    fecha_ingreso       DATE,
    domicilio_personal  direccion,
    domicilio_comercial direccion
);

--EFECTUAR OPERACIONES DML

INSERT INTO usuarios
    (nombre, email, fecha_ingreso, domicilio_personal, domicilio_comercial)
VALUES ('CARLOS HERNANDEZ', 'carlos@hernandez.com', '2021-07-30',
        ROW (
            'RIO BIO-BIO',
            '0251',
            'SANTA ROSA',
            'VILLA LOS RIOS',
            'BLOCK 2',
            '205',
            2,
            'TEMUCO',
            ROW (
                -38.7185373, -72.5532641
                )
            ),
        ROW (
            'MANUEL MONTT',
            '0450',
            'TEMUCO CENTRO',
            'CENTRO',
            'EDIF A',
            '589',
            5,
            'TEMUCO',
            ROW (
                -38.7385415, -72.5890836
                )
            ));

UPDATE usuarios
SET domicilio_personal.calle = 'LOS AROMOS',
    domicilio_personal.numero = '1978',
    domicilio_personal.sector = 'PEDRO DE VALDIVIA',
    domicilio_personal.poblacion = 'VILLA ALEMANA',
    domicilio_personal.block = 'NO',
    domicilio_personal.depto = 0,
    domicilio_personal.piso = 1,
    domicilio_personal.ciudad = 'TEMUCO',
    domicilio_personal.posicion = ROW ( -38.7186236, -72.6207258 )
    WHERE id_usuario = 1;

SELECT *
FROM usuarios AS A
where (domicilio_personal).sector = 'PEDRO DE VALDIVIA'