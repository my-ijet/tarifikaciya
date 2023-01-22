unit foxpro_tarifikation;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, DB, Dbf, LConvEncoding, FileUtil, StrUtils, Variants;

type
  TFoxProUtil = class
  private
  public
  function DbfTranslate(Dbf: TDbf; Src, Dest: PChar; ToOEM: Boolean): Integer;
  end;


procedure ImportSpravochniky(DbfFilePath : String);
procedure ImportTarifikations(DbfFilePath : String);
procedure ImportOrganizations;
procedure ImportOrgGroups;
procedure ImportPersons;
procedure ImportPersonalGroups;
procedure ImportObrazovanie;
procedure ImportDoljnost;
procedure ImportKategories;
procedure ImportPredmet;
procedure ImportStavka;
procedure ImportNadbavka;
procedure ImportDoplata;

procedure ImportTarifikaciya;

implementation

uses
  main;

procedure ImportSpravochniky(DbfFilePath : String);
var
  i: Integer;
  DbfFileName, TarTableType: String;
  DbfFileNameDelimited: TStringArray;
begin
  DbfFileName := ExtractFileName(DbfFilePath);
  Form1.FoxProDbf.FilePath := ExtractFileDir(DbfFilePath);
  Form1.FoxProDbf.TableName := DbfFileName;
  Form1.FoxProDbf.Active := True;

  // Преобразуем строки в UTF8
  for i := 0 to Form1.FoxProDbf.Fields.Count-1 do
    if Form1.FoxProDbf.Fields[i] is TStringField then
      TStringField(Form1.FoxProDbf.Fields[i]).Transliterate := true;
  Form1.Refresh;

  case DbfFileName of
  'SU.DBF': ImportOrganizations;
  'SPRPG.DBF': ImportOrgGroups;
  'SPRFIO.DBF': ImportPersons;
  'SPRGR.DBF': ImportPersonalGroups;
  'SPRDL.DBF': ImportDoljnost;
  'SPROBR.DBF': ImportObrazovanie;
  'SPRPREDM.DBF': ImportPredmet;
  'SPRN.DBF': ImportNadbavka;
  'SPRDP.DBF': ImportDoplata;
  'STAVKI.DBF': ImportStavka;
  'SPRKAT.DBF': ImportKategories;
  end;

  Form1.FoxProDbf.Active := False;
end;

procedure ImportTarifikations(DbfFilePath : String);
var
  i: Integer;
  DbfFileName, TarTableType: String;
  DbfFileNameDelimited: TStringArray;
begin
  DbfFileName := ExtractFileName(DbfFilePath);
  Form1.FoxProDbf.FilePath := ExtractFileDir(DbfFilePath);
  Form1.FoxProDbf.TableName := DbfFileName;
  Form1.FoxProDbf.Active := True;

  // Преобразуем строки в UTF8
  for i := 0 to Form1.FoxProDbf.Fields.Count-1 do
    if Form1.FoxProDbf.Fields[i] is TStringField then
      TStringField(Form1.FoxProDbf.Fields[i]).Transliterate := true;
  Form1.Refresh;

  DbfFileNameDelimited := SplitString(DbfFileName, '_');
  if Length(DbfFileNameDelimited) > 0 then
    TarTableType := DbfFileNameDelimited[0];
  case TarTableType of
    'T1': ImportTarifikaciya;
    'T2': ; // TODOT импорт доп тар таблицы
  end;

  Form1.FoxProDbf.Active := False;
end;


// Находит ID по указанному полю если данные уже содержатся в справочнике
function FindIdIfExist(tablename : String;
                       FieldName : String;
                       FieldValue : Variant) : Integer;
begin
  Form1.QSelect.SQL.Text := 'select id from '+tablename;
  Form1.QSelect.SQL.Append(' where "'+FieldName+'" = ');
  case varType(FieldValue) of
    varString: Form1.QSelect.SQL.Append('"'+FieldValue+'" ;');
    varInteger: Form1.QSelect.SQL.Append(IntToStr(FieldValue)+' ;');
  end;
  Form1.QSelect.Open;
  Result := Form1.QSelect.FieldByName('id').AsInteger;
  Form1.QSelect.Close;
end;

function FindIdByFIO(familyname: String;
                     firstname: String;
                     middlename: String) : Integer;
