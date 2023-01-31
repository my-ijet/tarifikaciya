unit sql_commands;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs;

procedure PrepareTables;

procedure ImportTarifikaciyaFromT1;
procedure ImportTarNadbavkaFromT2;
procedure ImportTarJobFromT2;
procedure ImportTarJobDoplataFromT2;

procedure UpdateSpravochniky;
procedure UpdateTarJobs;
procedure UpdateTarNadbavky;
procedure UpdateTarJobDoplaty;

procedure RemoveDuplicatesFromT1;
procedure RemoveDuplicatesFromT2;
procedure RemoveDuplicatesFromSpravochnikyAfterImport;
procedure RemoveDuplicatesFromTarifikaciyaAfterImport;
procedure RemoveDuplicatesFromTarNadbavkaAfterImport;
procedure RemoveDuplicatesFromTarJobAfterImport;
procedure RemoveDuplicatesFromTarJobDoplataAfterImport;

procedure FindAndRemoveDuplicatesInData;
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
    ['pk int', 'gopl int']);

  //SqlAddColumnsToTable('obrazovanie',
  //  ['FOXPRO_KOD varchar(5)']);

  //SqlAddColumnsToTable('predmet',
  //  ['FOXPRO_KOD varchar(5)']);

  SqlAddColumnsToTable('nadbavka',
    ['por int', 'pr varchar(5)']);

  SqlAddColumnsToTable('doplata',
    ['por int', 'pk int', 'pr varchar(5)']);

  //SqlAddColumnsToTable('stavka',
  //  ['RAZR int']);

  //SqlAddColumnsToTable('kategory',
  //  ['FOXPRO_KOD varchar(5)']);

  with Form1.SQL.Script do begin
    AddText('create table if not exists T1 (');
    AddText('FOXPRO_KU varchar(5),');
    AddText('FOXPRO_TABN varchar(5),');
    AddText('FOXPRO_OBR varchar(5),');
    AddText('FOXPRO_NOMDIP text,');
    AddText('FOXPRO_STAGY int,');
    AddText('FOXPRO_STAGM int,');
    AddText('FOXPRO_DATAZN text, ');
    AddText('FOXPRO_DATA text );');

    AddText('create table if not exists T2 (');
    AddText('FOXPRO_KU varchar(5),');
    AddText('FOXPRO_TABN varchar(5),');
    AddText('FOXPRO_DOLJ varchar(5),');
    AddText('FOXPRO_PREDM varchar(5),');
    AddText('FOXPRO_CLOCK double,');
    AddText('FOXPRO_SUMCL double,');
    AddText('FOXPRO_NADB varchar(5),');
    AddText('FOXPRO_PROC_N double, ');
    AddText('FOXPRO_DOPL varchar(5),');
    AddText('FOXPRO_PROC_D double, ');
    AddText('FOXPRO_SUMD double, ');
    AddText('FOXPRO_RAZR varchar(5),');
    AddText('FOXPRO_KAT varchar(5),');
    AddText('FOXPRO_STAVKA double,');
    AddText('FOXPRO_STIM double,');
    AddText('FOXPRO_DATA text );');

    AddText('create table if not exists migration_table (');
    AddText('table_name varchar(15),');
    AddText('FOXPRO_KOD varchar(5),');
    AddText('to_id int );');
  end;

  Form1.SQL.Execute;
end;


