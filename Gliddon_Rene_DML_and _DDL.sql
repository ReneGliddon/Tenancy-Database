--DDL and DML script by RENE GLIDDON for DBST 651, completed on 11/01/2022

--DDL Script

SET ECHO ON;
SET SERVEROUTPUT ON;
SET LINESIZE 150;
SET PAGESIZE 200;

--Drops delete objects so you can run the same script multiple times

--Drop Tables
DROP TABLE user_list CASCADE CONSTRAINTS;
DROP TABLE database_transaction CASCADE CONSTRAINTS;
DROP TABLE primary_tenant CASCADE CONSTRAINTS;
DROP TABLE property CASCADE CONSTRAINTS;
DROP TABLE rental_contract CASCADE CONSTRAINTS;
DROP TABLE expense CASCADE CONSTRAINTS;
DROP TABLE income CASCADE CONSTRAINTS;

--Drop sequences
DROP SEQUENCE user_code_Seq;
DROP SEQUENCE transaction_code_Seq;
DROP SEQUENCE tenant_code_Seq;
DROP SEQUENCE expense_code_Seq;
DROP SEQUENCE income_code_Seq;
DROP SEQUENCE occupancy_code_Seq;
DROP SEQUENCE property_code_Seq;

--Create the tables

--Create user_list table
CREATE TABLE user_list
(
  user_code         NUMERIC NOT NULL,
  security_level    VARCHAR (10) NOT NULL,
  username          VARCHAR (30),
  user_password     VARCHAR (10),
  user_email        VARCHAR(30),
  --This will ensure a UNIQUE primary key
  PRIMARY KEY (user_code)
);

--Create database_transaction table
CREATE TABLE database_transaction
(
  transaction_code           NUMERIC NOT NULL,
  entity                     VARCHAR (20) NOT NULL,
  entity_code                NUMERIC NOT NULL,
  transacted_by              VARCHAR(20) NOT NULL,
  transaction_date_time      TIMESTAMP(2) NOT NULL,
  transaction_description    VARCHAR(30),
  transaction_notes          VARCHAR(30),
  --This will ensure a UNIQUE primary key
  PRIMARY KEY (transaction_code)
);

--Create primary_tenant table
CREATE TABLE primary_tenant
(
  tenant_code                NUMERIC NOT NULL,
  tenant_fn                  VARCHAR (10) NOT NULL,
  tenant_ln                  VARCHAR(10) NOT NULL,
  tenant_email               VARCHAR(30),
  tenant_phone               VARCHAR(20) NOT NULL,
  tenant_notes               VARCHAR(100),
  --This will ensire a UNIQUE primary key
  PRIMARY KEY (tenant_code)
);

--Create property table
CREATE TABLE property
(
  property_code              NUMERIC NOT NULL,
  property_nickname          VARCHAR(50) NOT NULL,
  mortgage_years             DECIMAL (8,2) NOT NULL,
  property_address           VARCHAR(50) NOT NULL,
  state                      VARCHAR(2),  
  zipcode                    VARCHAR (5),
  monthly_mortgage           DECIMAL(8,2) NOT NULL,
  hoa                        DECIMAL(8,2) NOT NULL,
  date_bought                DATE,
  sewage                     VARCHAR(30),
  electric                   VARCHAR(30),
  property_notes             VARCHAR(100),
  --This will ensure a UNIQUE primary key
  PRIMARY KEY (property_nickname)
);


--Create rental_contract table
CREATE TABLE rental_contract
(
  occupancy_code             NUMERIC NOT NULL,
  fk_tenant_code             NUMERIC NOT NULL,
  fk_property_nickname       VARCHAR(50) NOT NULL,
  rent                       DECIMAL(8,2) NOT NULL,
  charge_electric_to         VARCHAR(20),
  charge_sewage_to           VARCHAR(30),
  current_tenant             CHAR(1),
  date_start                 DATE NOT NULL,
  date_end                   DATE NOT NULL,
  --This will ensure a UNIQUE primary key
  PRIMARY KEY (occupancy_code),
  FOREIGN KEY (fk_tenant_code) REFERENCES primary_tenant(tenant_code)
);

--Create expense table
CREATE TABLE expense
(
  expense_code               NUMERIC NOT NULL,
  fk_property_nickname       VARCHAR(50) NOT NULL,
  expense_amount             DECIMAL(8,2) NOT NULL,
  expense_description        VARCHAR(50) NOT NULL,
  expense_date               DATE NOT NULL,
  expense_notes              VARCHAR(200),
  --This will ensure a UNIQUE primary key
  PRIMARY KEY (expense_code),
  FOREIGN KEY (fk_property_nickname) REFERENCES property(property_nickname)
);

--Create income table 
CREATE TABLE income
(
  income_code               NUMERIC NOT NULL,
  fk_property_nickname      VARCHAR(50) NOT NULL,
  income_amount             DECIMAL(8,2) NOT NULL,
  income_description        VARCHAR(50) NOT NULL,
  income_date               DATE NOT NULL,
  income_notes              VARCHAR(100),
  --This will ensure a UNIQUE primary key
  PRIMARY KEY (income_code),
  FOREIGN KEY (fk_property_nickname) REFERENCES property(property_nickname)
);

--Create sequences

--Create property_code sequence 
CREATE SEQUENCE  property_code_Seq
START WITH 1
INCREMENT BY 1;

--Create user sequence
CREATE SEQUENCE user_code_Seq
START WITH 100
INCREMENT BY 1;

--Create database_transcation sequence
CREATE SEQUENCE transaction_code_Seq
START WITH 1
INCREMENT BY 1;

--Create tenant_code sequence 
CREATE SEQUENCE tenant_code_Seq
START WITH 1
INCREMENT BY 1;

--Create occupancy_code sequence
CREATE SEQUENCE  occupancy_code_Seq
START WITH 100
INCREMENT BY 1;

--Create expense_code sequence
CREATE SEQUENCE  expense_code_Seq
START WITH 1
INCREMENT BY 1;

--Create income_code sequence 
CREATE SEQUENCE  income_code_Seq
START WITH 1
INCREMENT BY 1;

--Indexes

--Create indexes for foreign keys

--expense table
CREATE INDEX expense_property_nickname_index
ON expense(fk_property_nickname);

--income table
CREATE INDEX income_property_nickname_index
ON income(fk_property_nickname);

--rental_contract table
CREATE INDEX rental_tenant_index
ON rental_contract(fk_tenant_code);

CREATE INDEX rental_property_index
ON rental_contract(fk_property_nickname);

--Add some audit columns to the tables

--user_list
ALTER TABLE user_list 
ADD (
created_by VARCHAR2(30),
date_created DATE,
modified_by VARCHAR2(30),
date_modified DATE
);

--property
ALTER TABLE property 
ADD (
created_by VARCHAR2(30),
date_created DATE,
modified_by VARCHAR2(30),
date_modified DATE
);

--primary_tenant
ALTER TABLE primary_tenant
ADD (
created_by VARCHAR2(30),
date_created DATE,
modified_by VARCHAR2(30),
date_modified DATE
);

--rental_contract
ALTER TABLE rental_contract
ADD (
created_by VARCHAR2(30),
date_created DATE,
modified_by VARCHAR2(30),
date_modified DATE
);

--expense
ALTER TABLE expense
ADD (
created_by VARCHAR2(30),
date_created DATE,
modified_by VARCHAR2(30),
date_modified DATE
);

