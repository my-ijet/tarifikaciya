uses
  'service_users.pas',
  'service.pas',
  'spravochniky.pas',
  'tarifikation.pas';

procedure PrepareOtchety;
begin
  FillRequisites;
  FillTarOtchetPeriod;
end;

// Сохранение реквизитов
procedure Tarifikation_ListRequisitePersons_OnChange (Sender: TObject);
var
  itemId : String;
begin
  itemId := Tarifikation.ListRequisitePersons.sqlValue;
  SQLExecute('update _user set id_person = '+itemId+' where id = '+IntToStr(Application.User.id));
end;

procedure Tarifikation_ListRequisiteDoljnosty_OnChange (Sender: TObject);
var
  itemId : String;
begin
  itemId := Tarifikation.ListRequisiteDoljnosty.sqlValue;
  SQLExecute('update _user set id_doljnost = '+itemId+' where id = '+IntToStr(Application.User.id));
end;

procedure Tarifikation_ListRequisiteOrganizations_OnChange (Sender: TObject);
var
  itemId : String;
begin
  itemId := Tarifikation.ListRequisiteOrganizations.sqlValue;
  SQLExecute('update _user set id_organization = '+itemId+' where id = '+IntToStr(Application.User.id));
end;


// Заполнение реквизитов
procedure FillRequisites;
begin
  SetCurrentAppUserFieldToList(Tarifikation.ListRequisitePersons, 'id_person');
  SetCurrentAppUserFieldToList(Tarifikation.ListRequisiteDoljnosty, 'id_doljnost');
  SetCurrentAppUserFieldToList(Tarifikation.ListRequisiteOrganizations, 'id_organization');
end;

procedure FillTarOtchetPeriod;
begin
  Tarifikation.DateTarOtchetStart.DateTime := Tarifikation.DateTarStart.DateTime;
  Tarifikation.DateTarOtchetEnd.DateTime := Tarifikation.DateFilterTarDate.DateTime;
end;

begin
  // MessageDlg('Отчёты загружен!', mtInformation, mbOK, 0);
end.
