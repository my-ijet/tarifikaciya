unit otchety_frame;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Crt, PQConnection, SQLDB, DB, dbf, Forms, Controls,
  Graphics, Dialogs, ComCtrls, ExtCtrls, StdCtrls, DBCtrls,
  DBGrids, ActnList, Buttons, Menus;

type

  { TOtchetyFrame }

  TOtchetyFrame = class(TFrame)
    GroupBox1: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    PageControl1: TPageControl;
    RequisiteTab: TTabSheet;
    TabSheet1: TTabSheet;
  private

  public

  end;

implementation

{$R *.frm}

end.

