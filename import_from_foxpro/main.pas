unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, dbf, DB, process, Forms, Controls,
  Graphics, Dialogs, ComCtrls, StdCtrls, ExtCtrls, FileUtil, dialog,
  foxpro_tarifikation, SQLScript;

type

  { TForm1 }

  TForm1 = class(TForm)
    DataSource1: TDataSource;
    FoxProDbf: TDbf;
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
  Visible := False;

  Application.CreateForm(TForm2, Form2);

  FoxProUtil := TFoxProUtil.Create;

  if ParamCount > 0 then begin
    PathToDatabase := ParamStr(1);
  end;

  //Если ОК - продолжаем
  if dialog.Form2.ShowModal = 1 then
    Form1.Visible := True
  else Application.Terminate;

  FoxProDbf.OnTranslate := @FoxProUtil.DbfTranslate;

end;

procedure TForm1.TimerStartTimer(Sender: TObject);
begin
  TimerStart.Enabled := False;
  Start;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
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

  FoxProDbf.FilePath := PathToFoxProDir;
  FoundDbfFiles := FindAllFiles(PathToFoxProDir, '*.DBF', False);
  numOfFoundedFiles := FoundDbfFiles.Capacity;

  if numOfFoundedFiles > 0 then begin
    sql_commands.PrepareTables;

    for DbfFilePath in FoundDbfFiles do
    begin
      DbfFileName := ExtractFileName(DbfFilePath);
      Caption := DbfFileName+
                       ' | Осталось файлов: '+
                       IntToStr(numOfFoundedFiles);

      foxpro_tarifikation.ImportDbf(DbfFileName);
      Self.Refresh;

      Dec(numOfFoundedFiles);
    end;
    Caption := 'Импорт данных FoxPro';

    sql_commands.UpdateTables;
    sql_commands.ClearTables;
    MainTransaction.Commit;
    sql_commands.OptimizeDatabase;

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

