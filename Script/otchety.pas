uses
  'service_users.pas',
  'service.pas',
  'spravochniky.pas',
  'tarifikation.pas';

var
  ReportDsOtchetTar,
  ReportDsOtchetTarNadbavky, ReportDsOtchetTarJobs, ReportDsOtchetTarJobDoplaty,
  ReportDsUser, ReportDsOrgHead : TfrxDBDataset;

  DsOtchetTar,
  DsOtchetTarNadbavky, DsOtchetTarJobs, DsOtchetTarJobDoplaty,
  DsUser, DsOrgHead : TDataSet;

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
  MainTarFilter,
  OtchetStartDate, OtchetEndDate : String;
begin
  AppUserID := IntToStr(Application.User.Id);
  SelectedOrganization := Tarifikation.TableOtchetyOrganizations.sqlValue;
  OtchetStartDate := Tarifikation.DateTarOtchetStart.sqlDate;
  OtchetEndDate := Tarifikation.DateTarOtchetEnd.sqlDate;

  case Tarifikation.ListMainTar.dbItemID of
    0..1: begin MainTarFilter := ' ' end;
    2: begin MainTarFilter := ' and tarifikaciya.main = 1 ' end;
    3: begin MainTarFilter := ' and tarifikaciya.main = 0 ' end;
  end;

  // Запрос на получение полей Тарификации в выбранный период
  SQLQuery('WITH latest_tar as '+
           '(SELECT id, '+
           '        row_number() OVER (PARTITION by id_person ORDER by date DESC ) as MaxPersonDate '+
           'FROM tarifikaciya '+
           'where tarifikaciya.id_organization = ' + SelectedOrganization +
           '  and date between '+OtchetStartDate+' and '+OtchetEndDate+' '+
           ' ) '+ // Для отображения самых новых записей по дате

           'SELECT '+
           'tarifikaciya.id, '+
           'organization.short_name as "organization.short_name",'+
           'organization.full_name as "organization.full_name",'+
           'ROW_NUMBER() OVER(ORDER by date desc, person.familyname, person.firstname, person.middlename) as num_of_row, '+
           'strftime("%d.%m.%Y", date) as formated_date, '+
           'printf("%s %s" || char(10) || "%s", person.familyname, person.firstname, person.middlename) as "person.FIO", '+
           'obrazovanie.name as "obrazovanie.name", '+
           'diplom, '+
           'staj_year, '+
           'staj_month, '+
           'ROUND(total_tar_job.total_summa, 2) as total_summa '+
           'FROM tarifikaciya '+
           'JOIN organization ON tarifikaciya.id_organization = organization.id '+
           'LEFT JOIN person ON tarifikaciya.id_person = person.id '+
           'LEFT JOIN obrazovanie ON tarifikaciya.id_obrazovanie = obrazovanie.id '+
           'LEFT JOIN total_tar_job ON tarifikaciya.id = total_tar_job.id_tarifikaciya '+
           'JOIN latest_tar ON tarifikaciya.id = latest_tar.id and latest_tar.MaxPersonDate = 1 '+
           'WHERE '+
           '      tarifikaciya.id_organization = '+SelectedOrganization+' '+
                  MainTarFilter+' '+
           'ORDER by num_of_row',
           DsOtchetTar);

  // Запрос на получение полей Надбавок тарификации в выбранный период
  SQLQuery('WITH latest_tar as '+
           '(SELECT id, '+
           '        row_number() OVER (PARTITION by id_person ORDER by date DESC ) as MaxPersonDate '+
           'FROM tarifikaciya '+
           'where tarifikaciya.id_organization = ' + SelectedOrganization +
           '  and date between '+OtchetStartDate+' and '+OtchetEndDate+' '+
           ' ) '+ // Для отображения самых новых записей по дате

           'SELECT tar_nadbavka.id_tarifikaciya, '+
           'tar_nadbavka.id, '+
           'nadbavka.name, '+
           'tar_nadbavka.nad_percent, '+
           'ROUND(tar_nadbavka_summa.total_nadbavka_summa, 2) as total_nadbavka_summa '+
           'FROM tar_nadbavka '+
           'JOIN tarifikaciya ON tar_nadbavka.id_tarifikaciya = tarifikaciya.id '+
           'LEFT JOIN nadbavka ON tar_nadbavka.id_nadbavka = nadbavka.id '+
           'JOIN tar_nadbavka_summa ON tar_nadbavka.id = tar_nadbavka_summa.id '+
           'JOIN latest_tar ON tarifikaciya.id = latest_tar.id and latest_tar.MaxPersonDate = 1 '+
           'WHERE '+
           '      tarifikaciya.id_organization = '+SelectedOrganization+' '+
                  MainTarFilter+' '+
           '',
           DsOtchetTarNadbavky);

  // Запрос на получение полей Должностей тарификации в выбранный период
  SQLQuery('WITH latest_tar as '+
           '(SELECT id, '+
           '        row_number() OVER (PARTITION by id_person ORDER by date DESC ) as MaxPersonDate '+
           'FROM tarifikaciya '+
           'where tarifikaciya.id_organization = ' + SelectedOrganization +
           '  and date between '+OtchetStartDate+' and '+OtchetEndDate+' '+
           ' ) '+ // Для отображения самых новых записей по дате

           'SELECT '+
           'tar_job.id, '+
           'tar_job.id_tarifikaciya, '+
           'doljnost.name as doljnost_name, '+
           'predmet.name as predmet_name, '+
           'ROUND((ifnull(stavka.summa, 0)+(ifnull(stavka.summa, 0) * ifnull(oklad_plus_percent, 0) /100)), 2), '+
           'tar_job.clock, '+
           'ROUND(tar_job_summa.nagruzka, 2), '+
           'kategory.name, '+
           'ROUND(tar_job_summa.kategory_summa, 2), '+
           'ROUND(tar_job_summa.nadbavka_summa, 2), '+
           'ROUND(tar_job_summa.doplata_summa, 2), '+
           'ROUND(tar_job_summa.doplata_persent_summa, 2), '+
           'ROUND(tar_job_summa.total_percent_summa, 2), '+
           'ROUND(tar_job_summa.total_summa, 2) as itog_summa '+
           'FROM tar_job '+
           'JOIN tarifikaciya ON tar_job.id_tarifikaciya = tarifikaciya.id '+
           'LEFT JOIN doljnost ON tar_job.id_doljnost = doljnost.id '+
           'LEFT JOIN predmet ON tar_job.id_predmet = predmet.id '+
           'LEFT JOIN kategory ON tar_job.id_kategory = kategory.id '+
           'LEFT JOIN stavka ON tar_job.id_stavka = stavka.id '+
           'LEFT JOIN tar_job_summa ON tar_job.id = tar_job_summa.id '+
           'JOIN latest_tar ON tarifikaciya.id = latest_tar.id and latest_tar.MaxPersonDate = 1 '+
           'WHERE '+
           '      tarifikaciya.id_organization = '+SelectedOrganization+' '+
                  MainTarFilter+' '+
           'ORDER by doljnost.por, doljnost.name ',
           DsOtchetTarJobs);

  // Запрос на получение полей Доплат для должностей тарификации в выбранный период
  SQLQuery('select id from tar_job_doplata '+
           '',
           DsOtchetTarJobDoplaty);

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
  ReportDsOtchetTar := TfrxDBDataset.Create(Tarifikation);
  ReportDsOtchetTar.UserName := 'Tarifikaciya';
  ReportDsOtchetTar.CloseDataSource := True;
  ReportDsOtchetTar.OpenDataSource := True;
  ReportDsOtchetTar.DataSet := DsOtchetTar;

  ReportDsOtchetTarNadbavky := TfrxDBDataset.Create(Tarifikation);
  ReportDsOtchetTarNadbavky.UserName := 'TarNadbavky';
  ReportDsOtchetTarNadbavky.CloseDataSource := True;
  ReportDsOtchetTarNadbavky.OpenDataSource := True;
  ReportDsOtchetTarNadbavky.DataSet := DsOtchetTarNadbavky;

  ReportDsOtchetTarJobs := TfrxDBDataset.Create(Tarifikation);
  ReportDsOtchetTarJobs.UserName := 'TarJobs';
  ReportDsOtchetTarJobs.CloseDataSource := True;
  ReportDsOtchetTarJobs.OpenDataSource := True;
  ReportDsOtchetTarJobs.DataSet := DsOtchetTarJobs;

  ReportDsOtchetTarJobDoplaty := TfrxDBDataset.Create(Tarifikation);
  ReportDsOtchetTarJobDoplaty.UserName := 'TarJobDoplaty';
  ReportDsOtchetTarJobDoplaty.CloseDataSource := True;
  ReportDsOtchetTarJobDoplaty.OpenDataSource := True;
  ReportDsOtchetTarJobDoplaty.DataSet := DsOtchetTarJobDoplaty;

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

  Tarifikation.frxReport.DataSets.Add(ReportDsOtchetTar);
  Tarifikation.frxReport.DataSets.Add(ReportDsOtchetTarNadbavky);
  Tarifikation.frxReport.DataSets.Add(ReportDsOtchetTarJobs);
  Tarifikation.frxReport.DataSets.Add(ReportDsOtchetTarJobDoplaty);
  Tarifikation.frxReport.DataSets.Add(ReportDsUser);
  Tarifikation.frxReport.DataSets.Add(ReportDsOrgHead);


  ReportDsOtchetTar.DataSet.Close;
  ReportDsOtchetTarNadbavky.DataSet.Close;
  ReportDsOtchetTarJobs.DataSet.Close;
  ReportDsOtchetTarJobDoplaty.DataSet.Close;
  ReportDsUser.DataSet.Close;
  ReportDsOrgHead.DataSet.Close;

  Tarifikation.frxReport.Variables.Clear;
  // Tarifikation.frxReport.Variables[' ' + 'My Category 1'] := Null;
  Tarifikation.frxReport.Variables['OtchetEndDate'] := ''''+FormatDateTime('DD.MM.YYYY', Tarifikation.DateTarOtchetEnd.DateTime)+'''';

  Tarifikation.frxReport.PrepareReport;
