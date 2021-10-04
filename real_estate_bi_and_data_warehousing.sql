-- 1. Clean data
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- STATE
select * from monre.state;
select count(*) from monre.state;
select distinct state_code from monre.state;
select distinct state_name from monre.state;
-- ERROR 1: a null value in state_code and an invalid value in state_name

-- Clean data and create table state
drop table state purge;
create table state as select distinct * from monre.state;

delete from state where state_code is null; -- Fix ERROR 1

select * from state;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- POSTCODE
select * from monre.postcode;
select count(*) from monre.postcode;
select distinct postcode from monre.postcode order by postcode;
select distinct state_code from monre.postcode;

-- Check every postcode is distinct
select postcode, count(*) from monre.postcode group by postcode having count(*) > 1;

-- Check every row is distinct
select postcode, state_code, count(*) from monre.postcode group by postcode, state_code having count(*) > 1;

-- Check every state_code exists in the state table
select * from monre.postcode where state_code not in (select state_code from state); 

-- Create table postcode 
drop table postcode purge;
create table postcode as select distinct * from monre.postcode;
select * from postcode;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- ADDRESS
select * from monre.address;
select count(*) from monre.address;
select distinct street from monre.address;
select distinct suburb from monre.address;
select distinct postcode from monre.postcode;

-- Check every address_id is distinctr
select address_id, count(*) from monre.address group by address_id having count(*) > 1;

-- Check there are no duplicated adresses (with different IDs)
select * from monre.address where street in 
(select street from 
(select street, suburb, postcode, count(*) from monre.address 
group by street, suburb, postcode having count(*) > 1))
order by street, suburb, postcode; 
-- ERROR 2: Duplicated addresses with different PK (address_id)

-- Check every postcode exists in the postcode table
select * from address where postcode not in (select postcode from postcode);

-- Clean data and create table address
drop table address purge;
create table address as select distinct * from monre.address;

delete from address where street in 
(select street from 
(select street, suburb, postcode, count(*) from address 
group by street, suburb, postcode having count(*) > 1)); -- Fix ERROR 2

select * from address;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- ADVERTISEMENT
select * from monre.advertisement;
select count(*) from monre.advertisement;

-- Check every advert_id and advert_name are distinct
select advert_id, count(*) from monre.advertisement group by advert_id having count(*) > 1;
select advert_name, count(*) from monre.advertisement group by advert_name having count(*) > 1;

-- Check if there are any invalid values 
select * from monre.advertisement where advert_id <= 0; 

-- Create table advertisement
drop table advertisement purge;
create table advertisement as select distinct * from monre.advertisement;
select * from advertisement;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- PERSON
select * from monre.person;
select count(*) from monre.person;
select distinct person_id from monre.person order by person_id;
select distinct title from monre.person;
select distinct first_name from monre.person;
select distinct last_name from monre.person;
select distinct gender from monre.person;
select distinct address_id from monre.person order by address_id;

-- Check every person_id is distinct
select person_id, count(*) from  monre.person group by person_id having count(*) > 1;
select * from monre.person where person_id = 6995;
-- ERROR 3: person_id 6995 is duplicated

-- Check every row is distinct
select title, first_name, last_name, gender, address_id, phone_no, email, count(*) 
from monre.person
group by title, first_name, last_name, gender, address_id, phone_no, email 
having count(*) > 1;
-- Same as error 3

-- Check if person_id is null or < 0
select * from monre.person where person_id is null or person_id < 0;

-- Check null values
select * from monre.person where title = 'null';
-- ERROR 4: null values for person_id 7001

-- Check every address_id exists in the address table
select * from monre.person where address_id not in (select address_id from address);
-- Same as error 4

-- Clean data and create table person 
drop table person purge;
create table person as select distinct * from monre.person; -- Fix ERROR 3

delete from person where person_id = 7001; -- Fix ERROR 4

select * from person;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- AGENT
select * from monre.agent;
select count(*) from monre.agent;
select distinct salary from monre.agent;

-- Check every person_id is distinct
select person_id, count(*) from monre.agent group by person_id having count(*) > 1;

-- Check if person_id is null or < 0
select * from monre.agent where person_id is null or person_id < 0;

-- Check salary of agents are within a reasonable range
select * from monre.agent where salary is null or salary <= 0 or salary >= 1000000; 
-- ERROR 5: Incorrect salary figures for person_id 6844, 6000, 6997

-- Check every person_id exists in the person table;
select * from monre.agent where person_id not in (select person_id from person);
-- ERROR 6: person_id 6997 is not in the person table

-- Clean data and create table agent
drop table agent purge;
create table agent as select * from monre.agent;

update agent set salary = 100000 where person_id = 6844; -- Fix ERROR 5
update agent set salary = 120000 where person_id = 6000; -- Fix ERROR 5
delete from agent where person_id = 6997; -- Fix ERROR 6

select * from agent;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- OFFICE
select * from monre.office;
select count(*) from monre.office;
select distinct office_id from monre.office order by office_id;
select distinct office_name from monre.office;

-- Check every office_id and office_name are distinct
select office_id, count(*) from monre.office group by office_id having count(*) > 1;
select office_name, count(*) from monre.office group by office_name having count(*) > 1;

-- Check if office_id is null or < 0
select * from monre.office where office_id is null  or office_id < 0;

-- Check every row is distinct
select office_id, office_name, count(*) from monre.office group by office_id, office_name having count(*) > 1;

-- Create table office
drop table office purge;
create table office as select distinct * from monre.office; 
select * from office;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- AGENT_OFFICE
select * from monre.agent_office;
select count(*) from monre.agent_office;
select distinct person_id from monre.agent_office order by person_id;
select distinct office_id from monre.agent_office order by office_id;

-- Check if every person_id and office_id are null or < 0
select * from monre.agent_office where person_id is null or person_id < 0;
select * from monre.agent_office where office_id is null or office_id < 0;

-- Check every row is distinct
select person_id, office_id, count(*) from monre.agent_office group by person_id, office_id having count(*) > 1;

