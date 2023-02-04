uses
  'service.pas',
  'tarifikation.pas';

var
  DbFilePath, DbDirectory, DbName, BackupPath : String;

procedure FillTableDbBackup;
var
  BackupsList : TStringList;
  numOfFiles, i: Integer;
  BackupFileName : String;
  TableColumn : TNxCustomColumn;
begin
  BackupsList := TStringList.Create;
  BackupsList.Text := GetFilesList(DbDirectory+'backups\', '*.db', False);
  numOfFiles := BackupsList.Count;

  TableColumn := Tarifikation.TableDbBackups.Columns[0];
  TableColumn.Header.Caption := 'Список резервных копий';
  TableColumn.Width := 300;
  Tarifikation.TableDbBackups.ClearRows;

  if numOfFiles = 0 then Exit;
  Tarifikation.TableDbBackups.AddRow(numOfFiles);
  for i := 0 to numOfFiles - 1 do begin
    BackupFileName := ExtractFileName(BackupsList[i]);
    Tarifikation.TableDbBackups.Cells[0,i] := BackupFileName;
  end;

  TableColumn.SortKind := skDescending;
  TableColumn.Sorted := True;

  BackupsList.Free;
end;

procedure NewDbBackup;
var
  BackupFilePath, TimeStamp : String;
begin
  TimeStamp := FormatDateTime('YYYY-MM-DD_hh-mm-ss', Now);
  BackupFilePath := BackupPath+'_'+TimeStamp+'.db';

  ForceDirectories(DbDirectory+'backups\');
  CopyFile(DbFilePath, BackupFilePath);
end;

procedure RestoreDbBackup(BackupName: String);
var
  BackupFilePath : String;
begin
  BackupFilePath := DbDirectory+'backups\'+BackupName;
  DeleteFile(DbFilePath);
  CopyFile(BackupFilePath, DbFilePath);
end;

procedure DeleteDbBackup(BackupName: String);
var
  BackupFilePath : String;
begin
  BackupFilePath := DbDirectory+'backups\'+BackupName;
  DeleteFile(BackupFilePath);
end;

function GetFileName(PathToDb: String): String;
var
  Name, Extention : String;
begin
  Name := ExtractFileName(PathToDb);
  Extention := ExtractFileExt(PathToDb);
  Name := ReplaceStr(Name, Extention, '');
  Result := Name;
end;

procedure ApplyFixesOnNewDatabase;
var
  SqlCreateTable: String;
begin
// Дополнительная настройка БД
  SQLExecute('pragma mmap_size = 268435456;');
  SQLExecute('pragma temp_store = memory;');
  SQLExecute('pragma journal_mode = WAL;');

// Убираем ошибку вовремя удаления связанной записи
  SQLExecute('PRAGMA foreign_keys=OFF;');

  SQLExecute('insert into comp_type (id, name) values(1, "комп."), (2, "стим.")');

  SQLExecute(
    'CREATE TABLE "_user_new" '+
    '(id INTEGER PRIMARY KEY ASC AUTOINCREMENT, '+
    '"username" TEXT NOT NULL DEFAULT "empty", '+
    '"password" TEXT, '+
    '"id__role" INTEGER, '+
    '"is_admin" INTEGER, '+
    '"is_active" INTEGER, '+
    '"email" TEXT, '+
    '"first_name" TEXT, '+
    '"last_name" TEXT, '+
    '"last_login" TEXT, '+
    '"date_joined" TEXT, '+
    '"id_doljnost" INTEGER, '+
    '"id_organization" INTEGER, '+
    '"id_person" INTEGER, '+
    '"date_tar_start" TEXT, '+
    '"date_tar_end" TEXT, '+
    '"date_tar_current" TEXT, '+
    '"id_org_group" INTEGER, '+
    '"id_organization1" INTEGER, '+
    'FOREIGN KEY(id__role) REFERENCES "_role"(id), '+
    'FOREIGN KEY(id_doljnost) REFERENCES "doljnost"(id) ON DELETE SET NULL, '+
    'FOREIGN KEY(id_organization) REFERENCES "organization"(id) ON DELETE SET NULL, '+
    'FOREIGN KEY(id_org_group) REFERENCES "org_group"(id) ON DELETE SET NULL, '+
    'FOREIGN KEY(id_organization1) REFERENCES "organization"(id) ON DELETE SET NULL, '+
    'FOREIGN KEY(id_person) REFERENCES "person"(id) ON DELETE SET NULL)'
    );

  SQLExecute('ALTER TABLE person add column '+
             'FIO text as (printf("%s %s %s", familyname, firstname, middlename))');

// запись значений в новые таблицы
  SQLExecute('insert into _user_new select * from _user;');
// удаление старых таблиц
  SQLExecute('drop table _user;');
// переименование новых таблиц
  SQLExecute('alter table _user_new rename to _user;');
  SQLExecute('PRAGMA foreign_keys=ON;');

// новые таблицы
  SQLExecute(
    'CREATE VIEW total_nadbavka AS '+
    'SELECT id_tarifikaciya, total(nad_percent) as total_percent '+
    'FROM tar_nadbavka '+
    'GROUP by id_tarifikaciya; '
    );

  SQLExecute(
    'CREATE VIEW total_job_doplata AS '+
    'SELECT id_tar_job, '+
    '       total(dop_percent) as total_percent, '+
    '       total(dop_summa) as total_summa '+
    'FROM tar_job_doplata '+
    'GROUP by id_tar_job; '
    );

  SQLExecute(
    'CREATE VIEW tar_job_summa AS '+
    'WITH job_itog as ( '+
    'SELECT tar_job.id, '+
    '       ifnull(stavka.summa, 0)+(ifnull(stavka.summa, 0) * ifnull(oklad_plus_percent, 0) /100) as oklad, '+
    '       (ifnull(stavka.summa, 0)+(ifnull(stavka.summa, 0) * ifnull(oklad_plus_percent, 0) / 100)) * ifnull(clock_coeff, 0)  as nagruzka, '+
    '       ifnull(kategory_coeff, 0) * ((ifnull(stavka.summa, 0)+(ifnull(stavka.summa, 0) * ifnull(oklad_plus_percent, 0) / 100)) * ifnull(clock_coeff, 0)) as kategory_summa '+

    'FROM tar_job '+
    'LEFT JOIN stavka on tar_job.id_stavka = stavka.id '+
    ') '+
    'SELECT tar_job.id, '+
    '       tar_job.id_tarifikaciya, '+
    '       (job_itog.nagruzka / 100 * ifnull(total_nadbavka.total_percent, 0)) as nadbavka_summa, '+

    '       ifnull(total_job_doplata.total_summa, 0) as doplata_summa, '+
    '       (job_itog.nagruzka / 100 * ifnull(total_job_doplata.total_percent, 0) ) as doplata_persent_summa, '+

    '       job_itog.oklad, job_itog.nagruzka, job_itog.kategory_summa, '+

    '       ( job_itog.nagruzka / 100 * (ifnull(total_nadbavka.total_percent, 0) + ifnull(total_job_doplata.total_percent, 0))) as total_percent_summa, '+

    '       (job_itog.nagruzka + job_itog.kategory_summa + ifnull(total_job_doplata.total_summa, 0) + '+
    '       (job_itog.nagruzka / 100 * (ifnull(total_nadbavka.total_percent, 0) + ifnull(total_job_doplata.total_percent, 0))) ) as total_summa '+

    'FROM job_itog '+
    'JOIN tar_job on tar_job.id = job_itog.id '+
    'LEFT JOIN total_nadbavka on tar_job.id_tarifikaciya = total_nadbavka.id_tarifikaciya '+
    'LEFT JOIN total_job_doplata on tar_job.id = total_job_doplata.id_tar_job '
    );

  SQLExecute(
    'CREATE VIEW tar_job_doplata_summa AS '+
    'WITH '+
    'total_tar_job_nagruzka as '+
    '(SELECT tar_job_summa.id, tar_job_summa.id_tarifikaciya, '+
    '        total(tar_job_summa.nagruzka) as total_summa '+
    ' FROM tar_job_summa '+
    ' GROUP by tar_job_summa.id_tarifikaciya, tar_job_summa.id) '+

    'SELECT tar_job_doplata.id, '+
    '       tar_job_doplata.id_tar_job, '+
    '       ifnull(dop_summa, 0) as total_summa, '+
    '       ifnull(dop_percent, 0) as total_percent, '+

    '       (total_tar_job_nagruzka.total_summa / 100 * ifnull(dop_percent, 0)) as total_percent_summa, '+
    '       (ifnull(dop_summa, 0) + (total_tar_job_nagruzka.total_summa / 100 * ifnull(dop_percent, 0))) as total_doplata_summa '+
    'FROM tar_job_doplata '+
    'JOIN total_tar_job_nagruzka on tar_job_doplata.id_tar_job = total_tar_job_nagruzka.id '
    );

  SQLExecute(
    'CREATE VIEW tar_nadbavka_summa AS '+
    'WITH total_tar_job_nagruzka as '+
    '(SELECT tar_job_summa.id_tarifikaciya, '+
    '        total(tar_job_summa.nagruzka) as total_summa '+
    ' FROM tar_job_summa '+
    ' GROUP by tar_job_summa.id_tarifikaciya) '+
    'SELECT tar_nadbavka.id, '+
    '       tar_nadbavka.id_tarifikaciya, '+
    '       nad_percent, '+
    '       ( total_summa / 100 * nad_percent ) as total_nadbavka_summa '+
    'FROM tar_nadbavka '+
    'LEFT JOIN total_tar_job_nagruzka on tar_nadbavka.id_tarifikaciya = total_tar_job_nagruzka.id_tarifikaciya; '
    );

  SQLExecute(
    'CREATE VIEW tar_nad_dop AS '+
    'SELECT id_tar_job, '+
    '       doplata.name, '+
    '       dop_percent as percent, '+
    '       dop_summa as summa, '+
    '       por, id_comp_type '+
    'FROM tar_job_doplata '+
    'JOIN doplata on tar_job_doplata.id_doplata = doplata.id '+
    'UNION ALL '+
    'SELECT tar_job.id, '+
    '       nadbavka.name, '+
    '       nad_percent as percent, '+
    '       0 as summa, '+
    '       nadbavka.por, id_comp_type '+
    'FROM tar_nadbavka '+
    'JOIN nadbavka on tar_nadbavka.id_nadbavka = nadbavka.id '+
    'JOIN tar_job on tar_nadbavka.id_tarifikaciya = tar_job.id_tarifikaciya '
    );

  SQLExecute(
    'CREATE VIEW total_tar_nad_dop AS '+
    'SELECT id_tar_job, id_comp_type, '+
    '       total(percent) as percent, '+
    '       total(summa) as summa '+
    'FROM tar_nad_dop '+
    'GROUP by id_tar_job, id_comp_type');

  SQLExecute(
    'CREATE VIEW tar_job_viplaty_comp AS '+
    'SELECT tar_job.id, tar_job.id_tarifikaciya, '+
    'total_tar_nad_dop.percent, '+
    'total_tar_nad_dop.summa '+
    'FROM tar_job '+
    'JOIN total_tar_nad_dop on tar_job.id = total_tar_nad_dop.id_tar_job '+
    '                      and total_tar_nad_dop.id_comp_type = 1');
  SQLExecute(
    'CREATE VIEW tar_job_viplaty_stim AS '+
    'SELECT tar_job.id, tar_job.id_tarifikaciya, '+
    'total_tar_nad_dop.percent, '+
    'total_tar_nad_dop.summa '+
    'FROM tar_job '+
    'JOIN total_tar_nad_dop on tar_job.id = total_tar_nad_dop.id_tar_job '+
    '                      and total_tar_nad_dop.id_comp_type = 2');

  SQLExecute(
    'CREATE VIEW total_tar_job AS '+
    'SELECT id_tarifikaciya, '+
    '       total(total_summa) as total_summa '+
    'from tar_job_summa '+
    'GROUP by id_tarifikaciya;'
    );

end;

procedure UpdateAllTables;
begin
  UpdateDatabase('org_head');
  UpdateDatabase('org_group');
  UpdateDatabase('organization');
  UpdateDatabase('person');
  UpdateDatabase('personal_group');
  UpdateDatabase('doljnost');
  UpdateDatabase('obrazovanie');
  UpdateDatabase('predmet');
  UpdateDatabase('nadbavka');
  UpdateDatabase('doplata');
  UpdateDatabase('stavka');
  UpdateDatabase('kategory');
  UpdateDatabase('comp_type');
  UpdateDatabase('tarifikaciya');
  UpdateDatabase('tar_nadbavka');
  UpdateDatabase('tar_job');
  UpdateDatabase('tar_job_doplata');
  UpdateDatabase('_user');
  UpdateDatabase('_role');

  DbStatisticsCalculate;
end;

procedure DbStatisticsCalculate;
var
  filesize: Int64;
  divider: Integer;
  DbSize, Postfix: String;
begin
  Tarifikation.LabelNumTarifikations.Caption := SQLExecute('select count(*) from tarifikaciya;');
  Tarifikation.LabelNumPersons.Caption := SQLExecute('select count(*) from person;');
  Tarifikation.LabelNumOrganizations.Caption := SQLExecute('select count(*) from organization;');

  // TODO DELETE
  Tarifikation.LabelNumTarJobs.Caption := SQLExecute('select count(*) from tar_job;');
  Tarifikation.LabelNumTarNadbavky.Caption := SQLExecute('select count(*) from tar_nadbavka;');
  Tarifikation.LabelNumTarDoplaty.Caption := SQLExecute('select count(*) from tar_job_doplata;');

  filesize := GetFileSize(DbFilePath);
  if filesize < 1000 then DbSize := IntToStr(filesize)+' байт' else
  if filesize < 1000000 then DbSize := IntToStr(filesize/1024)+' Кбайт' else
  if filesize < 1000000000 then DbSize := IntToStr(filesize/1048576)+' Мбайт' else
  if filesize < 1000000000000 then DbSize := IntToStr(filesize/1073741824)+' Гбайт';

  Tarifikation.LabelDatabaseSize.Caption := DbSize;
end;

procedure OptimizeDatabase;
begin
  try SQLExecute('pragma wal_checkpoint; VACUUM');
  except end;
  SQLExecute('pragma optimize;');
end;

procedure DeleteSpravochniky;
begin
  if MessageDlg('ВСЕ справочники и связанные тарификационные списки будут УДАЛЕНЫ (рекомендуется создать резервную копию). Продолжить?', mtConfirmation, mbYes or mbNo, 0) = mrNo
  then Exit;

  SQLExecute('delete from org_head;');
  SQLExecute('delete from organization;');
  SQLExecute('delete from org_group;');
  SQLExecute('delete from person;');
  SQLExecute('delete from personal_group;');
  SQLExecute('delete from doljnost;');
  SQLExecute('delete from obrazovanie;');
  SQLExecute('delete from predmet;');
  SQLExecute('delete from nadbavka;');
  SQLExecute('delete from doplata;');
  SQLExecute('delete from stavka;');
  SQLExecute('delete from kategory;');

  OptimizeDatabase;

  UpdateAllTables;
end;

procedure DeleteTarifikationsBeforSelectedDate(SelectedDate: String);
begin
  SQLExecute('delete from tarifikaciya '+
             'where date(date) < date('+SelectedDate+')');

  OptimizeDatabase;

  UpdateAllTables;
end;

procedure DeleteTarifikations;
begin
  if MessageDlg('ВСЕ тарификации будут УДАЛЕНЫ (рекомендуется создать резервную копию). Продолжить?', mtConfirmation, mbYes or mbNo, 0) = mrNo
  then Exit;

  SQLExecute('delete from tarifikaciya;');
  SQLExecute('delete from tar_nadbavka;');
  SQLExecute('delete from tar_job;');
  SQLExecute('delete from tar_job_doplata;');

  OptimizeDatabase;

  UpdateAllTables;
end;

// Находим дубли
function SqlApplyMigrationTable(TableName: String;
                                 ChildTable: String) : String;
var
  SQL_result : String = '';
begin
  SQL_result := 'UPDATE '+TableName+
    ' SET id_'+ChildTable+' = migration_table.to_id '+
    ' FROM migration_table '+
    ' where '+TableName+'.id_'+ChildTable+' = migration_table.from_id '+
    '  and migration_table.table_name = "'+ChildTable+'"; ';
  Result := SQL_result;
end;

function SqlDeleteSpravochnikyWithMigrationTable(TableName: String) : String;
var
  SQL_result : String = '';
begin
  SQL_result := 'DELETE FROM '+TableName+
    ' WHERE id in ( '+
    ' SELECT from_id FROM migration_table '+
    ' WHERE table_name = "'+TableName+'"); ';
  Result := SQL_result;
end;

procedure FindAndDeleteDublicates;
var
  spravochniky: array[0..10] of String;
  sql_command, sprav : String;
  i : Integer;
begin
  sql_command := 'create table if not exists migration_table '+
                 '(table_name varchar(15), from_id int, to_id int);';
  SQLExecute(sql_command);

  spravochniky[0] := 'org_group';
  spravochniky[1] := 'personal_group';
  spravochniky[2] := 'doljnost';
  spravochniky[3] := 'obrazovanie';
  spravochniky[4] := 'predmet';
  spravochniky[5] := 'nadbavka';
  spravochniky[6] := 'doplata';
  spravochniky[7] := 'stavka';
  spravochniky[8] := 'kategory';

  for i:=0 to 8 do begin
    sprav := spravochniky[i];
    sql_command := 'insert into migration_table (table_name, from_id, to_id) '+
                    'SELECT "'+sprav+'", t2.id, t1.id '+
                    'FROM (SELECT id, name FROM '+sprav+' GROUP by name) as t1 '+
                    'JOIN '+sprav+' as t2 on t1.name = t2.name and t1.id != t2.id;';
    SQLExecute(sql_command);
  end;

  sql_command := 'insert into migration_table (table_name, from_id, to_id) '+
                 'SELECT "organization", t2.id, t1.id '+
                 'FROM (SELECT id, short_name FROM organization GROUP by short_name) as t1 '+
                 'JOIN organization as t2 on t1.short_name = t2.short_name and t1.id != t2.id;';
  SQLExecute(sql_command);

  sql_command := 'insert into migration_table (table_name, from_id, to_id) '+
                 'SELECT "person", t2.id, t1.id '+
                 'FROM (SELECT id, familyname, firstname, middlename FROM person '+
                 '      GROUP by familyname, firstname, middlename) as t1 '+
                 'JOIN person as t2 '+
                 ' on t1.familyname = t2.familyname '+
                 ' and t1.firstname = t2.firstname '+
                 ' and t1.middlename = t2.middlename '+
                 ' and t1.id != t2.id;';
  SQLExecute(sql_command);

  sql_command := SqlApplyMigrationTable('organization', 'org_group');
  SQLExecute(sql_command);
  sql_command := SqlApplyMigrationTable('tarifikaciya', 'person');
  SQLExecute(sql_command);
  sql_command := SqlApplyMigrationTable('tar_job', 'doljnost');
  SQLExecute(sql_command);
  sql_command := SqlApplyMigrationTable('tar_job', 'predmet');
  SQLExecute(sql_command);
  sql_command := SqlApplyMigrationTable('tar_job', 'stavka');
  SQLExecute(sql_command);
  sql_command := SqlApplyMigrationTable('tar_job', 'kategory');
  SQLExecute(sql_command);
  sql_command := SqlApplyMigrationTable('tar_nadbavka', 'nadbavka');
  SQLExecute(sql_command);
  sql_command := SqlApplyMigrationTable('tar_job_doplata', 'doplata');
  SQLExecute(sql_command);

  spravochniky[9] := 'organization';
  spravochniky[10] := 'person';
  for i:=0 to 10 do begin
    sprav := spravochniky[i];
    sql_command := SqlDeleteSpravochnikyWithMigrationTable(sprav);
    SQLExecute(sql_command);
  end;

  sql_command := 'drop table if exists migration_table';
  SQLExecute(sql_command);

  OptimizeDatabase;

  UpdateAllTables;
end;
// Находим дубли

procedure Peretarifikaciya(SelectedDate: String);
begin
  // SQLExecute('delete from tarifikaciya '+
             // 'where date(date) < date('+SelectedDate+')');

  OptimizeDatabase;

  UpdateAllTables;
end;

begin
  DbFilePath := GetDatabaseFilePath;
  DbDirectory := ExtractFileDir(DbFilePath);
  DbName := GetFileName(DbFilePath);

  if DbDirectory = '' then DbDirectory := ExtractFilePath(application.ExeName);

  ForceDirectories(DbDirectory+'backups\');
  BackupPath := DbDirectory+'backups\'+DbName;
end.
