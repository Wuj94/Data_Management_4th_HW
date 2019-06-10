# we assume that any customer is stable enough not to require
# neither surrogate nor timestamp key
create table if not exists Customer(
    customer_sur_key int auto_increment primary key,
    customer_id int(10) NOT NULL UNIQUE,
    marital_status char NULL, #Married, single, divorced, and widowed are
    occupation varchar(20) not null,
    ssn varchar(30),
    foreign key(ssn) references Registry(ssn)
);

create table CategoryBridge(
    customer_sur_key int,
    category_sur_key int,
    foreign key customer_sur_key references Customer(customer_sur_key),
    foreign key category_sur_key references Category(category_sur_key)
)