--Check if any person_id does not exist in the agent table
select * from monre.agent_office where person_id not in (select person_id from agent);
-- ERROR 7: person_id 6997 not in the agent table

-- Check if any office ID does not exist in the office table
select * from monre.agent_office where office_id not in (select office_id from office);

-- Clean data and create table agent_office
drop table agent_office purge;
create table agent_office as select distinct * from monre.agent_office;

delete from agent_office where person_id = 6997; -- Fix ERROR 7

select * from agent_office;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CLIENT
select * from monre.client;
select count(*) from monre.client;
select distinct person_id from monre.client order by person_id;
select distinct max_budget from monre.client order by max_budget;

-- Check every person ID is distinct
select person_id, count(*) from monre.client group by person_id having count(*) > 1;

-- Check if person_id is null or < 0
select * from monre.client where person_id is null or person_id < 0;

-- Check if max_budget is null or < 0
select * from monre.client where max_budget is null or max_budget < 0; 
-- ERROR 8: The max budget of person_id 5901 is less than 0

-- Check if max_budget < min_budget
select * from monre.client where max_budget <= min_budget; 
-- ERROR 9: Maximum budget is less than minimum budget for 3 person_id 5900, 5901, 5902

-- Check every person_id exists in the person table
select * from monre.client where person_id not in (select person_id from person);
-- ERROR 10: person_id 7000, 7001 is not in the person table

-- Clean data and create table client
drop table client purge;
create table client as select * from monre.client;

update client set max_budget = 15000 where person_id = 5901; -- Fix ERROR 8
update client set max_budget = 8500 where person_id = 5900; -- Fix ERROR 9
update client set min_budget = 50 where person_id = 5900; -- Fix ERROR 9
update client set max_budget = 12500 where person_id = 5902; -- Fix ERROR 9
update client set min_budget = 5440 where person_id = 5902; -- Fix ERROR 9 
delete from client where person_id = 7000 and person_id = 7001; -- Fix ERROR 10

select * from monre.client;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- FEATURE  
select * from monre.feature;
select count(*) from monre.feature;
select distinct feature_code from monre.feature order by feature_code;
select distinct feature_description from monre.feature;

-- Check every feature_code and feature_description are distinct
select feature_code, count(*) from monre.feature group by feature_code having count(*) > 1;
select feature_description, count(*) from monre.feature group by feature_description having count(*) > 1;

-- Check if feature_code is null or < 0
select * from monre.feature where feature_code is null or feature_code < 0;

-- Check if feature_description is null
select * from monre.feature where feature_description is null;

-- Check every row is distinct
select feature_code, feature_description, count(*) from monre.feature group by feature_code, feature_description having count(*) > 1;

-- Create table feature
drop table feature purge;
create table feature as select * from monre.feature;
select * from feature;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CLIENT_WISH
select * from monre.client_wish;
select count(*) from monre.client_wish;
select distinct feature_code from monre.client_wish order by feature_code;
select distinct person_id from monre.client_wish order by person_id;

-- Check if there are any null values in client_wish
select * from monre.client_wish 
where feature_code is null or person_id is null;

-- Check every feature_code or person_id exists in the feature and client table respectively
select * from monre.client_wish 
where feature_code not in (select feature_code from feature)
or person_id not in (select person_id from client);

-- Create table client_wish
drop table client_wish purge;
create table client_wish as select * from monre.client_wish;
select * from client_wish;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- PROPERTY
select * from monre.property;
select count(*) from monre.property;
select distinct property_id from monre.property;
select distinct property_date_added from monre.property;
select distinct address_id from monre.property order by address_id;
select distinct property_type from monre.property;
select distinct property_no_of_bedrooms from monre.property;
select distinct property_no_of_bathrooms from monre.property;
select distinct property_no_of_garages from monre.property;
select distinct property_size from monre.property order by property_size desc;

-- Check every property_id is distinct
select property_id, count(*) from monre.property group by property_id having count(*) > 1;
-- ERROR 11: duplicated values for person_id 6177, 6179

-- Check if property_id is null or < 0
select * from monre.property where property_id is null or property_id < 0;

-- Check every row is distinct
select property_date_added, address_id, property_type, 
property_no_of_bedrooms, property_no_of_bathrooms, property_no_of_garages, property_size, property_description, count(*)
from monre.property 
group by property_date_added, address_id, property_type, 
property_no_of_bedrooms, property_no_of_bathrooms, property_no_of_garages, property_size, property_description
having count(*) > 1;
-- Same as error 11

-- Check every address_id exists in the address table
select * from monre.property where address_id not in (select address_id from monre.address);

-- Clean data and create table property
drop table property purge;
create table property as select distinct * from monre.property; -- Fix error 11
select * from property;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- PROPERTY_ADVERT
select * from monre.property_advert;
select count(*) from monre.property_advert;
select distinct property_id from monre.property_advert order by property_id desc;
select distinct advert_id from monre.property_advert order by advert_id desc;
select distinct agent_person_id from monre.property_advert order by agent_person_id desc; 
select distinct cost from monre.property_advert order by cost desc;

-- Check if every property_id exists in the property table
select * from monre.property_advert where property_id not in (select property_id from property);

-- Check if every advert_id exists in the advertisement table
select * from monre.property_advert where advert_id not in (select advert_id from advertisement);

-- Check if every agent_person_id exists in the agent table
select * from monre.property_advert where agent_person_id not in (select person_id from agent);

-- Check if cost is null or < 0;
select * from monre.property_advert where cost is null or cost < 0;

-- Check every row is distinct
select property_id, advert_id, agent_person_id, cost, count(*)
from monre.property_advert 
group by property_id, advert_id, agent_person_id, cost
having count(*) > 1;

-- Create table property_advert
drop table property_advert;
create table property_advert as select distinct * from monre.property_advert;
select * from property_advert;
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------- 
-- PROPERTY_FEATURE
select * from monre.property_feature;
select distinct property_id from monre.property_feature order by property_id desc;
select distinct feature_code from monre.property_feature order by feature_code desc;

