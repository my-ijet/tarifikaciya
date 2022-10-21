unit spravochniky_frame;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Crt, PQConnection, SQLDB, DB, dbf, Forms, Controls,
  Graphics, Dialogs, ComCtrls, ExtCtrls, StdCtrls, DBCtrls,
  DBGrids, ActnList, Buttons, Menus;

type

  { TSpravochnikyFrame }

  TSpravochnikyFrame = class(TFrame)
    BtnDoljnosty: TButton;
    BtnDoplaty: TButton;
    BtnNadbavky: TButton;
    BtnOrganizations: TButton;
    BtnOrgGrups: TButton;
    BtnPersons: TButton;
    BtnPredmety: TButton;
    BtnStavky: TButton;
    DBGrid1: TDBGrid;
    GBSpravochniki: TGroupBox;
  private

  public

  end;

implementation

{$R *.frm}

end.

