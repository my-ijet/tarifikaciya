unit main_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Crt, PQConnection, SQLDB, DB, dbf, Forms, Controls,
  Graphics, Dialogs, ComCtrls, PairSplitter, ExtCtrls, StdCtrls, DBCtrls,
  DBGrids, IniPropStorage, ActnList, Buttons, Menus,
  fpspreadsheetctrls, fpspreadsheetgrid;

type

  { TMainForm }

  TMainForm = class(TForm)
    BtnBackupDatabase: TBitBtn;
    BtnConnectToHost: TBitBtn;
    BtnDeleteBackup: TBitBtn;
    BtnDeleteDatabase: TBitBtn;
    BtnDeleteTarTable: TBitBtn;
    BtnDoljnosty: TButton;
    BtnDoplaty: TButton;
    BtnDuplicateDatabase: TBitBtn;
    BtnDuplicateTarTable: TBitBtn;
    BtnImportFromFOXPRO: TBitBtn;
    BtnJoinWithCurrentDataBase: TBitBtn;
    BtnNadbavky: TButton;
    BtnNewDatabase: TBitBtn;
    BtnNewTarTable: TBitBtn;
    BtnOrganizations: TButton;
    BtnOrgGrups: TButton;
    BtnPersons: TButton;
    BtnPredmety: TButton;
    BtnRenameDatabase: TBitBtn;
    BtnRestoreDatabase: TBitBtn;
    BtnStavky: TButton;
    DBGrid1: TDBGrid;
    GBSpravochniki: TGroupBox;
    GBOrganizations: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    CurrentTarifikationDate: TComboBox;
    CurrentDatabase: TComboBox;
    EditDbDb: TEdit;
    EditDbHost: TEdit;
    EditDbLogin: TEdit;
    EditDbPassword: TEdit;
    GBCurrentDatabase: TGroupBox;
    GBDatabases: TGroupBox;
    GBLoginPassword: TGroupBox;
    GBRestoreDatabases: TGroupBox;
    GBTarifikaciyaTables: TGroupBox;
    GroupBox1: TGroupBox;
    ImageList: TImageList;
    DataSource1: TDataSource;
    Dbf1: TDbf;
    IniPropStorage: TIniPropStorage;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ListOrganizations: TListBox;
    ListDatabases: TListBox;
    ListDatabaseBackups: TListBox;
    ListTarTables: TListBox;
    Otchety: TTabSheet;
    MainPageControl: TPageControl;
    PairSplitter1: TPairSplitter;
    PairSplitter2: TPairSplitter;
    PQMainConnection: TPQConnection;
    PSDown: TPairSplitterSide;
    PSSOrganizatons: TPairSplitterSide;
    PSSRight: TPairSplitterSide;
    PSUp: TPairSplitterSide;
    Settings: TTabSheet;
    Spravochniki: TTabSheet;
    SQLQuery1: TSQLQuery;
    SQLScript1: TSQLScript;
    SQLTransaction1: TSQLTransaction;
    sWorkbookSource1: TsWorkbookSource;
    sWorksheetGrid1: TsWorksheetGrid;
    TabControl1: TTabControl;
    TabControl2: TTabControl;
    Service: TTabSheet;
    Tarifikaciya: TTabSheet;

    procedure BtnConnectToHostClick(Sender: TObject);
    procedure CurrentDatabaseChange(Sender: TObject);
    procedure CurrentTarifikationDateChange(Sender: TObject);
    procedure EditDbDbChange(Sender: TObject);
    procedure EditDbHostChange(Sender: TObject);
    procedure EditDbLoginChange(Sender: TObject);
    procedure EditDbPasswordChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);

    procedure LoadSettings;
    procedure SaveSettings;

    procedure ConnectToHost;
    procedure ChangeCurrentDatabase;
    procedure PrepareDatabaseList;
    procedure PrepareDatabaseBackupsList;
    procedure ChangeCurrentTarifikationDate;
    procedure PrepareCurrentDatabaseLists;
  private
    NeedSaveSettings: Boolean;

  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.frm}

{ TMainForm }


procedure TMainForm.FormCreate(Sender: TObject);
begin
  MainPageControl.TabIndex := 0;
  LoadSettings;
end;