--income
ALTER TABLE income
ADD (
created_by VARCHAR2(30),
date_created DATE,
modified_by VARCHAR2(30),
date_modified DATE
);

--database_transaction table will not have audit columns as it is an audit table

--Views

--View each table (except database_transaction) without audit columns

--user_list: this view shows basic user_list information without audit columns
CREATE OR REPLACE VIEW view_user_list AS
SELECT user_code, security_level, username, user_password, user_email FROM user_list;

--property: this view shows basic property information without audit columns
CREATE OR REPLACE VIEW view_property AS
SELECT property_code, property_nickname, mortgage_years, property_address, monthly_mortgage, hoa, sewage, electric, property_notes FROM property;

--primary_tenant: this view shows basic primary_tenant information without audit columns
CREATE OR REPLACE VIEW view_primary_tenant AS
SELECT tenant_code, tenant_fn, tenant_ln, tenant_email, tenant_phone, tenant_notes FROM primary_tenant;

--rental_contract: this view shows basic rental_contract information without audit columns
CREATE OR REPLACE VIEW view_rental_contract AS
SELECT occupancy_code, fk_tenant_code, fk_property_nickname, rent, charge_electric_to, charge_sewage_to, current_tenant, date_start, date_end FROM rental_contract;

--expense: this view shows basic expense information without audit columns
CREATE OR REPLACE VIEW view_expense AS
SELECT expense_code, fk_property_nickname, expense_amount, expense_description, expense_date, expense_notes FROM expense;

--income: this view shows basic income information without audit columns
CREATE OR REPLACE VIEW view_income AS
SELECT income_code, fk_property_nickname, income_amount, income_description, income_date, income_notes FROM income;

--Views that manipulate data to show helpful information to the property owner

--Tenant phone view. This view is to create a phone list for the property owner to view and call if necessary
CREATE OR REPLACE VIEW tenant_phone AS
SELECT  tenant_fn || ' ' ||  tenant_ln AS "Name", tenant_phone AS "Phone Number" FROM primary_tenant;

--Expenses by tenant occupancy view. The purpose of this view is to view all expenses incurred by tenant. This is to see if a tenant is causing an abnormal amount of expenses due to damages
CREATE OR REPLACE VIEW tenant_expense AS
SELECT c.tenant_fn || ' ' || c.tenant_ln AS "Name", a.fk_tenant_code AS "tenant_code", b.expense_description, b.expense_amount 
FROM primary_tenant c 
INNER JOIN rental_contract a ON c.tenant_code = a.fk_tenant_code 
INNER JOIN expense b ON a.fk_property_nickname = b.fk_property_nickname; 

--Income paid by each tenant view.
--First set the column size so that it displays in a readable fashion
column c1 heading "Name" format a15
column c2 heading "Property" format a15
column c3 heading "Paid On" format a15
column c4 heading "Description" format a15
column c5 heading "Amount" format a15
column c6 heading "Contract Dates" format a20

--Create the view of income per tenant per property to see how much income has been generated by each tenant per property
--This allows the property owner to see if rent payments have been missed, and if so, if late fees were collected
CREATE OR REPLACE VIEW income_per_tenant_per_rental_contract AS
SELECT a.tenant_fn || ' ' || a.tenant_ln c1, b.fk_property_nickname c2, c.income_date c3, c.income_description c4, c.income_amount c5, b.date_start || ' ' || b.date_end c6
FROM primary_tenant a
INNER JOIN rental_contract b ON a.tenant_code = b.fk_tenant_code
INNER JOIN income c ON b.fk_property_nickname = c.fk_property_nickname
WHERE c.income_date <= (SELECT CURRENT_DATE FROM dual) AND c.income_date >= b.date_start;

--triggers

--audit table database_transaction and sequence triggers for each table

--property table

--trigger to populate the database_transaction table when a row is inserted into property, as well as to create a sequenced primary key when it is null
CREATE OR REPLACE TRIGGER property_insert_trig
BEFORE INSERT 
ON property
FOR EACH ROW
DECLARE entity NUMERIC; username VARCHAR(20); date_time TIMESTAMP;
BEGIN
IF :NEW.property_code IS NULL THEN
:NEW.property_code := property_code_Seq.NEXTVAL;
END IF;
entity := :NEW.property_code;
SELECT sys_context('USERENV','CURRENT_USER') INTO username FROM dual;
SELECT CURRENT_TIMESTAMP INTO date_time FROM dual;
INSERT INTO database_transaction(transaction_code, entity, entity_code, transacted_by, transaction_date_time, transaction_description)
VALUES (transaction_code_Seq.nextVal, 'property', entity, username, date_time, 'Property added'); 
END;
/

--trigger to populate the database_transaction table when a row is updated in property
CREATE OR REPLACE TRIGGER property_update_trig
BEFORE UPDATE ON property
FOR EACH ROW
DECLARE entity NUMERIC; username VARCHAR(20); date_time TIMESTAMP;
BEGIN
IF :NEW.property_code IS NULL THEN
:NEW.property_code := property_code_Seq.NEXTVAL;
END IF;
entity := :NEW.property_nickname;
SELECT sys_context('USERENV','CURRENT_USER') INTO username FROM dual;
SELECT CURRENT_TIMESTAMP INTO date_time FROM dual;
INSERT INTO database_transaction(transaction_code, entity, entity_code, transacted_by, transaction_date_time, transaction_description)
VALUES (transaction_code_Seq.nextVal, 'property', entity, username, date_time, 'Property updated'); 
END;
/

--primary_tenant table

--trigger to populate the database_transaction table when a row is inserted into primary_tenant as well as to create a sequenced primary key when it is null
CREATE OR REPLACE TRIGGER primary_tenant_insert_trig
BEFORE INSERT 
ON primary_tenant
FOR EACH ROW
DECLARE entity NUMERIC; username VARCHAR(20); date_time TIMESTAMP;
BEGIN
IF :NEW.tenant_code IS NULL THEN
:NEW.tenant_code := tenant_code_Seq.NEXTVAL;
END IF;
entity := :NEW.tenant_code;
SELECT sys_context('USERENV','CURRENT_USER') INTO username FROM dual;
SELECT CURRENT_TIMESTAMP INTO date_time FROM dual;
INSERT INTO database_transaction(transaction_code, entity, entity_code, transacted_by, transaction_date_time, transaction_description)
VALUES (transaction_code_Seq.nextVal, 'primary_tenant', entity, username, date_time, 'Primary tenant added'); 
END;
/

--trigger to populate the database_transaction table when a row is updated in primary_tenant table
CREATE OR REPLACE TRIGGER primary_tenant_update_trig
AFTER UPDATE ON primary_tenant
FOR EACH ROW
DECLARE entity NUMERIC; username VARCHAR(20); date_time TIMESTAMP;
BEGIN
entity := :NEW.tenant_code;
SELECT sys_context('USERENV','CURRENT_USER') INTO username FROM dual;
SELECT CURRENT_TIMESTAMP INTO date_time FROM dual;
INSERT INTO database_transaction(transaction_code, entity, entity_code, transacted_by, transaction_date_time, transaction_description)
VALUES (transaction_code_Seq.nextVal, 'primary tenant', entity, username, date_time, 'Property updated'); 
END;
/

--rental_contract table

