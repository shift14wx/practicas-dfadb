CREATE SCHEMA IF NOT EXISTS actividad01;
-- Tabla con datos primitivos
CREATE TABLE producto
(
    producto varchar(200),
    precio   numeric(7, 2) DEFAULT 0,
    fecha    date
);

-- tabla con datos compuestos

CREATE TYPE coordenadas AS
(
    latitud      FLOAT,
    longitud     FLOAT,
    departamento character varying
);

CREATE TYPE datos_personales AS
(
    nombre    character varying,
    apellido  character varying,
    edad      int,
    direccion coordenadas
);

CREATE TABLE jugadores
(
    id_jugador       SERIAL NOT NULL PRIMARY KEY,
    n_camisa         int,
    datos_personales datos_personales
);



CREATE TABLE jugadores_CDFAS
(
) INHERITS (jugadores);
CREATE TABLE jugadores_CDaguila
(
) INHERITS (jugadores);
CREATE TABLE jugadores_CDalianza
(
) INHERITS (jugadores);

ALTER TABLE jugadores_CDFAS
    ADD CONSTRAINT jcdfas CHECK ( (datos_personales).direccion.departamento = 'SANTA ANA' );
ALTER TABLE jugadores_CDaguila
    ADD CONSTRAINT jcdaguila CHECK ( (datos_personales).direccion.departamento = 'SAN MIGUEL' );
ALTER TABLE jugadores_CDalianza
    ADD CONSTRAINT jcdalianza CHECK ( (datos_personales).direccion.departamento = 'SAN SALVADOR');

CREATE OR REPLACE FUNCTION insertar_jugadores()
    RETURNS TRIGGER AS
$$
BEGIN
    if ((NEW).datos_personales.direccion.departamento = 'SANTA ANA')
    THEN
        INSERT INTO jugadores_CDFAS VALUES (NEW.*);
    ELSEIF ((NEW).datos_personales.direccion.departamento = 'SAN MIGUEL')
    THEN
        INSERT INTO jugadores_CDaguila VALUES (NEW.*);
    ELSEIF ((NEW).datos_personales.direccion.departamento = 'SAN SALVADOR')
    THEN
        INSERT INTO jugadores_CDalianza VALUES (NEW.*);
    END IF;
    RETURN NULL;
END
$$
    LANGUAGE plpgsql;


CREATE TRIGGER insertar_jugadores_equipo
BEFORE INSERT ON jugadores
FOR EACH ROW EXECUTE PROCEDURE insertar_jugadores();


INSERT INTO jugadores
(n_camisa, datos_personales) VALUES
(1, ROW('Carlos', 'Hernandez', 25, ROW(-25.20202,-87.00002,'SANTA ANA') ) );


INSERT INTO jugadores
(n_camisa, datos_personales) VALUES
    (1, ROW('Nico', 'Gol', 30, ROW(-25.20202,-87.00002,'SAN MIGUEL') ) );

INSERT INTO jugadores
(n_camisa, datos_personales) VALUES
    (1, ROW('Rodolfo', 'Zelaya', 28, ROW(-25.20202,-87.00002,'SAN SALVADOR') ) );