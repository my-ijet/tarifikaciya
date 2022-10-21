create table org_group(
  id serial primary key,
  name varchar
);
create table organization(
  id serial primary key,
  name varchar
);

create table person(
  id serial primary key,
  familyname varchar,
  firstname varchar,
  middlename varchar
);

create table doljnost(
  id serial primary key,
  name varchar
);

create table predmet(
  id serial primary key,
  name varchar
);

create table stavka(
  id serial primary key,
  name varchar
);
create table nadbavka(
  id serial primary key,
  name varchar
);
create table doplata(
  id serial primary key,
  name varchar
);
