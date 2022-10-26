unit import_from_foxpro_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, Dbf, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  ExtCtrls, LConvEncoding, SQLDB, FileUtil;

type

  { TImportFromFoxProForm }

  TImportFromFoxProForm = class(TForm)
    BtnOk: TButton;
    BtnCancel: TButton;
    FoxProDbf: TDbf;
    DirFoxPro: TDirectoryEdit;
    EditDbName: TEdit;
    LabelDbName: TLabel;
    LabelPathToFoxPro: TLabel;
    Log: TMemo;
    GNewOrCurrentDB: TRadioGroup;
    QInsertFromFoxPro: TSQLQuery;
    SQLClearTables: TSQLScript;
    procedure FormCreate(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);

    procedure FindDbfInDirectoryAndImport;
    procedure PrepareToImportDbf(DbfFileName: String);
    procedure ImportOrganizations;
    procedure ImportOrgGroups;
    procedure ImportPersons;
    procedure ImportObrazovanie;
    procedure ImportPersonalGroups;
    procedure ImportDoljnost;
    procedure ImportKategories;
    procedure ImportPredmet;
    procedure ImportStavka;
    procedure ImportNadbavka;
    procedure ImportDoplata;

    function DbfTranslate(Dbf: TDbf; Src, Dest: PChar; ToOEM: Boolean): Integer;
    procedure clear;
  private

  public

  end;

var
  ImportFromFoxProForm: TImportFromFoxProForm;

implementation
{$R *.frm}

uses
  main_form, data_module;

{ TImportFromFoxProForm }

procedure TImportFromFoxProForm.FormCreate(Sender: TObject);
begin
  FoxProDbf.OnTranslate := @DbfTranslate;

  {$IfDef ONRELEASE}
  DirFoxPro.Text := '';
  {$EndIf}
end;

procedure TImportFromFoxProForm.BtnOkClick(Sender: TObject);
var
  dbname: String;
begin
  dbname := MainForm.ValidateDatabaseName(EditDbName.Text);
  if (DirFoxPro.Text = '')
  or (not DirectoryExists(DirFoxPro.Text))
  Then begin
    ModalResult := mrNone;
    Exit;
  end;

  if GNewOrCurrentDB.ItemIndex = 0
  then begin
    if dbname = ''
    Then begin
      ModalResult := mrNone;
      Exit;
    end
    else begin
      TarDataModule.NewDatabase(dbname);
      MainForm.CurrentDatabaseName := dbname;
    end;
  end;

  Self.Refresh;
  FindDbfInDirectoryAndImport;

  clear;
end;

procedure TImportFromFoxProForm.FindDbfInDirectoryAndImport;
var
  FoundDbfFiles: TStringList;
  DbfFileName, DbfFilePath: String;
begin
  Log.Text := 'Импорт данных из:';
  FoxProDbf.FilePath := DirFoxPro.Text;
  FoundDbfFiles := FindAllFiles(DirFoxPro.Text, '*.DBF', False);
  Self.Refresh;

  for DbfFilePath in FoundDbfFiles do
  begin
    DbfFileName := ExtractFileName(DbfFilePath);
    PrepareToImportDbf(DbfFileName);
  end;
  SQLClearTables.Execute;
  TarDataModule.MainTransaction.Commit;
  FreeAndNil(FoundDbfFiles);
end;

procedure TImportFromFoxProForm.PrepareToImportDbf(DbfFileName: String);
var
  i: Integer;
begin
  Log.Append(DbfFileName);
  Self.Refresh;

  FoxProDbf.TableName := DbfFileName;
  FoxProDbf.Active := True;

  // Преобразуем строки в UTF8
  for i := 0 to FoxProDbf.Fields.Count-1 do
    if FoxProDbf.Fields[i] is TStringField then
      TStringField(FoxProDbf.Fields[i]).Transliterate := true;

  case DbfFileName of
  'SU.DBF': ImportOrganizations;
  'SPRPG.DBF': ImportOrgGroups;
  'SPRFIO.DBF': ImportPersons;
  'SPROBR.DBF': ImportObrazovanie;
  'SPRGR.DBF': ImportPersonalGroups;
  'SPRDL.DBF': ImportDoljnost;
  'SPRKAT.DBF': ImportKategories;
  'SPRPREDM.DBF': ImportPredmet;
  'STAVKI.DBF': ImportStavka;
  'SPRN.DBF': ImportNadbavka;
  'SPRDP.DBF': ImportDoplata;
  end;

  FoxProDbf.Active := False;
end;

