unit main_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Crt, PQConnection, SQLDB, DB, dbf, Forms, Controls, Graphics,
  Dialogs, ComCtrls, PairSplitter, ExtCtrls, StdCtrls, DBCtrls, DBGrids,
  IniPropStorage, ActnList, Buttons, Menus;

type

  { TMainForm }

  TMainForm = class(TForm)
    BtnRenameDatabase: TBitBtn;
    BtnBackupDatabase: TBitBtn;
    BtnConnectToDB: TBitBtn;
    BtnDeleteBackup: TBitBtn;
    BtnDeleteDatabase: TBitBtn;
    BtnDeleteTarTable: TBitBtn;
    BtnDuplicateDatabase: TBitBtn;
    BtnDuplicateTarTable: TBitBtn;
    BtnImportFromFOXPRO: TBitBtn;
    BtnJoinWithCurrentDataBase: TBitBtn;
    BtnNewDatabase: TBitBtn;
    BtnNewTarTable: TBitBtn;
    BtnOrganizations: TButton;
    BtnPredmety: TButton;
    BtnDoljnosty: TButton;
    BtnNadbavky: TButton;
    BtnPersons: TButton;
    BtnDoplaty: TButton;
    BtnRestoreDatabase: TBitBtn;
    BtnStavky: TButton;
    BtnOrgGrups: TButton;
    CurrentDatabase: TComboBox;
    EditDbHost: TEdit;
    GBCurrentDatabase: TGroupBox;
    GBTarifikaciyaTables: TGroupBox;
    GBRestoreDatabases: TGroupBox;
    ImageList: TImageList;
    Label5: TLabel;
    ListDatabases: TListBox;
    DataSource1: TDataSource;
    Dbf1: TDbf;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    DBListBox1: TDBListBox;
    EditDbLogin: TEdit;
    EditDbPassword: TEdit;
    GBLoginPassword: TGroupBox;
    GBDatabases: TGroupBox;
    IniPropStorage1: TIniPropStorage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ListDatabases_3: TListBox;
    ListTarTables: TListBox;
    PairSplitter2: TPairSplitter;
    Panel1: TPanel;
    PQMainConnection: TPQConnection;
    PSSOrganizatons: TPairSplitterSide;
    PageControl1: TPageControl;
    PairSplitter1: TPairSplitter;
    PSSRight: TPairSplitterSide;
    SQLQuery1: TSQLQuery;
    SQLScript1: TSQLScript;
    SQLTransaction1: TSQLTransaction;
    TabControl1: TTabControl;
    Otchety: TTabSheet;
    TabControl2: TTabControl;
    Tarifikaciya: TTabSheet;
    Spravochniki: TTabSheet;
    Settings: TTabSheet;
    TaskDialog1: TTaskDialog;
    procedure BtnConnectToDBClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.frm}

{ TMainForm }


procedure TMainForm.FormCreate(Sender: TObject);
begin
  EditDbHost.Text := PQMainConnection.HostName;
  EditDbLogin.Text := PQMainConnection.Role;
  EditDbPassword.Text := PQMainConnection.Password;
  //PQMainConnection.DatabaseName;
  //IniPropStorage1.StoredValue['current_table'];
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  IniPropStorage1.WriteString('current_table', 'Test_table');
end;

procedure TMainForm.BtnConnectToDBClick(Sender: TObject);
begin
  with PQMainConnection do
  begin
    HostName := EditDbHost.Text;
    Role := EditDbLogin.Text;
    Password := EditDbPassword.Text;

    Connected := True;
  end;
end;

end.

