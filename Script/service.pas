uses
  'service_users.pas',
  'service_databases.pas',
  'spravochniky.pas',
  'otchety.pas',
  'tarifikation.pas';

var
  DatabaseFilePath : string;

procedure PrepareService;
begin
  FillTableDbBackup;
  DbStatisticsCalculate;
end;

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
  ClearDatabase;
end;

procedure Tarifikation_BtnOptimizeDatabase_OnClick (Sender: TObject; var Cancel: boolean);
begin
  OptimizeDatabase;
end;

procedure Tarifikation_BtnRefreshAllTables_OnClick (Sender: TObject; var Cancel: boolean);
begin
  UpdateAllTables;
  Tarifikation_PrepareTarTables;
  DbStatisticsCalculate;
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

// Бэкапы
procedure Tarifikation_BtnNewDbBackup_OnClick (Sender: TObject; var Cancel: boolean);
begin
  NewDbBackup;
  FillTableDbBackup;
end;

procedure Tarifikation_BtnRestoreDbBackup_OnClick (Sender: TObject; var Cancel: boolean);
var
  row: Integer;
  SelDbName: String;
begin
  row := Tarifikation.TableDbBackups.SelectedRow;
  if row = -1 then begin
    MessageDlg('Не выбрана запись резервной копии для восстановления', mtInformation, mbOK, 0);
    Exit;
  end;
  if MessageDlg('ВСЕ данные будут УДАЛЕНЫ (рекомендуется создать резервную копию). Продолжить?', mtConfirmation, mbYes or mbNo, 0) = mrNo
  then Exit;

  SelDbName := Tarifikation.TableDbBackups.Cells[0,row];

  RestoreDbBackup(SelDbName);
  RestartApplication;
end;

procedure Tarifikation_BtnDeleteDbBackup_OnClick (Sender: TObject; var Cancel: boolean);
var
  tmpRow : TRow;
  rowIndex : Integer;
  SelDbName: String;
begin
  if not CheckSelectedAndConfirm(Tarifikation.TableDbBackups) then Exit;

  for rowIndex:=0 to Tarifikation.TableDbBackups.RowCount - 1 do begin
    tmpRow := Tarifikation.TableDbBackups.Row[rowIndex];
    if tmpRow.Selected then begin
      SelDbName := Tarifikation.TableDbBackups.Cells[0, rowIndex];
      DeleteDbBackup(SelDbName);
    end;
  end;
  FillTableDbBackup;
end;
// Бэкапы


begin
  DatabaseFilePath := GetDatabaseFilePath;

  // MessageDlg('Сервис загружен!', mtInformation, mbOK, 0);
end.
