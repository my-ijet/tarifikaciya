

// Форма тарификации, подставляется
// ранее выбранная организация и текущая дата тарификации
procedure frmEditTarifikation_OnShow (Sender: TObject; Action: string);
begin
  frmEditTarifikation.ListOrganizations.dbItemID := Tarifikation.TableTarOrganizations.dbItemID;

  if not frmEditTarifikation.DateTarDate.Checked then
    frmEditTarifikation.DateTarDate.DateTime := Tarifikation.DateFilterTarDate.DateTime;

  frmEditTarifikation.DateTarDate.MinDate := Tarifikation.DateTarStart.DateTime;
  frmEditTarifikation.DateTarDate.MaxDate := Tarifikation.DateTarEnd.DateTime;
end;

// Форма должности тарификации, подставляются
// организация, сотрудник и дата тарификации
procedure frmEditTarJob_OnShow (Sender: TObject; Action: string);
var
  TarID,
  TarOrganization, TarPerson, TarDate : String;
begin
  TarID := IntToStr(Tarifikation.TableTarifikaciya.dbItemID);
  TarOrganization := SQLExecute('select short_name from tarifikaciya '+
                                'join organization on tarifikaciya.id_organization = organization.id '+
                                'where tarifikaciya.id = '+TarID);
  TarPerson := SQLExecute('select printf("%i - %s %s %s", person.id, person.familyname, person.firstname, person.middlename) '+
                          'from tarifikaciya '+
                          'join person on tarifikaciya.id_person = person.id '+
                          'where tarifikaciya.id = '+TarID);
  TarDate := SQLExecute('select date from tarifikaciya '+
                        'where tarifikaciya.id = '+TarID);

  frmEditTarJob.TarOrganization.Text := TarOrganization;
  frmEditTarJob.TarPerson.Text := TarPerson;
  frmEditTarJob.TarDate.DateTime := SQLDateTimeToDateTime(TarDate);
end;

begin
  // MessageDlg('Формы тарификации загружены!', mtInformation, mbOK, 0);
end.
