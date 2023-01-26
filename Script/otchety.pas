﻿uses
  'service_users.pas',
  'service.pas',
  'spravochniky.pas',
  'tarifikation.pas';

var
  ReportDsOtchet, ReportDsUser, ReportDsOrgHead : TfrxDBDataset;
  DsOtchet, DsUser, DsOrgHead : TDataSet;

procedure PrepareOtchety;
begin
  Tarifikation.ListFilterOtchetyOrganizations.dbItemId := Tarifikation.ListFilterTarOrganizations.dbItemId;
  Tarifikation.BtnFilterOtchetyOrganizations.Click;
  Tarifikation.TableOtchetyOrganizations.dbItemId := Tarifikation.TableTarOrganizations.dbItemId;

  FillTarOtchetPeriod;
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

procedure PrepareReport;
var
  AppUserID, SelectedOrganization,
  OtchetStartDate, OtchetEndDate : String;
begin
  AppUserID := IntToStr(Application.User.Id);
  SelectedOrganization := Tarifikation.TableOtchetyOrganizations.sqlValue;
  OtchetStartDate := Tarifikation.DateTarOtchetStart.sqlDate;
  OtchetEndDate := Tarifikation.DateTarOtchetEnd.sqlDate;

  // Запрос на получение полей Тарификации в выбранный период
  SQLQuery('WITH latest_tar as '+
           '(SELECT id, '+
           '        row_number() OVER (PARTITION by id_person ORDER by date DESC ) as MaxPersonDate '+
           'FROM tarifikaciya '+
           'where tarifikaciya.id_organization = ' + SelectedOrganization +
           '  and date between '+OtchetStartDate+' and '+OtchetEndDate+' '+
           ' ) '+ // Для отображения самых новых записей по дате

           'SELECT '+
           'organization.short_name as "organization.short_name",'+
           'organization.full_name as "organization.full_name",'+
           'tarifikaciya.id, '+
           'ROW_NUMBER() OVER(ORDER by person.familyname, person.firstname, person.middlename) as num_of_row, '+
           'date, '+
           'printf("%s %s" || char(10) || "%s", person.familyname, person.firstname, person.middlename) as "person.FIO", '+
           'obrazovanie.name as "obrazovanie.name", '+
           'diplom, '+
           'staj_year, '+
           'staj_month, '+
           'total_tar_job.total_summa '+
           'FROM tarifikaciya '+
           'JOIN organization ON tarifikaciya.id_organization = organization.id '+
           'JOIN person ON tarifikaciya.id_person = person.id '+
           'JOIN obrazovanie ON tarifikaciya.id_obrazovanie = obrazovanie.id '+
           'LEFT JOIN total_tar_job ON tarifikaciya.id = total_tar_job.id_tarifikaciya '+
           'JOIN latest_tar ON tarifikaciya.id = latest_tar.id and latest_tar.MaxPersonDate = 1 '+
           'WHERE '+
           '      tarifikaciya.id_organization = '+SelectedOrganization+' '+
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
           'doljnost.name as doljnost '+
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

  Tarifikation.frxReport.DataSets.Add(ReportDsOtchet);
  Tarifikation.frxReport.DataSets.Add(ReportDsUser);
  Tarifikation.frxReport.DataSets.Add(ReportDsOrgHead);

  ReportDsOtchet.DataSet.Close;
  ReportDsUser.DataSet.Close;
  ReportDsOrgHead.DataSet.Close;

  Tarifikation.frxReport.Variables.Clear;
  // Tarifikation.frxReport.Variables[' ' + 'My Category 1'] := Null;
  Tarifikation.frxReport.Variables['OtchetEndDate'] := ''''+FormatDateTime('DD.MM.YYYY', Tarifikation.DateTarOtchetEnd.DateTime)+'''';

  Tarifikation.frxReport.PrepareReport;
end;

procedure ClearAfterReport;
begin
  DsOtchet.Free;  ReportDsOtchet.Free;
  DsUser.Free;    ReportDsUser.Free;
  DsOrgHead.Free; ReportDsOrgHead.Free;

  Tarifikation.frxReport.Clear;
  Tarifikation.frxReport.DataSets.Clear;
  Tarifikation.frxReport.Variables.Clear;
end;

// Кнопки отчёта
procedure Tarifikation_BtnOtchet_OnClick (Sender: TObject; var Cancel: boolean);
begin
  PrepareReport;
end;
procedure Tarifikation_BtnOtchet_OnAfterClick (Sender: TObject; var Cancel: boolean);
begin
  ClearAfterReport;
end;

procedure Tarifikation_BtnEditOtchet_OnClick (Sender: TObject; var Cancel: boolean);
begin
  PrepareReport;
end;
procedure Tarifikation_BtnEditOtchet_OnAfterClick (Sender: TObject; var Cancel: boolean);
begin
  ClearAfterReport;
end;

procedure Tarifikation_BtnQuickPrintOtchet_OnClick (Sender: TObject; var Cancel: boolean);
begin
  PrepareReport;
end;
procedure Tarifikation_BtnQuickPrintOtchet_OnAfterClick (Sender: TObject);
begin
  ClearAfterReport;
end;

procedure Tarifikation_BtnOtchetToXLS_OnClick (Sender: TObject; var Cancel: boolean);
begin
  PrepareReport;
end;
procedure Tarifikation_BtnOtchetToXLS_OnAfterClick (Sender: TObject);
begin
  ClearAfterReport;
end;

procedure Tarifikation_BtnOtchetToODS_OnClick (Sender: TObject; var Cancel: boolean);
begin
  PrepareReport;
end;
procedure Tarifikation_BtnOtchetToODS_OnAfterClick (Sender: TObject);
begin
  ClearAfterReport;
end;

procedure Tarifikation_BtnOtchetToPDF_OnClick (Sender: TObject; var Cancel: boolean);
begin
  PrepareReport;
end;
procedure Tarifikation_BtnOtchetToPDF_OnAfterClick (Sender: TObject);
begin
  ClearAfterReport;
end;
// Кнопки отчёта

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
  // if Tarifikation.TableOtchetyOrganizations.CanFocus then
  //   Tarifikation.TableOtchetyOrganizations.SetFocus;
end;


begin
  // MessageDlg('Отчёты загружен!', mtInformation, mbOK, 0);
end.
