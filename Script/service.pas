var
  DatabaseFilePath : string;

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

procedure DeleteRecordFromTable(var table: TdbStringGridEx);
var
  rowIndex, numRows : Integer = 0;
  tmpRow : TRow;
begin
// Считаем количество выделенных записей
  for rowIndex:=0 to table.RowCount - 1 do begin
    tmpRow := table.Row[rowIndex];
    if tmpRow.Selected then begin
      Inc(numRows);
    end;
  end;

  if numRows = 0 then begin
    MessageDlg('Не выбрана ни одна запись для удаления', mtInformation, mbOK, 0);
    Exit;
  end;
  if MessageDlg('Удалить запись ('+IntToStr(numRows)+'шт.)?', mtConfirmation, mbYes or mbNo, 0) = mrNo
  then Exit;

  table.BeginUpdate;
  for rowIndex:=0 to table.RowCount - 1 do begin
    tmpRow := table.Row[rowIndex];
    if tmpRow.Selected then begin
      SQLExecute('delete from '+table.dbGeneralTable+' where id = '+IntToStr(tmpRow.ID));
    end;
  end;
  table.EndUpdate;

  table.dbUpdate;
end;

function GetDatabaseFilePath: string;
var
   ini: TIniFile;
begin
     ini := TiniFile.Create (Application.SettingsFile);
     result := ini.ReadString('Options', 'server', 'sqlite.db');
     ini.Free;
end;

procedure Tarifikation_BtnImportFromFoxPro_OnClick (Sender: TObject; var Cancel: boolean);
begin
  OpenFile( DatabaseFilePath+' "'+Application.ExeName+'"', 'import_from_foxpro.exe');
  Tarifikation.Close;
end;

procedure Tarifikation_BtnRemoveDatabase_OnClick (Sender: TObject; var Cancel: boolean);
begin
end;

begin
  DatabaseFilePath := GetDatabaseFilePath;
end.
