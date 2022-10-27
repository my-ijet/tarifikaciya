
alter table organization
add FOXPRO_KOD varchar(5),
add pg varchar(5);

alter table org_group
add FOXPRO_KOD varchar(5);

alter table person
add FOXPRO_KOD varchar(5);

alter table obrazovanie
add FOXPRO_KOD varchar(5);

alter table personal_group
add FOXPRO_KOD varchar(5);

alter table doljnost
add FOXPRO_KOD varchar(5);

alter table kategory
add FOXPRO_KOD varchar(5);

alter table predmet
add FOXPRO_KOD varchar(5);

alter table nadbavka
add FOXPRO_KOD varchar(5);

alter table doplata
add FOXPRO_KOD varchar(5);
