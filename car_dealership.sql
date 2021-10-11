--Create customer table
CREATE TABLE customers(
	customer_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	phone_number VARCHAR(20),
	email VARCHAR(50),
	vin_number VARCHAR(100)
);

--Insert data to customer table
INSERT INTO customers(customer_id, first_name, last_name, phone_number, email, vin_number)
VALUES(	3, 'Dave', 'Kopp', '312-789-6754', 'dkopp@mail.com', 'F78H238K76J1259');
	
SELECT * FROM customers;

--Create sales_person table
CREATE TABLE sales_person(
	sales_emp_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	employee_email VARCHAR(100)
);

--Insert data into sales_person Table
INSERT INTO sales_person(first_name, last_name, employee_email)
VALUES
	('Stewy', 'Rhoades', 'srhodes@dealership.com'),
	('Herbert', 'Fink', 'hfink@dealership.com'),
	('Ronald', 'Appleblossom', 'rappleblossom@dealership.com');

SELECT * from sales_person;

DELETE FROM sales_person;

ALTER SEQUENCE sales_person_sales_emp_id_seq RESTART WITH 1;

--Create car_inventory Table
CREATE TABLE car_inventory(
	vin_number VARCHAR(100) PRIMARY KEY,
	year_ INTEGER,
	make VARCHAR(50),
	model VARCHAR(50),
	miles INTEGER,
	used_or_new VARCHAR(4),
	amount NUMERIC(10,2)
);

--Insert data into car_inventory
INSERT INTO car_inventory(vin_number, year_, make, model, miles, used_or_new, amount)
VALUES
	('F78K93J23J546V1', 2013, 'Hyundai', 'Vera Cruz', 109342, 'USED', 8525.99),
	('F89N73H237J618V', 2020, 'Mercedes-Benz', 'S550', 225, 'NEW', 95999.99),
	('F73H69M6V3627J5', 2016, 'Toyota', 'Camry', 12975, 'USED', 12995.99),
	('F837J34I9B76V3V', 2018, 'Ford', 'Mustang', 10647, 'USED', 14650.99);
	
--Create invoice_car Table
CREATE TABLE invoice_car(
	invoice_id SERIAL PRIMARY KEY,
	sales_emp_id INTEGER,
	customer_id INTEGER,
	vin_number VARCHAR(100),
	date_created DATE DEFAULT CURRENT_DATE,
	FOREIGN KEY(sales_emp_id) REFERENCES sales_person(sales_emp_id),
	FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
	FOREIGN KEY(vin_number) REFERENCES car_inventory(vin_number)
);

ALTER TABLE invoice_car
RENAME TO car_invoice;

--Insert data into car_invoice table
INSERT INTO car_invoice(sales_emp_id, customer_id, vin_number)
VALUES
	((SELECT sales_emp_id FROM sales_person WHERE sales_emp_id = 1),(SELECT customer_id FROM customers WHERE customer_id = 2), 'F89N73H237J618V'),
	((SELECT sales_emp_id FROM sales_person WHERE sales_emp_id = 3),(SELECT customer_id FROM customers WHERE customer_id = 4), 'F78K93J23J546V1');


--Create mechanic Table
CREATE TABLE mechanic(
	mechanic_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	employee_email VARCHAR(100)
);

--Insert data into mechainc table
INSERT INTO mechanic(first_name, last_name, employee_email)
VALUES
	('Rick', 'Short', 'rshort@dealership.com'),
	('Lucas', 'Miller', 'lmiller@dealership.com'),
	('Toby', 'Redford', 'tredford@dealership.com'),
	('Danny', 'Ocean', 'docean@dealership.com');
	
--CREATE parts Table
CREATE TABLE parts(
	part_id SERIAL PRIMARY KEY,
	part_name VARCHAR(50),
	description VARCHAR(250),
	price NUMERIC(6,2),
	quantity INTEGER
);