procedure TImportFromFoxProForm.ImportOrganizations;
begin
  with QInsertFromFoxPro do
  begin
  SQL.Text := 'insert into organization';
  SQL.Append('(short_name, foxpro_kod, pg, gr)');
  SQL.Append('values (:short_name, :foxpro_kod, :pg, :gr)');

  while not FoxProDbf.EOF do
  begin
    ParamByName('short_name').AsString := FoxProDbf.FieldByName('NAIM').AsString;
    ParamByName('foxpro_kod').AsString := FoxProDbf.FieldByName('KOD').AsString;
    ParamByName('pg').AsInteger := FoxProDbf.FieldByName('PG').AsInteger;
    ParamByName('gr').AsInteger := FoxProDbf.FieldByName('GR').AsInteger;
    ExecSQL;

    FoxProDbf.Next;
  end;
  end;
end;

procedure TImportFromFoxProForm.ImportOrgGroups;
begin
  with QInsertFromFoxPro do
  begin
  SQL.Text := 'insert into org_group';
  SQL.Append('(name, foxpro_kod)');
  SQL.Append('values (:name, :foxpro_kod)');

  while not FoxProDbf.EOF do
  begin
    ParamByName('name').AsString := FoxProDbf.FieldByName('NAIM').AsString;
    ParamByName('foxpro_kod').AsString := FoxProDbf.FieldByName('KOD').AsString;
    ExecSQL;

    FoxProDbf.Next;
  end;
  end;
end;

procedure TImportFromFoxProForm.ImportPersons;
var
  tmpstr, familyname, firstname, middlename: String;
  splittedstr: array of String;
begin
  familyname := '';
  firstname := '';
  middlename := '';

  with QInsertFromFoxPro do
  begin
  SQL.Text := 'insert into person';
  SQL.Append('(familyname, firstname, middlename, foxpro_kod)');
  SQL.Append('values (:familyname, :firstname, :middlename, :foxpro_kod)');

  while not FoxProDbf.EOF do
  begin
    tmpstr := Trim(FoxProDbf.FieldByName('NAIM').AsString);
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
    ParamByName('foxpro_kod').AsString := FoxProDbf.FieldByName('KOD').AsString;
    ExecSQL;

    FoxProDbf.Next;
  end;
  end;
end;

procedure TImportFromFoxProForm.ImportObrazovanie;
begin
  with QInsertFromFoxPro do
  begin
  SQL.Text := 'insert into obrazovanie';
  SQL.Append('(name, foxpro_kod)');
  SQL.Append('values (:name, :foxpro_kod)');

  while not FoxProDbf.EOF do
  begin
    ParamByName('name').AsString := FoxProDbf.FieldByName('NAIM').AsString;
    ParamByName('foxpro_kod').AsString := FoxProDbf.FieldByName('KOD').AsString;
    ExecSQL;

    FoxProDbf.Next;
  end;
  end;
end;

procedure TImportFromFoxProForm.ImportPersonalGroups;
begin
  with QInsertFromFoxPro do
  begin
  SQL.Text := 'insert into personal_group';
  SQL.Append('(name, foxpro_kod)');
  SQL.Append('values (:name, :foxpro_kod)');

  while not FoxProDbf.EOF do
  begin
    ParamByName('name').AsString := FoxProDbf.FieldByName('NAIM').AsString;
    ParamByName('foxpro_kod').AsString := FoxProDbf.FieldByName('KOD').AsString;
    ExecSQL;

    FoxProDbf.Next;
  end;
  end;
end;

procedure TImportFromFoxProForm.ImportDoljnost;
begin
  with QInsertFromFoxPro do
  begin
  SQL.Text := 'insert into doljnost';
  SQL.Append('(name, kolvo, foxpro_kod, por, pk, gopl)');
  SQL.Append('values (:name, :kolvo, :foxpro_kod, :por, :pk, :gopl)');

  while not FoxProDbf.EOF do
  begin
    ParamByName('name').AsString := FoxProDbf.FieldByName('NAIM').AsString;
    ParamByName('kolvo').AsInteger := FoxProDbf.FieldByName('KOLVO').AsInteger;
    ParamByName('por').AsInteger := FoxProDbf.FieldByName('POR').AsInteger;
    ParamByName('pk').AsInteger := FoxProDbf.FieldByName('PK').AsInteger;
    ParamByName('gopl').AsInteger := FoxProDbf.FieldByName('GOPL').AsInteger;
    ParamByName('foxpro_kod').AsString := FoxProDbf.FieldByName('KOD').AsString;
    ExecSQL;

    FoxProDbf.Next;
  end;
  end;