procedure ImportTarifikaciyaFromT1;
begin
  with Form1.SQL.Script do begin
    Clear;
    AddText('INSERT INTO tarifikaciya');
    AddText('(id_organization, date, id_person, id_obrazovanie, diplom,');
    AddText('staj_year, staj_month, main)');
    AddText('SELECT ifnull(organization.id, 0) as id_organization,');
    AddText('   date(T1.FOXPRO_DATA) as date,');
    AddText('   ifnull(person.id, 0) as id_person,');
    AddText('   ifnull(obrazovanie.id, 0) as id_obrazovanie,');
    AddText('   T1.FOXPRO_NOMDIP,');
    AddText('   T1.FOXPRO_STAGY,');
    AddText('   T1.FOXPRO_STAGM,');
    AddText('   IIF( T1.FOXPRO_DATA = T1.FOXPRO_DATAZN, 1, 0) as main');
    AddText('FROM T1');
    AddText('JOIN organization on T1.FOXPRO_KU = organization.FOXPRO_KOD');
    AddText('LEFT JOIN person on T1.FOXPRO_TABN = person.FOXPRO_KOD');
    AddText('LEFT JOIN obrazovanie on T1.FOXPRO_OBR = obrazovanie.FOXPRO_KOD');
  end;
  Form1.MainConnection.ExecuteDirect('PRAGMA foreign_keys=OFF;');
  Form1.SQL.Execute;
  Form1.MainConnection.ExecuteDirect('PRAGMA foreign_keys=ON;');

  RemoveDuplicatesFromTarifikaciyaAfterImport;
end;

procedure ImportTarNadbavkaFromT2;
begin
  with Form1.SQL.Script do begin
    Clear;
    AddText('INSERT INTO tar_nadbavka');
    AddText('(id_tarifikaciya, id_nadbavka, nad_percent)');
    AddText('WITH tar as (SELECT');
    AddText('organization.id as id_organization,');
    AddText('person.id as id_person,');
    AddText('date(T1.FOXPRO_DATA) as date,');
    AddText('FOXPRO_KU, FOXPRO_TABN, FOXPRO_DATA');
    AddText('FROM T1');
    AddText('JOIN organization on T1.FOXPRO_KU = organization.FOXPRO_KOD');
    AddText('LEFT JOIN person on T1.FOXPRO_TABN = person.FOXPRO_KOD)');
    AddText('SELECT tarifikaciya.id, ');
    AddText('       ifnull(nadbavka.id, 0) as id_nadbavka,');
    AddText('       T2.FOXPRO_PROC_N as nad_percent');
    AddText('FROM T2');
    AddText('JOIN tar on T2.FOXPRO_KU = tar.FOXPRO_KU');
    AddText('        and T2.FOXPRO_TABN = tar.FOXPRO_TABN');
    AddText('        and T2.FOXPRO_DATA = tar.FOXPRO_DATA');
    AddText('JOIN tarifikaciya on tar.id_organization = tarifikaciya.id_organization');
    AddText('                 and tar.id_person = tarifikaciya.id_person');
    AddText('                 and tar.date = tarifikaciya.date');
    AddText('JOIN nadbavka on T2.FOXPRO_NADB = nadbavka.FOXPRO_KOD;');
      AddText('WHERE T2.FOXPRO_PROC_N > 0');
  end;
  Form1.MainConnection.ExecuteDirect('PRAGMA foreign_keys=OFF;');
  Form1.SQL.Execute;
  Form1.MainConnection.ExecuteDirect('PRAGMA foreign_keys=ON;');

  RemoveDuplicatesFromTarNadbavkaAfterImport;
end;