end;

procedure ClearAfterReport;
begin
  DsOtchetTar.Free;           ReportDsOtchetTar.Free;
  DsOtchetTarNadbavky.Free;   ReportDsOtchetTarNadbavky.Free;
  DsOtchetTarJobs.Free;       ReportDsOtchetTarJobs.Free;
  DsOtchetTarJobDoplaty.Free; ReportDsOtchetTarJobDoplaty.Free;
  DsUser.Free;                ReportDsUser.Free;
  DsOrgHead.Free;             ReportDsOrgHead.Free;

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

procedure Tarifikation_TableOtchetyOrganizations_OnCellDoubleClick (Sender: TObject; ACol, ARow: Integer);
begin
  Tarifikation.BtnOtchet.Click;
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
  // if Tarifikation.TableOtchetyOrganizations.CanFocus then
  //   Tarifikation.TableOtchetyOrganizations.SetFocus;
end;


begin
  Tarifikation.ListMainTar.dbAddRecord(1, 'Все');
  Tarifikation.ListMainTar.dbAddRecord(2, 'Основные');
  Tarifikation.ListMainTar.dbAddRecord(3, 'Дополнительные');
  Tarifikation.ListMainTar.ItemIndex := 2;
  // MessageDlg('Отчёты загружен!', mtInformation, mbOK, 0);
end.