end;

procedure TImportFromFoxProForm.ImportKategories;
begin
    with QInsertFromFoxPro do
    begin
    SQL.Text := 'insert into kategory';
    SQL.Append('(name, foxpro_kod)');
    SQL.Append('values (:name, :foxpro_kod)');

    while not FoxProDbf.EOF do
    begin
      ParamByName('name').AsString := FoxProDbf.FieldByName('NAIM').AsString;
      ParamByName('foxpro_kod').AsString := FoxProDbf.FieldByName('KOD').AsString;
      ExecSQL;

      FoxProDbf.Next;
    end;
    end;
end;

procedure TImportFromFoxProForm.ImportPredmet;
begin
    with QInsertFromFoxPro do
    begin
    SQL.Text := 'insert into predmet';
    SQL.Append('(name, clock, foxpro_kod)');
    SQL.Append('values (:name, :clock, :foxpro_kod)');

    while not FoxProDbf.EOF do
    begin
      ParamByName('name').AsString := FoxProDbf.FieldByName('NAIM').AsString;
      ParamByName('clock').AsInteger := FoxProDbf.FieldByName('CLOCK').AsInteger;
      ParamByName('foxpro_kod').AsString := FoxProDbf.FieldByName('KOD').AsString;
      ExecSQL;

      FoxProDbf.Next;
    end;
    end;
end;

procedure TImportFromFoxProForm.ImportStavka;
begin
    with QInsertFromFoxPro do
    begin
    SQL.Text := 'insert into stavka';
    SQL.Append('(razr, sumst)');
    SQL.Append('values (:razr, :sumst)');

    while not FoxProDbf.EOF do
    begin
      ParamByName('razr').AsInteger := FoxProDbf.FieldByName('RAZR').AsInteger;
      ParamByName('sumst').AsCurrency := FoxProDbf.FieldByName('SUMST').AsCurrency;
      ExecSQL;

      FoxProDbf.Next;
    end;
    end;
end;

procedure TImportFromFoxProForm.ImportNadbavka;
begin
    with QInsertFromFoxPro do
    begin
    SQL.Text := 'insert into nadbavka';
    SQL.Append('(name, proc, foxpro_kod, por, pr)');
    SQL.Append('values (:name, :proc, :foxpro_kod, :por, :pr)');

    while not FoxProDbf.EOF do
    begin
      ParamByName('name').AsString := FoxProDbf.FieldByName('NAIM').AsString;
      ParamByName('proc').AsFloat := FoxProDbf.FieldByName('PROC').AsFloat;
      ParamByName('por').AsInteger := FoxProDbf.FieldByName('POR').AsInteger;
      ParamByName('pr').AsString := FoxProDbf.FieldByName('PR').AsString;
      ParamByName('foxpro_kod').AsString := FoxProDbf.FieldByName('KOD').AsString;
      ExecSQL;

      FoxProDbf.Next;
    end;
    end;
end;

procedure TImportFromFoxProForm.ImportDoplata;
begin
    with QInsertFromFoxPro do
    begin
    SQL.Text := 'insert into doplata';
    SQL.Append('(name, foxpro_kod, por, pk, pr)');
    SQL.Append('values (:name, :foxpro_kod, :por, :pk, :pr)');

    while not FoxProDbf.EOF do
    begin
      ParamByName('name').AsString := FoxProDbf.FieldByName('NAIM').AsString;
      ParamByName('por').AsInteger := FoxProDbf.FieldByName('POR').AsInteger;
      ParamByName('pk').AsInteger := FoxProDbf.FieldByName('PK').AsInteger;
      ParamByName('pr').AsString := FoxProDbf.FieldByName('PR').AsString;
      ParamByName('foxpro_kod').AsString := FoxProDbf.FieldByName('KOD').AsString;
      ExecSQL;

      FoxProDbf.Next;
    end;
    end;
end;

function TImportFromFoxProForm.DbfTranslate(Dbf: TDbf; Src, Dest: PChar; ToOEM: Boolean): Integer;
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

procedure TImportFromFoxProForm.clear;
begin
  FoxProDbf.Active := False;
  EditDbName.Text := '';
  //DirFoxPro.Text := '';
  Log.Clear;
  log.Append('Укажите название базы данных');
  log.Append('и путь до директории содержащей');
  log.Append('старые базы тарификации');
end;

procedure TImportFromFoxProForm.BtnCancelClick(Sender: TObject);
begin
end;

end.