begin
  Form1.QSelect.SQL.Text := 'select id from person ';
  Form1.QSelect.SQL.Append('where familyname like "'+familyname+'"');
  Form1.QSelect.SQL.Append('  and firstname like "'+firstname+'"');
  Form1.QSelect.SQL.Append('  and middlename like "'+middlename+'"');
  Form1.QSelect.SQL.Append('limit 1 ;');
  Form1.QSelect.Open;
  Result := Form1.QSelect.FieldByName('id').AsInteger;
  Form1.QSelect.Close;
end;

function FindIdInMigrationTable(tablename : String;
                                FOXPRO_KOD : String) : Integer;
begin
  Form1.QSelect.SQL.Text := 'select to_id from migration_table ';
  Form1.QSelect.SQL.Append('where table_name = "'+tablename+'"');
  Form1.QSelect.SQL.Append('  and FOXPRO_KOD = "'+FOXPRO_KOD+'" ');
  Form1.QSelect.SQL.Append('limit 1 ;');
  Form1.QSelect.Open;
  Result := Form1.QSelect.FieldByName('to_id').AsInteger;
  Form1.QSelect.Close;
end;

procedure AddToMigrationTable(tablename : String;
                             FOXPRO_KOD : String;
                             ToId : Integer);
begin
  Form1.QSelect.SQL.Text := 'insert into migration_table ';
  Form1.QSelect.SQL.Append('(table_name, FOXPRO_KOD, to_id)');
  Form1.QSelect.SQL.Append('values ("'+tablename+'", "'+FOXPRO_KOD+'", '+IntToStr(ToId)+' );');
  Form1.QSelect.ExecSQL;
end;

