unit data_module;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, PQConnection, SQLDB, Dialogs, Process;

type

  { TTarDataModule }

  TTarDataModule = class(TDataModule)
    DSSpravochniky: TDataSource;
    DSAllDatabases: TDataSource;
    MainConnection: TPQConnection;
    QAllDatabases: TSQLQuery;
    MainTransaction: TSQLTransaction;
    SQLCreateTables: TSQLScript;
    QPersons: TSQLQuery;
    QOrganizations: TSQLQuery;
    QOrgGroups: TSQLQuery;
    QObrazovanie: TSQLQuery;
    QDoljnost: TSQLQuery;
    QKategories: TSQLQuery;
    QPredmet: TSQLQuery;
    QStavka: TSQLQuery;
    QNadbavka: TSQLQuery;
    QDoplata: TSQLQuery;
    QPersonalGroups: TSQLQuery;
    QAllTarDates: TSQLQuery;

    procedure ConnectToHost(NewHostName, NewUserName, NewPassword, NewDatabaseName : String);

    procedure NewDatabase(dbname: String);
    procedure RenameDatabase(FromName, ToName: String);
    procedure DuplicateDatabase(FromName, ToName: String);
    procedure BackupDatabase(dbname: String);
    procedure RestoreDatabase(BackupFile: String);
    procedure DeleteDatabase(dbname: String);
  private

  public
    procedure PrepQueries;

  end;

var
  TarDataModule: TTarDataModule;

implementation
{$R *.frm}

uses
  main_form;

{ TTarDataModule }

procedure TTarDataModule.ConnectToHost(NewHostName, NewUserName, NewPassword, NewDatabaseName : String);
begin
  try with MainConnection do
  begin
    Connected := False;
    HostName := NewHostName;
    UserName := NewUserName;
    Password := NewPassword;
    DatabaseName := NewDatabaseName;
    Connected := True;
  end;
  except
    ShowMessage('Неудаётся подключиться к серверу Postgres');
    MainForm.MainPageControl.TabIndex := 3;
    MainForm.ServicePageControl.TabIndex := 1;
  end;
end;

procedure TTarDataModule.NewDatabase(dbname: String);
var
  SqlCreateDB: String;
begin
  SqlCreateDB := 'create database ' + AnsiQuotedStr(dbname,'"');

  with MainConnection do
  begin
    ExecuteDirect('End Transaction');
    ExecuteDirect(SqlCreateDB);
    ExecuteDirect('Begin Transaction');

    DatabaseName := dbname;
    Connected := False; Connected := True;

    SQLCreateTables.Execute;
  end;
end;

procedure TTarDataModule.RenameDatabase(FromName, ToName: String);
var
  SqlCreateDB: String;
begin
  SqlCreateDB := 'ALTER DATABASE ' + AnsiQuotedStr(FromName,'"');
  SqlCreateDB += ' RENAME TO ' + AnsiQuotedStr(ToName,'"');

  try with MainConnection do
  begin
    ExecuteDirect('End Transaction');
    ExecuteDirect(SqlCreateDB);
    ExecuteDirect('Begin Transaction');

    Connected := False; Connected := True;
  end;
  except
    ShowMessage('Рабочую базу данных переименовать нельзя');
  end;
end;

procedure TTarDataModule.DuplicateDatabase(FromName, ToName: String);
var
  SqlDuplicateDB: String;
begin
  SqlDuplicateDB := 'CREATE DATABASE ' + AnsiQuotedStr(ToName,'"');
  SqlDuplicateDB += ' WITH TEMPLATE ' + AnsiQuotedStr(FromName,'"');

  try with MainConnection do
  begin
    ExecuteDirect('End Transaction');
    ExecuteDirect(SqlDuplicateDB);
    ExecuteDirect('Begin Transaction');

    Connected := False; Connected := True;
  end;
  except
    ShowMessage('Рабочую базу данных дублировать нельзя');
  end;
end;

procedure TTarDataModule.BackupDatabase(dbname: String);
var
  response, BackupPath, dump_file: String;
begin
  BackupPath := GetCurrentDir+DirectorySeparator+'Backups';
  if not DirectoryExists(BackupPath)
  Then CreateDir(BackupPath);

  dump_file := BackupPath+DirectorySeparator;
  dump_file += FormatDateTime('YY-MM-DD hh-mm-ss ', Now) + dbname+'.dump';

  RunCommand('pg_dump',
  ['-U', MainForm.EditHostLogin.Text,
  '-h', MainForm.EditHostIP.Text,
  '-d', dbname,'-FC',
  '-f', dump_file],
  response, [], swoHIDE);
end;

procedure TTarDataModule.RestoreDatabase(BackupFile: String);
var
  response: String;
begin

  RunCommand('pg_restore',
  ['-U', MainForm.EditHostLogin.Text,
  '-h', MainForm.EditHostIP.Text,
  '-d', MainForm.EditHostDbName.Text,
  '-C', '-c', BackupFile],
  response, [], swoHIDE);
end;

procedure TTarDataModule.DeleteDatabase(dbname: String);
var
  SqlDeleteDB: String;
begin
  SqlDeleteDB := 'drop database ' + AnsiQuotedStr(dbname,'"');

  try with MainConnection do
  begin
    ExecuteDirect('End Transaction');
    ExecuteDirect(SqlDeleteDB);
    ExecuteDirect('Begin Transaction');

    Connected := False; Connected := True;
  end;
  except
    ShowMessage('Рабочую базу данных удалить нельзя');
  end;
end;

procedure TTarDataModule.PrepQueries;
begin
  //QAllDatabases.Active := True;
  QPersons.Active := True;
  QOrganizations.Active := True;
  QOrgGroups.Active := True;
  QObrazovanie.Active := True;
  QPersonalGroups.Active := True;
  QDoljnost.Active := True;
  QKategories.Active := True;
  QPredmet.Active := True;
  QStavka.Active := True;
  QNadbavka.Active := True;
  QDoplata.Active := True;
end;

end.