procedure ImportTarJobFromT2;
begin
  with Form1.SQL.Script do begin
    Clear;
    AddText('INSERT INTO tar_job');
    AddText('(id_tarifikaciya, id_doljnost, id_predmet, clock, clock_coeff,');
    AddText(' id_kategory, id_stavka, stavka_coeff)');
    AddText('WITH tar as (SELECT');
    AddText('       organization.id as id_organization,');
    AddText('       person.id as id_person,');
    AddText('       date(T1.FOXPRO_DATA) as date,');
    AddText('       FOXPRO_KU, FOXPRO_TABN, FOXPRO_DATA');
    AddText('FROM T1');
    AddText('JOIN organization on T1.FOXPRO_KU = organization.FOXPRO_KOD');
    AddText('LEFT JOIN person on T1.FOXPRO_TABN = person.FOXPRO_KOD)');
    AddText('SELECT tarifikaciya.id,');
    AddText('       ifnull(doljnost.id, 0) as id_doljnost,');
    AddText('       ifnull(predmet.id, 0) as id_predmet,');
    AddText('       FOXPRO_CLOCK as clock,');
    AddText('       FOXPRO_STAVKA as clock_coeff,');
    AddText('       ifnull(kategory.id, 0) as id_kategory,');
    AddText('       ifnull(stavka.id, 0) as id_stavka,');
    AddText('       FOXPRO_STAVKA as stavka_coeff');
    AddText('FROM T2');
    AddText('JOIN tar on T2.FOXPRO_KU = tar.FOXPRO_KU');
    AddText('        and T2.FOXPRO_TABN = tar.FOXPRO_TABN');
    AddText('        and T2.FOXPRO_DATA = tar.FOXPRO_DATA');
    AddText('JOIN tarifikaciya on tar.id_organization = tarifikaciya.id_organization');
    AddText('                 and tar.id_person = tarifikaciya.id_person');
    AddText('                 and tar.date = tarifikaciya.date');
    AddText('LEFT JOIN doljnost on T2.FOXPRO_DOLJ = doljnost.FOXPRO_KOD');
    AddText('LEFT JOIN predmet on T2.FOXPRO_PREDM = predmet.FOXPRO_KOD');
    AddText('LEFT JOIN kategory on T2.FOXPRO_KAT = kategory.FOXPRO_KOD');
    AddText('LEFT JOIN stavka on T2.FOXPRO_RAZR = stavka.FOXPRO_KOD');
  end;
  Form1.MainConnection.ExecuteDirect('PRAGMA foreign_keys=OFF;');
  Form1.SQL.Execute;
  Form1.MainConnection.ExecuteDirect('PRAGMA foreign_keys=ON;');

  RemoveDuplicatesFromTarJobAfterImport;
end;