procedure ImportOrganizations;
var
  FOXPRO_KOD, FOXPRO_NAIM : String;
  founded_id : Integer;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into organization';
    SQL.Append('(short_name, foxpro_kod, pg, gr)');
    SQL.Append('values (:short_name, :foxpro_kod, :pg, :gr)');

    while not Form1.FoxProDbf.EOF do begin
      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      // Проверка на код уже содержащийся в справочнике
      founded_id := FindIdIfExist('organization', 'FOXPRO_KOD', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на код уже содержащийся в таблице миграции
      founded_id := FindIdInMigrationTable('organization', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на наименования уже содержащиеся в справочнике
      founded_id := FindIdIfExist('organization', 'short_name', FOXPRO_NAIM);
      if founded_id <> 0 then begin
        AddToMigrationTable('organization', FOXPRO_KOD, founded_id);
        Form1.FoxProDbf.Next; Continue;
      end;

      ParamByName('foxpro_kod').AsString := FOXPRO_KOD;
      ParamByName('short_name').AsString := FOXPRO_NAIM;
      ParamByName('pg').AsString := Form1.FoxProDbf.FieldByName('PG').AsString;
      ParamByName('gr').AsInteger := Form1.FoxProDbf.FieldByName('GR').AsInteger;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportOrgGroups;
var
  FOXPRO_KOD, FOXPRO_NAIM : String;
  founded_id : Integer;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into org_group';
    SQL.Append('(name, foxpro_kod)');
    SQL.Append('values (:name, :foxpro_kod)');

    while not Form1.FoxProDbf.EOF do begin
      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      // Проверка на код уже содержащийся в справочнике
      founded_id := FindIdIfExist('org_group', 'FOXPRO_KOD', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на код уже содержащийся в таблице миграции
      founded_id := FindIdInMigrationTable('org_group', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на наименования уже содержащиеся в справочнике
      founded_id := FindIdIfExist('org_group', 'name', FOXPRO_NAIM);
      if founded_id <> 0 then begin
        AddToMigrationTable('org_group', FOXPRO_KOD, founded_id);
        Form1.FoxProDbf.Next; Continue;
      end;

      ParamByName('foxpro_kod').AsString := FOXPRO_KOD;
      ParamByName('name').AsString := FOXPRO_NAIM;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportPersons;
var
  FOXPRO_KOD : String;
  founded_id : Integer;
  tmpstr, familyname, firstname, middlename: String;
  splittedstr: array of String;
  i: Integer;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into person';
    SQL.Append('(familyname, firstname, middlename, foxpro_kod)');
    SQL.Append('values (:familyname, :firstname, :middlename, :foxpro_kod)');

    while not Form1.FoxProDbf.EOF do begin
      tmpstr := Trim(Form1.FoxProDbf.FieldByName('NAIM').AsString);
      while tmpstr.Contains('  ') do
        tmpstr := tmpstr.Replace('  ', ' ', [rfReplaceAll]);

      splittedstr := tmpstr.Split([' ']);
      familyname := ''; firstname := ''; middlename:= '';
      case Length(splittedstr) of
        0: begin end;
        1: familyname := splittedstr[0];
        2: begin
          familyname := splittedstr[0];
          firstname := splittedstr[1];
        end;
        3: begin
          familyname := splittedstr[0];
          firstname := splittedstr[1];
          middlename := splittedstr[2];
        end;
        else begin
          familyname := splittedstr[0];
          firstname := splittedstr[1];
          middlename += splittedstr[2];
          for i:=3 to Length(splittedstr)-1 do middlename += ' '+splittedstr[i];
        end;
      end;
      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;

      // Проверка на код уже содержащийся в справочнике
      founded_id := FindIdIfExist('person', 'FOXPRO_KOD', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на код уже содержащийся в таблице миграции
      founded_id := FindIdInMigrationTable('person', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на ФИО уже содержащиеся в справочнике
      founded_id := FindIdByFIO(familyname, firstname, middlename);
      if founded_id <> 0 then begin
        AddToMigrationTable('person', FOXPRO_KOD, founded_id);
        Form1.FoxProDbf.Next; Continue;
      end;

      ParamByName('foxpro_kod').AsString := FOXPRO_KOD;
      ParamByName('familyname').AsString := familyname;
      ParamByName('firstname').AsString := firstname;
      ParamByName('middlename').AsString := middlename;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportPersonalGroups;
var
  FOXPRO_KOD, FOXPRO_NAIM : String;
  founded_id : Integer;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into personal_group';
    SQL.Append('(name, foxpro_kod)');
    SQL.Append('values (:name, :foxpro_kod)');

    while not Form1.FoxProDbf.EOF do begin
      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      // Проверка на код уже содержащийся в справочнике
      founded_id := FindIdIfExist('personal_group', 'FOXPRO_KOD', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на код уже содержащийся в таблице миграции
      founded_id := FindIdInMigrationTable('personal_group', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на наименования уже содержащиеся в справочнике
      founded_id := FindIdIfExist('personal_group', 'name', FOXPRO_NAIM);
      if founded_id <> 0 then begin
        AddToMigrationTable('personal_group', FOXPRO_KOD, founded_id);
        Form1.FoxProDbf.Next; Continue;
      end;

      ParamByName('foxpro_kod').AsString := FOXPRO_KOD;
      ParamByName('name').AsString := FOXPRO_NAIM;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportDoljnost;
var
  FOXPRO_KOD, FOXPRO_NAIM : String;
  founded_id : Integer;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into doljnost';
    SQL.Append('(name, kolvo, foxpro_kod, por, pk, gopl)');
    SQL.Append('values (:name, :kolvo, :foxpro_kod, :por, :pk, :gopl)');

    while not Form1.FoxProDbf.EOF do begin
      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      // Проверка на код уже содержащийся в справочнике
      founded_id := FindIdIfExist('doljnost', 'FOXPRO_KOD', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на код уже содержащийся в таблице миграции
      founded_id := FindIdInMigrationTable('doljnost', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на наименования уже содержащиеся в справочнике
      founded_id := FindIdIfExist('doljnost', 'name', FOXPRO_NAIM);
      if founded_id <> 0 then begin
        AddToMigrationTable('doljnost', FOXPRO_KOD, founded_id);
        Form1.FoxProDbf.Next; Continue;
      end;

      ParamByName('foxpro_kod').AsString := FOXPRO_KOD;
      ParamByName('name').AsString := FOXPRO_NAIM;
      ParamByName('kolvo').AsInteger := Form1.FoxProDbf.FieldByName('KOLVO').AsInteger;
      ParamByName('por').AsInteger := Form1.FoxProDbf.FieldByName('POR').AsInteger;
      ParamByName('pk').AsInteger := Form1.FoxProDbf.FieldByName('PK').AsInteger;
      ParamByName('gopl').AsInteger := Form1.FoxProDbf.FieldByName('GOPL').AsInteger;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportObrazovanie;
var
  FOXPRO_KOD, FOXPRO_NAIM : String;
  founded_id : Integer;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into obrazovanie';
    SQL.Append('(name, foxpro_kod)');
    SQL.Append('values (:name, :foxpro_kod)');

    while not Form1.FoxProDbf.EOF do begin
      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      // Проверка на код уже содержащийся в справочнике
      founded_id := FindIdIfExist('obrazovanie', 'FOXPRO_KOD', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на код уже содержащийся в таблице миграции
      founded_id := FindIdInMigrationTable('obrazovanie', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на наименования уже содержащиеся в справочнике
      founded_id := FindIdIfExist('obrazovanie', 'name', FOXPRO_NAIM);
      if founded_id <> 0 then begin
        AddToMigrationTable('obrazovanie', FOXPRO_KOD, founded_id);
        Form1.FoxProDbf.Next; Continue;
      end;

      ParamByName('foxpro_kod').AsString := FOXPRO_KOD;
      ParamByName('name').AsString := FOXPRO_NAIM;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportPredmet;
var
  FOXPRO_KOD, FOXPRO_NAIM : String;
  founded_id : Integer;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into predmet';
    SQL.Append('(name, clock, foxpro_kod)');
    SQL.Append('values (:name, :clock, :foxpro_kod)');

    while not Form1.FoxProDbf.EOF do begin
      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      // Проверка на код уже содержащийся в справочнике
      founded_id := FindIdIfExist('predmet', 'FOXPRO_KOD', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на код уже содержащийся в таблице миграции
      founded_id := FindIdInMigrationTable('predmet', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на наименования уже содержащиеся в справочнике
      founded_id := FindIdIfExist('predmet', 'name', FOXPRO_NAIM);
      if founded_id <> 0 then begin
        AddToMigrationTable('predmet', FOXPRO_KOD, founded_id);
        Form1.FoxProDbf.Next; Continue;
      end;

      ParamByName('foxpro_kod').AsString := FOXPRO_KOD;
      ParamByName('name').AsString := FOXPRO_NAIM;
      ParamByName('clock').AsInteger := Form1.FoxProDbf.FieldByName('CLOCK').AsInteger;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportNadbavka;
var
  FOXPRO_KOD, FOXPRO_NAIM : String;
  founded_id : Integer;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into nadbavka';
    SQL.Append('(name, percent, foxpro_kod, por, pr)');
    SQL.Append('values (:name, :percent, :foxpro_kod, :por, :pr)');

    while not Form1.FoxProDbf.EOF do begin
      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      // Проверка на код уже содержащийся в справочнике
      founded_id := FindIdIfExist('nadbavka', 'FOXPRO_KOD', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на код уже содержащийся в таблице миграции
      founded_id := FindIdInMigrationTable('nadbavka', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на наименования уже содержащиеся в справочнике
      founded_id := FindIdIfExist('nadbavka', 'name', FOXPRO_NAIM);
      if founded_id <> 0 then begin
        AddToMigrationTable('nadbavka', FOXPRO_KOD, founded_id);
        Form1.FoxProDbf.Next; Continue;
      end;

      ParamByName('foxpro_kod').AsString := FOXPRO_KOD;
      ParamByName('name').AsString := FOXPRO_NAIM;
      ParamByName('percent').AsFloat := Form1.FoxProDbf.FieldByName('PROC').AsFloat;
      ParamByName('por').AsInteger := Form1.FoxProDbf.FieldByName('POR').AsInteger;
      ParamByName('pr').AsString := Form1.FoxProDbf.FieldByName('PR').AsString;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportDoplata;
var
  FOXPRO_KOD, FOXPRO_NAIM : String;
  founded_id : Integer;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into doplata';
    SQL.Append('(name, foxpro_kod, por, pk, pr)');
    SQL.Append('values (:name, :foxpro_kod, :por, :pk, :pr)');

    while not Form1.FoxProDbf.EOF do begin
      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      // Проверка на код уже содержащийся в справочнике
      founded_id := FindIdIfExist('doplata', 'FOXPRO_KOD', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на код уже содержащийся в таблице миграции
      founded_id := FindIdInMigrationTable('doplata', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на наименования уже содержащиеся в справочнике
      founded_id := FindIdIfExist('doplata', 'name', FOXPRO_NAIM);
      if founded_id <> 0 then begin
        AddToMigrationTable('doplata', FOXPRO_KOD, founded_id);
        Form1.FoxProDbf.Next; Continue;
      end;

      ParamByName('foxpro_kod').AsString := FOXPRO_KOD;
      ParamByName('name').AsString := FOXPRO_NAIM;
      ParamByName('por').AsInteger := Form1.FoxProDbf.FieldByName('POR').AsInteger;
      ParamByName('pk').AsInteger := Form1.FoxProDbf.FieldByName('PK').AsInteger;
      ParamByName('pr').AsString := Form1.FoxProDbf.FieldByName('PR').AsString;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportStavka;
var
  FOXPRO_RAZR : Integer;
  founded_id : Integer;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into stavka';
    SQL.Append('(razr, summa)');
    SQL.Append('values (:razr, :summa)');

    while not Form1.FoxProDbf.EOF do begin
      FOXPRO_RAZR := Form1.FoxProDbf.FieldByName('RAZR').AsInteger;

      // Проверка на код уже содержащийся в справочнике
      founded_id := FindIdIfExist('stavka', 'razr', FOXPRO_RAZR);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      ParamByName('razr').AsInteger := FOXPRO_RAZR;
      ParamByName('summa').AsCurrency := Form1.FoxProDbf.FieldByName('SUMST').AsCurrency;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportKategories;
var
  FOXPRO_KOD, FOXPRO_NAIM : String;
  founded_id : Integer;
begin
  with Form1.QInsertFromFoxPro do  begin
    SQL.Text := 'insert into kategory';
    SQL.Append('(name, foxpro_kod)');
    SQL.Append('values (:name, :foxpro_kod)');

    while not Form1.FoxProDbf.EOF do begin
      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      // Проверка на код уже содержащийся в справочнике
      founded_id := FindIdIfExist('kategory', 'FOXPRO_KOD', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на код уже содержащийся в таблице миграции
      founded_id := FindIdInMigrationTable('kategory', FOXPRO_KOD);
      if founded_id <> 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на наименования уже содержащиеся в справочнике
      founded_id := FindIdIfExist('kategory', 'name', FOXPRO_NAIM);
      if founded_id <> 0 then begin
        AddToMigrationTable('kategory', FOXPRO_KOD, founded_id);
        Form1.FoxProDbf.Next; Continue;
      end;

      ParamByName('foxpro_kod').AsString := FOXPRO_KOD;
      ParamByName('name').AsString := FOXPRO_NAIM;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;


procedure ImportTarifikaciya;
var
  FOXPRO_KU, FOXPRO_TABN, date : String;
  founded : Boolean;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into tarifikaciya ';
    SQL.Append('(FOXPRO_KU, FOXPRO_TABN, FOXPRO_OBR, diplom, staj_year, staj_month, date)');
    SQL.Append('values (:FOXPRO_KU, :FOXPRO_TABN, :FOXPRO_OBR, :diplom, :staj_year, :staj_month, :date);');

    while not Form1.FoxProDbf.EOF do begin
      FOXPRO_KU := Form1.FoxProDbf.FieldByName('KU').AsString;
      FOXPRO_TABN := Form1.FoxProDbf.FieldByName('TABN').AsString;
      date := FormatDateTime('YYYY-MM-DD HH:MM:SS.SSS',
                             Form1.FoxProDbf.FieldByName('DATA').AsDateTime);

      ParamByName('FOXPRO_KU').AsString := FOXPRO_KU;
      ParamByName('FOXPRO_TABN').AsString := FOXPRO_TABN;
      ParamByName('FOXPRO_OBR').AsString := Form1.FoxProDbf.FieldByName('OBR').AsString;
      ParamByName('diplom').AsString := Form1.FoxProDbf.FieldByName('NOMDIP').AsString;
      ParamByName('staj_year').AsInteger := Form1.FoxProDbf.FieldByName('STAGY').AsInteger;
      ParamByName('staj_month').AsInteger := Form1.FoxProDbf.FieldByName('STAGM').AsInteger;
      ParamByName('date').AsString := date;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;


function TFoxProUtil.DbfTranslate(Dbf: TDbf; Src, Dest: PChar; ToOEM: Boolean): Integer;
var
  s: String;
  cp: String;
begin
  cp := 'cp866';
  if ToOEM then
    s := ConvertEncoding(Src, 'utf8', cp)
  else
    s := ConvertEncoding(Src, cp, 'utf8');
  StrCopy(Dest, PChar(s));
  Result := StrLen(Dest);
end;

end.