-- Check every property_id exists in the property table
select * from monre.property_feature where property_id not in (select property_id from property);

-- Check every feature_code exists in the property table
select * from monre.property_feature where feature_code not in (select feature_code from property);

-- Check every row is distinct
select property_id, feature_code, count(*) from monre.property_feature group by property_id, feature_code having count(*) > 1;

-- Create table property_feature
drop table property_feature purge;
create  table property_feature as select distinct * from monre.property_feature;
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------- 
-- RENT
select * from monre.rent;
select count(*) from monre.rent;
select distinct rent_id from monre.rent order by rent_id desc;
select distinct agent_person_id from monre.rent order by agent_person_id desc;
select distinct client_person_id from monre.rent order by client_person_id desc;
select distinct property_id from monre.rent order by property_id desc;
select distinct rent_start_date from monre.rent;
select distinct rent_end_date from monre.rent;
select distinct price from monre.rent order by price desc;

-- Check every rent_id is distinct
select rent_id, count(*) from monre.rent group by rent_id having count(*) > 1;

-- Check every agent_person_id exists in the agent table
select * from monre.rent where agent_person_id not in (select person_id from agent);
-- ERROR 12: agent_person_id 6002 is not in the agent table

-- Check every client_person_id  exists in the client table
select * from monre.rent where client_person_id not in (select person_id from client);
-- ERROR 13: client_person_id is not in the client table

-- Check every property_id exists in the property table
select * from monre.rent where property_id not in (select property_id from property);

-- Check if price is <= 0 or null
select * from monre.rent where price <= 0 or price is null;

-- Check if rent_start_date > rent_end_date
select * from monre.rent where rent_start_date > rent_end_date; 
-- ERROR 14: in rent_id 3284, rent_start_date > rent_end_date

-- Clean data and create table rent
drop table rent purge;
create table rent as select distinct * from  monre.rent;

delete from rent where agent_person_id = 6002; -- Fix ERROR 12, ERROR 13 and ERROR 14

select * from rent;
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------- 
-- SALE
select * from monre.sale;
select count(*) from monre.sale;
select distinct sale_id from monre.sale order by sale_id desc;
select distinct agent_person_id from monre.sale order by agent_person_id desc;
select distinct client_person_id from monre.sale order by client_person_id desc;
select distinct sale_date from monre.sale order by sale_date desc; 
select distinct property_id from monre.sale order by property_id desc;
select distinct price from monre.sale order by price desc;

-- Check every rent_id is distinct
select sale_id, count(*) from monre.sale group by sale_id having count(*) > 1;

-- Check every agent_person_id exists in the agent table
select * from monre.sale where agent_person_id not in (select person_id from agent);

-- Check every client_person_id  exists in the client table
select * from monre.sale where client_person_id not in (select person_id from client);

-- Check every property_id exists in the property table
select * from monre.sale where property_id not in (select property_id from property);

-- Check if price is <= 0 or null
select * from monre.sale where price <= 0 or price is null;

-- Create table sale
drop table sale purge;
create table sale as select distinct * from  monre.sale;
select * from sale;
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------- 
-- VISIT
select * from monre.visit;
select count(*) from monre.visit;
select distinct client_person_id from monre.visit order by client_person_id desc;
select distinct agent_person_id from monre.visit order by agent_person_id desc;
select distinct property_id from monre.visit order by property_id desc;
select distinct visit_date from monre.visit order by visit_date desc;
select distinct duration from monre.visit order by duration desc;

-- Check every row is distinct
select client_person_id, agent_person_id, property_id, visit_date, count(*)
from monre.visit
group by client_person_id, agent_person_id, property_id, visit_date
having count(*) > 1;

-- Check every client_person_id exists in the client table
select * from monre.visit where client_person_id not in (select person_id from client);
-- ERROR 15: client_person_id 6000 is not in the client table

-- Check every agent_person_id exists in the agent table
select * from monre.visit where agent_person_id not in (select person_id from agent);
-- ERROR 16: agent_person_id 6001 is not in the agent table

-- Check every property_id exists in the property table
select * from monre.visit where property_id not in (select property_id from property);

-- Check every visit_date is valid
select distinct to_char(visit_date, 'yyyy') from monre.visit;
-- ERROR 17: Year 2999 does not make sense

-- Clean data and create table visit
drop table visit purge;
create table visit as select distinct * from monre.visit;

delete from visit where client_person_id = 6000; -- Fix ERROR 15, ERROR 16, ERROR 17
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------- 
-- 2. Data warehouse
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Dimension tables
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- BUDGET_DIM
drop table budget_dim purge;
create table budget_dim (
budget_category varchar2(20),
minimum_budget numeric,
maximum_budget numeric);

insert into budget_dim values ('Low', 0, 1000);
insert into budget_dim values ('Medium', 1001, 100000);
insert into budget_dim values ('High', 100001, 10000000);

select * from budget_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- GENDER_DIM
drop table gender_dim purge;
create table gender_dim as select distinct gender from person;

select * from gender_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- FEATURE_DIM
drop table feature_dim purge;
create table feature_dim as select distinct * from feature;

select * from feature_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CLIENT_WISH_DIM
drop table client_wish_dim purge;
create table client_wish_dim as select distinct * from client_wish;

select * from client_wish_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CLIENT_DIM
drop table client_dim purge;
create table client_dim as select distinct c.person_id as client_id, p.title, p.first_name, p.last_name
from client c, person p where c.person_id = p.person_id order by c.person_id;

select * from client_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- AGENT_DIM
drop table agent_dim purge;
create table agent_dim as select distinct a.person_id as agent_id, p.title, p.first_name, p.last_name
from agent a, person p where a.person_id = p.person_id order by a.person_id;

select * from agent_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- AGENT_OFFICE_GROUP_DIM
-- Create table pog_temp_dim containing total employees and size for each office
drop table pog_temp_dim purge;
create table pog_temp_dim as
select ao.office_id, o.office_name, count(ao.person_id) as total_employees 
from agent_office ao, office o 
where ao.office_id = o.office_id
group by ao.office_id, o.office_name;

