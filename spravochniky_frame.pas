unit spravochniky_frame;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Crt, PQConnection, SQLDB, dbf, DB, Forms, Controls,
  Graphics, Dialogs, ComCtrls, ExtCtrls, StdCtrls, DBCtrls,
  DBGrids, ActnList, Buttons, Menus;

type

  { TSpravochnikyFrame }

  TSpravochnikyFrame = class(TFrame)
    DBGrid1: TDBGrid;
    DBGrid10: TDBGrid;
    DBGrid11: TDBGrid;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    DBGrid4: TDBGrid;
    DBGrid5: TDBGrid;
    DBGrid6: TDBGrid;
    DBGrid7: TDBGrid;
    DBGrid8: TDBGrid;
    DBGrid9: TDBGrid;
    DBNavigator1: TDBNavigator;
    GBSpravochniki: TGroupBox;
    ListTables: TListBox;
    PageControl: TPageControl;
    GroupActive: TRadioGroup;
    TabPersons: TTabSheet;
    TabOrganizations: TTabSheet;
    TabOrgGroups: TTabSheet;
    TabObrazovanie: TTabSheet;
    TabPersonalGroups: TTabSheet;
    TabDoljnost: TTabSheet;
    TabKategories: TTabSheet;
    TabPredmety: TTabSheet;
    TabStavky: TTabSheet;
    TabNadbavky: TTabSheet;
    TabDoplaty: TTabSheet;
    procedure GroupActiveSelectionChanged(Sender: TObject);
    procedure ListTablesClick(Sender: TObject);

    procedure ChangeQuery(var NewQuery: TSQLQuery);
  private
    mIsArchived: Boolean;

  public

  end;

implementation
uses
  data_module;

{$R *.frm}

{ TSpravochnikyFrame }

procedure TSpravochnikyFrame.ListTablesClick(Sender: TObject);
begin
  PageControl.TabIndex := ListTables.ItemIndex;

  with TarDataModule do
  begin
    case ListTables.ItemIndex of
    0: ChangeQuery(QOrganizations);
    1: ChangeQuery(QOrgGroups);
    2: ChangeQuery(QPersons);
    3: ChangeQuery(QObrazovanie);
    4: ChangeQuery(QPersonalGroups);
    5: ChangeQuery(QDoljnost);
    6: ChangeQuery(QKategories);
    7: ChangeQuery(QPredmet);
    8: ChangeQuery(QStavka);
    9: ChangeQuery(QNadbavka);
    10: ChangeQuery(QDoplata);
    end;
  end;

end;

procedure TSpravochnikyFrame.ChangeQuery(var NewQuery: TSQLQuery);
begin
  with TarDataModule do
  begin
    DSSpravochniky.DataSet.Active := True;
    DSSpravochniky.DataSet.Refresh;

    DSSpravochniky.DataSet := NewQuery;
    NewQuery.ParamByName('ISARCHIVED').AsBoolean := mIsArchived;
    NewQuery.Refresh;
    NewQuery.Active := True;
  end;
end;

procedure TSpravochnikyFrame.GroupActiveSelectionChanged(Sender: TObject);
begin
  with TarDataModule do
  begin
  if GroupActive.ItemIndex = 0
  then mIsArchived := False
  else mIsArchived := True;

  QOrganizations.ParamByName('ISARCHIVED').AsBoolean := mIsArchived;
  QOrgGroups.ParamByName('ISARCHIVED').AsBoolean := mIsArchived;
  QPersons.ParamByName('ISARCHIVED').AsBoolean := mIsArchived;
  QObrazovanie.ParamByName('ISARCHIVED').AsBoolean := mIsArchived;
  QPersonalGroups.ParamByName('ISARCHIVED').AsBoolean := mIsArchived;
  QDoljnost.ParamByName('ISARCHIVED').AsBoolean := mIsArchived;
  QKategories.ParamByName('ISARCHIVED').AsBoolean := mIsArchived;
  QPredmet.ParamByName('ISARCHIVED').AsBoolean := mIsArchived;
  QStavka.ParamByName('ISARCHIVED').AsBoolean := mIsArchived;
  QNadbavka.ParamByName('ISARCHIVED').AsBoolean := mIsArchived;
  QDoplata.ParamByName('ISARCHIVED').AsBoolean := mIsArchived;

  DSSpravochniky.DataSet.Refresh;
  DSSpravochniky.DataSet.Active := True;
  end;
end;

end.

