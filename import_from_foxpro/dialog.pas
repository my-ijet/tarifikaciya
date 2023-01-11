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
    procedure FormCreate(Sender: TObject);
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

procedure TForm2.FormCreate(Sender: TObject);
begin
end;

procedure TForm2.BtnOkClick(Sender: TObject);
begin
  main.PathToDatabase := FileNameEdit1.Text;
  main.PathToFoxProDir := DirectoryEdit1.Text;
end;

end.

