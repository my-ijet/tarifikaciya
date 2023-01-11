program import_from_foxpro;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  SysUtils,
  Forms, main, dialog
  { you can add units after this };

{$R *.res}

var
  PathToDatabase: string = '';

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;

  if ParamCount > 0 then begin
    PathToDatabase := ParamStr(1);
  end;

  Application.CreateForm(TForm1, Form1);
  Form1.Visible := False;
  Application.CreateForm(TForm2, Form2);
  if FileExists(PathToDatabase) then
    dialog.Form2.FileNameEdit1.Text := PathToDatabase;
  if dialog.Form2.ShowModal = 1 then
    Form1.Visible := True
  else
    Application.Terminate;

  Application.Run;
end.