procedure ImportTarJobDoplataFromT2;
begin
  with Form1.SQL.Script do begin
      Clear;
      AddText('INSERT INTO tar_job_doplata');
      AddText('(id_tar_job, id_doplata, dop_percent, dop_summa)');
      AddText('WITH tar as (SELECT');
      AddText('       tarifikaciya.id,');
      AddText('       organization.id as id_organization,');
      AddText('       person.id as id_person,');
      AddText('       date(T1.FOXPRO_DATA) as date,');
      AddText('       FOXPRO_KU, FOXPRO_TABN, FOXPRO_DATA');
      AddText('FROM T1');
      AddText('JOIN organization on T1.FOXPRO_KU = organization.FOXPRO_KOD');
      AddText('JOIN tarifikaciya on organization.id = tarifikaciya.id_organization');
      AddText('                 and person.id = tarifikaciya.id_person');
      AddText('                 and date(T1.FOXPRO_DATA) = tarifikaciya.date');
      AddText('LEFT JOIN person on T1.FOXPRO_TABN = person.FOXPRO_KOD),');
      AddText('job as (SELECT');
      AddText('       doljnost.id as id_doljnost,');
      AddText('       predmet.id as id_predmet,');
      AddText('       FOXPRO_CLOCK as clock,');
      AddText('       kategory.id as id_kategory,');
      AddText('       stavka.id as id_stavka,');
      AddText('       FOXPRO_STAVKA as stavka_coeff,');
      AddText('       FOXPRO_KU, FOXPRO_TABN, FOXPRO_DOLJ, FOXPRO_PREDM,');
      AddText('       FOXPRO_NADB, FOXPRO_DOPL, FOXPRO_PROC_D, FOXPRO_SUMD,');
      AddText('       FOXPRO_KAT, FOXPRO_RAZR, FOXPRO_STIM, FOXPRO_SUMCL,');
      AddText('       FOXPRO_DATA');
      AddText('FROM T2');
      AddText('JOIN organization on T2.FOXPRO_KU = organization.FOXPRO_KOD');
      AddText('LEFT JOIN person on T2.FOXPRO_TABN = person.FOXPRO_KOD');
      AddText('LEFT JOIN doljnost on T2.FOXPRO_DOLJ = doljnost.FOXPRO_KOD');
      AddText('LEFT JOIN predmet on T2.FOXPRO_PREDM = predmet.FOXPRO_KOD');
      AddText('LEFT JOIN nadbavka on T2.FOXPRO_NADB = nadbavka.FOXPRO_KOD');
      AddText('LEFT JOIN doplata on T2.FOXPRO_DOPL = doplata.FOXPRO_KOD');
      AddText('LEFT JOIN kategory on T2.FOXPRO_KAT = kategory.FOXPRO_KOD');
      AddText('LEFT JOIN stavka on T2.FOXPRO_RAZR = stavka.FOXPRO_KOD )');
      AddText('SELECT tar_job.id,');
      AddText('       ifnull(doplata.id, 0) as id_doplata,');
      AddText('       T2.FOXPRO_PROC_D as dop_percent,');
      AddText('       iif(ROUND(ifnull(T2.FOXPRO_PROC_D, 0),2) != 0, 0, ROUND(T2.FOXPRO_SUMD,2)) as dop_summa');
      AddText('FROM T2');
      AddText('JOIN tar on T2.FOXPRO_KU = tar.FOXPRO_KU');
      AddText('        and T2.FOXPRO_TABN = tar.FOXPRO_TABN');
      AddText('        and T2.FOXPRO_DATA = tar.FOXPRO_DATA');
      AddText('JOIN job on T2.FOXPRO_KU = job.FOXPRO_KU');
      AddText('        and T2.FOXPRO_TABN = job.FOXPRO_TABN');
      AddText('        and T2.FOXPRO_DATA = job.FOXPRO_DATA');
      AddText('        and T2.FOXPRO_DOLJ = job.FOXPRO_DOLJ');
      AddText('        and T2.FOXPRO_PREDM = job.FOXPRO_PREDM');
      AddText('        and T2.FOXPRO_CLOCK = job.clock');
      AddText('        and T2.FOXPRO_NADB = job.FOXPRO_NADB');
      AddText('        and T2.FOXPRO_DOPL = job.FOXPRO_DOPL');
      AddText('        and T2.FOXPRO_PROC_D = job.FOXPRO_PROC_D');
      AddText('        and T2.FOXPRO_SUMD = job.FOXPRO_SUMD');
      AddText('        and T2.FOXPRO_KAT = job.FOXPRO_KAT');
      AddText('        and T2.FOXPRO_RAZR = job.FOXPRO_RAZR');
      AddText('        and T2.FOXPRO_STAVKA = job.stavka_coeff');
      AddText('        and T2.FOXPRO_STIM = job.FOXPRO_STIM');
      AddText('        and T2.FOXPRO_SUMCL = job.FOXPRO_SUMCL');
      AddText('JOIN tar_job on tar_job.id_tarifikaciya = tar.id');
      AddText('            and tar_job.id_doljnost = job.id_doljnost');
      AddText('            and tar_job.id_predmet = job.id_predmet');
      AddText('            and tar_job.clock = job.clock');
      AddText('            and tar_job.id_kategory = job.id_kategory');
      AddText('            and tar_job.id_stavka = job.id_stavka');
      AddText('            and tar_job.stavka_coeff = job.stavka_coeff');
      AddText('JOIN doplata on T2.FOXPRO_DOPL = doplata.FOXPRO_KOD');
      AddText('WHERE T2.FOXPRO_SUMD > 0');

      Form1.MainConnection.ExecuteDirect('PRAGMA foreign_keys=OFF;');
      Form1.SQL.Execute;
      Form1.MainConnection.ExecuteDirect('PRAGMA foreign_keys=ON;');

      RemoveDuplicatesFromTarJobDoplataAfterImport;
  end;
end;


procedure RemoveDuplicatesFromTable(TableName: String;
                                    Columns: String);
