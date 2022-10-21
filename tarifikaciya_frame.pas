unit tarifikaciya_frame;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Crt, PQConnection, SQLDB, DB, dbf, Forms, Controls,
  Graphics, Dialogs, ComCtrls, PairSplitter, ExtCtrls, StdCtrls, DBCtrls,
  DBGrids, ActnList, Buttons, Menus;

type

  { TTarifikaciyaFrame }

  TTarifikaciyaFrame = class(TFrame)
    GBOrganizations: TGroupBox;
    ListOrganizations: TListBox;
    PairSplitter1: TPairSplitter;
    PairSplitter2: TPairSplitter;
    PSDown: TPairSplitterSide;
    PSSOrganizatons: TPairSplitterSide;
    PSSRight: TPairSplitterSide;
    PSUp: TPairSplitterSide;
    TabControl1: TTabControl;
  private

  public

  end;

implementation

{$R *.frm}

end.

