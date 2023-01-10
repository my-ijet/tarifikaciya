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
  Tarifikation.ListFilterOrgGroup.Clear;
  Tarifikation.EditFilterOrgShortName.Clear;
  Tarifikation.CheckFilterOrganizationArchived.State := 0;
  Tarifikation.BtnFilterOrganizations.Click;
end;
// Организации

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

begin
  Tarifikation.BtnFilterOrganizations.Click;
  Tarifikation.BtnFilterOrgGroups.Click;
  Tarifikation.BtnFilterPersons.Click;
  Tarifikation.BtnFilterPersonalGroups.Click;
  Tarifikation.BtnFilterDoljnosty.Click;
  Tarifikation.BtnFilterObrazovaniya.Click;
  Tarifikation.BtnFilterPredmety.Click;
  Tarifikation.BtnFilterNadbavkyDoplaty.Click;
  Tarifikation.BtnFilterStavky.Click;
  Tarifikation.BtnFilterKategory.Click;
end.
