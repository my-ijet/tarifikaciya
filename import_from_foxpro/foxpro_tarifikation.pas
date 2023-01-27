unit foxpro_tarifikation;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, DB, Dbf, Forms,
  LConvEncoding, FileUtil, StrUtils, Variants;

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
procedure ImportTarJob;

implementation

uses
  main, sql_commands;

procedure ImportSpravochniky(DbfFilePath : String);
var
  i: Integer;
  DbfFileName: String;
begin
  DbfFileName := ExtractFileName(DbfFilePath);
  Form1.FoxProDbf.FilePath := ExtractFileDir(DbfFilePath);
  Form1.FoxProDbf.TableName := DbfFileName;
  Form1.FoxProDbf.Active := True;
  Form1.ProgressBar.Position := 0;
  Form1.ProgressBar.Max := Form1.FoxProDbf.PhysicalRecordCount;
  Form1.ProgressBar.Step := Round(Form1.ProgressBar.Max * 0.1)+1;

  // Преобразуем строки в UTF8
  for i := 0 to Form1.FoxProDbf.Fields.Count-1 do
    if Form1.FoxProDbf.Fields[i] is TStringField then
      TStringField(Form1.FoxProDbf.Fields[i]).Transliterate := true;

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
  Form1.FoxProDbf.Close;
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
  Form1.ProgressBar.Position := 0;
  Form1.ProgressBar.Max := Form1.FoxProDbf.PhysicalRecordCount;
  Form1.ProgressBar.Step := Round(Form1.ProgressBar.Max * 0.1)+1;

  // Преобразуем строки в UTF8
  for i := 0 to Form1.FoxProDbf.Fields.Count-1 do
    if Form1.FoxProDbf.Fields[i] is TStringField then
      TStringField(Form1.FoxProDbf.Fields[i]).Transliterate := true;

  DbfFileNameDelimited := SplitString(DbfFileName, '_'); TarTableType := '';
  if Length(DbfFileNameDelimited) > 0 then
    TarTableType := DbfFileNameDelimited[0];
  case TarTableType of
    'T1': ImportTarifikaciya;
    'T2': ImportTarJob;
  end;

  Form1.FoxProDbf.Active := False;
  Form1.FoxProDbf.Close;
end;


// Находит ID по указанному полю если данные уже содержатся в справочнике
function FindIdIfExist(tablename : String;
                       FieldName : String;
                       FieldValue : String) : Integer;
begin
  Form1.QSelect.SQL.Text := 'select id from '+tablename;
  Form1.QSelect.SQL.Append(' where "'+FieldName+'" = "'+FieldValue+'";');
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

function FindIdWithMigrationTable(tablename : String;
                                FOXPRO_KOD : String) : Integer; Inline;
begin
  Form1.QSelect.SQL.Text := 'select '+tablename+'.id from '+tablename+' ';
  Form1.QSelect.SQL.Append('left join migration_table on ');
  Form1.QSelect.SQL.Append('          '+tablename+'.id = migration_table.to_id ');
  Form1.QSelect.SQL.Append('      and migration_table.table_name = "'+tablename+'" ');
  Form1.QSelect.SQL.Append('where '+tablename+'.FOXPRO_KOD = "'+FOXPRO_KOD+'"');
  Form1.QSelect.SQL.Append('   or migration_table.FOXPRO_KOD = "'+FOXPRO_KOD+'" ');
  Form1.QSelect.SQL.Append('limit 1');
  Form1.QSelect.Open;
  Result := Form1.QSelect.FieldByName('id').AsInteger;
  Form1.QSelect.Close;
end;

function FindIdInTarifikaciya (FOXPRO_KU : String;
                               FOXPRO_TABN : String;
                               FOXPRO_DATA : String) : Integer;
var
  id_organization, id_person : Integer;