procedure TMainForm.BtnConnectToHostClick(Sender: TObject);
begin
  ConnectToHost;
  if PQMainConnection.Connected then
    BtnConnectToHost.Enabled := False;
end;

procedure TMainForm.CurrentDatabaseChange(Sender: TObject);
begin
  ChangeCurrentDatabase;
end;

procedure TMainForm.CurrentTarifikationDateChange(Sender: TObject);
begin
  ChangeCurrentTarifikationDate;
end;

procedure TMainForm.EditDbDbChange(Sender: TObject);
begin
  NeedSaveSettings := True;
  BtnConnectToHost.Enabled := True;
end;

procedure TMainForm.EditDbHostChange(Sender: TObject);
begin
  NeedSaveSettings := True;
  BtnConnectToHost.Enabled := True;
end;

procedure TMainForm.EditDbLoginChange(Sender: TObject);
begin
  NeedSaveSettings := True;
  BtnConnectToHost.Enabled := True;
end;

procedure TMainForm.EditDbPasswordChange(Sender: TObject);
begin
  NeedSaveSettings := True;
  BtnConnectToHost.Enabled := True;
end;

procedure TMainForm.ConnectToHost;
begin
  with PQMainConnection do
  begin
    Connected := False;

    HostName := EditDbHost.Text;
    Role := EditDbLogin.Text;
    Password := EditDbPassword.Text;
    DatabaseName := EditDbDb.Text;

    Connected := True;
  end;
end;

procedure TMainForm.ChangeCurrentDatabase;
begin
  NeedSaveSettings := True;
  if CurrentDatabase.Text = '' then Exit;

  with PQMainConnection do
  begin
    Connected := False;
    DatabaseName := CurrentDatabase.Text;
    Connected := True;
  end;
end;

procedure TMainForm.PrepareDatabaseList;
begin
//Получить список баз данных, установить в доступные и в текущую
  with ListDatabases.Items do
  begin
    Clear;
  end;
  with CurrentDatabase.Items do
  begin
    Clear;
    //Add('');
  end;
end;

procedure TMainForm.PrepareDatabaseBackupsList;
begin
//Получить список рез копий баз данных
end;

procedure TMainForm.ChangeCurrentTarifikationDate;
begin
  NeedSaveSettings := True;
end;

procedure TMainForm.PrepareCurrentDatabaseLists;
begin
  if CurrentDatabase.Text = '' then Exit;
//Получить список таблиц
  with ListTarTables.Items do
  begin
    Clear;
  end;
//Получить список дат основных тарификаций
  with CurrentTarifikationDate.Items do
  begin
    Clear;
  end;
//Получить список организаций
  with ListOrganizations.Items do
  begin
    Clear;
  end;
end;

procedure TMainForm.LoadSettings;
begin
  with IniPropStorage do
  begin
    IniSection := 'settings';
    WindowState := StrToWindowState(ReadString('WindowState', 'wsMaximized'));
    EditDbHost.Text := ReadString('host', 'localhost');
    EditDbLogin.Text := ReadString('login', 'postgres');
    EditDbPassword.Text := ReadString('password', '');
    EditDbDb.Text := ReadString('database', 'postgres');
    ConnectToHost;

    PrepareDatabaseList;

    IniSection := 'client';
    CurrentDatabase.Text := ReadString('database', '');
    ChangeCurrentDatabase;
    PrepareCurrentDatabaseLists;

    CurrentTarifikationDate.Text := ReadString('TarifikationDate', '');
    ChangeCurrentTarifikationDate;
  end;

  NeedSaveSettings := False;
end;

procedure TMainForm.SaveSettings;
begin
  with IniPropStorage do
  begin
    IniSection := 'settings';
    WriteString('host', EditDbHost.Text);
    WriteString('login', EditDbLogin.Text);
    WriteString('password', EditDbPassword.Text);
    WriteString('database', EditDbDb.Text);
    WriteString('WindowState', WindowStateToStr(WindowState));

    IniSection := 'client';
    WriteString('database', CurrentDatabase.Text);
    WriteString('TarifikationDate', CurrentTarifikationDate.Text);
  end;
end;

procedure TMainForm.FormWindowStateChange(Sender: TObject);
begin
  NeedSaveSettings := True;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if NeedSaveSettings then SaveSettings;
end;

end.

