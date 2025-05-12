-- 1) Crear la base de datos y seleccionarla
CREATE DATABASE IF NOT EXISTS economia_usa;
USE economia_usa;

-- 2) Tabla quintil_bajo (igual que antes)
CREATE TABLE quintil_bajo (
  anio YEAR NOT NULL,
  valor DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (anio, valor)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3) Tabla inflacion_eeuu con DECIMAL(8,6) para permitir dos dígitos en la parte entera
CREATE TABLE inflacion_eeuu (
  anio YEAR NOT NULL,
  porcentaje_inflacion DECIMAL(8,6) NOT NULL,
  PRIMARY KEY (anio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4) Insertar datos en quintil_bajo
INSERT INTO quintil_bajo (anio, valor) VALUES
  (2021, 14859.00),
  (2020, 15350.00),
  (2019, 16199.00),
  (2018, 14863.00),
  (2017, 14725.00),
  (2017, 14654.00),
  (2016, 14613.00),
  (2015, 14246.00),
  (2014, 13376.00),
  (2013, 13507.00),
  (2013, 13573.00),
  (2012, 13584.00),
  (2011, 13568.00),
  (2010, 13691.00),
  (2009, 14624.00),
  (2008, 14704.00),
  (2007, 15131.00),
  (2006, 15291.00),
  (2005, 14818.00),
  (2004, 14729.00),
  (2003, 14761.00),
  (2002, 15087.00),
  (2001, 15548.00),
  (2000, 16025.00),
  (1999, 16173.00),
  (1998, 15365.00),
  (1997, 14925.00),
  (1996, 14827.00),
  (1995, 14779.00),
  (1994, 13990.00),
  (1993, 13625.00),
  (1992, 13774.00),
  (1991, 14058.00),
  (1990, 14448.00),
  (1989, 14796.00),
  (1988, 14274.00),
  (1987, 14029.00),
  (1986, 13665.00),
  (1985, 13518.00),
  (1984, 13539.00),
  (1983, 13109.00),
  (1982, 12956.00),
  (1981, 13201.00),
  (1980, 13530.00),
  (1979, 13985.00),
  (1978, 14084.00),
  (1977, 13620.00),
  (1976, 13687.00),
  (1975, 13358.00),
  (1974, 13827.00),
  (1973, 13878.00),
  (1972, 13260.00),
  (1971, 12515.00),
  (1970, 12437.00),
  (1969, 12657.00),
  (1968, 12358.00),
  (1967, 11378.00);

-- 5) Insertar datos en inflacion_eeuu
INSERT INTO inflacion_eeuu (anio, porcentaje_inflacion) VALUES
  (1960, 1.457976),
  (1961, 1.070724),
  (1962, 1.198773),
  (1963, 1.239669),
  (1964, 1.278912),
  (1965, 1.585169),
  (1966, 3.015075),
  (1967, 2.772786),
  (1968, 4.271796),
  (1969, 5.462386),
  (1970, 5.838255),
  (1971, 4.292767),
  (1972, 3.272278),
  (1973, 6.177760),
  (1974, 11.054805),
  (1975, 9.143147),
  (1976, 5.744813),
  (1977, 6.501684),
  (1978, 7.630964),
  (1979, 11.254471),
  (1980, 13.549202),
  (1981, 10.334563),
  (1982, 6.131427),
  (1983, 3.212435),
  (1984, 4.300535),
  (1985, 3.545644),
  (1986, 1.898048),
  (1987, 3.664563),
  (1988, 4.077741),
  (1989, 4.827003),
  (1990, 5.397956),
  (1991, 4.234964),
  (1992, 3.028820),
  (1993, 2.951657),
  (1994, 2.607442),
  (1995, 2.805420),
  (1996, 2.931204),
  (1997, 2.337690),
  (1998, 1.552279),
  (1999, 2.188027),
  (2000, 3.376857),
  (2001, 2.826171),
  (2002, 1.586032),
  (2003, 2.270095),
  (2004, 2.677237),
  (2005, 3.392747),
  (2006, 3.225944),
  (2007, 2.852672),
  (2008, 3.839100),
  (2009, -0.355546),
  (2010, 1.640043),
  (2011, 3.156842),
  (2012, 2.069337),
  (2013, 1.464833),
  (2014, 1.622223),
  (2015, 0.118627),
  (2016, 1.261583),
  (2017, 2.130110),
  (2018, 2.442583),
  (2019, 1.812210),
  (2020, 1.233584),
  (2021, 4.697859),
  (2022, 8.002800),
  (2023, 4.116338);


WITH
  -- 1) Cálculo del factor acumulado y % de inflación acumulada hasta cada año
  cum AS (
    SELECT
      anio,
      porcentaje_inflacion,
      EXP(
        SUM(LN(1 + porcentaje_inflacion/100))
        OVER (ORDER BY anio)
      ) AS factor_acumulado,
      ROUND(
        (EXP(
           SUM(LN(1 + porcentaje_inflacion/100))
           OVER (ORDER BY anio)
         ) - 1) * 100,
        2
      ) AS inflacion_acumulada_pct
    FROM inflacion_eeuu
  ),
  -- 2) Factor acumulado en 1967 (base para normalizar)
  base67 AS (
    SELECT factor_acumulado AS factor_1967
    FROM cum
    WHERE anio = 1967
  )
SELECT
  q.anio,
  c.porcentaje_inflacion        AS inflacion_anual_pct,
  c.inflacion_acumulada_pct     AS inflacion_acumulada_pct,
  q.valor                        AS valor_nominal,
  -- Valor ajustado a poder adquisitivo de 1967
  ROUND(
    q.valor
    / (c.factor_acumulado / b.factor_1967)
  , 2)                           AS valor_en_1967,
  -- Cuántas veces han subido los precios respecto a 1967
  ROUND(
    c.factor_acumulado
    / b.factor_1967
  , 4)                           AS factor_inflacion_relativa,
  -- % de poder adquisitivo perdido desde 1967
  ROUND(
    (1
     - b.factor_1967 / c.factor_acumulado
    ) * 100
  , 2)                           AS perdida_poder_adquisitivo_pct
FROM quintil_bajo   AS q
JOIN cum            AS c  ON c.anio = q.anio
CROSS JOIN base67   AS b
WHERE q.anio >= 1967
ORDER BY q.anio;
