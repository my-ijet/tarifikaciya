unit foxpro_tarifikation;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, Dbf, LConvEncoding, FileUtil;

type
  TFoxProUtil = class
  private
  public
  function DbfTranslate(Dbf: TDbf; Src, Dest: PChar; ToOEM: Boolean): Integer;
  end;


procedure ImportDbf(DbfFilePath : String);
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

procedure ImportDbf(DbfFilePath : String);
var
  i: Integer;
  DbfFileName: String;
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

  'T1_0109.DBF': ImportTarifikaciya; // TODOT Исправить
// Добавить для каждого T1_* импорт тарификации и
// для каждого T2_* импорт доп тар таблицы
  end;

  Form1.FoxProDbf.Active := False;
end;


procedure ImportOrganizations;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into organization';
    SQL.Append('(short_name, foxpro_kod, pg, gr)');
    SQL.Append('values (:short_name, :foxpro_kod, :pg, :gr)');

    while not Form1.FoxProDbf.EOF do begin
      ParamByName('short_name').AsString := Form1.FoxProDbf.FieldByName('NAIM').AsString;
      ParamByName('foxpro_kod').AsString := Form1.FoxProDbf.FieldByName('KOD').AsString;
      ParamByName('pg').AsString := Form1.FoxProDbf.FieldByName('PG').AsString;
      ParamByName('gr').AsInteger := Form1.FoxProDbf.FieldByName('GR').AsInteger;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportOrgGroups;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into org_group';
    SQL.Append('(name, foxpro_kod)');
    SQL.Append('values (:name, :foxpro_kod)');

    while not Form1.FoxProDbf.EOF do begin
      ParamByName('name').AsString := Form1.FoxProDbf.FieldByName('NAIM').AsString;
      ParamByName('foxpro_kod').AsString := Form1.FoxProDbf.FieldByName('KOD').AsString;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportPersons;
var
  tmpstr, familyname, firstname, middlename: String;
  splittedstr: array of String;
begin
  familyname := ''; firstname := ''; middlename:= '';

  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into person';
    SQL.Append('(familyname, firstname, middlename, foxpro_kod)');
    SQL.Append('values (:familyname, :firstname, :middlename, :foxpro_kod)');

    while not Form1.FoxProDbf.EOF do begin
      tmpstr := Trim(Form1.FoxProDbf.FieldByName('NAIM').AsString);
      while tmpstr.Contains('  ') do
        tmpstr := tmpstr.Replace('  ', ' ', [rfReplaceAll]);

      splittedstr := tmpstr.Split([' ']);
      case Length(splittedstr) of
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
      end;

       ParamByName('familyname').AsString := familyname;
       ParamByName('firstname').AsString := firstname;
       ParamByName('middlename').AsString := middlename;
       ParamByName('foxpro_kod').AsString := Form1.FoxProDbf.FieldByName('KOD').AsString;
       ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportPersonalGroups;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into personal_group';
    SQL.Append('(name, foxpro_kod)');
    SQL.Append('values (:name, :foxpro_kod)');

    while not Form1.FoxProDbf.EOF do begin
       ParamByName('name').AsString := Form1.FoxProDbf.FieldByName('NAIM').AsString;
       ParamByName('foxpro_kod').AsString := Form1.FoxProDbf.FieldByName('KOD').AsString;
       ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportDoljnost;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into doljnost';
    SQL.Append('(name, kolvo, foxpro_kod, por, pk, gopl)');
    SQL.Append('values (:name, :kolvo, :foxpro_kod, :por, :pk, :gopl)');

    while not Form1.FoxProDbf.EOF do
    begin
      ParamByName('name').AsString := Form1.FoxProDbf.FieldByName('NAIM').AsString;
      ParamByName('kolvo').AsInteger := Form1.FoxProDbf.FieldByName('KOLVO').AsInteger;
      ParamByName('por').AsInteger := Form1.FoxProDbf.FieldByName('POR').AsInteger;
      ParamByName('pk').AsInteger := Form1.FoxProDbf.FieldByName('PK').AsInteger;
      ParamByName('gopl').AsInteger := Form1.FoxProDbf.FieldByName('GOPL').AsInteger;
      ParamByName('foxpro_kod').AsString := Form1.FoxProDbf.FieldByName('KOD').AsString;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportObrazovanie;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into obrazovanie';
    SQL.Append('(name, foxpro_kod)');
    SQL.Append('values (:name, :foxpro_kod)');

    while not Form1.FoxProDbf.EOF do begin
       ParamByName('name').AsString := Form1.FoxProDbf.FieldByName('NAIM').AsString;
       ParamByName('foxpro_kod').AsString := Form1.FoxProDbf.FieldByName('KOD').AsString;
       ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportPredmet;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into predmet';
    SQL.Append('(name, clock, foxpro_kod)');
    SQL.Append('values (:name, :clock, :foxpro_kod)');

    while not Form1.FoxProDbf.EOF do begin
      ParamByName('name').AsString := Form1.FoxProDbf.FieldByName('NAIM').AsString;
      ParamByName('clock').AsInteger := Form1.FoxProDbf.FieldByName('CLOCK').AsInteger;
      ParamByName('foxpro_kod').AsString := Form1.FoxProDbf.FieldByName('KOD').AsString;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportNadbavka;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into nadbavka';
    SQL.Append('(name, percent, foxpro_kod, por, pr)');
    SQL.Append('values (:name, :percent, :foxpro_kod, :por, :pr)');

    while not Form1.FoxProDbf.EOF do begin
      ParamByName('name').AsString := Form1.FoxProDbf.FieldByName('NAIM').AsString;
      ParamByName('percent').AsFloat := Form1.FoxProDbf.FieldByName('PROC').AsFloat;
      ParamByName('por').AsInteger := Form1.FoxProDbf.FieldByName('POR').AsInteger;
      ParamByName('pr').AsString := Form1.FoxProDbf.FieldByName('PR').AsString;
      ParamByName('foxpro_kod').AsString := Form1.FoxProDbf.FieldByName('KOD').AsString;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportDoplata;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into doplata';
    SQL.Append('(name, foxpro_kod, por, pk, pr)');
    SQL.Append('values (:name, :foxpro_kod, :por, :pk, :pr)');

    while not Form1.FoxProDbf.EOF do begin
      ParamByName('name').AsString := Form1.FoxProDbf.FieldByName('NAIM').AsString;
      ParamByName('por').AsInteger := Form1.FoxProDbf.FieldByName('POR').AsInteger;
      ParamByName('pk').AsInteger := Form1.FoxProDbf.FieldByName('PK').AsInteger;
      ParamByName('pr').AsString := Form1.FoxProDbf.FieldByName('PR').AsString;
      ParamByName('foxpro_kod').AsString := Form1.FoxProDbf.FieldByName('KOD').AsString;
      ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportStavka;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into stavka';
    SQL.Append('(razr, summa)');
    SQL.Append('values (:razr, :summa)');

    while not Form1.FoxProDbf.EOF do begin
       ParamByName('razr').AsInteger := Form1.FoxProDbf.FieldByName('RAZR').AsInteger;
       ParamByName('summa').AsCurrency := Form1.FoxProDbf.FieldByName('SUMST').AsCurrency;
       ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportKategories;
