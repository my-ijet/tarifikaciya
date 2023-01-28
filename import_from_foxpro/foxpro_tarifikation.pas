unit foxpro_tarifikation;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, DB, Dbf, Forms,
  Math, LConvEncoding, FileUtil, StrUtils, Variants;

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

procedure ImportFoxProT1;
procedure ImportFoxProT2;

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
    'T1': ImportFoxProT1;
    'T2': ImportFoxProT2;
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
                        FOXPRO_KAT : String;
                        stavka_coeff : Double) : Integer;
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
  Form1.QSelect.SQL.Append('  and printf("%.2f", stavka_coeff) = ');
  Form1.QSelect.SQL.Append('  printf("%.2f", cast("'+FormatFloat('0.00', stavka_coeff)+'" as real))');
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

function FindIdInTarJobDoplata(id_tar_job : Integer;
                               FOXPRO_DOPL : String) : Integer;
var
  id_doplata : Integer;
begin
  id_doplata := FindIdWithMigrationTable('doplata', FOXPRO_DOPL);
  if id_doplata = 0 then Exit(-1);

  Form1.QSelect.SQL.Text := 'select id from tar_job_doplata ';
  Form1.QSelect.SQL.Append('where id_tar_job = '+IntToStr(id_tar_job));
  Form1.QSelect.SQL.Append('  and id_doplata = '+IntToStr(id_doplata));
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

      ParamByName('foxpro_kod').AsString := FOXPRO_KOD;
      ParamByName('name').AsString := FOXPRO_NAIM;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;


procedure ImportFoxProT1;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into T1 ';
    SQL.Append('(FOXPRO_KU, FOXPRO_TABN, FOXPRO_OBR, ');
    SQL.Append(' FOXPRO_NOMDIP, FOXPRO_STAGY, FOXPRO_STAGM, ');
    SQL.Append(' FOXPRO_DATA, FOXPRO_DATAZN )');
    SQL.Append('values (:FOXPRO_KU, :FOXPRO_TABN, :FOXPRO_OBR, ');
    SQL.Append(' :FOXPRO_NOMDIP, :FOXPRO_STAGY, :FOXPRO_STAGM, ');
    SQL.Append(' :FOXPRO_DATA, :FOXPRO_DATAZN );');

    while not Form1.FoxProDbf.EOF do begin
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;
      ParamByName('FOXPRO_KU').AsString := Form1.FoxProDbf.FieldByName('KU').AsString;
      ParamByName('FOXPRO_TABN').AsString := Form1.FoxProDbf.FieldByName('TABN').AsString;
      ParamByName('FOXPRO_OBR').AsString := Form1.FoxProDbf.FieldByName('OBR').AsString;
      ParamByName('FOXPRO_NOMDIP').AsString := Form1.FoxProDbf.FieldByName('NOMDIP').AsString;
      ParamByName('FOXPRO_STAGY').AsInteger := Form1.FoxProDbf.FieldByName('STAGY').AsInteger;
      ParamByName('FOXPRO_STAGM').AsInteger := Form1.FoxProDbf.FieldByName('STAGM').AsInteger;
      ParamByName('FOXPRO_DATA').AsDateTime := Form1.FoxProDbf.FieldByName('DATA').AsDateTime;
      ParamByName('FOXPRO_DATAZN').AsDateTime := Form1.FoxProDbf.FieldByName('DATAZN').AsDateTime;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportFoxProT2;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into T2 ';
    SQL.Append('(FOXPRO_KU, FOXPRO_TABN, FOXPRO_DOLJ, ');
    SQL.Append('FOXPRO_PREDM, FOXPRO_CLOCK, FOXPRO_SUMCL, ');
    SQL.Append('FOXPRO_NADB, FOXPRO_DOPL, ');
    SQL.Append('FOXPRO_PROC_D, FOXPRO_SUMD, ');
    SQL.Append('FOXPRO_RAZR, FOXPRO_KAT, ');
    SQL.Append('FOXPRO_STAVKA, FOXPRO_STIM, ');
    SQL.Append('FOXPRO_DATA )');
    SQL.Append('values');
    SQL.Append('(:FOXPRO_KU, :FOXPRO_TABN, :FOXPRO_DOLJ, ');
    SQL.Append(':FOXPRO_PREDM, :FOXPRO_CLOCK, :FOXPRO_SUMCL, ');
    SQL.Append(':FOXPRO_NADB, :FOXPRO_DOPL, ');
    SQL.Append(':FOXPRO_PROC_D, :FOXPRO_SUMD, ');
    SQL.Append(':FOXPRO_RAZR, :FOXPRO_KAT, ');
    SQL.Append(':FOXPRO_STAVKA, :FOXPRO_STIM, ');
    SQL.Append(':FOXPRO_DATA );');

    while not Form1.FoxProDbf.EOF do begin
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;
      ParamByName('FOXPRO_KU').AsString := Form1.FoxProDbf.FieldByName('KU').AsString;
      ParamByName('FOXPRO_TABN').AsString := Form1.FoxProDbf.FieldByName('TABN').AsString;
      ParamByName('FOXPRO_DOLJ').AsString := Form1.FoxProDbf.FieldByName('DOLJ').AsString;
      ParamByName('FOXPRO_PREDM').AsString := Form1.FoxProDbf.FieldByName('PREDM').AsString;
      ParamByName('FOXPRO_CLOCK').AsFloat := Form1.FoxProDbf.FieldByName('CLOCK').AsFloat;
      ParamByName('FOXPRO_SUMCL').AsFloat := Form1.FoxProDbf.FieldByName('SUMCL').AsFloat;
      ParamByName('FOXPRO_NADB').AsString := Form1.FoxProDbf.FieldByName('NADB').AsString;
      ParamByName('FOXPRO_DOPL').AsString := Form1.FoxProDbf.FieldByName('DOPL').AsString;
      ParamByName('FOXPRO_PROC_D').AsFloat := Form1.FoxProDbf.FieldByName('PROC_D').AsFloat;
      ParamByName('FOXPRO_SUMD').AsFloat := Form1.FoxProDbf.FieldByName('SUMD').AsFloat;
      ParamByName('FOXPRO_RAZR').AsString := Form1.FoxProDbf.FieldByName('RAZR').AsString;
      ParamByName('FOXPRO_KAT').AsString := Form1.FoxProDbf.FieldByName('KAT').AsString;
      ParamByName('FOXPRO_STAVKA').AsFloat := Form1.FoxProDbf.FieldByName('STAVKA').AsFloat;
      ParamByName('FOXPRO_STIM').AsFloat := Form1.FoxProDbf.FieldByName('STIM').AsFloat;
      ParamByName('FOXPRO_DATA').AsDateTime := Form1.FoxProDbf.FieldByName('DATA').AsDateTime;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;


