-- Tutorial from https://www.postgresql.org/docs
-- Copied contents from https://www.postgresql.org/docs

SELECT version();

CREATE TABLE weather (
    city            varchar(80),
    temp_lo         int,           -- low temperature
    temp_hi         int,           -- high temperature
    prcp            real,          -- precipitation
    date            date
);

-- Two dashes (“--”) introduce comments

-- varchar(80) specifies a data type that can store arbitrary character strings up to 80 characters in length. 
-- int is the normal integer type. 
-- real is a type for storing single precision floating-point numbers. 
-- date should be self-explanatory.

CREATE TABLE cities (
    name            varchar(80),
    location        point
);

-- DROP TABLE tablename;

INSERT INTO weather VALUES ('San Francisco', 46, 50, 0.25, '1994-11-27');

-- database 'cities' has a column 'location' that has 'point' type.
-- 'point' is a data type that can store a geometric point in a two-dimensional plane.
-- 'point' requires a coordinate pair as input as shown below.
INSERT INTO cities VALUES ('San Francisco', '(-194.0, 53.0)');

-- An alternative syntax allows you to list the columns explicitly.
INSERT INTO weather (city, temp_lo, temp_hi, prcp, date)
    VALUES ('San Francisco', 43, 57, 0.0, '1994-11-29');

-- You can list the columns in a different order. 
-- You can leave out some columns, e.g., if the precipitation is unknown.
INSERT INTO weather (date, city, temp_hi, temp_lo)
    VALUES ('1994-11-29', 'Hayward', 54, 37);

-- omitting a column shows empty/(NULL) value for that column.
SELECT * FROM weather;

SELECT city, (temp_hi+temp_lo)/2 AS temp_avg, date FROM weather;
-- The AS clause is optional.

-- A query can be “qualified” by adding a WHERE clause that specifies which rows are wanted.
-- The WHERE clause contains a Boolean (truth value) expression 
-- and only rows for which the Boolean expression is true are returned.
SELECT * FROM weather
    WHERE city = 'San Francisco' AND prcp > 0.0;

SELECT * FROM weather
    ORDER BY city;

-- You can request that duplicate rows be excluded from the result of a query
SELECT DISTINCT city
    FROM weather;

SELECT DISTINCT city
    FROM weather
    ORDER BY city;

-- Queries can access multiple tables at once, 
-- or access the same table that multiple rows of the table are being processed at the same time.

-- Querie that access multiple tables (or multiple instances same table) are called join queries.
-- They combine rows from one table with rows from a second table, 
-- with an expression specifying which rows are to be paired.
SELECT * FROM weather 
    JOIN cities ON city = name;
-- Columns from the weather and cities tables are concatenated.
-- 'Hayward' is not shown because of the mismatch in the city name between the two tables.

-- Can be also be written as...
SELECT *
    FROM weather, cities
    WHERE city = name;

-- If there were duplicate column names in the two tables you'd need to qualify the column names.
SELECT weather.city, weather.temp_lo, weather.temp_hi,
       weather.prcp, weather.date, cities.location
    FROM weather JOIN cities ON weather.city = cities.name;

-- Let's get 'Hayward' back in.
SELECT *
    FROM weather LEFT OUTER JOIN cities ON weather.city = cities.name;
-- The LEFT OUTER JOIN returns all rows from the left table (weather),
-- and the matched rows from the right table (cities).

-- You can confirm LEFT OUTER here.
SELECT *
    FROM weather RIGHT OUTER JOIN cities ON weather.city = cities.name;

SELECT *
    FROM weather FULL OUTER JOIN cities ON weather.city = cities.name;
-- The FULL OUTER JOIN returns all rows from both tables.

-- This is called a self join.
SELECT w1.city, w1.temp_lo AS low, w1.temp_hi AS high,
       w2.city, w2.temp_lo AS low, w2.temp_hi AS high
    FROM weather w1 JOIN weather w2
        ON w1.temp_lo < w2.temp_lo AND w1.temp_hi > w2.temp_hi;
-- 'FROM weather w1 JOIN weather w2' conceptually gives 3*3 = 9 rows
-- 'ON w1.temp_lo < w2.temp_lo AND w1.temp_hi > w2.temp_hi;' filters out self-pair.
-- Surviving pair has w2’s range strictly inside w1’s range.