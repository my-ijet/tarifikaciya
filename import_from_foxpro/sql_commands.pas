unit sql_commands;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs;

procedure PrepareTables;
procedure UpdateSpravochniky;
procedure UpdateTarifikations;
procedure UpdateTarJobs;
procedure UpdateTarNadbavky;
procedure ClearTables;
procedure OptimizeDatabase;

implementation

uses
  main;

procedure SqlAddColumnsToTable(TableName: String;
                               Columns: TStringArray);
var
  Column: String;
begin
  with Form1.SQL.Script do begin
    for Column in Columns do begin
      AddText('alter table '+TableName+' add column '+Column+';');
    end;
  end;
end;

procedure SqlUpdateTarTable(TarTableName: String;
                            FieldName: String;
                            TableName: String);
begin
  with Form1.SQL.Script do begin
    AddText('UPDATE '+TarTableName);
    AddText('SET id_'+TableName+' = '+TableName+'.id');
    AddText('FROM '+TableName);
    AddText('where '+TarTableName+'.'+FieldName+' = '+TableName+'.FOXPRO_KOD;');
  end;
end;

procedure SqlApplyMigrationTable(TableName: String;
                                 FieldName: String;
                                 ChildTable: String);
begin
  with Form1.SQL.Script do begin
    AddText('UPDATE '+TableName);
    AddText('SET id_'+ChildTable+' = migration_table.to_id');
    AddText('FROM migration_table');
    AddText('where '+TableName+'.'+FieldName+' = migration_table.FOXPRO_KOD');
    AddText('  and migration_table.table_name = "'+ChildTable+'";');
  end;
end;

procedure SqlRemoveColumnsFromTable(TableName: String;
                                    Columns: TStringArray);
var
  Column: String;
begin
  with Form1.SQL.Script do begin
    for Column in Columns do begin
      AddText('alter table '+TableName+' drop column '+Column+';');
    end;
  end;
end;

procedure PrepareTables;
begin
  Form1.SQL.Script.Clear;
  SqlAddColumnsToTable('organization',
    ['pg varchar(5)', 'gr varchar(5)']);

  //SqlAddColumnsToTable('org_group',
  //  ['FOXPRO_KOD varchar(5)']);

  //SqlAddColumnsToTable('person',
  //  ['FOXPRO_KOD varchar(5)']);

  //SqlAddColumnsToTable('personal_group',
  //  ['FOXPRO_KOD varchar(5)']);

  SqlAddColumnsToTable('doljnost',
    ['kolvo int', 'por int', 'pk int', 'gopl int']);

  //SqlAddColumnsToTable('obrazovanie',
  //  ['FOXPRO_KOD varchar(5)']);

  //SqlAddColumnsToTable('predmet',
  //  ['FOXPRO_KOD varchar(5)']);

  SqlAddColumnsToTable('nadbavka',
    ['FOXPRO_KOD varchar(5)', 'por int', 'pr varchar(5)']);

  SqlAddColumnsToTable('doplata',
    ['por int', 'pk int', 'pr varchar(5)']);

  //SqlAddColumnsToTable('stavka',
  //  ['RAZR int']);

  //SqlAddColumnsToTable('kategory',
  //  ['FOXPRO_KOD varchar(5)']);

  SqlAddColumnsToTable('tarifikaciya',
    ['FOXPRO_KU varchar(5)', 'FOXPRO_TABN varchar(5)', 'FOXPRO_OBR varchar(5)']);

  SqlAddColumnsToTable('tar_job',
    ['FOXPRO_DOLJ varchar(5)', 'FOXPRO_PREDM varchar(5)',
     'FOXPRO_SUMCL real',
     'FOXPRO_NADB varchar(5)', 'FOXPRO_DOPL varchar(5)',
     'FOXPRO_RAZR varchar(5)', 'FOXPRO_KAT varchar(5)',
     'FOXPRO_STIM real']);

  SqlAddColumnsToTable('tar_nadbavka',
    ['FOXPRO_NADB varchar(5)']);


  with Form1.SQL.Script do begin
    AddText('create table migration_table (');
    AddText('table_name varchar(15),');
    AddText('FOXPRO_KOD varchar(5),');
    AddText('to_id int );');
  end;

  Form1.SQL.Execute;
end;

procedure UpdateSpravochniky;
begin
  with Form1.SQL.Script do begin
    Clear;
    AddText('UPDATE organization');
    AddText('SET id_org_group = org_group.id');
    AddText('FROM org_group');
    AddText('where organization.pg = org_group.FOXPRO_KOD;');
    SqlApplyMigrationTable('organization', 'id_org_group', 'org_group');
  end;
  Form1.SQL.Execute;
end;

