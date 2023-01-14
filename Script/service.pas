uses
  'otchety.pas';

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
  tmpRow : TRow; tmpRowId : String;
  _userUpdateSQL: String = '';
  _userDataSet: TDataSet;
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

// Обработка спец случаев
  case table.dbGeneralTable of
    'organization': begin
        _userUpdateSQL := 'update _user set id_organization = NULL where id_organization = ';
        SQLQuery('select id_organization from _user where id_organization not NULL', _userDataSet);
      end;
    'person': begin
        _userUpdateSQL := 'update _user set id_person = NULL where id_person = ';
        SQLQuery('select id_person from _user where id_person not NULL', _userDataSet);
      end;
    'doljnost': begin
        _userUpdateSQL := 'update _user set id_doljnost = NULL where id_doljnost = ';
        SQLQuery('select id_doljnost from _user where id_doljnost not NULL', _userDataSet);
      end;
  end;
  table.BeginUpdate;
  While not _userDataSet.EOF do begin
    for rowIndex:=0 to table.RowCount - 1 do begin
      tmpRow := table.Row[rowIndex];
      if tmpRow.Selected then begin
        tmpRowId := IntToStr(tmpRow.ID);

        if _userDataSet.Fields[0].asString = tmpRowId then begin
          SQLExecute(_userUpdateSQL + tmpRowId);
          _userDataSet.Delete;

          FillRequisites;
          break;
        end;
      end;
    end;

    _userDataSet.Next;
  end;
  table.EndUpdate;
// Обработка спец случаев

  table.BeginUpdate;
  for rowIndex:=0 to table.RowCount - 1 do begin
    tmpRow := table.Row[rowIndex];
    if tmpRow.Selected then begin
      tmpRowId := IntToStr(tmpRow.ID);

      SQLExecute('delete from '+table.dbGeneralTable+' where id = '+tmpRowId);
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
