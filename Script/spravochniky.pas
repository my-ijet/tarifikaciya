uses
  'service.pas',
  'otchety.pas',
  'tarifikation.pas';


procedure Tarifikation_SpravochnikyTabs_OnChange (Sender: TObject);
begin
  PrepareSpravochniky;
end;

procedure PrepareSpravochniky;
begin
  case Tarifikation.SpravochnikyTabs.ActivePageIndex of
    0 : Tarifikation.BtnFilterOrganizations.Click;
    1 : Tarifikation.BtnFilterOrgGroups.Click;
    2 : Tarifikation.BtnFilterPersons.Click;
    3 : Tarifikation.BtnFilterPersonalGroups.Click;
    4 : Tarifikation.BtnFilterDoljnosty.Click;
    5 : Tarifikation.BtnFilterObrazovaniya.Click;
    6 : Tarifikation.BtnFilterPredmety.Click;
    7 : Tarifikation.BtnFilterNadbavky.Click;
    8 : Tarifikation.BtnFilterDoplaty.Click;
    9 : Tarifikation.BtnFilterStavky.Click;
    10 : Tarifikation.BtnFilterKategory.Click;
  end;
end;

// Организации
procedure Tarifikation_CheckFilterOrganizationArchived_OnClick (Sender: TObject);
begin
  Tarifikation.BtnFilterOrganizations.Click;
end;

procedure Tarifikation_BtnClearFilterOrganizations_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.EditFilterOrgShortName.Clear;
  Tarifikation.ListFilterOrgGroup.ItemIndex := 0;
  Tarifikation.CheckFilterOrganizationArchived.State := 0;

  Tarifikation.BtnFilterOrganizations.Click;
end;
// Организации

// Группы организаций
procedure Tarifikation_BtnClearFilterOrgGroups_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.EditFilterOrgGroups.Clear;
  Tarifikation.BtnFilterOrgGroups.Click;
end;
// Группы организаций

// Сотрудники
procedure Tarifikation_CheckFilterPersonArchived_OnClick (Sender: TObject);
begin
  Tarifikation.BtnFilterPersons.Click;
end;

procedure Tarifikation_BtnClearFilterPersons_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.EditFilterPersonsFamilyname.Clear;
  Tarifikation.EditFilterPersonsFirstname.Clear;
  Tarifikation.EditFilterPersonsMiddlename.Clear;
  Tarifikation.CheckFilterPersonArchived.State := 0;

  Tarifikation.BtnFilterPersons.Click;
end;
// Сотрудники

// Группы сотрудников
procedure Tarifikation_BtnClearFilterPersonalGroups_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.EditFilterPersonalGroups.Clear;
  Tarifikation.BtnFilterPersonalGroups.Click;
end;
// Группы сотрудников

// Должности
procedure Tarifikation_CheckFilterDoljnostArchived_OnClick (Sender: TObject);
begin
  Tarifikation.BtnFilterDoljnosty.Click;
end;

procedure Tarifikation_BtnClearFilterDoljnosty_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.EditFilterDoljnosty.Clear;
  Tarifikation.CheckFilterDoljnostArchived.State := 0;

  Tarifikation.BtnFilterDoljnosty.Click;
end;
// Должности

// Образования
procedure Tarifikation_BtnClearFilterObrazovaniya_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.EditFilterObrazovaniya.Clear;
  Tarifikation.BtnFilterObrazovaniya.Click;
end;
// Образования

// Предметы
procedure Tarifikation_CheckFilterPredmetArchived_OnClick (Sender: TObject);
begin
  Tarifikation.BtnFilterPredmety.Click;
end;

procedure Tarifikation_BtnClearFilterPredmety_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.EditFilterPredmety.Clear;
  Tarifikation.CheckFilterPredmetArchived.State := 0;

  Tarifikation.BtnFilterPredmety.Click;
end;
// Предметы

// Надбавки
procedure Tarifikation_CheckFilterNadbavkaArchived_OnClick (Sender: TObject);
begin
  Tarifikation.BtnFilterNadbavky.Click;
end;

procedure Tarifikation_BtnClearFilterNadbavky_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.EditFilterNadbavky.Clear;
  Tarifikation.CheckFilterNadbavkaArchived.State := 0;

  Tarifikation.BtnFilterNadbavky.Click;
end;
// Надбавки

// Доплаты
procedure Tarifikation_CheckFilterDoplataArchived_OnClick (Sender: TObject);
begin
  Tarifikation.BtnFilterDoplaty.Click;
end;

procedure Tarifikation_BtnClearFilterDoplaty_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.EditFilterDoplaty.Clear;
  Tarifikation.CheckFilterDoplataArchived.State := 0;

  Tarifikation.BtnFilterDoplaty.Click;
