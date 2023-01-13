unit dialog;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, EditBtn, StdCtrls,
  Buttons;

type

  { TForm2 }

  TForm2 = class(TForm)
    BtnOk: TBitBtn;
    BtnCancel: TBitBtn;
    DirectoryEdit1: TDirectoryEdit;
    FileNameEdit1: TFileNameEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure BtnOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;

implementation
uses
  main;

{$R *.lfm}

{ TForm2 }

procedure TForm2.BtnOkClick(Sender: TObject);
begin
  if not FileExists(FileNameEdit1.Text) then begin
    ModalResult := mrNone;
    ShowMessage('Укажите файл базы данных');
    Exit;
  end;
  if not DirectoryExists(DirectoryEdit1.Text) then begin
    ModalResult := mrNone;
    ShowMessage('Укажите путь до FoxPro базы данных');
    Exit;
  end;
  main.PathToDatabase := FileNameEdit1.Text;
  main.PathToFoxProDir := DirectoryEdit1.Text;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  if FileExists(main.PathToDatabase) then
    FileNameEdit1.Text := main.PathToDatabase;
end;

end.

