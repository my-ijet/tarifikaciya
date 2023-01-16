unit sql_commands;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs;

procedure PrepareTables;
procedure UpdateTables;
procedure ClearTables;
procedure OptimizeDatabase;

implementation

uses
  main;

procedure PrepareTables;
begin
  with Form1.SQL.Script do begin
    Text := '';
    AddText('alter table organization add column FOXPRO_KOD varchar(5);');
    AddText('alter table organization add column pg varchar(5);');
    AddText('alter table organization add column gr varchar(5);');

    AddText('alter table org_group add column FOXPRO_KOD varchar(5);');

    AddText('alter table person add column FOXPRO_KOD varchar(5);');

    AddText('alter table personal_group add column FOXPRO_KOD varchar(5);');

    AddText('alter table doljnost add column FOXPRO_KOD varchar(5);');
    AddText('alter table doljnost add column kolvo int;');
    AddText('alter table doljnost add column por int;');
    AddText('alter table doljnost add column pk int;');
    AddText('alter table doljnost add column gopl int;');

    AddText('alter table obrazovanie add column FOXPRO_KOD varchar(5);');

    AddText('alter table predmet add column FOXPRO_KOD varchar(5);');

    AddText('alter table nadbavka add column FOXPRO_KOD varchar(5);');
    AddText('alter table nadbavka add column por int;');
    AddText('alter table nadbavka add column pr varchar(5);');

    AddText('alter table doplata add column FOXPRO_KOD varchar(5);');
    AddText('alter table doplata add column por int;');
    AddText('alter table doplata add column pk int;');
    AddText('alter table doplata add column pr varchar(5);');

    AddText('alter table stavka add column RAZR int;');

    AddText('alter table kategory add column FOXPRO_KOD varchar(5);');

    AddText('alter table tarifikaciya add column FOXPRO_KU varchar(5);');
    AddText('alter table tarifikaciya add column FOXPRO_TABN varchar(5);');
    AddText('alter table tarifikaciya add column FOXPRO_OBR varchar(5);');

  end;
  Form1.SQL.Execute;
end;

procedure UpdateTables;
begin
  with Form1.SQL.Script do begin
    Text := '';
    AddText('UPDATE organization');
    AddText('SET id_org_group = org_group.id');
    AddText('FROM org_group');
    AddText('where organization.pg = org_group.FOXPRO_KOD;');

    AddText('UPDATE tarifikaciya');
    AddText('SET id_organization = organization.id');
    AddText('FROM organization');
    AddText('where tarifikaciya.FOXPRO_KU = organization.FOXPRO_KOD;');
    AddText('UPDATE tarifikaciya');
    AddText('SET id_person = person.id');
    AddText('FROM person');
    AddText('where tarifikaciya.FOXPRO_TABN = person.FOXPRO_KOD;');
    AddText('UPDATE tarifikaciya');
    AddText('SET id_obrazovanie = obrazovanie.id');
    AddText('FROM obrazovanie');
    AddText('where tarifikaciya.FOXPRO_OBR = obrazovanie.FOXPRO_KOD;');

  end;
  Form1.SQL.Execute;
end;

procedure ClearTables;
var
  numMissedTarOrgs: String;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := '';
    SQL.Append('select count(*) as num ');
    SQL.Append('from tarifikaciya where id_organization = 0;');
    Open;
    numMissedTarOrgs := FieldByName('num').AsString;
    Close;
  end;
  if numMissedTarOrgs <> '0' then
    ShowMessage('Для '+numMissedTarOrgs+
                ' записей, организации в справочнике не найдены,'+LineEnding+
                'они не будут импортированны!');

  with Form1.SQL.Script do begin
    Text := '';
    AddText('alter table organization drop column FOXPRO_KOD;');
    AddText('alter table organization drop column pg;');
    AddText('alter table organization drop column gr;');

    AddText('alter table org_group drop column FOXPRO_KOD;');

    AddText('alter table person drop column FOXPRO_KOD;');

    AddText('alter table personal_group drop column FOXPRO_KOD;');

    AddText('alter table doljnost drop column FOXPRO_KOD;');
    AddText('alter table doljnost drop column kolvo;');
    AddText('alter table doljnost drop column por;');
    AddText('alter table doljnost drop column pk;');
    AddText('alter table doljnost drop column gopl;');

    AddText('alter table obrazovanie drop column FOXPRO_KOD;');

    AddText('alter table predmet drop column FOXPRO_KOD;');

    AddText('alter table nadbavka drop column FOXPRO_KOD;');
    AddText('alter table nadbavka drop column por;');
    AddText('alter table nadbavka drop column pr;');

    AddText('alter table doplata drop column FOXPRO_KOD;');
    AddText('alter table doplata drop column por;');
    AddText('alter table doplata drop column pk;');
    AddText('alter table doplata drop column pr;');

    AddText('alter table stavka drop column RAZR;');

    AddText('alter table kategory drop column FOXPRO_KOD;');

    AddText('alter table tarifikaciya drop column FOXPRO_KU;');
    AddText('alter table tarifikaciya drop column FOXPRO_TABN;');
    AddText('alter table tarifikaciya drop column FOXPRO_OBR;');

    AddText('delete from tarifikaciya where id_organization = 0;');
  end;
  Form1.SQL.Execute;
end;

procedure OptimizeDatabase;
begin
  with Form1.MainConnection do begin
    ExecuteDirect('End Transaction');
    ExecuteDirect('VACUUM; pragma optimize;');
    ExecuteDirect('Begin Transaction');
  end;
end;

end.

