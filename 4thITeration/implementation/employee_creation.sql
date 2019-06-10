CREATE TABLE IF NOT EXISTS Employee(
    employee_id mediumint primary key,
    ssn varchar(30) not null,
    belonging_branch varchar(20) not null, #probably unesful cause it s a key
    foreign key(ssn) references Registry(ssn),
    foreign key(belonging_branch) references Branch(name)
);

CREATE TABLE IF NOT EXISTS Branch( # it's unconfortable to be forced to do things using a long sting, but we're looking
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