--trigger to populate the database_transaction table when a row is inserted into rental_contract as well as to create a sequenced primary key when it is null
CREATE OR REPLACE TRIGGER rental_contract_insert_trig
BEFORE INSERT 
ON rental_contract
FOR EACH ROW
DECLARE entity NUMERIC; username VARCHAR(20); date_time TIMESTAMP;
BEGIN
IF :NEW.occupancy_code IS NULL THEN
:NEW.occupancy_code := occupancy_code_Seq.NEXTVAL;
END IF;
entity := :NEW.occupancy_code;
SELECT sys_context('USERENV','CURRENT_USER') INTO username FROM dual;
SELECT CURRENT_TIMESTAMP INTO date_time FROM dual;
INSERT INTO database_transaction(transaction_code, entity, entity_code, transacted_by, transaction_date_time, transaction_description)
VALUES (transaction_code_Seq.nextVal, 'Rental contract', entity, username, date_time, 'Rental contract added'); 
END;
/

--trigger to populate the database_transaction table when a row is updated in rental_contract table
CREATE OR REPLACE TRIGGER rental_contract_update_trig
AFTER UPDATE ON rental_contract
FOR EACH ROW
DECLARE entity NUMERIC; username VARCHAR(20); date_time TIMESTAMP;
BEGIN
entity := :NEW.occupancy_code;
SELECT sys_context('USERENV','CURRENT_USER') INTO username FROM dual;
SELECT CURRENT_TIMESTAMP INTO date_time FROM dual;
INSERT INTO database_transaction(transaction_code, entity, entity_code, transacted_by, transaction_date_time, transaction_description)
VALUES (transaction_code_Seq.nextVal, 'Rental contract', entity, username, date_time, 'Rental contract updated'); 
END;
/

--expense table

--trigger to populate the database_transaction table when a row is inserted into the expense table as well as to create a sequenced primary key when it is null
CREATE OR REPLACE TRIGGER expense_insert_trig
BEFORE INSERT 
ON expense
FOR EACH ROW
DECLARE entity NUMERIC; username VARCHAR(20); date_time TIMESTAMP;
BEGIN
IF :NEW.expense_code IS NULL THEN
:NEW.expense_code := expense_code_Seq.NEXTVAL;
END IF;
entity := :NEW.expense_code;
SELECT sys_context('USERENV','CURRENT_USER') INTO username FROM dual;
SELECT CURRENT_TIMESTAMP INTO date_time FROM dual;
INSERT INTO database_transaction(transaction_code, entity, entity_code, transacted_by, transaction_date_time, transaction_description)
VALUES (transaction_code_Seq.nextVal, 'Expense', entity, username, date_time, 'Expense added'); 
END;
/

--trigger to populate the database_transaction table when a row is updated in expense table
CREATE OR REPLACE TRIGGER expense_update_trig
AFTER UPDATE ON expense
FOR EACH ROW
DECLARE entity NUMERIC; username VARCHAR(20); date_time TIMESTAMP;
BEGIN
entity := :NEW.expense_code;
SELECT sys_context('USERENV','CURRENT_USER') INTO username FROM dual;
SELECT CURRENT_TIMESTAMP INTO date_time FROM dual;
INSERT INTO database_transaction(transaction_code, entity, entity_code, transacted_by, transaction_date_time, transaction_description)
VALUES (transaction_code_Seq.nextVal, 'expense', entity, username, date_time, 'expense updated'); 
END;
/

--income table

--trigger to populate the database_transaction table when a row is inserted into rental_contract as well as to create a sequenced primary key when it is null
CREATE OR REPLACE TRIGGER income_insert_trig
BEFORE INSERT 
ON income
FOR EACH ROW
DECLARE entity NUMERIC; username VARCHAR(20); date_time TIMESTAMP;
BEGIN
IF :NEW.income_code IS NULL THEN
:NEW.income_code := income_code_Seq.NEXTVAL;
END IF;
entity := :NEW.income_code;
SELECT sys_context('USERENV','CURRENT_USER') INTO username FROM dual;
SELECT CURRENT_TIMESTAMP INTO date_time FROM dual;
INSERT INTO database_transaction(transaction_code, entity, entity_code, transacted_by, transaction_date_time, transaction_description)
VALUES (transaction_code_Seq.nextVal, 'Income', entity, username, date_time, 'Income added'); 
END;
/


--trigger to populate the database_transaction table when a row is updated in income table
CREATE OR REPLACE TRIGGER income_update_trig
AFTER UPDATE ON income
FOR EACH ROW
DECLARE entity NUMERIC; username VARCHAR(20); date_time TIMESTAMP;
BEGIN
entity := :NEW.income_code;
SELECT sys_context('USERENV','CURRENT_USER') INTO username FROM dual;
SELECT CURRENT_TIMESTAMP INTO date_time FROM dual;
INSERT INTO database_transaction(transaction_code, entity, entity_code, transacted_by, transaction_date_time, transaction_description)
VALUES (transaction_code_Seq.nextVal, 'Income', entity, username, date_time, 'Income updated'); 
END;
/

--user_list table

--trigger to populate the database_transaction table when a row is inserted into user_list as well as to create a sequenced primary key when it is null
CREATE OR REPLACE TRIGGER user_list_insert_trig
BEFORE INSERT 
ON user_list
FOR EACH ROW
DECLARE entity NUMERIC; username VARCHAR(20); date_time TIMESTAMP;
BEGIN
IF :NEW.user_code IS NULL THEN
:NEW.user_code := user_code_Seq.NEXTVAL;
END IF;
entity := :NEW.user_code;
SELECT sys_context('USERENV','CURRENT_USER') INTO username FROM dual;
SELECT CURRENT_TIMESTAMP INTO date_time FROM dual;
INSERT INTO database_transaction(transaction_code, entity, entity_code, transacted_by, transaction_date_time, transaction_description)
VALUES (transaction_code_Seq.nextVal, 'User', entity, username, date_time, 'User added'); 
END;
/

--trigger to populate the database_transaction table when a row is updated in rental_contract table
CREATE OR REPLACE TRIGGER user_list_update_trig
AFTER UPDATE ON user_list
FOR EACH ROW
DECLARE entity NUMERIC; username VARCHAR(20); date_time TIMESTAMP;
BEGIN
entity := :NEW.user_code;
SELECT sys_context('USERENV','CURRENT_USER') INTO username FROM dual;
SELECT CURRENT_TIMESTAMP INTO date_time FROM dual;
INSERT INTO database_transaction(transaction_code, entity, entity_code, transacted_by, transaction_date_time, transaction_description)
VALUES (transaction_code_Seq.nextVal, 'User', entity, username, date_time, 'User updated'); 
END;
/

--END DDL

--DML Script
SET ECHO ON;
SET SERVEROUTPUT ON;
SET LINESIZE 150;
SET PAGESIZE 200;
--insert some sample data

--parent tables

--primary_tenant table
INSERT INTO primary_tenant (tenant_code, tenant_fn, tenant_ln, tenant_email, tenant_phone, tenant_notes)
VALUES (tenant_code_Seq.nextVal, 'Lisa', 'Smith', 'lisasmith@gmail.com', '222 112 9090', 'requested to pay on the 5th of each month instead of the 1st');

INSERT INTO primary_tenant (tenant_code, tenant_fn, tenant_ln, tenant_email, tenant_phone, tenant_notes)
VALUES (tenant_code_Seq.nextVal, 'Amy', 'Adams', 'amyadams@gmail.com', '222 111 1010', 'has a pet ferret');

