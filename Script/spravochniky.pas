uses
  'service.pas',
  'otchety.pas',
  'tarifikation.pas';

// Организации
procedure Tarifikation_ListFilterOrgGroup_OnChange (Sender: TObject);
begin
  Tarifikation.BtnFilterOrganizations.Click;
end;

procedure Tarifikation_EditFilterOrgShortName_OnChange (Sender: TObject);
begin
  Tarifikation.BtnFilterOrganizations.Click;
end;

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
procedure Tarifikation_EditFilterOrgGroups_OnChange (Sender: TObject);
begin
  Tarifikation.BtnFilterOrgGroups.Click;
end;

procedure Tarifikation_BtnClearFilterOrgGroups_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.EditFilterOrgGroups.Clear;
  Tarifikation.BtnFilterOrgGroups.Click;
end;
// Группы организаций

// Сотрудники
procedure Tarifikation_EditFilterPersonsFamilyname_OnChange (Sender: TObject);
begin
  Tarifikation.BtnFilterPersons.Click;
end;

procedure Tarifikation_EditFilterPersonsFirstname_OnChange (Sender: TObject);
begin
  Tarifikation.BtnFilterPersons.Click;
end;

procedure Tarifikation_EditFilterPersonsMiddlename_OnChange (Sender: TObject);
begin
  Tarifikation.BtnFilterPersons.Click;
end;

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
procedure Tarifikation_EditFilterPersonalGroups_OnChange (Sender: TObject);
begin
  Tarifikation.BtnFilterPersonalGroups.Click;
end;

procedure Tarifikation_BtnClearFilterPersonalGroups_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.EditFilterPersonalGroups.Clear;
  Tarifikation.BtnFilterPersonalGroups.Click;
end;
// Группы сотрудников

// Должности
procedure Tarifikation_EditFilterDoljnosty_OnChange (Sender: TObject);
begin
  Tarifikation.BtnFilterDoljnosty.Click;
end;

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
procedure Tarifikation_EditFilterObrazovaniya_OnChange (Sender: TObject);
begin
  Tarifikation.BtnFilterObrazovaniya.Click;
end;

procedure Tarifikation_BtnClearFilterObrazovaniya_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.EditFilterObrazovaniya.Clear;
  Tarifikation.BtnFilterObrazovaniya.Click;
end;
// Образования

// Предметы
procedure Tarifikation_EditFilterPredmety_OnChange (Sender: TObject);
begin
  Tarifikation.BtnFilterPredmety.Click;
end;

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
procedure Tarifikation_EditFilterNadbavky_OnChange (Sender: TObject);
begin
  Tarifikation.BtnFilterNadbavky.Click;
end;

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
procedure Tarifikation_EditFilterDoplaty_OnChange (Sender: TObject);
begin
  Tarifikation.BtnFilterDoplaty.Click;
end;

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
procedure Tarifikation_EditFilterStavky_OnChange (Sender: TObject);
begin
  Tarifikation.BtnFilterStavky.Click;
end;

procedure Tarifikation_CheckFilterStavkaArchived_OnClick (Sender: TObject);
begin
  Tarifikation.BtnFilterStavky.Click;
end;

procedure Tarifikation_BtnClearFilterStavky_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.EditFilterStavky.Clear;
  Tarifikation.CheckFilterStavkaArchived.State := 0;
  Tarifikation.BtnFilterStavky.Click;
end;
// Ставки

// Категории
procedure Tarifikation_EditFilterKategory_OnChange (Sender: TObject);
begin
  Tarifikation.BtnFilterKategory.Click;
end;

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

procedure PrepareSpravochniky;
begin
  Tarifikation.BtnFilterOrganizations.Click;
  Tarifikation.BtnFilterOrgGroups.Click;
  Tarifikation.BtnFilterPersons.Click;
  Tarifikation.BtnFilterPersonalGroups.Click;
  Tarifikation.BtnFilterDoljnosty.Click;
  Tarifikation.BtnFilterObrazovaniya.Click;
  Tarifikation.BtnFilterPredmety.Click;
  Tarifikation.BtnFilterNadbavky.Click;
  Tarifikation.BtnFilterDoplaty.Click;
  Tarifikation.BtnFilterStavky.Click;
  Tarifikation.BtnFilterKategory.Click;
end;

begin
  // MessageDlg('Справочники загружены!', mtInformation, mbOK, 0);
end.
