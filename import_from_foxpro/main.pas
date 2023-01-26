unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, dbf, DB, Forms, Controls,
  Graphics, Dialogs, ComCtrls, StdCtrls, ExtCtrls, FileUtil, dialog,
  foxpro_tarifikation;

type

  { TForm1 }

  TForm1 = class(TForm)
    DataSource1: TDataSource;
    FoxProDbf: TDbf;
    QSelect: TSQLQuery;
    Status: TLabel;
    MainConnection: TSQLite3Connection;
    QInsertFromFoxPro: TSQLQuery;
    SQL: TSQLScript;
    MainTransaction: TSQLTransaction;
    TimerStart: TTimer;
    TimerQuit: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SQLException(Sender: TObject; Statement: TStrings;
      TheException: Exception; var Continue: boolean);
    procedure TimerStartTimer(Sender: TObject);
    procedure TimerQuitTimer(Sender: TObject);

    procedure Start;
  private

  public

  end;

var
  Form1: TForm1;
  FoxProUtil: TFoxProUtil;
  PathToDatabase: string = '';
  PathToFoxProDir: string = '';

implementation

uses
  sql_commands;

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  Application.CreateForm(TForm2, Form2);

  FoxProUtil := TFoxProUtil.Create;

  if ParamCount > 0 then begin
    PathToDatabase := ParamStr(1);
  end;

end;

procedure TForm1.TimerStartTimer(Sender: TObject);
begin
  TimerStart.Enabled := False;
  Start;
end;

procedure TForm1.FormShow(Sender: TObject);
begin

  //Если ОК - продолжаем
  if dialog.Form2.ShowModal = 1 then
  else Application.Terminate;

  FoxProDbf.OnTranslate := @FoxProUtil.DbfTranslate;

  TimerStart.Enabled := True;
end;

procedure TForm1.Start;
var
  FoundDbfFiles: TStringList;
  DbfFileName, DbfFilePath: String;
  numOfFoundedFiles: Integer = 0;
begin
  MainConnection.DatabaseName := PathToDatabase;
  MainConnection.Connected := True;
  if not MainConnection.Connected then begin
    Status.Caption := 'Ошибка подключения!';
    TimerQuit.Enabled := True;
    Exit;
  end;

  FoundDbfFiles := FindAllFiles(PathToFoxProDir, '*.DBF', True);
  numOfFoundedFiles := FoundDbfFiles.Capacity;

  if numOfFoundedFiles > 0 then begin
    sql_commands.PrepareTables;

// Импорт справочников
    //MainConnection.ExecuteDirect('PRAGMA foreign_keys=OFF;');
    for DbfFilePath in FoundDbfFiles do
    begin
      DbfFileName := ExtractFileName(DbfFilePath);
      Caption := DbfFileName;

      ImportSpravochniky(DbfFilePath);
      Self.Refresh;
    end;
    //MainConnection.ExecuteDirect('PRAGMA foreign_keys=ON;');
// Импорт справочников
    sql_commands.UpdateSpravochniky;
    MainTransaction.Commit;

// Импорт таблиц тарификации
    //MainConnection.ExecuteDirect('PRAGMA foreign_keys=OFF;');
    for DbfFilePath in FoundDbfFiles do
    begin
      DbfFileName := ExtractFileName(DbfFilePath);
      Caption := DbfFileName;

      ImportTarifikations(DbfFilePath);
      Self.Refresh;
    end;
    //MainConnection.ExecuteDirect('PRAGMA foreign_keys=ON;');
// Импорт таблиц тарификации
    MainTransaction.Commit;
    Caption := 'Импорт данных FoxPro';

    sql_commands.ClearTables;
    MainTransaction.Commit;

    sql_commands.OptimizeDatabase;
    MainTransaction.Commit;

    Caption := 'Импорт завершен!';
    Status.Caption := 'Импорт завершен!';
  end else Status.Caption := 'Файлы не найдены!';

  FreeAndNil(FoundDbfFiles);

  TimerQuit.Enabled := True;
end;

// Таймер задержки выключения программы
procedure TForm1.TimerQuitTimer(Sender: TObject);
begin
  TimerQuit.Enabled := False;
  Application.Terminate;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FoxProUtil);
end;

procedure TForm1.SQLException(Sender: TObject; Statement: TStrings;
  TheException: Exception; var Continue: boolean);
begin
  Continue := True;
end;

end.

