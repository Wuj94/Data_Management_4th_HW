drop database if exists rolap;
create database rolap;
use rolap;

create table if not exists Product(
    timestamp int auto_increment primary key,
    fake_price_pk int,
    fake_brand_pk int,
    price decimal(4,2) not null,
    brand varchar(20) null, #NULLable because I want it to be  flexible enough wrt the application we're going to build.
    manufacturer varchar(20) null #as before
);

create table if not exists Sale(
    sale_sur_key bigint auto_increment primary key, # to be true, it's a timestamp too
    # cause we wanna analyse incomes of different sales in different times point, where
    # the relation before-after makes the data more clear.
    income decimal(6,2) not null,
    sale_date date not null,
    customer_ssn varchar(30)
);

create table if not exists BridgeDetail(
    #here we have a functional dependency:
    #basically, we have an injective function from the first 3 fields onto the set of all 2ple (qty, discount) fields.
    fake_price_pk int,
    fake_brand_pk int,
    timestamp int auto_increment unique,
    primary key (fake_brand_pk, fake_price_pk),
    #the following are not null because we the table doesn't make sense at all otherwise.
    qty int NOT NULL, #the committent is supposed to be no more than a big single super market. Like TCP, "slow start" (that's not trivial)
    discount int NOT NULL #it's percentage expressed

);

# this is a shared table between employee and sale... design error? maybe, i'll think about that next iteration first/main meeting
# I put it in the Sale hierarchy cause, say, the opinion are relative to a specific sale.
create table if not exists Opinion(
    # just inventing bullshits to make it appear senseful
    customer_opinion char null,
    employee_opinion char null

);

#not unstable but it's not the case to put varchar(20) in an aggregate table/n-n relation
create table if not exists Category(
    category_sur_key int auto_increment primary key,
    name varchar(20) not null unique,
    dept_name varchar(20)
);

create table if not exists SaleCategory(
    category_sur_key int not null,
    sale_sur_key bigint not null
);

create table if not exists Department(
    name varchar(20) primary key
);

#Shared with Department and Product
create table if not exists Detail(
    detail_sur_key int auto_increment primary key,
    brand varchar(20) null, #NULLable because I want it to be  flexible enough wrt the application we're going to build.
    manufacturer varchar(20) null, #as before
    dept_name varchar(20) not null
);

create table if not exists Employee(
    employee_id mediumint auto_increment primary key,
    ssn varchar(30) not null,
    belonging_branch varchar(20) not null #probably unesful cause it s a key
);

create table if not exists Branch( # it's unconfortable to be forced to do things using a long sting, but we're looking
    # forward to implement a user interface
    name varchar(20) primary key,
    time tinyint auto_increment unique
);

create table if not exists Registry(
  ssn varchar(30) primary key,#this field is supposed to contain all possible "country dependent SSN"
  first_name varchar(20) NOT NULL,
  second_name varchar(20) NULL,
  last_name varchar(20) NOT NULL,
  phone varchar(15) NOT NULL, #this field is supposed to contain state number (+39 for Italy) and the number itself.
  email varchar(30) NOT NULL, #why 30? think about calabrese.7#s@studenti.uniroma1.it
  birthdate date NOT NULL,
  gender char NOT NULL #the application / trigger is supposed to handle this single char (ex: F: female, M:male, S:somethingelse)
);

# we assume that any customer is stable enough not to require
# neither surrogate nor timestamp key
create table if not exists Customer(
    customer_sur_key int auto_increment primary key,
    customer_id int(10) NOT NULL UNIQUE,
    marital_status char NULL, #*M*arried, *S*ingle, *D*ivorced, and *W*idowed
    occupation varchar(20) not null,
    ssn varchar(30)
);

create table if not exists CategoryBridge(
    customer_sur_key int,
    category_sur_key int
);

create index customer_ssn_index on Customer(ssn);

alter table Sale add constraint foreign key(customer_ssn) references Customer(ssn);

alter table SaleCategory add constraint foreign key(category_sur_key) references Category(category_sur_key),
    add constraint foreign key(sale_sur_key) references Sale(sale_sur_key);

alter table Detail add constraint foreign key(dept_name) references Department(name);

alter table Employee add constraint foreign key(ssn) references Registry(ssn),
    add constraint foreign key(belonging_branch) references Branch(name);

alter table Customer add constraint foreign key(ssn) references Registry(ssn);

alter table Category add constraint foreign key (dept_name) references Department(name);

alter table CategoryBridge add constraint foreign key(customer_sur_key) references Customer(customer_sur_key),
    add constraint foreign key(category_sur_key) references Category(category_sur_key);