INSERT INTO primary_tenant (tenant_code, tenant_fn, tenant_ln, tenant_email, tenant_phone, tenant_notes)
VALUES (tenant_code_Seq.nextVal, 'Barbara', 'Bayleaf', 'barbay@gmail.com', '123 102 3090', 'requested the kitchen be repainted');

INSERT INTO primary_tenant (tenant_code, tenant_fn, tenant_ln, tenant_email, tenant_phone, tenant_notes)
VALUES (tenant_code_Seq.nextVal, 'Curtis', 'Caveman', 'curtcave@gmail.com', '200 312 8766', 'drummer. may new to add soundproofing if neighbors complain');

INSERT INTO primary_tenant (tenant_code, tenant_fn, tenant_ln, tenant_email, tenant_phone, tenant_notes)
VALUES (tenant_code_Seq.nextVal, 'Darlene', 'Davis', 'davisthedarling@gmail.com', '232 122 9990', 'single mom');

INSERT INTO primary_tenant (tenant_code, tenant_fn, tenant_ln, tenant_email, tenant_phone, tenant_notes)
VALUES (tenant_code_Seq.nextVal, 'Elliot', 'Earl', 'earlelli@gmail.com', '213 100 0090', 'neighbors complain he is weird');

INSERT INTO primary_tenant (tenant_code, tenant_fn, tenant_ln, tenant_email, tenant_phone, tenant_notes)
VALUES (tenant_code_Seq.nextVal, 'Farrah', 'Fawcett', 'farfaw@gmail.com', '122 000 9090', '2 dogs');

INSERT INTO primary_tenant (tenant_code, tenant_fn, tenant_ln, tenant_email, tenant_phone, tenant_notes)
VALUES (tenant_code_Seq.nextVal, 'Gary', 'Indiana', 'onedollarhouse@gmail.com', '192 222 1190', 'inherited from previous owner');

INSERT INTO primary_tenant (tenant_code, tenant_fn, tenant_ln, tenant_email, tenant_phone, tenant_notes)
VALUES (tenant_code_Seq.nextVal, 'Harry', 'Smith', 'harhar@gmail.com', '200 162 3489', 'reliable tenant');

INSERT INTO primary_tenant (tenant_code, tenant_fn, tenant_ln, tenant_email, tenant_phone, tenant_notes)
VALUES (tenant_code_Seq.nextVal, 'Ingrid', 'Indigo', 'indigo@gmail.com', '415 199 9090', 'repainted the livingroom purple. take out of deposit when she leaves');

--user_list table
INSERT INTO user_list (user_code, security_level)
VALUES (user_code_Seq.nextVal, 'tenant');

INSERT INTO user_list (user_code, security_level)
VALUES (user_code_Seq.nextVal, 'owner');

INSERT INTO user_list (user_code, security_level)
VALUES (user_code_Seq.nextVal, 'tenant');

INSERT INTO user_list (user_code, security_level)
VALUES (user_code_Seq.nextVal, 'owner');

INSERT INTO user_list (user_code, security_level)
VALUES (user_code_Seq.nextVal, 'tenant');

INSERT INTO user_list (user_code, security_level)
VALUES (user_code_Seq.nextVal, 'tenant');

INSERT INTO user_list (user_code, security_level)
VALUES (user_code_Seq.nextVal, 'tenant');

INSERT INTO user_list (user_code, security_level)
VALUES (user_code_Seq.nextVal, 'tenant');

INSERT INTO user_list (user_code, security_level)
VALUES (user_code_Seq.nextVal, 'tenant');

INSERT INTO user_list (user_code, security_level)
VALUES (user_code_Seq.nextVal, 'tenant');

--property table

INSERT INTO property (property_code, property_nickname, mortgage_years, property_address, state, zipcode, monthly_mortgage, hoa, sewage, electric, property_notes)
VALUES (property_code_Seq.nextVal, 'Alaska', 30, '123 Alaska Street, Tacoma', 'WA', '98499', 900.00, 0.00, 'Tacoma Sewage', 'Tacoma Electric', 'Needs renovations');

INSERT INTO property (property_code, property_nickname, mortgage_years, property_address, state, zipcode, monthly_mortgage, hoa, sewage, electric, property_notes)
VALUES (property_code_Seq.nextVal, 'Edgewood Unit 1', 30, '123 Edgewood Street, Edgewood', 'MD', '21040', 700.00, 0.00, 'YuckYuck Sewage', 'Tacoma Electric', 'mortgage split with unit 2');

INSERT INTO property (property_code, property_nickname, mortgage_years, property_address, state, zipcode, monthly_mortgage, hoa, sewage, electric, property_notes)
VALUES (property_code_Seq.nextVal, 'Edgewood Unit 2', 30, '123 Edgewood Street, Edgewood', 'MD',  '21040', 700.00, 0.00, 'Tacoma Sewage', 'Tacoma Electric', 'mortgage split with unit 1');

INSERT INTO property (property_code, property_nickname, mortgage_years, property_address, state, zipcode, monthly_mortgage, hoa, sewage, electric, property_notes)
VALUES (property_code_Seq.nextVal, 'Yakima Unit 1', 30, '123 Yakima Street, Overland Park', 'KS', '66204', 500.00, 0.00, 'Tacoma Sewage', 'Tacoma Electric', 'mortgage split 4 ways');

INSERT INTO property (property_code, property_nickname, mortgage_years, property_address, state, zipcode, monthly_mortgage, hoa, sewage, electric, property_notes)
VALUES (property_code_Seq.nextVal, 'Yakima Unit 2', 30, '123 Yakima Street, Overland Park', 'KS', '66204', 500.00, 0.00, 'Tacoma Sewage', 'Tacoma Electric', 'mortgage split 4 ways');

INSERT INTO property (property_code, property_nickname, mortgage_years, property_address,  state, zipcode, monthly_mortgage, hoa, sewage, electric, property_notes)
VALUES (property_code_Seq.nextVal, 'Yakima Unit 3', 30, '123 Yakima Street, Overland Park', 'KS', '66204', 500.00, 0.00, 'Tacoma Sewage', 'Tacoma Electric', 'mortgage split 4 ways');

INSERT INTO property (property_code, property_nickname, mortgage_years, property_address,  state, zipcode, monthly_mortgage, hoa, sewage, electric, property_notes)
VALUES (property_code_Seq.nextVal, 'Yakima Unit 4', 30, '123 Yakima Street, Overland Park', 'KS', '66204', 500.00, 0.00, 'Tacoma Sewage', 'Tacoma Electric', 'mortgage split 4 ways');

INSERT INTO property (property_code, property_nickname, mortgage_years, property_address, state,  zipcode, monthly_mortgage, hoa, sewage, electric, property_notes)
VALUES (property_code_Seq.nextVal, 'Monroe Unit 1', 30, '123 Monroe Street, Bel Air', 'MD', '21014', 500.00, 0.00, 'Tacoma Sewage', 'Tacoma Electric', 'mortgage split 4 ways. high-end renovation in 2021');

INSERT INTO property (property_code, property_nickname, mortgage_years, property_address,  state, zipcode, monthly_mortgage, hoa, sewage, electric, property_notes)
VALUES (property_code_Seq.nextVal, 'Monroe Unit 2', 30, '123 Monroe Street, Bel Air', 'MD', '21014', 500.00, 0.00, 'Tacoma Sewage', 'Tacoma Electric', 'mortgage split 4 ways');