begin
  with Form1.SQL.Script do begin
    Clear;
    AddText('DELETE FROM '+TableName+' ');
    AddText('WHERE '+TableName+'.ROWID in (SELECT ROWID from ');
    AddText('(SELECT ROWID, ROW_NUMBER() OVER ( PARTITION BY ');
    AddText(Columns);
    AddText(') AS Row_Number ');
    AddText(' FROM '+TableName+') as SortedTable ');
    AddText(' WHERE Row_Number > 1)');
  end;
  Form1.SQL.Execute;
end;

procedure RemoveDuplicatesFromT1;
var
  columns: String;
begin
  columns := 'FOXPRO_KU, FOXPRO_TABN, FOXPRO_OBR, '+
             'FOXPRO_NOMDIP, FOXPRO_STAGY, FOXPRO_STAGM, '+
             'FOXPRO_DATAZN, FOXPRO_DATA ';
  RemoveDuplicatesFromTable('T1', columns);
end;

procedure RemoveDuplicatesFromT2;
var
  columns: String;
begin
  columns := 'FOXPRO_KU, FOXPRO_TABN, FOXPRO_DOLJ, '+
             'FOXPRO_PREDM, FOXPRO_CLOCK, '+
             'FOXPRO_NADB, FOXPRO_DOPL, '+
             'FOXPRO_PROC_D, FOXPRO_SUMD, '+
             'FOXPRO_RAZR, FOXPRO_KAT, '+
             'FOXPRO_STAVKA, FOXPRO_STIM, '+
             'FOXPRO_DATA ';
  RemoveDuplicatesFromTable('T2', columns);
end;

procedure RemoveDuplicatesFromSpravochnikyAfterImport;
var
  spravochniky: TStringArray;
  sprav : String;
begin
  spravochniky := ['organization',
                   'org_group',
                   'person',
                   'personal_group',
                   'doljnost',
                   'obrazovanie',
                   'predmet',
                   'nadbavka',
                   'doplata',
                   'stavka',
                   'kategory'];

  for sprav in spravochniky do begin
    RemoveDuplicatesFromTable(sprav, 'FOXPRO_KOD ');
  end;
end;

procedure RemoveDuplicatesFromTarifikaciyaAfterImport;
var
  columns: String;
begin
  columns := 'id_organization, date, id_person, id_obrazovanie, diplom, '+
             'staj_year, staj_month, main ';
  RemoveDuplicatesFromTable('tarifikaciya', columns);
end;

procedure RemoveDuplicatesFromTarNadbavkaAfterImport;
var
  columns: String;
begin
  columns := 'id_tarifikaciya, id_nadbavka ';
  RemoveDuplicatesFromTable('tar_nadbavka', columns);
end;

procedure RemoveDuplicatesFromTarJobAfterImport;
var
  columns: String;
begin
  columns := 'id_tarifikaciya, id_doljnost, id_predmet, clock, clock_coeff, '+
             'id_kategory, id_stavka, stavka_coeff ';
  RemoveDuplicatesFromTable('tar_job', columns);
end;

procedure RemoveDuplicatesFromTarJobDoplataAfterImport;
var
  columns: String;
begin
  columns := 'id_tar_job, id_doplata, dop_percent, dop_summa ';
  RemoveDuplicatesFromTable('tar_job_doplata', columns);
end;


procedure FindAndRemoveDuplicatesInData;
begin
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

procedure UpdateTarJobDoplaty;
begin
  with Form1.SQL.Script do begin
    Clear;
    SqlUpdateTarTable('tar_job_doplata','FOXPRO_DOPL', 'doplata');
    SqlApplyMigrationTable('tar_job_doplata', 'FOXPRO_DOPL', 'doplata');
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
    ['pk', 'gopl']);

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

  with Form1.SQL.Script do begin
    AddText('drop table if exists migration_table;');

    AddText('drop table if exists T1;');
    AddText('drop table if exists T2;');
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

