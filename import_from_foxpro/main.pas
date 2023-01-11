unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, dbf, DB, Forms, Controls, Graphics,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    DataSource1: TDataSource;
    Dbf1: TDbf;
    ProgressBar1: TProgressBar;
    SQLite3Connection1: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    StaticText1: TStaticText;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private

  public

  end;

var
  Form1: TForm1;
  PathToDatabase: string;
  PathToFoxProDir: string;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Application.Terminate;
end;

end.

