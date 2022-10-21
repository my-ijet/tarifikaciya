unit main_form;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, Crt, PQConnection, SQLDB, DB, dbf, Forms, Controls,
  Graphics, Dialogs, ComCtrls, ExtCtrls, StdCtrls, DBCtrls,
  DBGrids, IniPropStorage, ActnList, Buttons, Menus, ExtDlgs,
  tarifikaciya_frame, otchety_frame, spravochniky_frame;

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
    ListCurrentTarifikationDate: TComboBox;
    ImageList: TImageList;
    InfoTarDbConnection: TCheckBox;
    Ini: TIniPropStorage;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ListDatabaseBackups: TListBox;
    ListDatabases: TDBLookupListBox;
    ListTarTables: TListBox;
    OtchetyTab: TTabSheet;
    MainPageControl: TPageControl;
    Panel1: TPanel;
    ServicePageControl: TPageControl;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SpravochnikyTab: TTabSheet;
    Service: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TarifikaciyaTab: TTabSheet;

    TarifikaciyaFrame: TTarifikaciyaFrame;
    OtchetyFrame: TOtchetyFrame;
    SpravochnikyFrame: TSpravochnikyFrame;

    procedure BtnConnectToHostClick(Sender: TObject);
    procedure BtnDeleteDatabaseClick(Sender: TObject);
    procedure BtnNewDatabaseClick(Sender: TObject);
    procedure BtnRenameDatabaseClick(Sender: TObject);
    procedure ListCurrentDatabaseChange(Sender: TObject);
    procedure ListCurrentTarifikationDateChange(Sender: TObject);
    procedure EditHostDbNameEditingDone(Sender: TObject);
    procedure EditHostIPEditingDone(Sender: TObject);
    procedure EditHostLoginEditingDone(Sender: TObject);
    procedure EditHostPasswordEditingDone(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);

    procedure OnConnect(sender: TObject);
    procedure OnDisconnect(sender: TObject);
    procedure SetCaptionToCurrDatabaseName;

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
  {$EndIf}
  LoadSettings;
end;

procedure TMainForm.BtnConnectToHostClick(Sender: TObject);
begin
  TarDataModule.ConnectToHost(
    EditHostIP.Text,
    EditHostLogin.Text,
    EditHostPassword.Text,
    EditHostDbName.Text);
end;

procedure TMainForm.BtnDeleteDatabaseClick(Sender: TObject);
begin
  if ListDatabases.ItemIndex < 0 then Exit;

  TarDataModule.DeleteDatabase(ListDatabases.GetSelectedText);
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
begin
//Получить список рез копий баз данных
end;

procedure TMainForm.ChangeCurrentTarifikationDate;
begin
end;

procedure TMainForm.SetCurrentDatabaseName(dbname: String);
var
  indexOfDbName: Integer;
begin
  indexOfDbName := ListCurrentDatabase.Items.IndexOf(dbname);
  if indexOfDbName < 0 then Exit;

  mCurrentDatabaseName := dbname;
  TarDataModule.ChangeCurrentDatabase(dbname);
  TarDataModule.PrepQueries;

  NeedSaveSettings := True;
end;

procedure TMainForm.LoadSettings;
begin
  with Ini do
  begin
    EditHostIP.Text := ReadString('host', 'localhost');
    EditHostLogin.Text := ReadString('login', 'postgres');
    EditHostPassword.Text := ReadString('password', '');
    EditHostDbName.Text := ReadString('host_database', 'postgres');
    BtnConnectToHostClick(MainForm);

    CurrentDatabaseName := ReadString('cur_database', '');
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

procedure TMainForm.SetCaptionToCurrDatabaseName;
var
  NewCaption: String;
begin
  NewCaption := 'Тарификация - "' + CurrentDatabaseName + '"';
  MainForm.Caption := NewCaption;
end;

procedure TMainForm.OnConnect(sender: TObject);
begin
  TarDataModule.QAllDatabases.Active := True;
  ListCurrentDatabase.Text := CurrentDatabaseName;
  SetCaptionToCurrDatabaseName;

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

