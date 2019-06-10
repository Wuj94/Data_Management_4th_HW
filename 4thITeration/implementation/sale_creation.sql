CREATE TABLE IF NOT EXISTS Product(
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
    income decimal(6,2) NOT NULL
);

create table SaleCategory(
    category_sur_key int not null,
    sale_sur_key bigint not null,
    foreign key(category_sur_key) references Category(category_sur_key),
    foreign key(sale_sur_key) references Sale(sale_sur_key)

);

CREATE TABLE IF NOT EXISTS BridgeDetail(
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

#Shared with Department and Product
create table if not exists Detail(
    detail_sur_key int auto_increment primary key,
    brand varchar(20) null, #NULLable because I want it to be  flexible enough wrt the application we're going to build.
    manufacturer varchar(20) null, #as before
    dept_name varchar(20) not null,
    foreign key(dept_name) references Department(name)
);

# this is a shared table between employee and sale... design error? maybe, i'll think about that next iteration first/main meeting
# I put it in the Sale hierarchy cause, say, the opinion are relative to a specific sale.
create table if not exists Opinion(
    # just inventing bullshits to make it appear senseful
    customer_opinion char null,
    employee_opinion char null

);

create table if not exists Category(
    category_sur_key int auto_increment primary key,
    name varchar(20) not null unique
);

create table Department(
    name varchar(20) primary key
)