alter table pog_temp_dim add (office_size varchar2(20));
update pog_temp_dim set office_size =
(case
when total_employees < 4 then 'Small'
when total_employees >= 4 and total_employees <= 12 then 'Medium'
when total_employees >12 then 'Big'
end);

select * from pog_temp_dim;

-- Create table person_ffice_group_dim containing office_group_list
drop table agent_office_group_dim purge;
create table agent_office_group_dim as select distinct a.person_id as agent_id,
listagg(ao.office_id, ',') within group (order by ao.office_id) as office_group_list,
listagg(a1.office_size, ',') within group (order by a1.office_size) as size_group_list,
listagg(a1.office_name, ',') within group (order by a1.office_name) as name_group_list
from agent a, agent_office ao, pog_temp_dim a1
where a.person_id = ao.person_id
and ao.office_id = a1.office_id
group by a.person_id;

select * from agent_office_group_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- LOCATION_DIM
drop table location_dim purge;
create table location_dim as select distinct a.address_id, a.street, a.suburb, p.state_code, s.state_name
from address a, postcode p, state s
where a.postcode = p.postcode
and p.state_code = s.state_code
order by p.state_code;

select * from location_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- RENTAL_PROPERTY_DIM
drop table rental_property_temp_dim purge;
create table rental_property_temp_dim as
select distinct r.property_id, p.property_type, p.property_no_of_bedrooms, r.rent_start_date
from rent r, property p
where r.property_id = p.property_id
and r.rent_start_date is not null;

alter table rental_property_temp_dim add (property_scale varchar2(20));

update rental_property_temp_dim set property_scale =
(case
when property_no_of_bedrooms <= 1 then 'Extra small'
when property_no_of_bedrooms in (2,3) then 'Small'
when property_no_of_bedrooms in (4,5,6) then 'Meidum'
when property_no_of_bedrooms in (7,8,9,10) then 'Large'
when property_no_of_bedrooms > 10 then 'Extra large'
end);

drop table rental_property_dim purge;
create table rental_property_dim as select property_id, property_type, property_scale, rent_start_date
from rental_property_temp_dim order by property_id;

select * from rental_property_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- RENTAL_PRICE_DIM
drop table rental_price_dim purge;
create table rental_price_dim as select distinct property_id, rent_start_date, rent_end_date, price 
from rent where rent_start_date is not null order by property_id;

select * from rental_price_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- FEATURE_CATEGORY_DIM
drop table feature_category_dim purge;
create table feature_category_dim (
feature_category varchar2(20),
min_features numeric, 
max_features numeric);

insert into feature_category_dim values ('Very basic', 1, 9);
insert into feature_category_dim values ('Standard', 10, 20);
insert into feature_category_dim values ('Luxurious', 21, 100000);

select * from feature_category_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- RENTAL_PERIOD_DIM
drop table rental_period_dim purge;
create table rental_period_dim (
rental_period varchar2(20),
min_duration numeric,
max_duration numeric,
remarks varchar2(20));

insert into rental_period_dim values ('Short', 0, 5, 'Rented_property');
insert into rental_period_dim values ('Meidum', 5, 12, 'Rented_property');
insert into rental_period_dim values ('Long', 12, 100000, 'Rented_property');
insert into rental_period_dim values (null, null, null, 'Unrented_property');

select * from rental_period_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- RENTAL_TIME_DIM
-- Assume rental time is indentified based on rent_start_date
drop table rental_time_dim purge;
create table rental_time_dim as 
select distinct to_char(rent_start_date, 'yyyymmdd') as rental_time_id,
to_char(rent_start_date, 'yyyy') as year, to_char(rent_start_date, 'mm') as month,
to_char(rent_start_date, 'dd') as date1
from rent where rent_start_date is not null order by rental_time_id;

alter table rental_time_dim add (season varchar2(20));

update rental_time_dim set season =
(case
when month >= 9 and month <= 11 then 'Spring'
when month in (12,1,2) then 'Summer'
when month >= 3 and month <=  5 then 'Autumn'
when month >= 6 and month <= 8 then 'Winter'
end);

select * from rental_time_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- SALE_TIME_DIM
drop table sale_time_dim purge;
create table sale_time_dim as 
select distinct to_char(sale_date, 'yyyymm') as sale_time_id,
to_char(sale_date, 'yyyy') as year, to_char(sale_date, 'mm') as month
from sale where sale_date is not null order by sale_time_id;

alter table sale_time_dim add (season varchar2(20));
update sale_time_dim set season =
(case
when month >= 9 and month <= 11 then 'Spring'
when month in (12,1,2) then 'Summer'
when month >= 3 and month <=  5 then 'Autumn'
when month >= 6 and month <= 8 then 'Winter'
end);

select * from sale_time_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- SALE_PROPERTY_DIM
-- Create table p1
drop table p1 purge;
create table p1 as
select s.property_id, listagg(pf.feature_code, ',') within group (order by pf.feature_code) as feature_group_list,
listagg(f.feature_description, ',') within group (order by f.feature_description) as description_group_list
from sale s, property_feature pf, feature f
where s.property_id = pf.property_id
and s.sale_date is not null
and pf.feature_code = f.feature_code
group by s.property_id;
select * from p1;

-- Create table p2 
drop table p2 purge;
create table p2 as
select distinct s.property_id, p.property_type, p.property_no_of_bedrooms
from sale s, property p
where s.property_id = p.property_id
and sale_date is not null;

alter table p2 add (property_scale varchar2(20));

update p2 set property_scale =
(case
when property_no_of_bedrooms <= 1 then 'Extra small'
when property_no_of_bedrooms in (2,3) then 'Small'
when property_no_of_bedrooms in (4,5,6) then 'Meidum'
when property_no_of_bedrooms in (7,8,9,10) then 'Large'
when property_no_of_bedrooms > 10 then 'Extra large'
end);
select * from p2 order by property_id;