begin
  id_organization := FindIdWithMigrationTable('organization', FOXPRO_KU);
  if id_organization = 0 then Exit(-1);
  id_person := FindIdWithMigrationTable('person', FOXPRO_TABN);
  if id_person = 0 then Exit(-1);

  Form1.QSelect.SQL.Text := 'select tarifikaciya.id from tarifikaciya ';
  Form1.QSelect.SQL.Append('where tarifikaciya.id_organization = '+IntToStr(id_organization));
  Form1.QSelect.SQL.Append('  and tarifikaciya.id_person = '+IntToStr(id_person));
  Form1.QSelect.SQL.Append('  and date(tarifikaciya.date) = date("'+FOXPRO_DATA+'") ');
  Form1.QSelect.SQL.Append('limit 1 ;');
  Form1.QSelect.Open;
  Result := Form1.QSelect.FieldByName('id').AsInteger;
  Form1.QSelect.Close;
end;

function FindIdInTarJob(id_tarifikaciya : Integer;
                        FOXPRO_DOLJ : String;
                        FOXPRO_PREDM : String;
                        FOXPRO_RAZR : String;
                        FOXPRO_KAT : String                         ) : Integer;
var
  id_doljnost, id_predmet, id_kategory, id_stavka : Integer;
begin
  id_doljnost := FindIdWithMigrationTable('doljnost', FOXPRO_DOLJ);
  if id_doljnost = 0 then Exit(-1);
  id_predmet := FindIdWithMigrationTable('predmet', FOXPRO_PREDM);
  if id_predmet = 0 then Exit(-1);
  id_kategory := FindIdWithMigrationTable('kategory', FOXPRO_KAT);
  if id_kategory = 0 then Exit(-1);
  id_stavka := FindIdWithMigrationTable('stavka', FOXPRO_RAZR);
  if id_stavka = 0 then Exit(-1);

  Form1.QSelect.SQL.Text := 'select id from tar_job ';
  Form1.QSelect.SQL.Append('where id_tarifikaciya = '+IntToStr(id_tarifikaciya));
  Form1.QSelect.SQL.Append('  and id_doljnost = '+IntToStr(id_doljnost));
  Form1.QSelect.SQL.Append('  and id_predmet = '+IntToStr(id_predmet));
  Form1.QSelect.SQL.Append('  and id_kategory = '+IntToStr(id_kategory));
  Form1.QSelect.SQL.Append('  and id_stavka = '+IntToStr(id_stavka));
  Form1.QSelect.SQL.Append('limit 1 ;');
  Form1.QSelect.Open;
  Result := Form1.QSelect.FieldByName('id').AsInteger;
  Form1.QSelect.Close;
end;

function FindIdInTarNadbavka(id_tarifikaciya : Integer;
                             FOXPRO_NADB : String) : Integer;
var
  id_nadbavka : Integer;
