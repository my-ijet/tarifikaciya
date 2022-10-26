unit main_form;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, Crt, PQConnection, SQLDB, DB, dbf, Forms, Controls,
  Graphics, Dialogs, ComCtrls, ExtCtrls, StdCtrls, DBCtrls,
  DBGrids, IniPropStorage, ActnList, Buttons, Menus, ExtDlgs, FileUtil,
  import_from_foxpro_form, tarifikaciya_frame, otchety_frame, spravochniky_frame;

type

  { TMainForm }

  TMainForm = class(TForm)
    BtnBackupDatabase: TBitBtn;
    BtnConnectToHost: TButton;
    BtnDeleteBackup: TBitBtn;
    BtnDeleteDatabase: TBitBtn;
    BtnDeleteTarTable: TBitBtn;
    BtnDuplicateDatabase: TBitBtn;
    BtnDuplicateTarTable: TBitBtn;
    BtnImportFromFOXPRO: TBitBtn;
    BtnJoinWithCurrentDataBase: TBitBtn;
    BtnNewDatabase: TBitBtn;
    BtnNewTarTable: TBitBtn;
    BtnRenameDatabase: TBitBtn;
    BtnRestoreDatabase: TBitBtn;
    CalendarDialog1: TCalendarDialog;
    GBCurrentDatabase: TGroupBox;
    GBDatabases: TGroupBox;
    GBRestoreDatabases: TGroupBox;
    EditHostDbName: TEdit;
    EditHostIP: TEdit;
    EditHostLogin: TEdit;
    EditHostPassword: TEdit;
    GBLoginPassword: TGroupBox;
    GBTarifikaciyaTables: TGroupBox;
    ListCurrentDatabase: TDBLookupComboBox;
    ImageList: TImageList;
    InfoTarDbConnection: TCheckBox;
    Ini: TIniPropStorage;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ListCurrentTarifikationDate: TDBLookupComboBox;
    ListDatabaseBackups: TListBox;
    ListDatabases: TDBLookupListBox;
    ListTarTables: TListBox;
    OtchetyTab: TTabSheet;
    MainPageControl: TPageControl;
    Panel1: TPanel;
    ServicePageControl: TPageControl;
    SpravochnikyTab: TTabSheet;
    Service: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TarifikaciyaTab: TTabSheet;

    TarifikaciyaFrame: TTarifikaciyaFrame;
    OtchetyFrame: TOtchetyFrame;
    SpravochnikyFrame: TSpravochnikyFrame;

    procedure BtnConnectToHostClick(Sender: TObject);
    procedure BtnDeleteBackupClick(Sender: TObject);
    procedure BtnDeleteDatabaseClick(Sender: TObject);
    procedure BtnDuplicateDatabaseClick(Sender: TObject);
    procedure BtnImportFromFOXPROClick(Sender: TObject);
    procedure BtnNewDatabaseClick(Sender: TObject);
    procedure BtnRenameDatabaseClick(Sender: TObject);
    procedure BtnBackupDatabaseClick(Sender: TObject);
    procedure BtnRestoreDatabaseClick(Sender: TObject);
    procedure ListCurrentDatabaseChange(Sender: TObject);
    procedure ListCurrentTarifikationDateChange(Sender: TObject);
    procedure EditHostDbNameEditingDone(Sender: TObject);
    procedure EditHostIPEditingDone(Sender: TObject);
    procedure EditHostLoginEditingDone(Sender: TObject);
    procedure EditHostPasswordEditingDone(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure MainPageControlChange(Sender: TObject);

    procedure OnConnect(sender: TObject);
    procedure OnDisconnect(sender: TObject);
    procedure CheckAndChangeCurrentDatabase;
    procedure LoadSettings;
    procedure SaveSettings;
    function  ValidateDatabaseName(dbname: String): String;
    procedure PrepareDatabaseBackupsList;
    procedure ChangeCurrentTarifikationDate;
  private
    NeedSaveSettings: Boolean;
    mCurrentDatabaseName: String;
    CurrentTarifikationDate: String;

    procedure SetCurrentDatabaseName(dbname: String);

  public
    property CurrentDatabaseName: String read mCurrentDatabaseName write SetCurrentDatabaseName;
  end;

var
  MainForm: TMainForm;

implementation
{$R *.frm}

uses
  data_module;

{ TMainForm }


procedure TMainForm.FormCreate(Sender: TObject);
begin
  TarDataModule.MainConnection.AfterConnect := @OnConnect;
  TarDataModule.MainConnection.BeforeDisconnect := @OnDisconnect;

  TarifikaciyaFrame := TTarifikaciyaFrame.Create(MainForm);
  TarifikaciyaFrame.Parent := TarifikaciyaTab;
  OtchetyFrame := TOtchetyFrame.Create(MainForm);
  OtchetyFrame.Parent := OtchetyTab;
  SpravochnikyFrame := TSpravochnikyFrame.Create(MainForm);
  SpravochnikyFrame.Parent := SpravochnikyTab;

  {$IfDef ONRELEASE}
  MainPageControl.TabIndex := 0;
  SpravochnikyFrame.PageControl.TabIndex := 0;
  {$EndIf}
  LoadSettings;
  PrepareDatabaseBackupsList;
end;

procedure TMainForm.MainPageControlChange(Sender: TObject);
begin
  if ListCurrentDatabase.Text = ''
  then Exit;

  if MainPageControl.TabIndex = 2
  then
    TarDataModule.PrepQueries;
end;

procedure TMainForm.BtnConnectToHostClick(Sender: TObject);
begin
  TarDataModule.ConnectToHost(
    EditHostIP.Text,
    EditHostLogin.Text,
    EditHostPassword.Text,
    EditHostDbName.Text);
  if TarDataModule.MainConnection.Connected
  then CheckAndChangeCurrentDatabase;
end;

procedure TMainForm.BtnBackupDatabaseClick(Sender: TObject);
begin
  if ListDatabases.ItemIndex < 0 then Exit;

  TarDataModule.BackupDatabase(ListDatabases.GetSelectedText);
  PrepareDatabaseBackupsList;
end;

procedure TMainForm.BtnDeleteDatabaseClick(Sender: TObject);
begin
  if ListDatabases.ItemIndex < 0 then Exit;

  TarDataModule.DeleteDatabase(ListDatabases.GetSelectedText);
end;

procedure TMainForm.BtnImportFromFOXPROClick(Sender: TObject);
begin
  ImportFromFoxProForm.ShowModal;
end;

procedure TMainForm.BtnNewDatabaseClick(Sender: TObject);
var
  dbname: String;
begin
  if not InputQuery('Создание новой базы данных', 'Новое название:', dbname)
  then Exit;

  dbname := ValidateDatabaseName(dbname);

  if dbname = '' Then Exit;

  TarDataModule.NewDatabase(dbname);

  mCurrentDatabaseName := dbname;
  NeedSaveSettings := True;
end;

procedure TMainForm.BtnRenameDatabaseClick(Sender: TObject);
var
  OldName, NewName, TitleText: String;
begin
  if ListDatabases.ItemIndex < 0 then Exit;
  OldName := ListDatabases.GetSelectedText;

  TitleText := 'Переименовать базу данных - "' + OldName + '"';
  if not InputQuery(TitleText, 'Новое название:', NewName)
  then Exit;

  NewName := ValidateDatabaseName(NewName);

  if NewName = '' Then Exit;

  TarDataModule.RenameDatabase(OldName, NewName);
end;

procedure TMainForm.BtnDuplicateDatabaseClick(Sender: TObject);
var
  OldName, NewName, TitleText: String;
begin
  if ListDatabases.ItemIndex < 0 then Exit;
  OldName := ListDatabases.GetSelectedText;

  TitleText := 'Создание копии базы данных - "' + OldName + '"';
  if not InputQuery(TitleText, 'Новое название:', NewName)
  then Exit;

  NewName := ValidateDatabaseName(NewName);

  if NewName = '' Then Exit;

  TarDataModule.DuplicateDatabase(OldName, NewName);
end;

procedure TMainForm.ListCurrentDatabaseChange(Sender: TObject);
begin
  CurrentDatabaseName := ListCurrentDatabase.Text;
end;

procedure TMainForm.ListCurrentTarifikationDateChange(Sender: TObject);
begin
  CurrentTarifikationDate := '';
  ChangeCurrentTarifikationDate;
  NeedSaveSettings := True;
end;

procedure TMainForm.EditHostDbNameEditingDone(Sender: TObject);
begin
  if EditHostDbName.Text = TarDataModule.MainConnection.DatabaseName
  then Exit;
  NeedSaveSettings := True;
end;

procedure TMainForm.EditHostIPEditingDone(Sender: TObject);
begin
  if EditHostIP.Text = TarDataModule.MainConnection.HostName
  then Exit;
  NeedSaveSettings := True;
end;

procedure TMainForm.EditHostLoginEditingDone(Sender: TObject);
begin
  if EditHostLogin.Text = TarDataModule.MainConnection.UserName
  then Exit;
  NeedSaveSettings := True;
end;

procedure TMainForm.EditHostPasswordEditingDone(Sender: TObject);
begin
  if EditHostPassword.Text = TarDataModule.MainConnection.Password
  then Exit;
  NeedSaveSettings := True;
end;

procedure TMainForm.PrepareDatabaseBackupsList;
var
  FoundBackupFiles: TStringList;
  BackupPath,
  BackupFilePath, BackupFileName: String;
begin
  BackupPath := GetCurrentDir+DirectorySeparator+'Backups';
  if not DirectoryExists(BackupPath) Then Exit;

  FoundBackupFiles := FindAllFiles(BackupPath, '*.dump', False);

  ListDatabaseBackups.Clear;
  for BackupFilePath in FoundBackupFiles do
  begin
      BackupFileName := ExtractFileName(BackupFilePath);
      BackupFileName := BackupFileName.TrimRight('.dump');
      ListDatabaseBackups.Items.Add(BackupFileName);
  end;
  FreeAndNil(FoundBackupFiles);
end;

procedure TMainForm.BtnRestoreDatabaseClick(Sender: TObject);
var
  BackupPath,
  BackupFilePath, BackupFileName: String;
  i: Integer;
begin
  if ListDatabaseBackups.SelCount < 1 then Exit;

  TarDataModule.MainConnection.Connected := False;

  BackupPath := GetCurrentDir+DirectorySeparator+'Backups';
  for i := 0 to ListDatabaseBackups.Items.Count - 1 do
  begin
      If not ListDatabaseBackups.Selected[i] then Continue;
      BackupFileName := ListDatabaseBackups.Items.Strings[i] + '.dump';
      BackupFilePath := BackupPath+DirectorySeparator+BackupFileName;
      TarDataModule.RestoreDatabase(BackupFilePath);
  end;
  TarDataModule.MainConnection.Connected := True;
end;

procedure TMainForm.BtnDeleteBackupClick(Sender: TObject);
var
  BackupFilePath, BackupFileName: String;
  i: Integer;
begin
  if ListDatabaseBackups.SelCount < 1 then Exit;

  for i := 0 to ListDatabaseBackups.Items.Count - 1 do
  begin
      If not ListDatabaseBackups.Selected[i] then Continue;
      BackupFileName := ListDatabaseBackups.Items.Strings[i] + '.dump';
      BackupFilePath := 'Backups'+DirectorySeparator+BackupFileName;
      DeleteFile(BackupFilePath);
  end;

  PrepareDatabaseBackupsList;
end;

procedure TMainForm.ChangeCurrentTarifikationDate;
begin
end;

procedure TMainForm.SetCurrentDatabaseName(dbname: String);
begin
  mCurrentDatabaseName := dbname;
  NeedSaveSettings := True;

  CheckAndChangeCurrentDatabase;
end;

procedure TMainForm.LoadSettings;
begin
  with Ini do
  begin
    EditHostIP.Text := ReadString('host', 'localhost');
    EditHostLogin.Text := ReadString('login', 'postgres');
    EditHostPassword.Text := ReadString('password', '');
    EditHostDbName.Text := ReadString('host_database', 'postgres');

    mCurrentDatabaseName := ReadString('cur_database', '');
    BtnConnectToHostClick(MainForm);

    CurrentTarifikationDate := ReadString('TarifikationDate', '');
    ChangeCurrentTarifikationDate;
  end;

  NeedSaveSettings := False;
end;

procedure TMainForm.SaveSettings;
begin
  with Ini do
  begin
    WriteString('host', EditHostIP.Text);
    WriteString('login', EditHostLogin.Text);
    WriteString('password', EditHostPassword.Text);
    WriteString('host_database', EditHostDbName.Text);

    WriteString('cur_database', CurrentDatabaseName);
    WriteString('TarifikationDate', CurrentTarifikationDate);
  end;
end;

function TMainForm.ValidateDatabaseName(dbname: String): String;
var
  NewName, SpecialChars, Ch : String;
begin
  NewName := Trim(dbname);
  while NewName.Contains('  ') do
    NewName := NewName.Replace('  ', ' ', [rfReplaceAll]);

  SpecialChars:='!?&*@$\/|:;{}<>()[]`''"';
  for Ch in SpecialChars do
    NewName := NewName.Replace(Ch, '_', [rfReplaceAll]);
  Result := NewName;
end;

procedure TMainForm.CheckAndChangeCurrentDatabase;
var
  indexOfDbName: Integer;
begin
  indexOfDbName := ListCurrentDatabase.Items.IndexOf(CurrentDatabaseName);
  if indexOfDbName < 0
  then begin
    ShowMessage('Необходимо выбрать рабочую базу данных.');
    MainForm.MainPageControl.TabIndex := 3;
    MainForm.ServicePageControl.TabIndex := 0;
  end
  else begin
    TarDataModule.ConnectToHost(
      EditHostIP.Text,
      EditHostLogin.Text,
      EditHostPassword.Text,
      CurrentDatabaseName);
  end;
end;

procedure TMainForm.OnConnect(sender: TObject);
var
  dbname, NewCaption: String;
begin
  TarDataModule.QAllDatabases.Active := True;

  dbname := TarDataModule.MainConnection.DatabaseName;

  ListCurrentDatabase.Text := dbname;
  NewCaption := 'Тарификация - "' + dbname + '"';
  MainForm.Caption := NewCaption;

  InfoTarDbConnection.Checked := True;
end;

procedure TMainForm.OnDisconnect(sender: TObject);
begin
  InfoTarDbConnection.Checked := False;
end;


procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if NeedSaveSettings then SaveSettings;

  TarDataModule.MainConnection.BeforeDisconnect := nil;
end;

end.