INSERT INTO property (property_code, property_nickname, mortgage_years, property_address, state, zipcode, monthly_mortgage, hoa, sewage, electric, property_notes)
VALUES (property_code_Seq.nextVal, 'Monroe Unit 3', 30, '123 Monroe Street, Bel Air', 'MD', '21014', 500.00, 0.00, 'Tacoma Sewage', 'Tacoma Electric', 'mortgage split 4 ways. Recently renovated in 2022');

INSERT INTO property (property_code, property_nickname, mortgage_years, property_address, state, zipcode, monthly_mortgage, hoa, sewage, electric, property_notes)
VALUES (property_code_Seq.nextVal, 'Monroe Unit 4', 30, '123 Monroe Street, Bel Air', 'MD', '21014', 500.00, 0.00, 'Tacoma Sewage', 'Tacoma Electric', 'mortgage split 4 ways. undergoing renovation');

--child tables

--rental_contract table
INSERT INTO rental_contract(occupancy_code, fk_tenant_code, fk_property_nickname, rent, charge_electric_to, charge_sewage_to, current_tenant, date_start, date_end)
VALUES (occupancy_code_seq.nextval, 1, 'Alaska', 1100.00, 'Tenant', 'Tenant', 'Y', DATE '2020-01-01', DATE '2020-12-31');

INSERT INTO rental_contract(occupancy_code, fk_tenant_code, fk_property_nickname, rent, charge_electric_to, charge_sewage_to, current_tenant, date_start, date_end)
VALUES (occupancy_code_seq.nextval, 2, 'Edgewood Unit 1', 800.00, 'Tenant', 'Tenant', 'N', DATE '2020-01-01', DATE '2020-12-31');

INSERT INTO rental_contract(occupancy_code, fk_tenant_code, fk_property_nickname, rent, charge_electric_to, charge_sewage_to, current_tenant, date_start, date_end)
VALUES (occupancy_code_seq.nextval, 2, 'Edgewood Unit 1', 900.00, 'Tenant', 'Tenant', 'N', DATE '2021-01-01', DATE '2021-12-31');

INSERT INTO rental_contract(occupancy_code, fk_tenant_code, fk_property_nickname, rent, charge_electric_to, charge_sewage_to, current_tenant, date_start, date_end)
VALUES (occupancy_code_seq.nextval, 2, 'Edgewood Unit 1', 1100.00, 'Tenant', 'Tenant', 'Y', DATE '2022-01-01', DATE '2022-12-31');

INSERT INTO rental_contract(occupancy_code, fk_tenant_code, fk_property_nickname, rent, charge_electric_to, charge_sewage_to, current_tenant, date_start, date_end)
VALUES (occupancy_code_seq.nextval, 3, 'Edgewood Unit 2', 950.00, 'Tenant', 'Tenant', 'Y', DATE '2022-01-01', DATE '2022-12-31');

INSERT INTO rental_contract(occupancy_code, fk_tenant_code, fk_property_nickname, rent, charge_electric_to, charge_sewage_to, current_tenant, date_start, date_end)
VALUES (occupancy_code_seq.nextval, 4, 'Yakima Unit 1', 1100.00, 'Tenant', 'Tenant', 'Y', DATE '2022-01-01', DATE '2022-12-31');

INSERT INTO rental_contract(occupancy_code, fk_tenant_code, fk_property_nickname, rent, charge_electric_to, charge_sewage_to, current_tenant, date_start, date_end)
VALUES (occupancy_code_seq.nextval, 5, 'Yakima Unit 2', 550.00, 'Tenant', 'Tenant', 'Y', DATE '2022-01-01', DATE '2022-12-31');

INSERT INTO rental_contract(occupancy_code, fk_tenant_code, fk_property_nickname, rent, charge_electric_to, charge_sewage_to, current_tenant, date_start, date_end)
VALUES (occupancy_code_seq.nextval, 6, 'Yakima Unit 3', 1800.00, 'Tenant', 'Tenant', 'Y', DATE '2022-01-01', DATE '2022-12-31');

INSERT INTO rental_contract(occupancy_code, fk_tenant_code, fk_property_nickname, rent, charge_electric_to, charge_sewage_to, current_tenant, date_start, date_end)
VALUES (occupancy_code_seq.nextval, 7, 'Yakima Unit 4', 1150.00, 'Tenant', 'Tenant', 'Y', DATE '2022-01-01', DATE '2022-12-31');

INSERT INTO rental_contract(occupancy_code, fk_tenant_code, fk_property_nickname, rent, charge_electric_to, charge_sewage_to, current_tenant, date_start, date_end)
VALUES (occupancy_code_seq.nextval, 8, 'Monroe Unit 1', 12800.00, 'Tenant', 'Tenant', 'Y', DATE '2022-01-01', DATE '2022-12-31');

INSERT INTO rental_contract(occupancy_code, fk_tenant_code, fk_property_nickname, rent, charge_electric_to, charge_sewage_to, current_tenant, date_start, date_end)
VALUES (occupancy_code_seq.nextval, 9, 'Monroe Unit 2', 800.00, 'Tenant', 'Tenant', 'Y', DATE '2020-01-01', DATE '2020-12-31');

INSERT INTO rental_contract(occupancy_code, fk_tenant_code, fk_property_nickname, rent, charge_electric_to, charge_sewage_to, current_tenant, date_start, date_end)
VALUES (occupancy_code_seq.nextval, 10, 'Monroe Unit 3', 900.00, 'Tenant', 'Tenant', 'Y', DATE '2020-01-01', DATE '2020-12-31');

--expense table
INSERT INTO expense(expense_code, fk_property_nickname, expense_amount, expense_description, expense_date, expense_notes)
VALUES (expense_code_Seq.nextval, 'Monroe Unit 2', 150.00, 'Blocked Drain', DATE '2020-03-12', 'Hair in shower drain');

INSERT INTO expense(expense_code, fk_property_nickname, expense_amount, expense_description, expense_date, expense_notes)
VALUES (expense_code_Seq.nextval, 'Alaska', 100.00, 'Door handles', DATE '2020-03-12', 'tenant is afraid of doorknobs');

INSERT INTO expense(expense_code, fk_property_nickname, expense_amount, expense_description, expense_date, expense_notes)
VALUES (expense_code_Seq.nextval, 'Edgewood Unit 1', 2450.00, 'Exterminator', DATE '2022-05-12', 'infestation due to secret litter of ferret pups in the drywall');

INSERT INTO expense(expense_code, fk_property_nickname, expense_amount, expense_description, expense_date, expense_notes)
VALUES (expense_code_Seq.nextval, 'Edgewood Unit 2', 1150.00, 'Paint and Painter', DATE '2022-09-12', 'Kitchen repainted due to old cooking stains on wall');

INSERT INTO expense(expense_code, fk_property_nickname, expense_amount, expense_description, expense_date, expense_notes)
VALUES (expense_code_Seq.nextval, 'Edgewood Unit 2', 2150.00, 'Exterminator', DATE '2022-08-01', 'Ferrets found in wood panelling. Flea infestation due to this. Ferrets taken to Unit 1 to their mother');

INSERT INTO expense(expense_code, fk_property_nickname, expense_amount, expense_description, expense_date, expense_notes)
VALUES (expense_code_Seq.nextval, 'Edgewood Unit 2', 1550.00, 'Wall repair', DATE '2020-07-27', 'Hole between Unit 1 and Unit 2 discovered');