procedure OldImport;
var
  FOXPRO_KU, FOXPRO_TABN, date : String; FOXPRO_DATA : TDateTime;
  FOXPRO_DOLJ, FOXPRO_PREDM : String;
  clock, FOXPRO_SUMCL : Double;
  FOXPRO_NADB : String;
  FOXPRO_DOPL : String; FOXPRO_PROC_D, FOXPRO_SUMD : Double;
  FOXPRO_RAZR : String; FOXPRO_KAT : String;
  stavka_coeff, FOXPRO_STIM : Double;

  id_tarifikaciya,
  id_tar_job, id_tar_job_doplata : Integer;
begin
  Form1.ProgressBar.Max := Form1.FoxProDbf.PhysicalRecordCount * 3;
  Form1.ProgressBar.Step := Round(Form1.ProgressBar.Max * 0.025)+1;

  //Импорт Должностей тарификации
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into tar_job ';
    SQL.Append('(id_tarifikaciya,');
    SQL.Append(' FOXPRO_DOLJ, FOXPRO_PREDM, ');
    SQL.Append(' clock, FOXPRO_SUMCL,');
    SQL.Append(' FOXPRO_KAT,');
    SQL.Append(' FOXPRO_RAZR, stavka_coeff,');
    SQL.Append(' FOXPRO_STIM) ');
    SQL.Append('values (:id_tarifikaciya, ');
    SQL.Append(' :FOXPRO_DOLJ, :FOXPRO_PREDM, ');
    SQL.Append(' :clock, :FOXPRO_SUMCL,');
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
                            FOXPRO_RAZR, FOXPRO_KAT, stavka_coeff);
      if (id_tar_job = -1) or (id_tar_job > 0) then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      ParamByName('id_tarifikaciya').AsInteger := id_tarifikaciya;
      ParamByName('FOXPRO_DOLJ').AsString := FOXPRO_DOLJ;
      ParamByName('FOXPRO_PREDM').AsString := FOXPRO_PREDM;
      ParamByName('clock').AsFloat := clock;
      ParamByName('FOXPRO_SUMCL').AsFloat := FOXPRO_SUMCL;
      ParamByName('FOXPRO_RAZR').AsString := FOXPRO_RAZR;
      ParamByName('FOXPRO_KAT').AsString := FOXPRO_KAT;
      ParamByName('stavka_coeff').AsFloat := stavka_coeff;
      ParamByName('FOXPRO_STIM').AsFloat := FOXPRO_STIM;
      ExecSQL;

      Form1.FoxProDbf.Next;
      sql_commands.UpdateTarJobs;
    end;
  end;
  //Импорт Должностей тарификации

  //Импорт Доплат должностей тарификации
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into tar_job_doplata ';
    SQL.Append('(id_tar_job,');
    SQL.Append(' FOXPRO_DOPL, ');
    SQL.Append(' dop_percent, dop_summa) ');
    SQL.Append('values (:id_tar_job, ');
    SQL.Append(' :FOXPRO_DOPL, ');
    SQL.Append(' :dop_percent, :dop_summa);');

    Form1.FoxProDbf.First;
    while not Form1.FoxProDbf.EOF do begin
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;

      FOXPRO_KU := Form1.FoxProDbf.FieldByName('KU').AsString;
      FOXPRO_TABN := Form1.FoxProDbf.FieldByName('TABN').AsString;
      FOXPRO_DATA := Form1.FoxProDbf.FieldByName('DATA').AsDateTime;
      date := FormatDateTime('YYYY-MM-DD HH:MM:SS.SS', FOXPRO_DATA);
      FOXPRO_DOLJ := Form1.FoxProDbf.FieldByName('DOLJ').AsString;
      FOXPRO_PREDM := Form1.FoxProDbf.FieldByName('PREDM').AsString;
      FOXPRO_RAZR := Form1.FoxProDbf.FieldByName('RAZR').AsString;
      FOXPRO_KAT := Form1.FoxProDbf.FieldByName('KAT').AsString;
      stavka_coeff := Form1.FoxProDbf.FieldByName('STAVKA').AsFloat;

      FOXPRO_DOPL := Form1.FoxProDbf.FieldByName('DOPL').AsString;
      FOXPRO_PROC_D := Form1.FoxProDbf.FieldByName('PROC_D').AsFloat;
      FOXPRO_SUMD := Form1.FoxProDbf.FieldByName('SUMD').AsFloat;
      FOXPRO_STIM := Form1.FoxProDbf.FieldByName('STIM').AsFloat;

      // Находим ID тарификации по релевантным данным
      id_tarifikaciya := FindIdInTarifikaciya(FOXPRO_KU, FOXPRO_TABN, date);
      if id_tarifikaciya < 1 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Находим ID Должности тарификации по релевантным данным
      id_tar_job := FindIdInTarJob(id_tarifikaciya,
                            FOXPRO_DOLJ, FOXPRO_PREDM,
                            FOXPRO_RAZR, FOXPRO_KAT, stavka_coeff);
      if id_tar_job < 1 then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      // Находим ID Доплаты для должности тарификации по релевантным данным
      id_tar_job_doplata := FindIdInTarJobDoplata(id_tar_job, FOXPRO_DOPL);
      if (id_tar_job_doplata = -1) or (id_tar_job_doplata > 0) then begin
        Form1.FoxProDbf.Next; Continue;
      end;

      if (CompareValue(FOXPRO_PROC_D, 0) = 1) then
        FOXPRO_SUMD := 0;
      if (CompareValue(FOXPRO_STIM, 0) = 1) then
        FOXPRO_SUMD := FOXPRO_SUMD + FOXPRO_STIM;
      if (CompareValue(FOXPRO_PROC_D, 0) = 1) or (CompareValue(FOXPRO_SUMD, 0) = 1)
      then begin

        ParamByName('id_tar_job').AsInteger := id_tar_job;
        ParamByName('FOXPRO_DOPL').AsString := FOXPRO_DOPL;
        ParamByName('dop_percent').AsFloat := FOXPRO_PROC_D;
        ParamByName('dop_summa').AsFloat := FOXPRO_SUMD;
        ExecSQL;
      end;

      Form1.FoxProDbf.Next;
    end;
      sql_commands.UpdateTarJobDoplaty;
  end;
  //Импорт Доплат должностей тарификации
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
