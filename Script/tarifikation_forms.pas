
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

procedure frmEditTarJob_CalculateAllFields;
var
  OkladId, OkladSumma : String;
  Oklad, OkladPlusPercent, TotalOklad,
  ClockCoeff,
  Nagruzka,
  KategoryCoeff, AllCoeff,
  Stavka : Double = 0;
begin
  OkladId := IntToStr(frmEditTarJob.ListOklady.dbItemID);
  OkladSumma := SQLExecute('select summa from stavka '+
                           'where id = '+OkladId);
  if OkladSumma <> '' then
    Oklad := StrToFloat(OkladSumma);
  if frmEditTarJob.EditOkladPlusPercent.Text <> '' then
    OkladPlusPercent := StrToFloat(frmEditTarJob.EditOkladPlusPercent.Text);
  TotalOklad := Oklad + (Oklad / 100 * OkladPlusPercent);

  if frmEditTarJob.EditClockCoeff.Text <> '' then
    ClockCoeff := StrToFloat(frmEditTarJob.EditClockCoeff.Text);
  Nagruzka := TotalOklad * ClockCoeff;

  if frmEditTarJob.EditKategoryCoeff.Text <> '' then
    KategoryCoeff := StrToFloat(frmEditTarJob.EditKategoryCoeff.Text);
  if frmEditTarJob.EditAllCoeff.Text <> '' then
    AllCoeff := StrToFloat(frmEditTarJob.EditAllCoeff.Text);
  Stavka := Nagruzka * (KategoryCoeff+AllCoeff);

  frmEditTarJob.TotalOklad.Text := FormatFloat('0.##', TotalOklad);
  frmEditTarJob.Nagruzka.Text := FormatFloat('0.##', Nagruzka);
  frmEditTarJob.Stavka.Text := FormatFloat('0.##', Stavka);
end;

procedure frmEditTarJob_CalculateClockCoeff;
var
  DoljnostId, DoljnostClock : String;
  Clock, ClockCoeff : Double = 0;
begin
  DoljnostId := IntToStr(frmEditTarJob.ListDoljnosty.dbItemID);
  DoljnostClock := SQLExecute('select clock from doljnost '+
                              'where id = '+DoljnostId);
  if frmEditTarJob.EditClock.Text <> '' then
    Clock := StrToFloat(frmEditTarJob.EditClock.Text);
  if DoljnostClock <> '' then
    ClockCoeff := Clock / StrToFloat(DoljnostClock);

  frmEditTarJob.EditClockCoeff.Text := FormatFloat('0.##', ClockCoeff);

  frmEditTarJob_CalculateAllFields;
end;

procedure frmEditTarJob_ListOklady_OnChange (Sender: TObject);
begin
  frmEditTarJob_CalculateAllFields;
end;

procedure frmEditTarJob_EditOkladPlusPercent_OnChange (Sender: TObject);
begin
  frmEditTarJob_CalculateAllFields;
end;

procedure frmEditTarJob_EditClock_OnChange (Sender: TObject);
begin
  frmEditTarJob_CalculateClockCoeff;
end;

procedure frmEditTarJob_EditClockCoeff_OnChange (Sender: TObject);
begin
  frmEditTarJob_CalculateAllFields;
end;

procedure frmEditTarJob_ListPredmety_OnChange (Sender: TObject);
begin end;

procedure frmEditTarJob_ListDoljnosty_OnChange (Sender: TObject);
begin
  frmEditTarJob_CalculateClockCoeff;
end;

procedure frmEditTarJob_ListKategory_OnChange (Sender: TObject);
var
  KategoryID, KategoryCoeff : String;
begin
  KategoryID := IntToStr(frmEditTarJob.ListKategory.dbItemID);
  KategoryCoeff := SQLExecute('select coeff from kategory '+
                          'where id = '+KategoryID);
  frmEditTarJob.EditKategoryCoeff.Text := KategoryCoeff;
  frmEditTarJob_CalculateAllFields;
end;

procedure frmEditTarJob_EditKategoryCoeff_OnChange (Sender: TObject);
begin
  frmEditTarJob_CalculateAllFields;
end;

procedure frmEditTarJob_EditAllCoeff_OnChange (Sender: TObject);
begin
  frmEditTarJob_CalculateAllFields;
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
