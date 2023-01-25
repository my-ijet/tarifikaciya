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
  SqlCreateTable := 'CREATE TABLE "_user_new" '+
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
                    'FOREIGN KEY(id_person) REFERENCES "person"(id) ON DELETE SET NULL)';
  SQLExecute(SqlCreateTable);

// запись значений в новые таблицы
  SQLExecute('insert into _user_new select * from _user;');
// удаление старых таблиц
  SQLExecute('drop table _user;');
// переименование новых таблиц
  SQLExecute('alter table _user_new rename to _user;');
  SQLExecute('PRAGMA foreign_keys=ON;');

// новые таблицы
  SqlCreateTable :=
     'CREATE VIEW tar_job_doplata_summa AS '+
     'WITH total_doplata as '+
     ' (SELECT doplata.id, '+
     '		NULLIF((ifnull(doplata.percent, 0) + ifnull(tar_job_doplata.dop_percent, 0)), 0) as total_percent, '+
     '		NULLIF((ifnull(doplata.summa, 0) + ifnull(tar_job_doplata.dop_summa, 0)), 0) as total_summa '+
     ' FROM tar_job_doplata '+
     ' JOIN doplata on tar_job_doplata.id_doplata = doplata.id) '+
     'SELECT tar_job_doplata.id, '+
     '	   tar_job_doplata.id_tar_job, '+
     '	   total_summa, '+
     '	   total_percent, '+
     '	   (total_percent / 100 * stavka.summa) as total_percent_summa, '+
     '	   NULLIF(( ifnull(total_summa, 0) + (ifnull(total_percent, 0) / 100 * stavka.summa)), 0) as total_doplata_summa '+
     'FROM tar_job_doplata, total_doplata '+
     'JOIN tar_job on tar_job_doplata.id_tar_job = tar_job.id '+
     'JOIN stavka on tar_job.id_stavka = stavka.id '+
     'WHERE tar_job_doplata.id_doplata = total_doplata.id; ';
  SQLExecute(SqlCreateTable);

  SqlCreateTable :=
     'CREATE VIEW tar_job_summa AS '+
     'SELECT tar_job.id, '+
     '	   tar_job.id_tarifikaciya, '+
     '	   total_tar_job_doplata.total_summa as total_doplata_summa, '+
     '	   total_tar_job_doplata.total_percent as total_doplata_persent, '+
     '	   (total_tar_job_doplata.total_percent / 100 * stavka.summa) as total_doplata_persent_summa, '+
     '	   total_nadbavka.total_percent as total_nadbavka_percent, '+
     '	   (total_nadbavka.total_percent / 100 * stavka.summa) as total_nadbavka_summa, '+
     '	   NULLIF((ifnull(total_nadbavka.total_percent, 0) + ifnull(total_tar_job_doplata.total_percent, 0)), 0) as total_percent, '+
     '	   ( NULLIF((ifnull(total_nadbavka.total_percent, 0) + ifnull(total_tar_job_doplata.total_percent, 0)), 0) / 100 * stavka.summa ) as total_percent_summa, '+
     '	   (stavka.summa + ifnull(total_tar_job_doplata.total_summa, 0) + '+
     '	   ( (ifnull(total_nadbavka.total_percent, 0) + ifnull(total_tar_job_doplata.total_percent, 0)) / 100 * stavka.summa ) ) as total_summa '+
     'FROM tar_job '+
     'JOIN stavka on tar_job.id_stavka = stavka.id '+
     'LEFT JOIN total_nadbavka on tar_job.id_tarifikaciya = total_nadbavka.id_tarifikaciya '+
     'LEFT JOIN total_tar_job_doplata on tar_job.id = total_tar_job_doplata.id_tar_job; ';
  SQLExecute(SqlCreateTable);

  SqlCreateTable :=
     'CREATE VIEW tar_nadbavka_summa AS '+
     'WITH total_tar_job_stavka as '+
     '(SELECT tar_job.id_tarifikaciya, '+
     '		 sum(stavka.summa) as total_summa '+
     ' FROM tar_job '+
     ' JOIN stavka on tar_job.id_stavka = stavka.id '+
     ' GROUP by tar_job.id_tarifikaciya) '+
     'SELECT tar_nadbavka.id, '+
     '	    tar_nadbavka.id_tarifikaciya, '+
     '		nadbavka.percent, '+
     '	    ( percent / 100 * total_summa ) as total_nadbavka_summa '+
     'FROM tar_nadbavka, total_tar_job_stavka '+
     'JOIN tarifikaciya on tar_nadbavka.id_tarifikaciya = tarifikaciya.id '+
     'JOIN nadbavka on tar_nadbavka.id_nadbavka = nadbavka.id '+
     'WHERE total_tar_job_stavka.id_tarifikaciya = tar_nadbavka.id_tarifikaciya; ';
  SQLExecute(SqlCreateTable);

  SqlCreateTable :=
     'CREATE VIEW total_nadbavka AS '+
     'SELECT tar_nadbavka.id_tarifikaciya, sum(nadbavka.percent) as total_percent '+
     'FROM tar_nadbavka '+
     'JOIN nadbavka on tar_nadbavka.id_nadbavka = nadbavka.id '+
     'GROUP by tar_nadbavka.id_tarifikaciya; ';
  SQLExecute(SqlCreateTable);

  SqlCreateTable :=
     'CREATE VIEW total_tar_job AS '+
     'SELECT tar_job.id_tarifikaciya, '+
     '	   sum(total_summa) as total_summa '+
     'from tar_job '+
     'JOIN tar_job_summa on tar_job.id = tar_job_summa.id '+
     'GROUP by tar_job.id_tarifikaciya; ';
  SQLExecute(SqlCreateTable);

  SqlCreateTable :=
     'CREATE VIEW total_tar_job_doplata AS '+
     'SELECT tar_job_doplata.id_tar_job, '+
     '       sum(percent + dop_percent) as total_percent, '+
     '	   sum(summa + dop_summa) as total_summa '+
     'FROM tar_job_doplata '+
     'JOIN doplata on tar_job_doplata.id_doplata = doplata.id '+
     'GROUP by tar_job_doplata.id_tar_job; ';
  SQLExecute(SqlCreateTable);
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
  if MessageDlg('ВСЕ справочники будут УДАЛЕНЫ (рекомендуется создать резервную копию). Продолжить?', mtConfirmation, mbYes or mbNo, 0) = mrNo
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

begin
  DbFilePath := GetDatabaseFilePath;
  DbDirectory := ExtractFileDir(DbFilePath);
  DbName := GetFileName(DbFilePath);

  if DbDirectory = '' then DbDirectory := ExtractFilePath(application.ExeName);

  ForceDirectories(DbDirectory+'backups\');
  BackupPath := DbDirectory+'backups\'+DbName;
end.