-- Create table sale_property_dim
drop table sale_property_dim purge;
create table sale_property_dim as select p1.property_id, p1.feature_group_list, 
p1.description_group_list, p2.property_type, p2.property_scale
from p1, p2 where p1.property_id = p2.property_id order by p1.property_id;

select * from sale_property_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- SALE_PRICE_DIM
select * from sale;
drop table sale_price_dim purge;
create table sale_price_dim as select distinct property_id, sale_date, price 
from sale where sale_date is not null order by property_id;

select * from sale_price_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- VISIT_TIME_DIM
drop table visit_time_dim purge;
create table visit_time_dim as select distinct to_char(visit_date, 'yyyymmdd') as visit_time_id,
to_char(visit_date, 'yyyy') as year, to_char(visit_date, 'mm') as month,
to_char(visit_date, 'dd') as date1, to_char(visit_date, 'Day') as day
from visit;

alter table visit_time_dim add (season varchar2(20));

update visit_time_dim set season =
(case
when month >= 9 and month <= 11 then 'Spring'
when month in (12,1,2) then 'Summer'
when month >= 3 and month <=  5 then 'Autumn'
when month >= 6 and month <= 8 then 'Winter'
end);

select * from visit_time_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- VISIT_PROPERTY_DIM
drop table visit_property_dim purge;
create table visit_property_dim as select distinct property_id from visit;

select * from visit_property_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- ADVERT_TIME_DIM
drop table advert_time_dim purge;
create table advert_time_dim as select distinct to_char(property_date_added, 'yyyymm') as advert_time_id,
to_char(property_date_added, 'yyyy') as year, to_char(property_date_added, 'Mon') as month
from property order by advert_time_id;

select * from advert_time_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- ADVERTISEMENT_DIM
drop table advertisement_dim purge;
create table advertisement_dim as select distinct pa.advert_id, a.advert_name
from advertisement a, property_advert pa
where a.advert_id = pa.advert_id order by advert_id;

select * from advertisement_dim;
select * from advertisement_dim where advert_name like '%Sale%';
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- ADVERT_PRICE_DIM
drop table advert_price_dim purge;
create table advert_price_dim as select distinct pa.advert_id, pa.property_id, pa.cost
from property_advert pa order by pa.advert_id;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- ADVERT_PROPERTY_DIM
drop table advert_property_dim purge;
create table advert_property_dim as
select distinct property_id from property_advert;

select * from advert_property_dim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Fact tables
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CLIENT_FACT
drop table client_temp_fact purge;
create table client_temp_fact as select c.person_id as client_id, c.max_budget, p.gender, 
count(distinct c.person_id) as number_of_clients
from client c, person p, client_wish cw
where p.person_id = c.person_id
and cw.person_id = p.person_id
group by c.max_budget, p.gender, c.person_id;

alter table client_temp_fact add (budget_category varchar2(20));
update client_temp_fact set budget_category = 
(case
when max_budget >=0 and max_budget <= 1000 then 'Low'
when max_budget >= 1001 and max_budget <= 100000 then 'Medium'
when max_budget >= 100001 and max_budget <= 10000000 then 'High'
end);

select * from client_temp_fact;

drop table client_fact purge;
create table client_fact as select client_id, gender, budget_category, sum(number_of_clients) as number_of_clients
from client_temp_fact
group by client_id, gender, budget_category
order by client_id, gender;

select * from client_fact;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- AGENT_FACT  
-- Create table agent_fact
drop table agent_fact purge;
create table agent_fact as select a.person_id as agent_id, 
listagg(ao.office_id, ',') within group (order by ao.office_id) as office_group_list,
p.gender, a.salary as total_earning, count(distinct a.person_id) as number_of_agents
from agent_office ao, agent a, person p
where a.person_id = ao.person_id
and p.person_id = a.person_id
group by a.person_id, p.gender, a.salary;

select * from agent_fact;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- RENT_FACT
-- Create table f1 containing feature categories
drop table f1 purge;
create table f1 as
select r.property_id, count(pf.feature_code) as number_of_features
from rent r, property_feature pf
where r.property_id = pf.property_id
and r.rent_start_date is not null
group by r.property_id
order by r.property_id;
select * from f1;

alter table f1 add (feature_category varchar2(20));
update f1 set feature_category =
(case
when number_of_features < 10 then 'Very basic'
when number_of_features >= 10 and number_of_features <= 20 then 'Standard'
when number_of_features > 20 then 'Luxurious'
end);

select * from f1;

-- Create table rent_temp_fact
drop table rent_temp_fact purge;
create table rent_temp_fact as
select distinct a.person_id as agent_id, c.person_id as client_id, c.max_budget,
r.property_id, f1.feature_category, 
to_char(r.rent_start_date, 'yyyymmdd') as rental_time_id, 
(r.rent_end_date - r.rent_start_date)/30 as duration, p.address_id,
sum(r.price) as total_fee, count(r.rent_id) as number_of_rents
from agent a, client c, rent r, property p, f1
where a.person_id||c.person_id = r.agent_person_id||r.client_person_id
and f1.property_id = r.property_id 
and p.property_id = r.property_id
group by  a.person_id, c.person_id, c.max_budget, r.property_id, f1.feature_category,
to_char(r.rent_start_date, 'yyyymmdd'), (r.rent_end_date - r.rent_start_date)/30, address_id
order by a.person_id;

alter table rent_temp_fact add (rental_period varchar2(20));
alter table rent_temp_fact add (budget_category varchar2(20));

update rent_temp_fact set rental_period = 
(case
when duration > 0 and duration < 6 then 'Short'
when duration >= 6 and duration <= 12 then 'Meidum'
when duration > 12 then 'Long'
end);

update rent_temp_fact set budget_category =
(case 
when max_budget > 0 and max_budget < 1000 then 'Low'
when max_budget > 1001 and max_budget < 100000 then 'Medium'
when max_budget > 100001 and max_budget < 10000000 then 'High'
end);

select * from rent_temp_fact;

