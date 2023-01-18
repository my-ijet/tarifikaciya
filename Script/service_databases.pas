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
begin
// Дополнительная настройка БД
  SQLExecute('pragma mmap_size = 268435456;');
  SQLExecute('pragma temp_store = memory;');
  // SQLExecute('pragma journal_mode = WAL;');


// Убираем ошибку вовремя удаления связанной записи
  SQLExecute('PRAGMA foreign_keys=OFF;');
// новые таблицы
  SQLExecute('CREATE TABLE "_user_new" (id INTEGER PRIMARY KEY ASC AUTOINCREMENT, "username" TEXT NOT NULL DEFAULT "empty", "password" TEXT, "id__role" INTEGER, "is_admin" INTEGER, "is_active" INTEGER, "email" TEXT, "first_name" TEXT, "last_name" TEXT, "last_login" TEXT, "date_joined" TEXT, "id_doljnost" INTEGER, "id_organization" INTEGER, "id_person" INTEGER, FOREIGN KEY(id__role) REFERENCES "_role"(id), FOREIGN KEY(id_doljnost) REFERENCES "doljnost"(id) ON DELETE SET NULL, FOREIGN KEY(id_organization) REFERENCES "organization"(id) ON DELETE SET NULL, FOREIGN KEY(id_person) REFERENCES "person"(id) ON DELETE SET NULL)');
// запись значений в новые таблицы
  SQLExecute('insert into _user_new select * from _user;');
// удаление старых таблиц
  SQLExecute('drop table _user;');
// переименование новых таблиц
  SQLExecute('alter table _user_new rename to _user;');

  SQLExecute('PRAGMA foreign_keys=ON;');

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
end;

procedure OptimizeDatabase;
begin
  try SQLExecute('VACUUM');
  except end;
  SQLExecute('pragma optimize;');
end;

procedure ClearDatabase;
begin
  if MessageDlg('ВСЕ данные будут УДАЛЕНЫ. Продолжить?', mtConfirmation, mbYes or mbNo, 0) = mrNo
  then Exit;

  SQLExecute('delete from tarifikaciya;');
  SQLExecute('delete from tar_nadbavka;');
  SQLExecute('delete from tar_job;');
  SQLExecute('delete from tar_job_doplata;');

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
  Tarifikation_PrepareTarTables;
end;

begin
  DbFilePath := GetDatabaseFilePath;
  DbDirectory := ExtractFileDir(DbFilePath);
  DbName := GetFileName(DbFilePath);

  if DbDirectory = '' then DbDirectory := ExtractFilePath(application.ExeName);

  ForceDirectories(DbDirectory+'backups\');
  BackupPath := DbDirectory+'backups\'+DbName;
end.