procedure UpdateTarifikations;
begin
  with Form1.SQL.Script do begin
    Clear;
    SqlUpdateTarTable('tarifikaciya', 'FOXPRO_KU', 'organization');
    SqlUpdateTarTable('tarifikaciya','FOXPRO_TABN', 'person');
    SqlUpdateTarTable('tarifikaciya','FOXPRO_OBR', 'obrazovanie');
    SqlApplyMigrationTable('tarifikaciya', 'FOXPRO_KU', 'organization');
    SqlApplyMigrationTable('tarifikaciya', 'FOXPRO_TABN', 'person');
    SqlApplyMigrationTable('tarifikaciya', 'FOXPRO_OBR', 'obrazovanie');
  end;
  Form1.SQL.Execute;
end;

procedure UpdateTarJobs;
begin
  with Form1.SQL.Script do begin
    Clear;
    SqlUpdateTarTable('tar_job','FOXPRO_DOLJ', 'doljnost');
    SqlUpdateTarTable('tar_job','FOXPRO_PREDM', 'predmet');
    SqlUpdateTarTable('tar_job','FOXPRO_RAZR', 'stavka');
    SqlUpdateTarTable('tar_job','FOXPRO_KAT', 'kategory');
    SqlApplyMigrationTable('tar_job', 'FOXPRO_DOLJ', 'doljnost');
    SqlApplyMigrationTable('tar_job', 'FOXPRO_PREDM', 'predmet');
    SqlApplyMigrationTable('tar_job', 'FOXPRO_RAZR', 'stavka');
    SqlApplyMigrationTable('tar_job', 'FOXPRO_KAT', 'kategory');
  end;
  Form1.SQL.Execute;
end;

procedure UpdateTarNadbavky;
begin
  with Form1.SQL.Script do begin
    Clear;
    SqlUpdateTarTable('tar_nadbavka','FOXPRO_NADB', 'nadbavka');
    SqlApplyMigrationTable('tar_nadbavka', 'FOXPRO_NADB', 'nadbavka');
  end;
  Form1.SQL.Execute;
end;

procedure ClearTables;
var
  numMissedTarOrgs: String;
begin
  with Form1.QSelect do begin
    SQL.Clear;
    SQL.Append('select count(*) as num ');
    SQL.Append('from tarifikaciya where id_organization = 0;');
    Open;
    numMissedTarOrgs := FieldByName('num').AsString;
    Close;
  end;
  if numMissedTarOrgs <> '0' then
    ShowMessage('Для '+numMissedTarOrgs+
                ' записей, организации в справочнике не найдены,'+LineEnding+
                'эти записи не будут импортированны!');
  Form1.SQL.Script.Clear;
  with Form1.SQL.Script do begin
    AddText('delete from tarifikaciya where id_organization = 0;');
  end;

  SqlRemoveColumnsFromTable('organization',
    ['pg', 'gr']);

  //SqlRemoveColumnsFromTable('org_group',
  //  ['FOXPRO_KOD']);

  //SqlRemoveColumnsFromTable('person',
  //  ['FOXPRO_KOD']);

  //SqlRemoveColumnsFromTable('personal_group',
  //  ['FOXPRO_KOD']);

  SqlRemoveColumnsFromTable('doljnost',
    ['kolvo', 'por', 'pk', 'gopl']);

  //SqlRemoveColumnsFromTable('obrazovanie',
  //  ['FOXPRO_KOD']);

  //SqlRemoveColumnsFromTable('predmet',
  //  ['FOXPRO_KOD']);

  SqlRemoveColumnsFromTable('nadbavka',
    ['por', 'pr']);

  SqlRemoveColumnsFromTable('doplata',
    ['por', 'pk', 'pr']);

  //SqlRemoveColumnsFromTable('stavka',
  //  ['RAZR']);

  //SqlRemoveColumnsFromTable('kategory',
  //  ['FOXPRO_KOD']);

  SqlRemoveColumnsFromTable('tarifikaciya',
    ['FOXPRO_KU', 'FOXPRO_TABN', 'FOXPRO_OBR']);

  SqlRemoveColumnsFromTable('tar_job',
    ['FOXPRO_PREDM', 'FOXPRO_DOLJ',
     'FOXPRO_SUMCL',
     'FOXPRO_NADB', 'FOXPRO_DOPL',
     'FOXPRO_RAZR', 'FOXPRO_KAT',
     'FOXPRO_STIM']);

  SqlRemoveColumnsFromTable('tar_nadbavka',
    ['FOXPRO_NADB']);

  with Form1.SQL.Script do begin
    AddText('drop table migration_table;');
  end;

  Form1.SQL.Execute;
end;

procedure OptimizeDatabase;
begin
  with Form1.MainConnection do begin
    ExecuteDirect('End Transaction');
    ExecuteDirect('VACUUM');
    ExecuteDirect('pragma optimize;');
    ExecuteDirect('Begin Transaction');
  end;
end;

end.

