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

SELECT *
    FROM weather w JOIN cities c ON w.city = c.name;
-- The above query is equivalent to the following query.
SELECT *
    FROM weather AS w JOIN cities AS c ON w.city = c.name;

-- An aggregate function computes a single result from multiple input rows. 
-- For example, there are aggregates to compute the...
-- count, sum, avg (average), max (maximum) and min (minimum) over a set of rows.

-- find the highest low-temperature reading
SELECT max(temp_lo) FROM weather;
-- we wanted to know what city (or cities) that reading occurred in
SELECT city FROM weather
    WHERE temp_lo = (SELECT max(temp_lo) FROM weather);
-- This will NOT work. SELECT city FROM weather WHERE temp_lo = max(temp_lo);

-- very useful in combination with GROUP BY clauses. For example, 
-- we can get the number of readings and the maximum low temperature observed in each city with.
SELECT city, count(*), max(temp_lo)
    FROM weather
    GROUP BY city;
-- We can filter these grouped rows using HAVING.
SELECT city, count(*), max(temp_lo)
    FROM weather
    GROUP BY city
    HAVING max(temp_lo) < 40;
-- gives us the same results for only the cities that have all temp_lo values below 40.
-- Finally, if we only care about cities whose names begin with “S”, we might do:
SELECT city, count(*), max(temp_lo)
    FROM weather
    WHERE city LIKE 'S%'            -- (1)
    GROUP BY city;
-- The LIKE operator does pattern matching.

-- WHERE selects input rows before conditionals and computation.
-- HAVING selects group rows after groups and aggregates are computed.

-- Another way to select the rows that go into an aggregate computation is to use FILTER.
SELECT city, count(*) FILTER (WHERE temp_lo < 45), max(temp_lo)
    FROM weather
    GROUP BY city;

-- You can update existing rows using the UPDATE command.
-- Suppose you discover the temperature readings are all off by 2 degrees after November 28. 
-- You can correct the data as follows:
UPDATE weather
    SET temp_hi = temp_hi - 2,  temp_lo = temp_lo - 2
    WHERE date > '1994-11-28';

-- Rows can be removed from a table using the DELETE command.
-- DELETE FROM <tablename>
DELETE FROM weather WHERE city = 'Hayward';

-- A view is a stored query that you can reference like a table.
-- Views are useful for encapsulating complex queries,
-- and for providing a level of security by restricting access to a predetermined set of rows and columns.
CREATE VIEW myview AS
    SELECT name, temp_lo, temp_hi, prcp, date, location
        FROM weather, cities
        WHERE city = name;

SELECT * FROM myview;

-- setting: There are `forecast` and `locations` tables.
-- You want to add/update to `forecast` table with specific set of locations.
-- You would want to use Foreign Keys. TO use them, you need a Parent table.
-- By setting `locations` table as a parent table, you would put the set of locations in there.
-- `forecast` table would be a child table with foreign key of `forecast.locations` referencing `locations.name`.
   DROP VIEW myview;
   DROP TABLE weather;
   DROP TABLE cities;
CREATE TABLE cities (
        name     varchar(80) primary key,
        location point
);

CREATE TABLE weather (
        city      varchar(80) references cities(name),
        temp_lo   int,
        temp_hi   int,
        prcp      real,
        date      date
);

-- This fails because 'Berkeley' is not in the primary key in `cities` table.
INSERT INTO weather VALUES ('Berkeley', 45, 53, 0.0, '1994-11-28');

SELECT * FROM weather;





-- 3.4 Transactions
-- setup start
CREATE TABLE branches (
        name    varchar(20) primary key,
        balance int
)

CREATE TABLE accounts (
        name    varchar(20) references branches(name),
        balance int
)

INSERT INTO branches (name, balance)
    VALUES ('Alice', 300), ('Bob', 200);
INSERT INTO accounts (name, balance)
    VALUES ('Alice', 300), ('Bob', 200);
-- setup end

-- Transactions are all or nothing.
-- If the process is ran from `BEGIN` to `COMMIT`, the changes are kept.
-- If any process between `BEGIN` to `COMMIT` is inturrupted, nothing changes.
-- A group of statements surrounded by `BEGIN` and `COMMIT` is sometimes called a transaction block.
BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
-- etc etc
COMMIT;

-- PostgreSQL treat statements without transaction wrapper like a transaction.
-- If you do not issue a BEGIN command, then each individual statement has an implicit BEGIN and (if successful) COMMIT wrapped around it. 

-- transaction can include `SAVEPOINT` that allow you to selectively discard parts of the transaction, while committing the rest.
-- After defining a savepoint with `SAVEPOINT`, you can if needed roll back to the savepoint with `ROLLBACK TO`.

-- if you are sure you won't need to roll back to a particular savepoint again, it can be released, so the system can free some resources. 
-- Keep in mind that either releasing or rolling back to a savepoint will automatically release all savepoints that were defined after it.

-- If multiple transaction blocks are running, each blocks can not see the changes within that block.
-- transaction blocks can only see the changes from the completed run of a block.

BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';
-- oops ... forget that and use Wally's account
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Wally';
COMMIT;

SELECT * FROM accounts;
SELECT * FROM branches;

-- Window functions.
-- `OVER ()` is introduced. It tells which rows it's allowed to look.

CREATE TABLE empsalary (depname text, empno int, salary int);
INSERT INTO empsalary VALUES
('develop',11,5200),('develop',7,4200),('develop',9,4500),
('develop',8,6000),('develop',10,5200),('personnel',5,3500),
('personnel',2,3900),('sales',3,4800),('sales',1,5000),('sales',4,4800);

-- Where as `GROUP BY` collapses each group into one row.
SELECT depname, avg(salary) FROM empsalary GROUP BY depname;
-- Window function keeps every row and attatches the result.
SELECT depname, empno, salary,
       avg(salary) OVER (PARTITION BY depname)
FROM empsalary;