begin
  id_nadbavka := FindIdWithMigrationTable('nadbavka', FOXPRO_NADB);
  if id_nadbavka = 0 then Exit(-1);

  Form1.QSelect.SQL.Text := 'select id from tar_nadbavka ';
  Form1.QSelect.SQL.Append('where id_tarifikaciya = '+IntToStr(id_tarifikaciya));
  Form1.QSelect.SQL.Append('  and id_nadbavka = '+IntToStr(id_nadbavka));
  Form1.QSelect.SQL.Append('limit 1 ;');
  Form1.QSelect.Open;
  Result := Form1.QSelect.FieldByName('id').AsInteger;
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
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;

      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      // Проверка на код уже содержащийся в справочнике и в таблице миграции
      founded_id := FindIdWithMigrationTable('organization', FOXPRO_KOD);
      if founded_id > 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на наименования уже содержащиеся в справочнике
      founded_id := FindIdIfExist('organization', 'short_name', FOXPRO_NAIM);
      if founded_id > 0 then begin
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
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;

      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      // Проверка на код уже содержащийся в справочнике и в таблице миграции
      founded_id := FindIdWithMigrationTable('org_group', FOXPRO_KOD);
      if founded_id > 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на наименования уже содержащиеся в справочнике
      founded_id := FindIdIfExist('org_group', 'name', FOXPRO_NAIM);
      if founded_id > 0 then begin
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
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;

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

      // Проверка на код уже содержащийся в справочнике и в таблице миграции
      founded_id := FindIdWithMigrationTable('person', FOXPRO_KOD);
      if founded_id > 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на ФИО уже содержащиеся в справочнике
      founded_id := FindIdByFIO(familyname, firstname, middlename);
      if founded_id > 0 then begin
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
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;

      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      // Проверка на код уже содержащийся в справочнике и в таблице миграции
      founded_id := FindIdWithMigrationTable('personal_group', FOXPRO_KOD);
      if founded_id > 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на наименования уже содержащиеся в справочнике
      founded_id := FindIdIfExist('personal_group', 'name', FOXPRO_NAIM);
      if founded_id > 0 then begin
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
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;

      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      // Проверка на код уже содержащийся в справочнике и в таблице миграции
      founded_id := FindIdWithMigrationTable('doljnost', FOXPRO_KOD);
      if founded_id > 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на наименования уже содержащиеся в справочнике
      founded_id := FindIdIfExist('doljnost', 'name', FOXPRO_NAIM);
      if founded_id > 0 then begin
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
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;

      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      // Проверка на код уже содержащийся в справочнике и в таблице миграции
      founded_id := FindIdWithMigrationTable('obrazovanie', FOXPRO_KOD);
      if founded_id > 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на наименования уже содержащиеся в справочнике
      founded_id := FindIdIfExist('obrazovanie', 'name', FOXPRO_NAIM);
      if founded_id > 0 then begin
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
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;

      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      // Проверка на код уже содержащийся в справочнике и в таблице миграции
      founded_id := FindIdWithMigrationTable('predmet', FOXPRO_KOD);
      if founded_id > 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на наименования уже содержащиеся в справочнике
      founded_id := FindIdIfExist('predmet', 'name', FOXPRO_NAIM);
      if founded_id > 0 then begin
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
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;

      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      // Проверка на код уже содержащийся в справочнике и в таблице миграции
      founded_id := FindIdWithMigrationTable('nadbavka', FOXPRO_KOD);
      if founded_id > 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на наименования уже содержащиеся в справочнике
      founded_id := FindIdIfExist('nadbavka', 'name', FOXPRO_NAIM);
      if founded_id > 0 then begin
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
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;

      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      // Проверка на код уже содержащийся в справочнике и в таблице миграции
      founded_id := FindIdWithMigrationTable('doplata', FOXPRO_KOD);
      if founded_id > 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на наименования уже содержащиеся в справочнике
      founded_id := FindIdIfExist('doplata', 'name', FOXPRO_NAIM);
      if founded_id > 0 then begin
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
  FOXPRO_KOD : String;
  founded_id : Integer;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into stavka';
    SQL.Append('(FOXPRO_KOD, summa)');
    SQL.Append('values (:FOXPRO_KOD, :summa)');

    while not Form1.FoxProDbf.EOF do begin
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;

      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('RAZR').AsString;

      // Проверка на код уже содержащийся в справочнике
      founded_id := FindIdIfExist('stavka', 'FOXPRO_KOD', FOXPRO_KOD);
      if founded_id > 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      ParamByName('FOXPRO_KOD').AsString := FOXPRO_KOD;
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
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;

      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      // Проверка на код уже содержащийся в справочнике и в таблице миграции
      founded_id := FindIdWithMigrationTable('kategory', FOXPRO_KOD);
      if founded_id > 0 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Проверка на наименования уже содержащиеся в справочнике
      founded_id := FindIdIfExist('kategory', 'name', FOXPRO_NAIM);
      if founded_id > 0 then begin
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
  FOXPRO_DATA, FOXPRO_DATAZN : TDateTime;
  isMain : Boolean = False;
  id_tarifikaciya : Integer;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into tarifikaciya ';
    SQL.Append('(FOXPRO_KU, FOXPRO_TABN, FOXPRO_OBR, ');
    SQL.Append(' diplom, staj_year, staj_month, date, main)');
    SQL.Append('values (:FOXPRO_KU, :FOXPRO_TABN, :FOXPRO_OBR, ');
    SQL.Append(' :diplom, :staj_year, :staj_month, :date, :main);');

    while not Form1.FoxProDbf.EOF do begin
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;

      FOXPRO_KU := Form1.FoxProDbf.FieldByName('KU').AsString;
      FOXPRO_TABN := Form1.FoxProDbf.FieldByName('TABN').AsString;
      FOXPRO_DATA := Form1.FoxProDbf.FieldByName('DATA').AsDateTime;
      date := FormatDateTime('YYYY-MM-DD HH:MM:SS.SS', FOXPRO_DATA);
      FOXPRO_DATAZN := Form1.FoxProDbf.FieldByName('DATAZN').AsDateTime;
      isMain := FOXPRO_DATA = FOXPRO_DATAZN;

      // Проверка по релевантным данным уже содержащимся в таблице тарификации
      id_tarifikaciya := FindIdInTarifikaciya(FOXPRO_KU, FOXPRO_TABN, date);
      if (id_tarifikaciya = -1) or (id_tarifikaciya > 0) then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      ParamByName('FOXPRO_KU').AsString := FOXPRO_KU;
      ParamByName('FOXPRO_TABN').AsString := FOXPRO_TABN;
      ParamByName('FOXPRO_OBR').AsString := Form1.FoxProDbf.FieldByName('OBR').AsString;
      ParamByName('diplom').AsString := Form1.FoxProDbf.FieldByName('NOMDIP').AsString;
      ParamByName('staj_year').AsInteger := Form1.FoxProDbf.FieldByName('STAGY').AsInteger;
      ParamByName('staj_month').AsInteger := Form1.FoxProDbf.FieldByName('STAGM').AsInteger;
      ParamByName('date').AsString := date;
      ParamByName('main').AsBoolean := isMain;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
  sql_commands.UpdateTarifikations;