begin
  with Form1.QInsertFromFoxPro do  begin
    SQL.Text := 'insert into kategory';
    SQL.Append('(name, foxpro_kod)');
    SQL.Append('values (:name, :foxpro_kod)');

    while not Form1.FoxProDbf.EOF do begin
       ParamByName('name').AsString := Form1.FoxProDbf.FieldByName('NAIM').AsString;
       ParamByName('foxpro_kod').AsString := Form1.FoxProDbf.FieldByName('KOD').AsString;
       ExecSQL;

      Form1.FoxProDbf.Next;
    end;
  end;
end;

procedure ImportTarifikaciya;
begin
  with Form1.QInsertFromFoxPro do begin
    SQL.Text := 'insert into tarifikaciya ';
    SQL.Append('(FOXPRO_KU, FOXPRO_TABN, FOXPRO_OBR, diplom, staj_year, staj_month, date)');
    SQL.Append('values (:FOXPRO_KU, :FOXPRO_TABN, :FOXPRO_OBR, :diplom, :staj_year, :staj_month, :date);');

    while not Form1.FoxProDbf.EOF do begin
      ParamByName('FOXPRO_KU').AsString := Form1.FoxProDbf.FieldByName('KU').AsString;
      ParamByName('FOXPRO_TABN').AsString := Form1.FoxProDbf.FieldByName('TABN').AsString;
      ParamByName('FOXPRO_OBR').AsString := Form1.FoxProDbf.FieldByName('OBR').AsString;
      ParamByName('diplom').AsString := Form1.FoxProDbf.FieldByName('NOMDIP').AsString;
      ParamByName('staj_year').AsInteger := Form1.FoxProDbf.FieldByName('STAGY').AsInteger;
      ParamByName('staj_month').AsInteger := Form1.FoxProDbf.FieldByName('STAGM').AsInteger;

      ParamByName('date').AsString := FormatDateTime('YYYY-MM-DD HH:MM:SS.SSS',
                                                     Form1.FoxProDbf.FieldByName('DATA').AsDateTime);
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
