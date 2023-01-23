uses
  'service_users.pas',
  'service.pas',
  'spravochniky.pas',
  'tarifikation.pas';

procedure PrepareOtchety;
begin
  Tarifikation.ListFilterOtchetyOrganizations.dbItemId := Tarifikation.ListFilterTarOrganizations.dbItemId;
  Tarifikation.BtnFilterOtchetyOrganizations.Click;
  Tarifikation.TableOtchetyOrganizations.dbItemId := Tarifikation.TableTarOrganizations.dbItemId;
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
  Tarifikation.DateTarOtchetEnd.DateTime := Tarifikation.DateTarEnd.DateTime;
end;

procedure ShowOtchet(EditMode : boolean = False);
var
  ReportDsOtchet, ReportDsUser, ReportDsOrgHead : TfrxDBDataset;
  DsOtchet, DsUser, DsOrgHead : TDataSet;
  PathToReportFile,
  AppUserID, SelectedOrganization,
  OtchetStartDate, OtchetEndDate : String;
begin
  PathToReportFile := ExtractFilePath(Application.ExeName)+'Report\report.fr3';
  AppUserID := IntToStr(Application.User.Id);
  SelectedOrganization := Tarifikation.TableOtchetyOrganizations.sqlValue;
  OtchetStartDate := Tarifikation.DateTarOtchetStart.sqlDate;
  OtchetEndDate := Tarifikation.DateTarOtchetEnd.sqlDate;

  // Запрос на получение полей Тарификации в выбранный период
  SQLQuery('SELECT '+
           // 'organization.short_name as "organization.short_name",'+
           // 'organization.full_name as "organization.full_name",'+
           'tarifikaciya.id, '+
           'date, '+
           'printf("%s %s'+Chr(10)+'%s", person.familyname, person.firstname, person.middlename) as "person.FIO", '+
           'obrazovanie.name as "obrazovanie.name", '+
           'diplom, '+
           'staj_year, '+
           'staj_month, '+
           'ROW_NUMBER() OVER(ORDER by person.familyname, person.firstname, person.middlename) as num_of_row '+
           'FROM tarifikaciya, '+
           '     (select id, max(date) from tarifikaciya '+
           '      where date between '+OtchetStartDate+' and '+OtchetEndDate+' '+
           '      group by id_person ORDER by date desc) as latest_tar '+         // Для отображения самых новых записей по дате
           'JOIN organization ON tarifikaciya.id_organization = organization.id '+
           'JOIN person ON tarifikaciya.id_person = person.id '+
           'JOIN obrazovanie ON tarifikaciya.id_obrazovanie = obrazovanie.id '+
           'WHERE '+
           '      organization.id = '+SelectedOrganization+' '+
           '  and tarifikaciya.id = latest_tar.id '+
           'ORDER by num_of_row',
           DsOtchet);

  // Запрос на получение полей Пользователя
  SQLQuery('WITH head as '+
           '(select id_organization, '+
           ' doljnost.name as doljnost_org_head, '+
           ' (printf("%s %s %s", person.familyname, person.firstname, person.middlename)) as FIO_org_head '+
           ' from org_head '+
           ' join person on org_head.id_person = person.id '+
           ' join doljnost on org_head.id_doljnost = doljnost.id '+
           ' join organization on org_head.id_organization = organization.id '+
           ' where date <= '+OtchetEndDate+' '+
           ' ORDER by date desc limit 1 ) '+  // Для отображения самых новых записей по дате

           'SELECT '+
           '(printf("%s %s %s", person.familyname, person.firstname, person.middlename)) as FIO_sotrudnika, '+
           'doljnost.name as doljnost_sotrudnika, '+
           'organization.short_name as organizaciya_short_name, '+
           'organization.full_name as organizaciya_full_name, '+
           'head.doljnost_org_head, '+
           'head.FIO_org_head '+
           'FROM _user, head '+
           'JOIN person ON _user.id_person = person.id '+
           'JOIN doljnost ON _user.id_doljnost = doljnost.id '+
           'JOIN organization ON _user.id_organization = organization.id '+
           'WHERE head.id_organization = _user.id_organization'+
           '  and _user.id = '+AppUserID,
           DsUser);


  // Запрос на получение полей Главы организации в выбранный период
  SQLQuery('SELECT '+
           '(printf("%s %s %s", person.familyname, person.firstname, person.middlename)) as FIO, '+
           'doljnost.name as doljnost, '+
           'organization.short_name as organizaciya_short_name, '+
           'organization.full_name as organizaciya_full_name '+
           'from org_head '+
           'join person on org_head.id_person = person.id '+
           'join doljnost on org_head.id_doljnost = doljnost.id '+
           'join organization on org_head.id_organization = organization.id '+
           'where organization.id = '+SelectedOrganization+' '+
           '  and date <= '+OtchetEndDate+' '+
           'ORDER by date desc limit 1 ',  // Для отображения самых новых записей по дате
           DsOrgHead);