-- Create table rent_fact
drop table rent_fact;
create table rent_fact as select agent_id, client_id, budget_category,
property_id, feature_category, rental_time_id,
rental_period, address_id, total_fee, number_of_rents
from rent_temp_fact;

select * from rent_fact;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- SALE_FACT
-- Create table sale_temp_fact
drop table sale_temp_fact purge;
create table sale_temp_fact as
select distinct s.property_id, listagg(pf.feature_code, ',') within group (order by pf.feature_code) as feature_group_list,
count(distinct s.sale_id) as number_of_sales
from sale s, property_feature pf
where s.property_id = pf.property_id
and s.sale_date is not null
group by s.property_id;

select * from sale_temp_fact; 

-- Create table sale_fact
drop table sale_temp_fact_1 purge;
create table sale_temp_fact_1 as
select distinct a.person_id as agent_id, c.person_id as client_id, c.max_budget, s.property_id, f1.feature_group_list, 
to_char(s.sale_date, 'yyyymm') as sale_time_id,
p.address_id, s.price as total_fee, f1.number_of_sales
from agent a, client c, sale s, property_feature pf, property p, sale_temp_fact f1
where a.person_id||c.person_id = s.agent_person_id||s.client_person_id
and s.property_id = pf.property_id
and p.property_id = s.property_id 
and s.sale_date is not null
and f1.property_id = pf.property_id
order by s.property_id;

alter table sale_temp_fact_1 add (budget_category varchar2(20));

update sale_temp_fact_1 set budget_category =
(case 
when max_budget > 0 and max_budget < 1000 then 'Low'
when max_budget > 1001 and max_budget < 100000 then 'Medium'
when max_budget > 100001 and max_budget < 10000000 then 'High'
end);

select * from sale_temp_fact_1;

-- Create table sale_fact
drop table sale_fact purge;
create table sale_fact as select agent_id, client_id, budget_category, property_id, feature_group_list,
sale_time_id, address_id, total_fee, number_of_sales from sale_temp_fact_1;

select * from sale_fact;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- VISIT_FACT
drop table visit_fact purge;
create table visit_fact as 
select distinct v.property_id, to_char(v.visit_date, 'yyyymmdd') as visit_time_id,
v.agent_person_id as agent_id, v.client_person_id as client_id,
count(distinct v.property_id) as number_of_properties,
count(distinct v.client_person_id||v.agent_person_id||v.property_id) as number_of_property_visits
from visit v
group by v.property_id, to_char(v.visit_date, 'yyyymmdd'),
v.agent_person_id, v.client_person_id;

select * from visit_fact;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- ADVERT_FACT
drop table advert_fact purge;
create table advert_fact as
select distinct pa.advert_id, pa.agent_person_id as agent_id, pa.property_id as advert_property_id,
to_char(p.property_date_added, 'yyyymm') as advert_time_id, count(distinct pa.property_id) as number_of_properties
from property_advert pa, property p
where p.property_id = pa.property_id
group by pa.advert_id, pa.agent_person_id, to_char(p.property_date_added, 'yyyymm'), pa.property_id;

select * from advert_fact order by advert_id, advert_time_id desc;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 3. Answer questions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- What is the total number of clients with a high budget? 
select budget_category, sum(number_of_clients) as number_of_clients
from client_fact
where budget_category = 'High'
group by budget_category;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- What is the average earning for all Ray White agents? 
select 'Ray White' as office_branch, sum(f.total_earning)/sum(f.number_of_agents) as average_earning
from agent_office_group_dim p, agent_fact f
where p.office_group_list = f.office_group_list
and p.agent_id = f.agent_id
and p.name_group_list like '%Ray White%'
group by 'Ray White';
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- What is the total number of female agents who work in a medium agent office? 
select gender, 'Medium' as office, sum(number_of_agents) as number_of_agents from
(select f.gender, p.size_group_list, sum(f.number_of_agents) as number_of_agents
from agent_fact f, agent_office_group_dim p
where f.office_group_list = p.office_group_list
and f.agent_id = p.agent_id
and p.size_group_list like '%Medium%'
and f.gender = 'Female'
group by f.gender, p.size_group_list)
group by gender, 'Medium';
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- What is the average rental fee of apartments around South Yarra, VIC in 2019? 
select rp.property_type, l.suburb, l.state_code, rt.year, 
sum(f.total_fee)/sum(f.number_of_rents) as average_rental_fee
from rent_fact f, rental_property_dim rp, location_dim l, rental_time_dim rt, agent_dim a
where f.property_id = rp.property_id 
and f.address_id = l.address_id
and f.rental_time_id = rt.rental_time_id
and rp.property_type like '%Apartment%' 
and l.suburb like '%South Yarra%'
and l.state_code like '%VIC%'
and rt.year = '2019'
group by rp.property_type, l.suburb, l.state_code, rt.year;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- What is the total number of rent for clients who stay in small scale properties with very basic features? 
select rp.property_scale, f.feature_category, sum(number_of_rents) as number_of_rents
from rental_property_dim rp, rent_fact f
where f.property_id = rp.property_id
and f.feature_category like '%Very basic%'
and rp.property_scale like '%Small%'
group by rp.property_scale, f.feature_category;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- What is the average sales for houses in VIC compared to NSW? 
select 'House type' as property_type, l.state_code, sum(f.total_fee)/sum(f.number_of_sales) as average_sales
from sale_fact f, location_dim l, sale_property_dim sp
where l.address_id = f.address_id
and sp.property_id = f.property_id
and sp.feature_group_list = f.feature_group_list
and sp.property_type like '%House%'
and state_code in ('VIC', 'NSW')
group by 'House type', l.state_code;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- What is the total number of sales for Townhouses with Air Conditioning and Security? 
select property_type, ' Air Conditioning and Security' as feature, sum(number_of_sales) as number_of_sales from
(select sp.property_type, sp.description_group_list, sum(f.number_of_sales) as number_of_sales
from sale_property_dim sp, sale_fact f
where f.property_id = sp.property_id
and sp.property_type like '%Townhouse%'
and f.feature_group_list = sp.feature_group_list
and sp.description_group_list like '%Air conditioning%%Secu%'
group by sp.property_type, sp.description_group_list)
group by property_type, ' Air Conditioning and Security';
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Who are the top 3 agents in Melbourne? 
-- Top 3 sales agents in Melbourne
select * from (select s.agent_id, p.title, p.first_name, p.last_name, l.suburb,
sum(total_fee * number_of_sales) as total_revenue 
from sale_fact s, person_dim p, location_dim l 
where s.agent_id = p.person_id
and l.address_id = s.address_id
and l.suburb like '%Melbourne%'
group by s.agent_id, p.title, p.first_name, p.last_name, l.suburb 
order by sum(total_fee * number_of_sales) desc) fetch first 3 rows only;

