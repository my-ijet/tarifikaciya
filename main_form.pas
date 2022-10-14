unit main_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Crt, PQConnection, SQLDB, DB, dbf, Forms, Controls, Graphics,
  Dialogs, ComCtrls, PairSplitter, ExtCtrls, StdCtrls, DBCtrls, DBGrids,
  IniPropStorage, ActnList;

type

  { TMainForm }

  TMainForm = class(TForm)
    BtnOrganizations: TButton;
    BtnPredmety: TButton;
    BtnDoljnosty: TButton;
    BtnNadbavky: TButton;
    BtnPersons: TButton;
    BtnDoplaty: TButton;
    BtnStavky: TButton;
    BtnOrgGrups: TButton;
    BtnConnectToDB: TButton;
    CurrentDatabase: TComboBox;
    DeleteDatabase: TButton;
    EditDbHost: TEdit;
    GBCurrentDatabase: TGroupBox;
    Label5: TLabel;
    ListDatabases: TListBox;
    NewDatabase: TButton;
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

