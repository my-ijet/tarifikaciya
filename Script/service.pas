﻿uses
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
  tmpRow : TRow; tmpRowId, tmpIdList : String = '';
begin
  if not CheckSelectedAndConfirm(table) then Exit;

// Подготавливаем список ID
  for rowIndex:=0 to table.RowCount - 1 do begin
    tmpRow := table.Row[rowIndex];
    if tmpRow.Selected then begin
      tmpRowId := IntToStr(tmpRow.ID);
      tmpIdList := tmpIdList + ', ' +tmpRowId;
    end;
  end;
  Delete(tmpIdList, 1, 2);

  table.BeginUpdate;
  SQLExecute('delete from '+table.dbGeneralTable+' where id in ('+tmpIdList+');');
  table.EndUpdate;

  UpdateDatabase(table.dbGeneralTable);
end;

procedure RecordToArchiveFromTable(var table: TdbStringGridEx; archived: Integer);
var
  rowIndex, numRows : Integer = 0;
  tmpRow : TRow; tmpRowId, tmpIdList : String = '';
begin
// Считаем количество выделенных записей
  for rowIndex:=0 to table.RowCount - 1 do begin
    tmpRow := table.Row[rowIndex];
    if tmpRow.Selected then Inc(numRows);
  end;
  if numRows = 0 then begin
    MessageDlg('Не выбрана ни одна запись', mtInformation, mbOK, 0);
    Exit;
  end;

  for rowIndex:=0 to table.RowCount - 1 do begin
    tmpRow := table.Row[rowIndex];
    if tmpRow.Selected then begin
      tmpRowId := IntToStr(tmpRow.ID);
      tmpIdList := tmpIdList + ', ' +tmpRowId;
    end;
  end;
  Delete(tmpIdList, 1, 2);

  table.BeginUpdate;
  SQLExecute('update '+table.dbGeneralTable+' set archived = '+IntToStr(archived)+' where id in ('+tmpIdList+');');
  table.EndUpdate;

  UpdateDatabase(table.dbGeneralTable);
end;

procedure FillTarPeriod;
var
  SqlResult : string;
  DateStart, DateEnd : TDateTime;
begin
  SqlResult := SQLExecute('select date_tar_start from _user where id = '+ IntToStr(Application.User.id));
  if SqlResult = '' then begin end
  else DateStart := SQLDateTimeToDateTime(SqlResult);

  DateEnd := Now;
  SqlResult := SQLExecute('select date_tar_end from _user where id = '+ IntToStr(Application.User.id));
  if SqlResult = '' then begin end
  else DateEnd := SQLDateTimeToDateTime(SqlResult);

  Tarifikation.DateTarStart.DateTime := DateStart;
  Tarifikation.DateTarEnd.DateTime := DateEnd;
end;


// Период Тарификации
procedure Tarifikation_DateTarStart_OnChange (Sender: TObject);
var
  SelectedDate : String;
  StartDateTime, EndDateTime, CurrentDateTime : TDateTime;
  CurrentDateTimeChecked : Boolean;
begin
  SelectedDate := Tarifikation.DateTarStart.sqlDate;
  SQLExecute('update _user set date_tar_start = '+SelectedDate+' where id = '+IntToStr(Application.User.id));

  StartDateTime := Tarifikation.DateTarStart.DateTime;
  EndDateTime := Tarifikation.DateTarEnd.DateTime;
  CurrentDateTime := Tarifikation.DateFilterTarDate.DateTime;
  CurrentDateTimeChecked := Tarifikation.DateFilterTarDate.Checked;

  if StartDateTime > EndDateTime then begin
    Tarifikation.DateTarEnd.DateTime := StartDateTime;
    Tarifikation_DateTarEnd_OnChange(Sender);
  end;
  if StartDateTime > CurrentDateTime then begin
    Tarifikation.DateFilterTarDate.DateTime := StartDateTime;
  end;
  Tarifikation.DateFilterTarDate.Checked := CurrentDateTimeChecked;
end;

procedure Tarifikation_DateTarEnd_OnChange (Sender: TObject);
var
  SelectedDate : String;
  StartDateTime, EndDateTime, CurrentDateTime : TDateTime;
  CurrentDateTimeChecked : Boolean;