end;

procedure ImportTarJob;
var
  FOXPRO_KU, FOXPRO_TABN, date : String; FOXPRO_DATA : TDateTime;
  FOXPRO_DOLJ, FOXPRO_PREDM : String;
  clock, FOXPRO_SUMCL : Double;
  FOXPRO_NADB : String;
  FOXPRO_DOPL : String; FOXPRO_PROC_D, FOXPRO_SUMD : Double;
  FOXPRO_RAZR : String; FOXPRO_KAT : String;
  stavka_coeff, FOXPRO_STIM : Double;

  id_tarifikaciya,
  id_tar_nadbavka,
  id_tar_job, id_tar_job_doplata : Integer;
begin
  Form1.ProgressBar.Max := Form1.FoxProDbf.PhysicalRecordCount * 2;
  Form1.ProgressBar.Step := Round(Form1.ProgressBar.Max * 0.05)+1;
  //Импорт Надбавок
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into tar_nadbavka ';
    SQL.Append('(id_tarifikaciya, FOXPRO_NADB)');
    SQL.Append('values (:id_tarifikaciya, :FOXPRO_NADB);');

    while not Form1.FoxProDbf.EOF do begin
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;

      FOXPRO_KU := Form1.FoxProDbf.FieldByName('KU').AsString;
      FOXPRO_TABN := Form1.FoxProDbf.FieldByName('TABN').AsString;
      FOXPRO_DATA := Form1.FoxProDbf.FieldByName('DATA').AsDateTime;
      date := FormatDateTime('YYYY-MM-DD HH:MM:SS.SS', FOXPRO_DATA);
      FOXPRO_NADB := Form1.FoxProDbf.FieldByName('NADB').AsString;

      // Находим ID тарификации по релевантным данным
      id_tarifikaciya := FindIdInTarifikaciya(FOXPRO_KU, FOXPRO_TABN, date);
      if id_tarifikaciya < 1 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Находим ID по релевантным данным в таблице тарификационных надбавок
      id_tar_nadbavka := FindIdInTarNadbavka(id_tarifikaciya, FOXPRO_NADB);
      if (id_tar_nadbavka = -1) or (id_tar_nadbavka > 0) then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      ParamByName('id_tarifikaciya').AsInteger := id_tarifikaciya;
      ParamByName('FOXPRO_NADB').AsString := FOXPRO_NADB;
      ExecSQL;
      sql_commands.UpdateTarNadbavky;
      Form1.FoxProDbf.Next;
    end;
  end;
  //Импорт Надбавок

  //Импорт Должностей тарификации
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into tar_job ';
    SQL.Append('(id_tarifikaciya,');
    SQL.Append(' FOXPRO_DOLJ, FOXPRO_PREDM, ');
    SQL.Append(' clock, FOXPRO_SUMCL,');
    SQL.Append(' FOXPRO_NADB,  FOXPRO_DOPL,');
    SQL.Append(' FOXPRO_KAT,');
    SQL.Append(' FOXPRO_RAZR, stavka_coeff,');
    SQL.Append(' FOXPRO_STIM) ');
    SQL.Append('values (:id_tarifikaciya, ');
    SQL.Append(' :FOXPRO_DOLJ, :FOXPRO_PREDM, ');
    SQL.Append(' :clock, :FOXPRO_SUMCL,');
    SQL.Append(' :FOXPRO_NADB, :FOXPRO_DOPL,');
    SQL.Append(' :FOXPRO_KAT,');
    SQL.Append(' :FOXPRO_RAZR, :stavka_coeff,');
    SQL.Append(' :FOXPRO_STIM);');

    Form1.FoxProDbf.First;
    while not Form1.FoxProDbf.EOF do begin
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;

      FOXPRO_KU := Form1.FoxProDbf.FieldByName('KU').AsString;
      FOXPRO_TABN := Form1.FoxProDbf.FieldByName('TABN').AsString;
      FOXPRO_DATA := Form1.FoxProDbf.FieldByName('DATA').AsDateTime;
      FOXPRO_DOLJ := Form1.FoxProDbf.FieldByName('DOLJ').AsString;
      FOXPRO_PREDM := Form1.FoxProDbf.FieldByName('PREDM').AsString;
      date := FormatDateTime('YYYY-MM-DD HH:MM:SS.SS', FOXPRO_DATA);
      clock := Form1.FoxProDbf.FieldByName('CLOCK').AsFloat;
      FOXPRO_SUMCL := Form1.FoxProDbf.FieldByName('SUMCL').AsFloat;
      FOXPRO_NADB := Form1.FoxProDbf.FieldByName('NADB').AsString;
      FOXPRO_DOPL := Form1.FoxProDbf.FieldByName('DOPL').AsString;
      FOXPRO_PROC_D := Form1.FoxProDbf.FieldByName('PROC_D').AsFloat;
      FOXPRO_SUMD := Form1.FoxProDbf.FieldByName('SUMD').AsFloat;
      FOXPRO_RAZR := Form1.FoxProDbf.FieldByName('RAZR').AsString;
      FOXPRO_KAT := Form1.FoxProDbf.FieldByName('KAT').AsString;
      stavka_coeff := Form1.FoxProDbf.FieldByName('STAVKA').AsFloat;
      FOXPRO_STIM := Form1.FoxProDbf.FieldByName('STIM').AsFloat;

      // Находим ID тарификации по релевантным данным
      id_tarifikaciya := FindIdInTarifikaciya(FOXPRO_KU, FOXPRO_TABN, date);
      if id_tarifikaciya < 1 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Находим ID Должности тарификации по релевантным данным
      id_tar_job := FindIdInTarJob(id_tarifikaciya,
                            FOXPRO_DOLJ, FOXPRO_PREDM,
                            FOXPRO_RAZR, FOXPRO_KAT);
      if (id_tar_job = -1) or (id_tar_job > 0) then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      ParamByName('id_tarifikaciya').AsInteger := id_tarifikaciya;
      ParamByName('FOXPRO_DOLJ').AsString := FOXPRO_DOLJ;
      ParamByName('FOXPRO_PREDM').AsString := FOXPRO_PREDM;
      ParamByName('clock').AsFloat := clock;
      ParamByName('FOXPRO_SUMCL').AsFloat := FOXPRO_SUMCL;
      ParamByName('FOXPRO_NADB').AsString := FOXPRO_NADB;
      ParamByName('FOXPRO_DOPL').AsString := FOXPRO_DOPL;
      ParamByName('FOXPRO_RAZR').AsString := FOXPRO_RAZR;
      ParamByName('FOXPRO_KAT').AsString := FOXPRO_KAT;
      ParamByName('stavka_coeff').AsFloat := stavka_coeff;
      ParamByName('FOXPRO_STIM').AsFloat := FOXPRO_STIM;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end; sql_commands.UpdateTarJobs;
  //Импорт Должностей тарификации

  //Импорт Доплат должностей тарификации
  //Импорт Доплат должностей тарификации

  //Импорт Стимулирующих доплат
  //Импорт Стимулирующих доплат
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