INSERT INTO expense(expense_code, fk_property_nickname, expense_amount, expense_description, expense_date, expense_notes)
VALUES (expense_code_Seq.nextval, 'Monroe Unit 1', 350.00, 'Chocolate fountain repair', DATE '2022-03-12', 'Chocolate fountain in bathroom needed a new pipe');

INSERT INTO expense(expense_code, fk_property_nickname, expense_amount, expense_description, expense_date, expense_notes)
VALUES (expense_code_Seq.nextval, 'Monroe Unit 1', 250.00, 'Chandeliar Reshining', DATE '2022-05-12', 'Chandelier needed reshining/repolishing');

INSERT INTO expense(expense_code, fk_property_nickname, expense_amount, expense_description, expense_date, expense_notes)
VALUES (expense_code_Seq.nextval, 'Monroe Unit 1', 100.00, 'Blocked Drain', DATE '2022-03-12', 'Diamonds from toilet seat dislodged into drain. Needed retrival');

INSERT INTO expense(expense_code, fk_property_nickname, expense_amount, expense_description, expense_date, expense_notes)
VALUES (expense_code_Seq.nextval, 'Monroe Unit 1', 550.00, 'Tank cleaning', DATE '2022-05-12', 'Jellyfish tank in the lobby required annual cleaning');

INSERT INTO expense(expense_code, fk_property_nickname, expense_amount, expense_description, expense_date, expense_notes)
VALUES (expense_code_Seq.nextval, 'Alaska', 850.00, 'New carpets', DATE '2022-02-02', 'new carpets installed');

INSERT INTO expense(expense_code, fk_property_nickname, expense_amount, expense_description, expense_date, expense_notes)
VALUES (expense_code_Seq.nextval, 'Yakima Unit 1', 1850.00, 'Porch repair', DATE '2022-09-24', 'porch was rotting and needed replacement');

--income table
INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Alaska', 1100.00, 'Rent', DATE '2022-10-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Alaska', 1100.00, 'Rent', DATE '2022-09-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Alaska', 1100.00, 'Rent', DATE '2022-08-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Alaska', 1100.00, 'Rent', DATE '2022-07-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Alaska', 1100.00, 'Rent', DATE '2022-06-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Alaska', 1100.00, 'Rent', DATE '2022-05-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Alaska', 1100.00, 'Rent', DATE '2022-02-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Monroe Unit 1', 12800.00, 'Rent', DATE '2022-01-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Monroe Unit 1', 12800.00, 'Rent', DATE '2022-02-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Monroe Unit 1', 12800.00, 'Rent', DATE '2022-03-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Monroe Unit 1', 100.00, 'Late fee', DATE '2022-04-15');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Monroe Unit 1', 100.00, 'Late fee', DATE '2022-05-15');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Monroe Unit 1', 38400.00, 'Rents due to date', DATE '2022-06-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Edgewood Unit 2', 950.00, 'Rent', DATE '2022-01-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Edgewood Unit 2', 950.00, 'Rent', DATE '2022-02-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Edgewood Unit 2', 950.00, 'Rent', DATE '2022-03-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Edgewood Unit 2', 950.00, 'Rent', DATE '2022-04-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Edgewood Unit 2', 950.00, 'Rent', DATE '2022-05-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Edgewood Unit 2', 950.00, 'Rent', DATE '2022-06-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Edgewood Unit 2', 100.00, 'Late Fee', DATE '2022-06-10');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Edgewood Unit 2', 950.00, 'Rent', DATE '2022-06-25');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Edgewood Unit 2', 950.00, 'Rent', DATE '2022-07-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Edgewood Unit 2', 950.00, 'Rent', DATE '2022-08-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Edgewood Unit 2', 950.00, 'Rent', DATE '2022-09-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Edgewood Unit 2', 950.00, 'Rent', DATE '2022-10-01');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Monroe Unit 3', 100.00, 'Late Fee', DATE '2022-01-10');

INSERT INTO income(income_code, fk_property_nickname, income_amount, income_description, income_date)
VALUES (income_code_Seq.nextval, 'Yakima Unit 3', 100.00, 'Late Fee', DATE '2022-01-10');



--database_transaction not needed to be added as this is done automatically via trigger

--Database queries to show that objects were created

--table queries (but not other tables in the dbst connection)

--show the tables exist
SELECT table_name FROM user_tables WHERE sample_size IS NULL;

--Describe tables
--user_list table
DESCRIBE user_list;

--property table
DESCRIBE property;

--primary_tenant table
DESCRIBE primary_tenant;

--rental_contract table
DESCRIBE rental_contract;

--expense table
DESCRIBE expense;

--income table
DESCRIBE income;

--database_transaction table
DESCRIBE database_transaction;

--indexes
--show indexes exist
-- only objects created after 7 March are selected due to the STUDENT database objects showing up as well
COLUMN a1 HEADING "Object Name" FORMAT a35
COLUMN a2 HEADING "Object Type" FORMAT a15
COLUMN a3 HEADING "Status" FORMAT a15
COLUMN a4 HEADING "Created" FORMAT a15

SELECT object_name a1, object_type a2,  status a3, created a4 
FROM user_objects  
WHERE created > '07-MAR-22' 
AND GENERATED = 'N' 
AND object_type = 'INDEX' ;

--triggers
--view triggers (selected only object_name to simplify viewing)
COLUMN b1 HEADING "Object Name" FORMAT a30
COLUMN b2 HEADING "Object Type" FORMAT a15
COLUMN b3 HEADING "Status" FORMAT a15
COLUMN b4 HEADING "Created" FORMAT a15

SELECT object_name b1, object_type b2,  status b3, created b4 
FROM user_objects 
WHERE object_type='TRIGGER';

--view views
--selected only object_name to simplify viewing
COLUMN d1 HEADING "Object Name" FORMAT a40
COLUMN d2 HEADING "Object Type" FORMAT a15
COLUMN d3 HEADING "Status" FORMAT a15
COLUMN d4 HEADING "Created" FORMAT a15

SELECT object_name d1, object_type d2,  status d3, created d4 
FROM user_objects 
WHERE object_type='VIEW';

--view indexes
--only object__name selected to simplify viewing, and only objects created after 7 March are selected due to the STUDENT database objects showing up as well
COLUMN e1 HEADING "Object Name" FORMAT a20
COLUMN e2 HEADING "Object Type" FORMAT a15
COLUMN e3 HEADING "Status" FORMAT a15
COLUMN e4 HEADING "Created" FORMAT a15
SELECT object_name e1, object_type e2,  status e3, created e4 FROM user_objects WHERE object_type='SEQUENCE' AND created > '07-MAR-22';


--Query 1: Select all columns and all rows from one table 
SELECT *
FROM primary_tenant;

--Query 2: Select five columns and all rows from one table
SELECT fk_property_nickname, expense_amount, expense_description, expense_date, expense_notes 
FROM expense;

--Query 3: Select all columns from all rows from one view
SELECT * 
FROM  income_per_tenant_per_rental_contract;

--Query 4: Using a join on 2 tables, select all columns and all rows from the tables without the use of a Cartesian product
SELECT * 
FROM rental_contract
INNER JOIN primary_tenant
ON rental_contract.fk_tenant_code = primary_tenant.tenant_code;

--Query 5: Select and order data retrieved from one table 
--First set the column size so that it displays in a readable fashion
column c1 heading "Expense Code" format a10
column c2 heading "Property" format a20
column c3 heading "Expense Amount" format a10
column c4 heading "Description" format a20
column c5 heading "Date" format a10
column c6 heading "Notes" format a30

