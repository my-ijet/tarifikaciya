uses
  'users.pas',
  'spravochniky.pas',
  'otchety.pas',
  'tarifikation.pas';

var
  DatabaseFilePath : string;

procedure RestartApplication;
begin
  OpenFile('"'+Application.ExeName+'"');
  Tarifikation.Close;
end;

function GetSettingsFilePath: string;
var
  R: TRegistry;
  tmpSettingsInAppData: boolean;
  tmpSettingsDir: string;
  tmpExeName: string;
begin
  tmpExeName := ExtractFileName(Application.ExeName);
  R := TRegistry.Create;
  R.RootKey := HKEY_CURRENT_USER;
  R.Access := KEY_READ;
  if R.OpenKey('Software\MyVisualDatabaseConfigs\'+tmpExeName,False) and (R.ReadInteger('SettingsInAppData') = 1) then
    tmpSettingsDir := GetEnvironmentVariable('APPDATA')+'\MyVisualDatabase\Configs\'+tmpExeName+'\'
  else
    tmpSettingsDir := ExtractFilePath(Application.ExeName);
  R.CloseKey;
  R.Free;

  result := tmpSettingsDir + 'settings.ini';
end;

function GetDatabaseFilePath: string;
var
  ini: TIniFile;
begin
  ini := TiniFile.Create(Application.SettingsFile);
  result := ini.ReadString('Options', 'server', 'sqlite.db');
  ini.Free;
end;

procedure ApplyFixesOnNewDatabase;
begin
// Дополнительная настройка БД
  SQLExecute('pragma mmap_size = 268435456;');
  SQLExecute('pragma temp_store = memory;');
  SQLExecute('pragma journal_mode = WAL;');


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
  SQLExecute('VACUUM');
  SQLExecute('pragma optimize;');
end;

function CheckSelectedAndConfirm(var table: TdbStringGridEx) : Boolean;
var
  rowIndex, numRows : Integer = 0;
  tmpRow : TRow;
begin
// Считаем количество выделенных записей
  for rowIndex:=0 to table.RowCount - 1 do begin
    tmpRow := table.Row[rowIndex];
    if tmpRow.Selected then Inc(numRows);
  end;

  if numRows = 0 then begin
    MessageDlg('Не выбрана ни одна запись для удаления', mtInformation, mbOK, 0);
    Result := False;
    Exit;
  end;
  if MessageDlg('Удалить запись ('+IntToStr(numRows)+'шт.)?', mtConfirmation, mbYes or mbNo, 0) = mrNo
  then begin Result := False; Exit; end;

  Result := True;
end;

procedure DeleteRecordFromTable(var table: TdbStringGridEx);
var
  rowIndex : Integer;
  tmpRow : TRow; tmpRowId : String;
begin
  if not CheckSelectedAndConfirm(table) then Exit;

  table.BeginUpdate;
  for rowIndex:=0 to table.RowCount - 1 do begin
    tmpRow := table.Row[rowIndex];
    if tmpRow.Selected then begin
      tmpRowId := IntToStr(tmpRow.ID);

      SQLExecute('delete from '+table.dbGeneralTable+' where id = '+tmpRowId);
    end;
  end;
  table.EndUpdate;

  UpdateDatabase(table.dbGeneralTable);
end;

// Утилиты
procedure Tarifikation_BtnImportFromFoxPro_OnClick (Sender: TObject; var Cancel: boolean);
begin
  OpenFile(DatabaseFilePath, 'import_from_foxpro.exe');
end;

procedure Tarifikation_BtnCleanDatabase_OnClick (Sender: TObject; var Cancel: boolean);
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
end;

procedure Tarifikation_BtnOptimizeDatabase_OnClick (Sender: TObject; var Cancel: boolean);
begin
  OptimizeDatabase;
end;

procedure Tarifikation_BtnRefreshAllTables_OnClick (Sender: TObject; var Cancel: boolean);
begin
  UpdateAllTables;
end;
// Утилиты

// Пользователи
procedure Tarifikation_BtnDeleteUser_OnClick (Sender: TObject; var Cancel: boolean);
var
  ShouldLogin : Boolean = False;
  tmpRow : TRow;
  rowIndex : Integer;
  DeleteSQL : String;
begin
  for rowIndex:=0 to Tarifikation.TableUsers.RowCount - 1 do begin
    tmpRow := Tarifikation.TableUsers.Row[rowIndex];
    if tmpRow.Selected and (tmpRow.ID = Application.User.Id) then
      ShouldLogin := True;
  end;

  DeleteRecordFromTable(Tarifikation.TableUsers);

  if ShouldLogin then begin
    Application.User.Id := -1;
    UserLogin(False);
  end;
end;

// Пользователи


begin
  DatabaseFilePath := GetDatabaseFilePath;

  // MessageDlg('Сервис загружен!', mtInformation, mbOK, 0);
end.