end;
// Доплаты

// Ставки
procedure Tarifikation_CheckFilterStavkaArchived_OnClick (Sender: TObject);
begin
  Tarifikation.BtnFilterStavky.Click;
end;

procedure Tarifikation_BtnClearFilterStavky_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.EditFilterStavkyRazr.Clear;
  Tarifikation.EditFilterStavkySymma.Clear;
  Tarifikation.CheckFilterStavkaArchived.State := 0;

  Tarifikation.BtnFilterStavky.Click;
end;
// Ставки

// Категории
procedure Tarifikation_BtnClearFilterKategory_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.EditFilterKategory.Clear;
  Tarifikation.BtnFilterKategory.Click;
end;
// Категории


// Кнопки удаления справочников
procedure Tarifikation_BtnDeleteKategory_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TableKategory);
end;

procedure Tarifikation_BtnDeleteStavka_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TableStavky);
end;

procedure Tarifikation_BtnDeleteDoplata_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TableDoplaty);
end;

procedure Tarifikation_BtnDeleteNadbavka_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TableNadbavky);
end;

procedure Tarifikation_BtnDeletePredmet_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TablePredmety);
end;

procedure Tarifikation_BtnDeleteObrazovanie_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TableObrazovaniya);
end;

procedure Tarifikation_BtnDeleteDoljnost_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TableDoljnosty);
end;

procedure Tarifikation_BtnDeletePersonalGroup_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TablePersonalGroup);
end;

procedure Tarifikation_BtnDeletePerson_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TablePersons);
end;

procedure Tarifikation_BtnDeleteOrgGroup_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TableOrgGroups);
end;

procedure Tarifikation_BtnDeleteOrganization_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TableOrganizations);
end;
// Кнопки удаления справочников

// Кнопки отправки в архив
procedure Tarifikation_BtnStavkyToArchive_OnClick (Sender: TObject; var Cancel: boolean);
begin
  if Tarifikation.CheckFilterStavkaArchived.Checked then
    RecordToArchiveFromTable(Tarifikation.TableStavky, 0)
  else
    RecordToArchiveFromTable(Tarifikation.TableStavky, 1);
end;

procedure Tarifikation_BtnDoplatyToArchive_OnClick (Sender: TObject; var Cancel: boolean);
begin
  if Tarifikation.CheckFilterDoplataArchived.Checked then
    RecordToArchiveFromTable(Tarifikation.TableDoplaty, 0)
  else
    RecordToArchiveFromTable(Tarifikation.TableDoplaty, 1);
end;

procedure Tarifikation_BtnNadbavkyToArchive_OnClick (Sender: TObject; var Cancel: boolean);
begin
  if Tarifikation.CheckFilterNadbavkaArchived.Checked then
    RecordToArchiveFromTable(Tarifikation.TableNadbavky, 0)
  else
    RecordToArchiveFromTable(Tarifikation.TableNadbavky, 1);
end;

procedure Tarifikation_BtnPredmetyToArchive_OnClick (Sender: TObject; var Cancel: boolean);
begin
  if Tarifikation.CheckFilterPredmetArchived.Checked then
    RecordToArchiveFromTable(Tarifikation.TablePredmety, 0)
  else
    RecordToArchiveFromTable(Tarifikation.TablePredmety, 1);
end;

procedure Tarifikation_BtnDoljnostyToArchive_OnClick (Sender: TObject; var Cancel: boolean);
begin
  if Tarifikation.CheckFilterDoljnostArchived.Checked then
    RecordToArchiveFromTable(Tarifikation.TableDoljnosty, 0)
  else
    RecordToArchiveFromTable(Tarifikation.TableDoljnosty, 1);
end;

procedure Tarifikation_BtnPersonsToArchive_OnClick (Sender: TObject; var Cancel: boolean);
begin
  if Tarifikation.CheckFilterPersonArchived.Checked then
    RecordToArchiveFromTable(Tarifikation.TablePersons, 0)
  else
    RecordToArchiveFromTable(Tarifikation.TablePersons, 1);
end;

procedure Tarifikation_BtnOrganizationsToArchive_OnClick (Sender: TObject; var Cancel: boolean);
begin
  if Tarifikation.CheckFilterOrganizationArchived.Checked then
    RecordToArchiveFromTable(Tarifikation.TableOrganizations, 0)
  else
    RecordToArchiveFromTable(Tarifikation.TableOrganizations, 1);
end;
// Кнопки отправки в архив

begin
  // MessageDlg('Справочники загружены!', mtInformation, mbOK, 0);
end.