SELECT expense_code c1, fk_property_nickname c2, expense_amount c3, expense_description c4, expense_date c5, expense_notes c6 
FROM expense
ORDER BY expense_date ASC;

--Query 6: Using a join on 3 tables, select 5 columns from the 3 tables. Use syntax that would limit the output to 10 rows 
SELECT c.property_nickname AS "Property", b.tenant_fn AS "First name", b.tenant_ln AS "Last name", a.rent AS "Rent", a.date_end AS "Contract End" 
FROM rental_contract a 
INNER JOIN primary_tenant b
ON a.fk_tenant_code = b.tenant_code
INNER JOIN property c
ON c.property_nickname = a.fk_property_nickname
WHERE b.tenant_code < 11;

--Query 7: Select distinct rows using joins on 3 tables
SELECT DISTINCT b.sewage, b.property_nickname AS "Properties", c.tenant_code AS "Tenant Code" 
FROM rental_contract a
INNER JOIN property b
ON a.fk_property_nickname = b.property_nickname
INNER JOIN primary_tenant c
ON a.fk_tenant_code = c.tenant_code;

--Query 8: Use GROUP BY and HAVING in a select statement using one or more tables
SELECT b.sewage, COUNT(b.property_nickname) AS "Number of Properties", COUNT(c.tenant_code) AS "Number of Contracts" 
FROM rental_contract a
INNER JOIN property b
ON a.fk_property_nickname = b.property_nickname
INNER JOIN primary_tenant c
ON a.fk_tenant_code = c.tenant_code
GROUP BY b.sewage
HAVING COUNT(b.property_nickname) >3;

--Query 9: Use IN clause to select data from one or more tables 
SELECT a.tenant_fn, a.tenant_ln, b.fk_tenant_code, c.property_nickname
FROM primary_tenant a
INNER JOIN rental_contract b
ON a.tenant_code = b.fk_tenant_code
INNER JOIN property c 
ON b.fk_property_nickname = c.property_nickname
WHERE a.tenant_code
IN ('1' , '3', '9');

--Query 10: Select length of one column from one table 
SELECT LENGTH (tenant_notes) AS "Length of Tenant Notes" 
FROM primary_tenant;

--Query 11: Delete one record from one table. Use select statements to demonstrate the table contents before and after the DELETE statement. 
--Make sure you use ROLLBACK afterwards so that the data will not be physically removed 

--Show the table before the DELETE statement 
--First set the column size so that it displays in a readable fashion
column c1 heading "Expense Code" format a10
column c2 heading "Property" format a20
column c3 heading "Expense Amount" format a10
column c4 heading "Description" format a20
column c5 heading "Date" format a10
column c6 heading "Notes" format a30
SELECT expense_code c1, fk_property_nickname c2, expense_amount c3, expense_description c4, expense_date c5, expense_notes c6 FROM expense;


--Delete one record
DELETE 
FROM expense 
WHERE expense_description = 'Wall repair';

--Show the table after the DELETE statement
--First set the column size so that it displays in a readable fashion
column c1 heading "Expense Code" format a10
column c2 heading "Property" format a20
column c3 heading "Expense Amount" format a10
column c4 heading "Description" format a20
column c5 heading "Date" format a10
column c6 heading "Notes" format a30
SELECT expense_code c1, fk_property_nickname c2, expense_amount c3, expense_description c4, expense_date c5, expense_notes c6 FROM expense;


--Rollback after DELETE statement
--Hwoever, the rollback rolls back more than just the DELETE statement (my insert statements, etc.) and causes issues when the script is run all together
--Hence, the rollback is commented out and must be uncommented, run individually (just for the delete statement), and recommented to allow the entire scritp to be run without errors
--ROLLBACK;


-- Query 12: Update one record from one table. Use select statements to demonstrate the table contents before and after the UPDATE statement. 
--Make sure you use ROLLBACK afterwards so that the data will not be physically removed

--Show table contents before update
--First set the column size so that it displays in a readable fashion
column c1 heading "Expense Code" format a10
column c2 heading "Property" format a20
column c3 heading "Expense Amount" format a10
column c4 heading "Description" format a20
column c5 heading "Date" format a10
column c6 heading "Notes" format a30
SELECT expense_code c1, fk_property_nickname c2, expense_amount c3, expense_description c4, expense_date c5, expense_notes c6 FROM expense;

--Update the table
UPDATE expense
SET expense_description = 'Ferret Whisperer'
WHERE expense_code = '5';

--Show table after update
--First set the column size so that it displays in a readable fashion
column c1 heading "Expense Code" format a10
column c2 heading "Property" format a20
column c3 heading "Expense Amount" format a10
column c4 heading "Description" format a20
column c5 heading "Date" format a10
column c6 heading "Notes" format a30
SELECT expense_code c1, fk_property_nickname c2, expense_amount c3, expense_description c4, expense_date c5, expense_notes c6 FROM expense;

--Rollback the update
--(however, this undoes my table inserts as well, renderign the rest of this script problematic hence, this rollback is commented out. )
--When using the update, it should be uncommented and rolled back individually (not the whole script)
--ROLLBACK;

--Perform 8 Additional Advanced Queries 

--Query 13: Calculate the minimum, maximum and average expense per zipcode
SELECT b.zipcode, MIN(a.expense_amount) AS "Min Expense", MAX(a.expense_amount) AS "Max Expense", ROUND(AVG(a.expense_amount)) AS "Avg Expense"
FROM expense a
INNER JOIN property b
ON a.fk_property_nickname = b.property_nickname
GROUP BY b.zipcode;

--Query 14: List the current occupants

--Drop the view that will be created in this query
DROP VIEW current_occupancy;

--Create a view of the current occupants with valid contracts (valid in the current year) with the property name and the dates of the contract
--This view is quite useful, and thus will be used in some queries that follow, to reduce redundant work
CREATE VIEW current_occupancy AS
SELECT DISTINCT d.property_nickname, d.zipcode, b.tenant_code,  b.tenant_fn || ' ' || b.tenant_ln AS "Tenant", c.date_start, c.date_end 
FROM primary_tenant b
INNER JOIN rental_contract c
ON b.tenant_code = c.fk_tenant_code
INNER JOIN property d
ON d.property_nickname = c.fk_property_nickname
WHERE c.current_tenant = 'Y'
AND c.date_end > (
                   SELECT add_months(
                                     (
                                        SELECT sysdate
                                        FROM dual
                                      ), 12*-1
                                     ) FROM dual
                 );

--Show the current occupants
SELECT * 
FROM current_occupancy;

--Query 15: Show the average expense per zipcode in the last year-to-date
SELECT DISTINCT a.zipcode, ROUND(AVG(b.expense_amount)) AS "Avg Expense"
FROM property a
FULL JOIN expense b
ON a.property_nickname = b.fk_property_nickname
WHERE b.expense_date >= (SELECT TO_CHAR(ADD_MONTHS((SELECT sysdate FROM dual), 12*-1),'dd-MON-yyyy') FROM dual)
AND b.expense_date <= (SELECT SYSDATE FROM DUAL)
GROUP BY a.zipcode
ORDER BY "Avg Expense" DESC;

--Query 16: Show tenants that are accumulating more than the average expenses in their zipcode in the last year
--We will use the previously developed view "current_occupancy"

--Drop the view that will be created in this query
DROP VIEW expense_summary;

