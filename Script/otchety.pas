uses
  'service.pas',
  'spravochniky.pas',
  'tarifikation.pas';

// Сохранение реквизитов
procedure Tarifikation_ListRequisitePersons_OnChange (Sender: TObject);
var
  itemId : Integer;
begin
  itemId := Tarifikation.ListRequisitePersons.dbItemID;
  if itemId = -1 then
    SQLExecute('update _user set id_person = NULL where id = '+IntToStr(Application.User.id))
  else
    SQLExecute('update _user set id_person = '+IntToStr(itemId)+' where id = '+IntToStr(Application.User.id));
end;

procedure Tarifikation_ListRequisiteDoljnosty_OnChange (Sender: TObject);
var
  itemId : Integer;
begin
  itemId := Tarifikation.ListRequisiteDoljnosty.dbItemID;
  if itemId = -1 then
    SQLExecute('update _user set id_doljnost = NULL where id = '+IntToStr(Application.User.id))
  else
    SQLExecute('update _user set id_doljnost = '+IntToStr(itemId)+' where id = '+IntToStr(Application.User.id));
end;

procedure Tarifikation_ListRequisiteOrganizations_OnChange (Sender: TObject);
var
  itemId : Integer;
begin
  itemId := Tarifikation.ListRequisiteOrganizations.dbItemID;
  if itemId = -1 then
    SQLExecute('update _user set id_organization = NULL where id = '+IntToStr(Application.User.id))
  else
    SQLExecute('update _user set id_organization = '+IntToStr(itemId)+' where id = '+IntToStr(Application.User.id));
end;


// Заполнение реквизитов
procedure FillRequisites;
var
  PersonId, DoljnostId, OrgID : Integer;
  SqlResult : string;
begin
  SqlResult := SQLExecute('select id_person from _user where id = '+ IntToStr(Application.User.id));
  if SqlResult = '' then Tarifikation.ListRequisitePersons.ItemIndex := -1
  else begin
    PersonId := StrToInt(SqlResult);
    Tarifikation.ListRequisitePersons.dbItemID := PersonId;
  end;

  SqlResult := SQLExecute('select id_doljnost from _user where id = '+ IntToStr(Application.User.id));
  if SqlResult = '' then Tarifikation.ListRequisiteDoljnosty.ItemIndex := -1
  else begin
    DoljnostId := StrToInt(SqlResult);
    Tarifikation.ListRequisiteDoljnosty.dbItemID := DoljnostId;
  end;

  SqlResult := SQLExecute('select id_organization from _user where id = '+ IntToStr(Application.User.id));
  if SqlResult = '' then Tarifikation.ListRequisiteOrganizations.ItemIndex := -1
  else begin
    OrgID := StrToInt(SqlResult);
    Tarifikation.ListRequisiteOrganizations.dbItemID := OrgID;
  end;
end;

begin
  // MessageDlg('Отчёты загружен!', mtInformation, mbOK, 0);
end.