# Materialized Views

## deptByCategorySale

drop table if exists deptByCategorySale;
create table deptByCategorySale
(
    sale_sur_key bigint not null,
    dept_name varchar(20) not null,
    category_name int not null,
    total_income  bigint not null,
    avg_autcome decimal(4,2) not null,
    count_transaction mediumint not null
);

INSERT INTO deptByCategorySale
SELECT S.sale_sur_key, D.name, C.name, SUM(S.income), AVG(S.income), COUNT(S.income)
  FROM Department D inner join Category C on D.name = C.dept_name inner join
        SaleCategory SC on SC.category_sur_key = C.category_sur_key inner join
      Sale S on SC.sale_sur_key = S.sale_sur_key
    GROUP BY S.sale_sur_key, D.name, C.name, D.name, C.name;

## On demand refresh stored procedure
drop procedure if exists refreshDeptByCategorySale;

DELIMITER $$

CREATE PROCEDURE refreshDeptByCategorySale (
    OUT rc INT
)
BEGIN

  TRUNCATE TABLE deptByCategorySale;

  INSERT INTO deptByCategorySale
  SELECT S.sale_sur_key, D.name, C.name, SUM(S.income), AVG(S.income), COUNT(S.income)
  FROM Department D inner join Category C on D.name = C.dept_name inner join
        SaleCategory SC on SC.category_sur_key = C.category_sur_key inner join
      Sale S on SC.sale_sur_key = S.sale_sur_key
    GROUP BY S.sale_sur_key, D.name, C.name, D.name, C.name;

  SET rc = 0;
END;
$$

DELIMITER ;

## topCustomerBySale
DROP TABLE if exists topCustomerBySale;
CREATE TABLE topCustomerBySale
(
    customer_SSN varchar(30) not null,
    max_sale decimal(6,2) not null,
    category_name varchar(20) not null,
    dept_name varchar(20) not null
);


insert into topCustomerBySale
select Cu.ssn, max(S.income), DCS.category_name, DCS.dept_name
from Customer Cu inner join Sale S on Cu.ssn = S.customer_ssn inner join deptByCategorySale DCS
      on DCS.sale_sur_key = S.sale_sur_key
group by Cu.ssn, DCS.category_name, DCS.dept_name;



## On demand refresh stored procedure
drop procedure if exists refreshTopCustomerBySale;

DELIMITER $$

CREATE PROCEDURE refreshTopCustomerBySale(
    OUT rc INT
)
BEGIN

  TRUNCATE TABLE topCustomerBySale;

  INSERT INTO topCustomerBySale
  SELECT Cu.ssn, max(S.income), DCS.category_name, DCS.dept_name
  FROM Customer Cu inner join Sale S on Cu.ssn = S.customer_ssn inner join deptByCategorySale DCS
      on DCS.sale_sur_key = S.sale_sur_key
      GROUP BY Cu.ssn, DCS.category_name, DCS.dept_name;

  SET rc = 0;
END;
$$

DELIMITER ;

## employeeBySale
DROP TABLE if exists employeeBySale;
CREATE TABLE employeeBySale
(
    employee_ssn varchar(30) not null ,
    employee_branch varchar(20) not null ,
    total_income bigint not null
);

create table if not exists Employee(
    employee_id mediumint auto_increment primary key,
    ssn varchar(30) not null,
    belonging_branch varchar(20) not null #probably unesful cause it s a key
);

INSERT INTO employeeBySale
select E.ssn, E.belonging_branch, sum(S.income)
from Employee E inner join Sale S on E.ssn = S.customer_ssn inner join deptByCategorySale DCS
      on DCS.sale_sur_key = S.sale_sur_key
where (SELECT YEAR(S.sale_date))  = (SELECT YEAR(CURDATE()))
group by E.ssn, E.belonging_branch, S.income;



## On demand refresh stored procedure
drop procedure if exists refreshEmployeeBySale;

DELIMITER $$

CREATE PROCEDURE refreshEmployeeBySale(
    OUT rc INT
)
BEGIN

  TRUNCATE TABLE employeeBySale;

  INSERT INTO employeeBySale
  select E.ssn, E.belonging_branch, sum(S.income)
    from Employee E inner join Sale S on E.ssn = S.customer_ssn inner join deptByCategorySale DCS
          on DCS.sale_sur_key = S.sale_sur_key
    where (SELECT YEAR(S.sale_date))  = (SELECT YEAR(CURDATE()))
    group by E.ssn, E.belonging_branch, S.income;


  SET rc = 0;
END;
$$

DELIMITER ;