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

procedure ImportFoxProT1;
procedure ImportFoxProT2;

implementation

uses
  main;

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
    SQL.Append('(name, clock, por, foxpro_kod, pk, gopl)');
    SQL.Append('values (:name, :clock, :por, :foxpro_kod, :pk, :gopl)');

    while not Form1.FoxProDbf.EOF do begin
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;

      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      ParamByName('foxpro_kod').AsString := FOXPRO_KOD;
      ParamByName('name').AsString := FOXPRO_NAIM;
      ParamByName('clock').AsInteger := Form1.FoxProDbf.FieldByName('KOLVO').AsInteger;
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
    SQL.Append('(name, percent, foxpro_kod, por, id_comp_type)');
    SQL.Append('values (:name, :percent, :foxpro_kod, :por, :id_comp_type)');

    while not Form1.FoxProDbf.EOF do begin
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;

      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      ParamByName('foxpro_kod').AsString := FOXPRO_KOD;
      ParamByName('name').AsString := FOXPRO_NAIM;
      ParamByName('percent').AsFloat := Form1.FoxProDbf.FieldByName('PROC').AsFloat;
      ParamByName('id_comp_type').AsInteger := Form1.FoxProDbf.FieldByName('PR').AsInteger;
      ParamByName('por').AsInteger := Form1.FoxProDbf.FieldByName('POR').AsInteger;
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
    SQL.Append('(name, foxpro_kod, por, pk, id_comp_type)');
    SQL.Append('values (:name, :foxpro_kod, :por, :pk, :id_comp_type)');

    while not Form1.FoxProDbf.EOF do begin
      if (Form1.FoxProDbf.PhysicalRecNo mod Form1.ProgressBar.Step) = 0 then begin
          Form1.ProgressBar.StepIt; Application.ProcessMessages;
      end;

      FOXPRO_KOD := Form1.FoxProDbf.FieldByName('KOD').AsString;
      FOXPRO_NAIM := Form1.FoxProDbf.FieldByName('NAIM').AsString;

      ParamByName('foxpro_kod').AsString := FOXPRO_KOD;
      ParamByName('name').AsString := FOXPRO_NAIM;
      ParamByName('id_comp_type').AsInteger := Form1.FoxProDbf.FieldByName('PR').AsInteger;
      ParamByName('por').AsInteger := Form1.FoxProDbf.FieldByName('POR').AsInteger;
      ParamByName('pk').AsInteger := Form1.FoxProDbf.FieldByName('PK').AsInteger;
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
    SQL.Append('FOXPRO_NADB, FOXPRO_PROC_N, ');
    SQL.Append('FOXPRO_DOPL, FOXPRO_PROC_D, FOXPRO_SUMD, ');
    SQL.Append('FOXPRO_RAZR, FOXPRO_KAT, ');
    SQL.Append('FOXPRO_STAVKA, FOXPRO_STIM, ');
    SQL.Append('FOXPRO_DATA )');
    SQL.Append('values');
    SQL.Append('(:FOXPRO_KU, :FOXPRO_TABN, :FOXPRO_DOLJ, ');
    SQL.Append(':FOXPRO_PREDM, :FOXPRO_CLOCK, :FOXPRO_SUMCL, ');
    SQL.Append(':FOXPRO_NADB, :FOXPRO_PROC_N, ');
    SQL.Append(':FOXPRO_DOPL, :FOXPRO_PROC_D, :FOXPRO_SUMD, ');
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
      ParamByName('FOXPRO_PROC_N').AsFloat := Form1.FoxProDbf.FieldByName('PROC_N').AsFloat;
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
