
alter table organization
drop column FOXPRO_KOD,
drop column pg;

alter table org_group
drop column FOXPRO_KOD;

alter table person
drop column FOXPRO_KOD;

alter table obrazovanie
drop column FOXPRO_KOD;

alter table personal_group
drop column FOXPRO_KOD;

alter table doljnost
drop column FOXPRO_KOD;

alter table kategory
drop column FOXPRO_KOD;

alter table predmet
drop column FOXPRO_KOD;

alter table nadbavka
drop column FOXPRO_KOD;

alter table doplata
drop column FOXPRO_KOD;