begin
  SelectedDate := Tarifikation.DateTarEnd.sqlDate;
  SQLExecute('update _user set date_tar_end = '+SelectedDate+' where id = '+IntToStr(Application.User.id));

  StartDateTime := Tarifikation.DateTarStart.DateTime;
  EndDateTime := Tarifikation.DateTarEnd.DateTime;
  CurrentDateTime := Tarifikation.DateFilterTarDate.DateTime;
  CurrentDateTimeChecked := Tarifikation.DateFilterTarDate.Checked;

  if EndDateTime < StartDateTime then begin
    Tarifikation.DateTarStart.DateTime := EndDateTime;
    Tarifikation_DateTarStart_OnChange(Sender);
  end;
  if EndDateTime < CurrentDateTime then begin
    Tarifikation.DateFilterTarDate.DateTime := EndDateTime;
  end;
  Tarifikation.DateFilterTarDate.Checked := CurrentDateTimeChecked;
end;
// Период Тарификации

// Утилиты
procedure Tarifikation_BtnImportFromFoxPro_OnClick (Sender: TObject; var Cancel: boolean);
begin
  OpenFile(DatabaseFilePath, 'import_from_foxpro.exe');
end;

procedure Tarifikation_BtnDelSpravochniky_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteSpravochniky;
end;

procedure Tarifikation_BtnDelTarifikations_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteTarifikations;
end;

procedure Tarifikation_BtnFindAndDeleteDublicates_OnClick (Sender: TObject; var Cancel: boolean);
begin
  FindAndDeleteDublicates;
end;

procedure Tarifikation_BtnOptimizeDatabase_OnClick (Sender: TObject; var Cancel: boolean);
begin
  OptimizeDatabase;
  DbStatisticsCalculate;
end;

procedure Tarifikation_BtnRefreshAllTables_OnClick (Sender: TObject; var Cancel: boolean);
begin
  UpdateAllTables;
  Tarifikation_PrepareTarTables;
end;
// Утилиты

// Форма перетарификации
procedure frmPeretarifikation_OnShow (Sender: TObject; Action: string);
begin
  frmPeretarifikation.TarDate.DateTime := Tarifikation.DateTarEnd.DateTime + 1;
end;

procedure frmPeretarifikation_BtnGo_OnClick (Sender: TObject; var Cancel: boolean);
var
  SelectedDate : String;
begin
  if frmPeretarifikation.TarDate.Checked then begin
    SelectedDate := frmPeretarifikation.TarDate.sqlDate;
    Peretarifikaciya(SelectedDate);

    SelectedDate := SQLExecute('select date('+SelectedDate+', "+1 year", "-1 day")');
    Tarifikation.DateTarStart.DateTime := frmPeretarifikation.TarDate.DateTime;
    Tarifikation.DateTarEnd.DateTime := SQLDateTimeToDateTime(SelectedDate);
    Tarifikation_DateTarStart_OnChange(Sender); Tarifikation_DateTarEnd_OnChange(Sender);
  end else begin
    Cancel := True;
    MessageDlg('Не выбрана дата тарификации', mtInformation, mbOK, 0);
  end;
end;
// Форма перетарификации

// Форма удаления записей тарификации
procedure frmDeleteTarBeforDate_OnShow (Sender: TObject; Action: string);
begin
  frmDeleteTarBeforDate.TarDate.DateTime := Tarifikation.DateTarStart.DateTime;
  frmDeleteTarBeforDate.TarDate.Checked := False;
end;

procedure frmDeleteTarBeforDate_BtnDelete_OnClick (Sender: TObject; var Cancel: boolean);
var
  SelectedDate : String;
begin
  if frmDeleteTarBeforDate.TarDate.Checked then begin
    SelectedDate := frmDeleteTarBeforDate.TarDate.sqlDate;
    DeleteTarifikationsBeforSelectedDate(SelectedDate);
  end else begin
    Cancel := True;
    MessageDlg('Не выбрана дата тарификации', mtInformation, mbOK, 0);
  end;
end;
// Форма удаления записей тарификации

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