-- Top 3 rent agents in Melbourne
select * from (select r.agent_id, p.title, p.first_name, p.last_name, l.suburb,
sum(total_fee * number_of_rents) as total_revenue 
from rent_fact r, person_dim p, location_dim l 
where r.agent_id = p.person_id
and l.address_id = r.address_id
and l.suburb like '%Melbourne%'
group by r.agent_id, p.title, p.first_name, p.last_name, l.suburb 
order by sum(total_fee * number_of_rents) desc) fetch first 3 rows only;

-- Top 3 agents in Melbourne in both sale and rent
-- Create table a1 containing total revenue of all sale agents
drop table a1 purge;
create table a1 as
select * from (select s.agent_id, p.title, p.first_name, p.last_name, l.suburb,
sum(total_fee * number_of_sales) as total_revenue 
from sale_fact s, person_dim p, location_dim l 
where s.agent_id = p.person_id
and l.address_id = s.address_id
and l.suburb like '%Melbourne%'
group by s.agent_id, p.title, p.first_name, p.last_name, l.suburb 
order by sum(total_fee * number_of_sales) desc);
select * from a1;

-- Create table a2 containing total revenue of all rent agents
drop table a2 purge;
create table a2 as
select * from (select r.agent_id, p.title, p.first_name, p.last_name, l.suburb,
sum(total_fee * number_of_rents) as total_revenue 
from rent_fact r, person_dim p, location_dim l 
where r.agent_id = p.person_id
and l.address_id = r.address_id
and l.suburb like '%Melbourne%'
group by r.agent_id, p.title, p.first_name, p.last_name, l.suburb 
order by sum(total_fee * number_of_rents) desc);
select * from a2;

