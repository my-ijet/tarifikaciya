
-- SPRPG
create table org_group(
  id serial primary key,
  name varchar,
  archived boolean not null default false
);
-- SU
create table organization(
  id serial primary key,
  short_name varchar,
  full_name varchar,
  group_id int references org_group on delete set null on update cascade,
  archived boolean not null default false,
  gr int2
);
-- SPRFIO
create table person(
  id serial primary key,
  familyname varchar,
  firstname varchar,
  middlename varchar,
  archived boolean not null default false
);
-- SPROBR
create table obrazovanie(
  id serial primary key,
  name varchar,
  archived boolean not null default false
);
-- SPRGR
create table personal_group(
  id serial primary key,
  name varchar,
  archived boolean not null default false
);
-- SPRDL
create table doljnost(
  id serial primary key,
  name varchar,
  archived boolean not null default false,
  kolvo int2,
  por int2,
  pk int2,
  gopl int2
);
-- SPRKAT
create table kategory(
  id serial primary key,
  name varchar,
  archived boolean not null default false
);
-- SPRPREDM
create table predmet(
  id serial primary key,
  name varchar,
  clock int2,
  archived boolean not null default false
);
-- STAVKI
create table stavka(
  id serial primary key,
  razr int2,
  sumst money,
  archived boolean not null default false
);
-- SPRN
create table nadbavka(
  id serial primary key,
  name varchar,
  archived boolean not null default false,
  proc numeric(4,1),
  por int2,
  pr varchar(1)
);
-- SPRDP
create table doplata(
  id serial primary key,
  name varchar,
  archived boolean not null default false,
  por int2,
  pk int2,
  pr varchar(1)
);
