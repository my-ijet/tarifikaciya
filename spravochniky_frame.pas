unit spravochniky_frame;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Crt, PQConnection, SQLDB, dbf, Forms, Controls,
  Graphics, Dialogs, ComCtrls, ExtCtrls, StdCtrls, DBCtrls,
  DBGrids, ActnList, Buttons, Menus;

type

  { TSpravochnikyFrame }

  TSpravochnikyFrame = class(TFrame)
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    GBSpravochniki: TGroupBox;
    ListTables: TListBox;
    PageControl1: TPageControl;
    RadioGroup1: TRadioGroup;
    TabPersons: TTabSheet;
    TabOrganizations: TTabSheet;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    procedure ListTablesClick(Sender: TObject);
  private

  public

  end;

implementation

{$R *.frm}

{ TSpravochnikyFrame }

procedure TSpravochnikyFrame.ListTablesClick(Sender: TObject);
begin
  PageControl1.TabIndex := ListTables.ItemIndex;
end;

end.

