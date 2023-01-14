unit sql_commands;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

procedure PrepareTables;
procedure UpdateTables;
procedure ClearTables;

implementation

uses
  main;

procedure PrepareTables;
begin
  with Form1.SQL.Script do begin
    Text := 'alter table organization';
    AddText('add column FOXPRO_KOD varchar(5);');
    AddText('alter table organization');
    AddText('add column pg varchar(5);');
    AddText('alter table organization');
    AddText('add column gr varchar(5);');

    AddText('alter table org_group');
    AddText('add column FOXPRO_KOD varchar(5);');

    AddText('alter table person');
    AddText('add column FOXPRO_KOD varchar(5);');

    AddText('alter table personal_group');
    AddText('add column FOXPRO_KOD varchar(5);');

    AddText('alter table doljnost');
    AddText('add column FOXPRO_KOD varchar(5);');
    AddText('alter table doljnost');
    AddText('add column kolvo int;');
    AddText('alter table doljnost');
    AddText('add column por int;');
    AddText('alter table doljnost');
    AddText('add column pk int;');
    AddText('alter table doljnost');
    AddText('add column gopl int;');

    AddText('alter table obrazovanie');
    AddText('add column FOXPRO_KOD varchar(5);');

    AddText('alter table predmet');
    AddText('add column FOXPRO_KOD varchar(5);');

    AddText('alter table nadbavka');
    AddText('add column FOXPRO_KOD varchar(5);');
    AddText('alter table nadbavka');
    AddText('add column por int;');
    AddText('alter table nadbavka');
    AddText('add column pr varchar(5);');

    AddText('alter table doplata');
    AddText('add column FOXPRO_KOD varchar(5);');
    AddText('alter table doplata');
    AddText('add column por int;');
    AddText('alter table doplata');
    AddText('add column pk int;');
    AddText('alter table doplata');
    AddText('add column pr varchar(5);');

    AddText('alter table stavka');
    AddText('add column RAZR int;');

    AddText('alter table kategory');
    AddText('add column FOXPRO_KOD varchar(5);');

    AddText('');
  end;
  Form1.SQL.Execute;
end;

procedure UpdateTables;
begin
  with Form1.SQL.Script do begin
    Text := 'UPDATE organization';
    AddText('SET id_org_group = org_group.id');
    AddText('FROM org_group');
    AddText('where organization.pg = org_group.FOXPRO_KOD;');

    AddText('');
  end;
  Form1.SQL.Execute;
end;

procedure ClearTables;
begin
  with Form1.SQL.Script do begin
    Text := 'alter table organization';
    AddText('drop column FOXPRO_KOD;');
    AddText('alter table organization');
    AddText('drop column pg;');
    AddText('alter table organization');
    AddText('drop column gr;');

    AddText('alter table org_group');
    AddText('drop column FOXPRO_KOD;');

    AddText('alter table person');
    AddText('drop column FOXPRO_KOD;');

    AddText('alter table personal_group');
    AddText('drop column FOXPRO_KOD;');

    AddText('alter table doljnost');
    AddText('drop column FOXPRO_KOD;');
    AddText('alter table doljnost');
    AddText('drop column kolvo;');
    AddText('alter table doljnost');
    AddText('drop column por;');
    AddText('alter table doljnost');
    AddText('drop column pk;');
    AddText('alter table doljnost');
    AddText('drop column gopl;');

    AddText('alter table obrazovanie');
    AddText('drop column FOXPRO_KOD;');

    AddText('alter table predmet');
    AddText('drop column FOXPRO_KOD;');

    AddText('alter table nadbavka');
    AddText('drop column FOXPRO_KOD;');
    AddText('alter table nadbavka');
    AddText('drop column por;');
    AddText('alter table nadbavka');
    AddText('drop column pr;');

    AddText('alter table doplata');
    AddText('drop column FOXPRO_KOD;');
    AddText('alter table doplata');
    AddText('drop column por;');
    AddText('alter table doplata');
    AddText('drop column pk;');
    AddText('alter table doplata');
    AddText('drop column pr;');

    AddText('alter table stavka');
    AddText('drop column RAZR;');

    AddText('alter table kategory');
    AddText('drop column FOXPRO_KOD;');

    AddText('');
  end;
  Form1.SQL.Execute;
end;

end.