// Переносим полученные датасеты в отчет
  ReportDsOtchet := TfrxDBDataset.Create(Tarifikation);
  ReportDsOtchet.UserName := 'Tarifikaciya';
  ReportDsOtchet.CloseDataSource := True;
  ReportDsOtchet.OpenDataSource := True;
  ReportDsOtchet.DataSet := DsOtchet;

  ReportDsUser := TfrxDBDataset.Create(Tarifikation);
  ReportDsUser.UserName := 'User';
  ReportDsUser.CloseDataSource := True;
  ReportDsUser.OpenDataSource := True;
  ReportDsUser.DataSet := DsUser;

  ReportDsOrgHead := TfrxDBDataset.Create(Tarifikation);
  ReportDsOrgHead.UserName := 'OrgHead';
  ReportDsOrgHead.CloseDataSource := True;
  ReportDsOrgHead.OpenDataSource := True;
  ReportDsOrgHead.DataSet := DsOrgHead;

  Tarifikation.frxReport.Clear;
  Tarifikation.frxReport.DataSets.Clear;
  Tarifikation.frxReport.DataSets.Add(ReportDsOtchet);
  Tarifikation.frxReport.DataSets.Add(ReportDsUser);
  Tarifikation.frxReport.DataSets.Add(ReportDsOrgHead);

  if EditMode then begin
  //DESIGN MODE
    Tarifikation.frxReport.LoadFromFile(PathToReportFile);
    Tarifikation.frxReport.DesignReport;
  end else begin
  //PREVIEW MODE
    ReportDsOtchet.DataSet.Close;
    ReportDsUser.DataSet.Close;
    ReportDsOrgHead.DataSet.Close;
    Tarifikation.frxReport.LoadFromFile(PathToReportFile);
    Tarifikation.frxReport.ShowReport;
  end;

  DsOtchet.Free;  ReportDsOtchet.Free;
  DsUser.Free;    ReportDsUser.Free;
  DsOrgHead.Free; ReportDsOrgHead.Free;

  Tarifikation.frxReport.Clear;
  Tarifikation.frxReport.DataSets.Clear;
end;


procedure Tarifikation_BtnOtchet_OnClick (Sender: TObject; var Cancel: boolean);
begin
  ShowOtchet;
end;

procedure Tarifikation_BtnEditOtchet_OnClick (Sender: TObject; var Cancel: boolean);
begin
  ShowOtchet(True);
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

procedure Tarifikation_TableOtchetyOrganizations_OnMouseEnter (Sender: TObject);
begin
  if Tarifikation.TableOtchetyOrganizations.CanFocus then
    Tarifikation.TableOtchetyOrganizations.SetFocus;
end;


begin
  // MessageDlg('Отчёты загружен!', mtInformation, mbOK, 0);
end.