--Insert data into parts table
INSERT INTO parts(part_name, description, price, quantity)
VALUES
	('carburetor', 'A carburetor is a device that mixes air and fuel for internal combustion engines in an appropriate air–fuel ratio for combustion.', 16.90, 5),
	('spark plugs', 'Small but mighty, the spark of electricity that the plug emits across a small gap creates the ignition for the combustion needed to start your car.', 9.95, 25),
	('alternator', 'An alternator converts mechanical energy to electrical energy with an alternating current.', 95.35, 4),
	('battery', 'A car battery provides the zap of electricity needed to put electrical components to work. It also converts chemical energy into the electrical energy that powers your car and delivers voltage to its starter.', 45.95, 12);
	
--Create car_service Table
CREATE TABLE car_service(
	service_ticket SERIAL PRIMARY KEY,
	customer_id INTEGER,
	vin_number VARCHAR(100),
	mechanic_id INTEGER,
	description VARCHAR(250),
	payment_amount NUMERIC(8,2),
	date_serviced TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	part_id INTEGER,
	quantity_used INTEGER,
	FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
	FOREIGN KEY(mechanic_id) REFERENCES mechanic(mechanic_id),
	FOREIGN KEY(part_id) REFERENCES parts(part_id)
);

--Insert data into car_service Table

INSERT INTO car_service(customer_id, vin_number, mechanic_id, description, payment_amount, part_id, quantity_used)
VALUES
	((SELECT customer_id FROM customers WHERE customer_id = 1), 'F76S9866EC78D89',(SELECT mechanic_id FROM mechanic WHERE mechanic_id = 4), 'put in new spark plugs', 98.65,(SELECT part_id FROM parts WHERE part_id = 2), 2);
	((SELECT customer_id FROM customers WHERE customer_id = 2), 'F87G67F563K24L3',(SELECT mechanic_id FROM mechanic WHERE mechanic_id = 4), 'put in new spark plugs', 98.65,(SELECT part_id FROM parts WHERE part_id = 2), 2),
	((SELECT customer_id FROM customers WHERE customer_id = 3), 'F78H238K76J1259',(SELECT mechanic_id FROM mechanic WHERE mechanic_id = 2), 'put in a new battery', 155.55,(SELECT part_id FROM parts WHERE part_id = 4), 1),
	((SELECT customer_id FROM customers WHERE customer_id = 1), 'F76S9866EC78D89',(SELECT mechanic_id FROM mechanic WHERE mechanic_id = 1), 'put in a new carburetor', 245.65,(SELECT part_id FROM parts WHERE part_id = 1), 1);

SELECT * FROM car_service;
-----------------------------------------------------------------------------
-------------------CREATE TWO STORED PROCEDURES------------------------------
--CREATING A TRIGGER FIRST BECAUSE THAT SEEMS MORE FUN

--CREATE TRIGGER FUNCTION
CREATE OR REPLACE FUNCTION trig_func() RETURNS TRIGGER AS
$$
BEGIN
WITH d AS(
	SELECT parts.quantity AS rowid, parts.quantity - car_service.quantity_used AS calculatedvalue
	FROM parts
	JOIN car_service
	ON car_service.part_id = parts.part_id
)
UPDATE parts
SET quantity = d.calculatedvalue
FROM d
WHERE quantity = d.rowid;
		
RETURN new;
END;
$$
LANGUAGE plpgsql;

--CREATE TRIGGER
CREATE TRIGGER update_parts_quantity
	AFTER INSERT ON car_service
	FOR EACH ROW
	EXECUTE PROCEDURE trig_func();
	
--SEEING IF IT WORKS
SELECT * FROM parts;
--It did!

--Stored Procedure #1 Add sales person or mechanic to the database

CREATE OR REPLACE PROCEDURE add_sales(
	_first VARCHAR(50),
	_last VARCHAR(50),
	email VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO sales_person(first_name, last_name, employee_email)
	VALUES(_first, _last, email);

END;
$$

CREATE OR REPLACE PROCEDURE add_mechanic(
	_first VARCHAR(50),
	_last VARCHAR(50),
	email VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO mechanic(first_name, last_name, employee_email)
	VALUES(_first, _last, email);

END;
$$

CALL add_sales('John', 'Travolta', 'jtravolta@dealership.com');

--Stored Procedure #2 
