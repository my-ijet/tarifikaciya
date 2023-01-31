
// Форма тарификации
// подставляетсяранее выбранная организация и текущая дата тарификации
procedure frmEditTarifikation_OnShow (Sender: TObject; Action: string);
begin
  if frmEditTarifikation.dbAction = 'NewRecord' then begin
    frmEditTarifikation.ListOrganizations.dbItemID := Tarifikation.TableTarOrganizations.dbItemID;
    frmEditTarifikation.DateTarDate.DateTime := Tarifikation.DateTarStart.DateTime;
  end;
end;

procedure frmEditTarifikation_BtnSaveTarifikaciya_OnAfterClick (Sender: TObject; var Cancel: boolean);
begin
  if frmEditTarifikation.dbAction = 'NewRecord' then begin
    Tarifikation.TableTarifikaciya.SelectedRow := -1;
  end;
  Tarifikation.BtnFilterTarifikaciya.Click;
end;
// Форма тарификации


// Форма Надбавки тарификации
//
procedure frmEditTarNadbavka_OnShow (Sender: TObject; Action: string);
begin
  if frmEditTarNadbavka.dbAction = 'NewRecord' then begin
  end;
end;

procedure frmEditTarNadbavka_ListNadbavky_OnChange (Sender: TObject);
var
  NadID, NadPercent : String;
begin
  NadID := IntToStr(frmEditTarNadbavka.ListNadbavky.dbItemID);
  NadPercent := SQLExecute('select percent from nadbavka '+
                          'where id = '+NadID);
  frmEditTarNadbavka.EditNadPercent.Text := NadPercent;
end;

procedure frmEditTarNadbavka_BtnSaveTarNadbavka_OnAfterClick (Sender: TObject; var Cancel: boolean);
begin
  if frmEditTarNadbavka.dbAction = 'NewRecord' then begin
    Tarifikation.TableTarNadbavky.SelectedRow := -1;
  end;
  Tarifikation.BtnFilterTarNadbavky.Click;
end;
// Форма Надбавки тарификации


// Форма должности тарификации
// подставляются организация, сотрудник и дата тарификации
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

procedure frmEditTarJob_BtnSaveTarJob_OnAfterClick (Sender: TObject; var Cancel: boolean);
begin
  if frmEditTarJob.dbAction = 'NewRecord' then begin
    Tarifikation.TableTarJobs.SelectedRow := -1;
  end;
  Tarifikation.BtnFilterTarJobs.Click;
end;
// Форма должности тарификации


// Форма Доплаты должности тарификации
//
procedure frmEditTarJobDoplata_OnShow (Sender: TObject; Action: string);
begin
  if frmEditTarJobDoplata.dbAction = 'NewRecord' then begin
  end;
end;

procedure frmEditTarJobDoplata_ListDoplaty_OnChange (Sender: TObject);
var
  DopID, DopPercent, DopSumma : String;
begin
  DopID := IntToStr(frmEditTarJobDoplata.ListDoplaty.dbItemID);
  DopPercent := SQLExecute('select percent from doplata '+
                           'where id = '+DopID);
  DopSumma := SQLExecute('select summa from doplata '+
                         'where id = '+DopID);
  frmEditTarJobDoplata.EditDopPercent.Text := DopPercent;
  frmEditTarJobDoplata.EditDopSumma.Text := DopSumma;
end;

procedure frmEditTarJobDoplata_BtnSaveTarJobDoplata_OnAfterClick (Sender: TObject; var Cancel: boolean);
begin
  if frmEditTarJobDoplata.dbAction = 'NewRecord' then begin
    Tarifikation.TableTarJobDoblaty.SelectedRow := -1;
  end;
  Tarifikation.BtnFilterTarJobs.Click;
end;
// Форма Доплаты должности тарификации


begin
  // MessageDlg('Формы тарификации загружены!', mtInformation, mbOK, 0);
end.