select agent_id, title, first_name, last_name, suburb, sum(total_revenue) as total_revenue
from 
(select agent_id, title, first_name, last_name, suburb, total_revenue from a1 union all
select agent_id, title, first_name, last_name, suburb, total_revenue from a2)
where rownum <= 3
group by agent_id, title, first_name, last_name, suburb order by total_revenue desc;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- What is the average number of property visits during summer? 
select vt.season, 
sum(f.number_of_property_visits)/sum(f.number_of_properties) as average_number_of_property_visits
from visit_fact f, visit_time_dim vt 
where f.visit_time_id = vt.visit_time_id
and vt.season like '%Summer%'
group by vt.season;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Which day is the most popular visit day? 
select vt.day, sum(f.number_of_property_visits) as  number_of_property_visits
from visit_fact f, visit_time_dim vt
where vt.visit_time_id = f.visit_time_id
group by vt.day order by sum(f.number_of_property_visits) desc
fetch first row only;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- What is the total number of properties being advertised for sale in April 2020? 
select 'Sale' as advert_type, advert_time_id, sum(number_of_properties) as number_of_properties from (
select a.advert_name, f.advert_time_id, sum(f.number_of_properties) as number_of_properties
from advertisement_dim a, advert_fact f
where a.advert_id = f.advert_id
and a.advert_name like '%Sale%'
and f.advert_time_id = 202004
group by a.advert_name, f.advert_time_id)
group  by advert_time_id, 'Sale';
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 4. OLAP
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- a. Simple reports
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- REPORT 1
-- Personal information of Agents who work in 'Big' office and have top 1 total earning
select * from (
select f.agent_id, a.title, a.first_name, a.last_name, ao.size_group_list,
sum(f.total_earning) as total_earning,
dense_rank() over (order by sum(f.total_earning) desc) as earning_rank
from agent_fact f, agent_dim a, agent_office_group_dim ao
where f.agent_id = a.agent_id
and f.agent_id = ao.agent_id
and f.office_group_list = ao.office_group_list
and ao.size_group_list like '%Big%'
group by f.agent_id, a.title, a.first_name, a.last_name, ao.size_group_list)
where earning_rank  <= 1;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- REPORT 2
-- Personal information of Agents who work in 'Big' office and have top 30% total earning  
select * from (
select f.agent_id, a.title, a.first_name, a.last_name, ao.size_group_list,
sum(f.total_earning) as total_earning,
percent_rank() over (order by sum(f.total_earning) desc) as percent_rank
from agent_fact f, agent_dim a, gender_dim g, agent_office_group_dim ao
where f.agent_id = a.agent_id
and f.agent_id = ao.agent_id
and f.office_group_list = ao.office_group_list
and ao.size_group_list like '%Big%'
group by f.agent_id, a.title, a.first_name, a.last_name, ao.size_group_list)
where percent_rank < 0.3;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- REPORT 3
-- Personal information and Total earning of all agents
select f.agent_id, a.title, a.first_name, a.last_name, ao.size_group_list,
sum(f.total_earning) as total_earning,
dense_rank() over (order by sum(f.total_earning) desc) as earning_rank
from agent_fact f, agent_dim a, gender_dim g, agent_office_group_dim ao
where f.agent_id = a.agent_id
and f.agent_id = ao.agent_id
and f.office_group_list = ao.office_group_list
and ao.size_group_list like '%Big%'
group by f.agent_id, a.title, a.first_name, a.last_name, ao.size_group_list;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- b. Reports with proper sub-totals
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- REPORT 4
-- The sub-total and total rental fees from each suburb, time period, and property type
select property_suburb, property_rental_period, type, total_fee from (
select l.suburb, f.rental_period, rp.property_type, sum(f.total_fee) as total_fee,
decode (grouping (l.suburb), 1, 'All suburbs', l.suburb) as property_suburb, 
decode (grouping (f.rental_period), 1, 'All rental periods', f.rental_period) as property_rental_period,
decode (grouping (rp.property_type), 1, 'All property types', rp.property_type) as type
from location_dim l, rent_fact f, rental_property_dim rp
where l.address_id = f.address_id 
and rp.property_id = f.property_id 
group by cube (l.suburb, f.rental_period, rp.property_type));
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- REPORT 5
-- The sub-total and total rental fees from each time period, and property type for every suburb with Partial Cube
select property_suburb, property_rental_period, type, total_fee from (
select l.suburb, f.rental_period, rp.property_type, sum(f.total_fee) as total_fee,
decode (grouping (l.suburb), 1, 'All suburbs', l.suburb) as property_suburb, 
decode (grouping (f.rental_period), 1, 'All rental periods', f.rental_period) as property_rental_period,
decode (grouping (rp.property_type), 1, 'All property types', rp.property_type) as type
from location_dim l, rent_fact f, rental_property_dim rp
where l.address_id = f.address_id 
and rp.property_id = f.property_id 
group by l.suburb, cube (f.rental_period, rp.property_type));
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- REPORT 6
-- The sub-total and total sales from each suburb, season, and property type
select property_suburb, season_time, type, total_fee from (
select l.suburb, st.season, sp.property_type, sum(f.total_fee) as total_fee,
decode (grouping (l.suburb), 1, 'All suburbs', l.suburb) as property_suburb, 
decode (grouping (st.season), 1, 'All seasons', st.season) as season_time,
decode (grouping (sp.property_type), 1, 'All property types', sp.property_type) as type
from location_dim l, sale_fact f, sale_property_dim sp, sale_time_dim st
where l.address_id = f.address_id 
and sp.property_id = f.property_id 
and f.sale_time_id = st.sale_time_id
group by rollup (l.suburb, st.season, sp.property_type));
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- REPORT 7
-- The sub-total and total sale from season and property type for every suburb
select property_suburb, season_time, type, total_fee from (
select l.suburb, st.season, sp.property_type, sum(f.total_fee) as total_fee,
decode (grouping (l.suburb), 1, 'All suburbs', l.suburb) as property_suburb, 
decode (grouping (st.season), 1, 'All seasons', st.season) as season_time,
decode (grouping (sp.property_type), 1, 'All property types', sp.property_type) as type
from location_dim l, sale_fact f, sale_property_dim sp, sale_time_dim st
where l.address_id = f.address_id 
and sp.property_id = f.property_id 
and f.sale_time_id = st.sale_time_id
group by l.suburb, rollup (st.season, sp.property_type));
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- c. Reports with moving and cumulative aggregates
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- REPORT 8
-- What is the total number of clients and cumulative number of clients
-- with a high budget in each year?
-- (the query is referring to the clients who had sale and rent activities)
select budget_category, year, to_char(count(client_id)) as number_of_clients,
to_char(sum(count(client_id)) over (
order by year rows unbounded preceding)) as cum_number_of_clients
from (select * from
(select f.client_id, f.budget_category, s.year as year from sale_fact f, sale_time_dim s
where f.sale_time_id = s.sale_time_id)
union 
select * from 
(select f.client_id, f.budget_category, r.year as year from rent_fact f, rental_time_dim r
where f.rental_time_id = r.rental_time_id))
where budget_category = 'High'
group by budget_category, year;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- REPORT 9
-- What is the total sale fee and cumulative fee by year?
select s.year, to_char(sum(f.total_fee), '9,999,999,999') as yearly_fee,
to_char(sum(sum(f.total_fee)) over (order by s.year rows unbounded preceding), '9,999,999,999') as cum_fee
from sale_time_dim s, sale_fact f
where s.sale_time_id = f.sale_time_id
group by s.year;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- REPORT 10
-- What is the number of properties that were visited in 2019 and preceding two years?
select r.year, to_char(sum(f.number_of_rents)) as total_rents,
to_char(avg(sum(f.number_of_rents)) over (order by r.year rows 2 preceding)) as moving_2_year_avg
from rent_fact f, rental_time_dim r
where f.rental_time_id = f.rental_time_id
group by r.year;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- d. Reports with Partitions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- REPORT 11
-- Show ranking of each property type based on the yearly total number of sales and 
-- the ranking of each state based on the yearly total number of sales.

-- the query is referring to do the rank according to both property type and state
select sp.property_type, l.state_name,
sum(f.total_fee) as total_fee,
dense_rank() over (order by sum(f.total_fee) desc) as fee_rank
from sale_fact f, location_dim l, sale_property_dim sp
where f.address_id = l.address_id
and sp.property_id = f.property_id
group by sp.property_type, l.state_name;

-- the query is referring to do the rank according to property type 
select sp.property_type, sum(f.total_fee) as total_fee,
dense_rank() over (order by sum(f.total_fee) desc) as fee_rank
from sale_fact f, sale_property_dim sp
where sp.property_id = f.property_id
group by sp.property_type;

-- the query is referring to do the rank according to property type 
select l.state_name, sum(f.total_fee) as total_fee,
dense_rank() over (order by sum(f.total_fee) desc) as fee_rank
from sale_fact f, location_dim l
where f.address_id = l.address_id
group by l.state_name;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- REPORT 12
-- Show ranking of each property type based on the yearly total number of sales and 
-- the ranking of each state based on the yearly total number of sales with partition
select sp.property_type, l.state_name,
sum(f.total_fee) as total_fee,
dense_rank() over (partition by sp.property_type order by sum(f.total_fee) desc) as rank_by_property_type,
dense_rank() over (partition by l.state_name order by sum(f.total_fee) desc) as rank_by_state
from sale_fact f, location_dim l, sale_property_dim sp
where f.address_id = l.address_id
and sp.property_id = f.property_id
group by sp.property_type, l.state_name;




