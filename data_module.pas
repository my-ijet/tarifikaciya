unit data_module;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, PQConnection, SQLDB;

type

  { TTarDataModule }

  TTarDataModule = class(TDataModule)
    DataSource1: TDataSource;
    DSAllDatabases: TDataSource;
    MainConnection: TPQConnection;
    QAllDatabases: TSQLQuery;
    MainTransaction: TSQLTransaction;
    SQLCreateTables: TSQLScript;
    SQLQuery1: TSQLQuery;

    procedure ConnectToHost(NewHostName, NewUserName, NewPassword, NewDatabaseName : String);
    procedure ChangeCurrentDatabase(NewDatabaseName : String);

    procedure NewDatabase(dbname: String);
    procedure DeleteDatabase(dbname: String);
    procedure RenameDatabase(FromName, ToName: String);
  private

  public
    procedure PrepQueries;

  end;

var
  TarDataModule: TTarDataModule;

implementation
{$R *.frm}

{ TTarDataModule }

procedure TTarDataModule.ConnectToHost(NewHostName, NewUserName, NewPassword, NewDatabaseName : String);
begin
  with MainConnection do
  begin
    HostName := NewHostName;
    UserName := NewUserName;
    Password := NewPassword;
    DatabaseName := NewDatabaseName;

    Connected := False; Connected := True;
  end;
end;

procedure TTarDataModule.ChangeCurrentDatabase(NewDatabaseName: String);
begin
  with MainConnection do
  begin
    DatabaseName := NewDatabaseName;

    Connected := False; Connected := True;
  end;
end;

procedure TTarDataModule.NewDatabase(dbname: String);
var
  SqlCreateDB: String;
  currDbName: String;
begin
  SqlCreateDB := 'create database ' + AnsiQuotedStr(dbname,'"');

  with MainConnection do
  begin
    ExecuteDirect('End Transaction');
    ExecuteDirect(SqlCreateDB);
    ExecuteDirect('Begin Transaction');

    currDbName := DatabaseName;
    DatabaseName := dbname;

    Connected := False; Connected := True;

    SQLCreateTables.Execute;
    DatabaseName := currDbName;

    Connected := False; Connected := True;
  end;
end;

procedure TTarDataModule.DeleteDatabase(dbname: String);
var
  SqlDeleteDB: String;
begin
  SqlDeleteDB := 'drop database ' + AnsiQuotedStr(dbname,'"');

  with MainConnection do
  begin
    ExecuteDirect('End Transaction');
    ExecuteDirect(SqlDeleteDB);
    ExecuteDirect('Begin Transaction');

    Connected := False; Connected := True;
  end;
end;

procedure TTarDataModule.RenameDatabase(FromName, ToName: String);
var
  SqlCreateDB: String;
begin
  SqlCreateDB := 'ALTER DATABASE ' + AnsiQuotedStr(FromName,'"');
  SqlCreateDB += ' RENAME TO ' + AnsiQuotedStr(ToName,'"');

  with MainConnection do
  begin
    ExecuteDirect('End Transaction');
    ExecuteDirect(SqlCreateDB);
    ExecuteDirect('Begin Transaction');

    Connected := False; Connected := True;
  end;
end;

procedure TTarDataModule.PrepQueries;
begin
  QAllDatabases.Active := True;
  SQLQuery1.Active := True;
end;

end.