--first, calculate the expected versus actual expediture during the life of the tenant's contract (not year to date, nor calendar year, but each contract year)
CREATE VIEW expense_summary AS
SELECT a.tenant_code, a.zipcode, NVL(ROUND(MONTHS_BETWEEN((SELECT sysdate FROM dual), a.date_start)/12, 2) * b."Avg Expense", 0) AS "Expected", NVL(c."Expenses Accumulated",0) AS "Actual" 
FROM current_occupancy a
INNER JOIN average_per_zip b
ON a.zipcode = b.zipcode
FULL JOIN accumulated_expense c 
ON c.tenant_code = a.tenant_code;

---Next, show the tenants that accumulated more expenses than what was expected/average using the cumulative view "expense summary"  developed in this query
SELECT a.tenant_code, a.tenant_fn || ' ' || a.tenant_ln AS "Tenant", a.tenant_phone, b."Actual" - b."Expected" AS "Over Average Per ZIP By"
FROM primary_tenant a 
INNER JOIN expense_summary b
ON a.tenant_code = b.tenant_code
WHERE b."Actual" > b."Expected";

--Query 16: Calculate how much income per tenant has been accumulated from properties in Washington state and Maryland
--We will use the previously developed view "current_occupancy" to assist

SELECT a.property_nickname, a."Tenant", a.tenant_code, SUM(b.income_amount) AS "Income Accumulated"
FROM current_occupancy a
INNER JOIN income b
ON a.property_nickname = b.fk_property_nickname
INNER JOIN property c 
ON a.property_nickname = c.property_nickname
WHERE c.state IN ('WA', 'MD')
GROUP BY a.property_nickname, a."Tenant", a.tenant_code;


--Query 17: List the tenants with current rental contracts who are behind in rent payments.
--We will use previously developed view, "current_occupancy", and develop new views based off of this to further the queries
DROP VIEW months_of_rent;
DROP VIEW rent_due;
DROP VIEW due_and_received_rent;

--First, create a view to calculate the number of months of rent due for contracts that are current
CREATE VIEW months_of_rent AS
SELECT tenant_code, round (
                            MONTHS_BETWEEN(
                                           (
                                             SELECT sysdate
                                             FROM dual
                                            ), date_start
                                          )
                            ) AS "Rent Payments Due"
FROM current_occupancy;

--Calculate the dollar amount of rent due over the course of the rental contract to date per tenant for current contracts, using the views created in this query
CREATE VIEW rent_due AS
SELECT a.tenant_code, a."Rent Payments Due" * b.rent AS "Rent Due"
FROM months_of_rent a
INNER JOIN rental_contract b
ON a.tenant_code = b.fk_tenant_code
WHERE b.date_end  > (
                      SELECT sysdate FROM dual
                     );

--Create a view showing the rent due and the rent received per current occupant, using the views created in this query to this point
CREATE VIEW due_and_received_rent AS
SELECT a.tenant_code, c."Rent Due", SUM(b.income_amount) AS "Rent Received"
FROM current_occupancy a
RIGHT OUTER JOIN rent_due c
ON a.tenant_code = c.tenant_code
INNER JOIN rental_contract d
ON c.tenant_code = d.fk_tenant_code
INNER JOIN property e
ON d.fk_property_nickname = e.property_nickname
INNER JOIN income b
ON b.fk_property_nickname = e.property_nickname
WHERE b.income_date BETWEEN TO_DATE(a.date_start) AND TO_DATE(a.date_end)
AND b.income_description = 'Rent'
GROUP BY a.tenant_code,  c."Rent Due";

--Show the details of the tenants with current rental contracts who are behind in rent, using the cumulative view created previously in this query
SELECT a.tenant_fn, a.tenant_ln, a.tenant_code, a.tenant_phone, a.tenant_email, ABS(b."Rent Received" - b."Rent Due") AS "Overdue By"
FROM primary_tenant a
RIGHT OUTER JOIN due_and_received_rent b
ON a.tenant_code = b.tenant_code
WHERE b."Rent Due" > b."Rent Received";

/*Query 18: List tenants who need their rental contracts renewed.
This includes tenants do  not have current rental contracts, but are still paying rent or late fees, i.e. are still actively living in the unit, 
as well as tenants whose contracts are expired, but they are still listed as current*/

--Drop views that will be created in this query
DROP VIEW paying_but_expired;
DROP VIEW current_but_expired;

--First, create a view to show tenants who are paying rent or late fees, but have an expired contract
CREATE VIEW paying_but_expired AS
SELECT DISTINCT fk_tenant_code
FROM income a
INNER JOIN rental_contract b
ON a.fk_property_nickname = b.fk_property_nickname
WHERE (
         a.income_description = 'Rent' 
         OR a.income_description = 'Late Fees' 
       )
AND b.date_end < a.income_date;

--Create a view to show tenants who are  listed as current, but have an expired contract
CREATE VIEW current_but_expired AS
SELECT a.fk_tenant_code 
FROM rental_contract a 
WHERE a.current_tenant = 'Y' 
AND a.date_end < (
                   SELECT sysdate FROM dual
                  );

--Merge the two views to create a comprehensive picture of tenants who need their contracts renewed, including their names, their contract details, 
--as well as the expiry date of their contract and the number of months the contract has been expired for.

SELECT DISTINCT a.tenant_code, a.tenant_fn || ' ' || a.tenant_ln AS "Tenant name", a.tenant_phone, a.tenant_email, d.date_end AS "Expiry Date",
       round(MONTHS_BETWEEN((select sysdate from dual), d.date_end)) AS "Months Expired"
FROM primary_tenant a 
INNER JOIN rental_contract d
ON a.tenant_code = d.fk_tenant_code
INNER JOIN current_but_expired b
ON a.tenant_code = b.fk_tenant_code
FULL OUTER JOIN paying_but_expired c
ON a.tenant_code = c.fk_tenant_code
ORDER BY a.tenant_code ASC;

--Query 19: show the average income per property in each in descending order

--drop the views that will be created to complete this query
DROP VIEW properties_per_state;
DROP VIEW income_by_state;

--Create a view to show properties per state
CREATE VIEW properties_per_state AS
SELECT state, COUNT(property_nickname) AS "Number"
FROM property 
GROUP BY state;

--Create a view to show income per state
CREATE VIEW income_by_state AS
SELECT b.state, SUM(a.income_amount) AS "State Income"
FROM income a
INNER JOIN property b
ON  a.fk_property_nickname = b.property_nickname
GROUP BY b.state;

--Show average income per property in each state
--Using the income_by_state and properties_per_state views
SELECT DISTINCT a.state, round(b."State Income"/c."Number",2) AS "Average Income Per Property"
FROM property a
INNER JOIN income_by_state b
ON a.state = b.state
INNER JOIN properties_per_state c
ON a.state = c.state
ORDER BY "Average Income Per Property" DESC;

--Query 20: For each zipcode that has at least one current tenant with a valid contract, show the number of tenants in that zipcode.
SELECT a.zipcode, COUNT(c.fk_tenant_code) AS "Number of Tenants"
FROM property a
INNER JOIN rental_contract c
ON a.property_nickname = c.fk_property_nickname
INNER JOIN primary_tenant b
ON c.fk_tenant_code = b.tenant_code
WHERE b.tenant_code IN 
(
    SELECT c.fk_tenant_code 
    FROM rental_contract c 
    WHERE c.date_end > 
    (
        SELECT sysdate
        FROM dual
    ) 
)
AND c.current_tenant = 'Y'
GROUP BY a.zipcode;

--END
