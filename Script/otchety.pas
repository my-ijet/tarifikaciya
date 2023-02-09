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
  SQLQuery('WITH RECURSIVE latest_tar as '+
           '(SELECT id, '+
           '        row_number() OVER (PARTITION by id_person ORDER by date DESC ) as MaxPersonDate '+ // Для отображения самых новых записей по дате
           'FROM tarifikaciya '+
           'where tarifikaciya.id_organization = ' + SelectedOrganization +
           '  and date between '+OtchetStartDate+' and '+OtchetEndDate+' ), '+
           'tar_number as '+
           '(SELECT tarifikaciya.id, '+
           '        ROW_NUMBER() OVER(ORDER by date desc, person.familyname, person.firstname, person.middlename) as num_of_row '+
           'FROM tarifikaciya '+
           'JOIN person on tarifikaciya.id_person = person.id '+
           'JOIN latest_tar ON tarifikaciya.id = latest_tar.id and latest_tar.MaxPersonDate = 1 '+
           'WHERE '+
           '      tarifikaciya.id_organization = '+SelectedOrganization+' '+
           '      and date between '+OtchetStartDate+' and '+OtchetEndDate+' '+
                  MainTarFilter+' ), '+

           'total_tar_comp_stim as '+
           '(SELECT tar_job_summa.id_tarifikaciya, '+
           'total(ifnull(tar_job_viplaty_comp.summa, 0) + (tar_job_summa.nagruzka / 100 * ifnull(tar_job_viplaty_comp.percent, 0))) as total_comp, '+
           'total(ifnull(tar_job_summa.kategory_summa, 0) + ifnull(tar_job_viplaty_stim.summa, 0) + (tar_job_summa.nagruzka / 100 * ifnull(tar_job_viplaty_stim.percent, 0))) as total_stim '+
           'FROM tarifikaciya '+
           'JOIN tar_job_summa on tarifikaciya.id = tar_job_summa.id_tarifikaciya '+
           'LEFT JOIN tar_job_viplaty_comp on tar_job_summa.id = tar_job_viplaty_comp.id '+
           'LEFT JOIN tar_job_viplaty_stim on tar_job_summa.id = tar_job_viplaty_stim.id '+
           'WHERE '+
           '      tarifikaciya.id_organization = '+SelectedOrganization+' '+
           '      and date between '+OtchetStartDate+' and '+OtchetEndDate+' '+
                  MainTarFilter+' '+
           'GROUP by tar_job_summa.id_tarifikaciya) '+

           'SELECT '+
           'tarifikaciya.id, '+
           'organization.short_name as "organization.short_name", '+
           'organization.full_name as "organization.full_name", '+
           'tar_number.num_of_row, '+
           'printf("%s"||char(10)||"%s"||char(10)||"%s", person.familyname, person.firstname, person.middlename) as "person.FIO", '+
           'printf("%s"||char(10)||"%s"||char(10)||"%iлет %iмес", obrazovanie.name, diplom, staj_year, staj_month) as obrazovanie_string, '+

           'tar_job.id as id_tar_job, '+
           'printf("%s"||char(10)||"%s", doljnost.name, predmet.name) as doljnost_string, '+
           'ROUND(tar_job_summa.oklad, 2) as oklad, '+
           'tar_job.clock_coeff, '+
           'printf("%s к."||char(10)||"%iр.", kategory.name, ROUND(tar_job_summa.kategory_summa, 2)) as kategory_string, '+

           'tar_nad_dop.name as nad_dop_name, '+
           'tar_nad_dop.summa + (tar_job_summa.nagruzka / 100 * ifnull(tar_nad_dop.percent, 0)) as nad_dop_summa, '+

           'printf("Нагр.: %s"||char(10)||"Комп.: %s"||char(10)||"Стим.: %s", '+
           'ROUND(tar_job_summa.nagruzka, 2), '+
           'ROUND(ifnull(tar_job_viplaty_comp.summa, 0) + (tar_job_summa.nagruzka / 100 * ifnull(tar_job_viplaty_comp.percent, 0)), 2), '+
           'ROUND(ifnull(tar_job_summa.kategory_summa, 0) + ifnull(tar_job_viplaty_stim.summa, 0) + (tar_job_summa.nagruzka / 100 * ifnull(tar_job_viplaty_stim.percent, 0)), 2) ) as viplaty_string, '+

           'printf("Итого.: %s"||char(10)||"Комп.: %s"||char(10)||"Стим.: %s", '+
           'ROUND(total_tar_job.total_summa, 2), '+
           'ROUND(ifnull(total_tar_comp_stim.total_comp, 0), 2), '+
           'ROUND(ifnull(total_tar_comp_stim.total_stim, 0), 2) ) as itog_zarplata '+

           'FROM tarifikaciya '+
           'LEFT JOIN total_tar_job ON tarifikaciya.id = total_tar_job.id_tarifikaciya '+

           'JOIN organization ON tarifikaciya.id_organization = organization.id '+
           'LEFT JOIN person ON tarifikaciya.id_person = person.id '+
           'LEFT JOIN obrazovanie ON tarifikaciya.id_obrazovanie = obrazovanie.id '+

           'LEFT JOIN tar_job on tarifikaciya.id = tar_job.id_tarifikaciya '+
           'LEFT JOIN tar_nad_dop on tar_job.id = tar_nad_dop.id_tar_job '+
           'LEFT JOIN tar_job_viplaty_comp on tar_job.id = tar_job_viplaty_comp.id '+
           'LEFT JOIN tar_job_viplaty_stim on tar_job.id = tar_job_viplaty_stim.id '+

           'LEFT JOIN doljnost ON tar_job.id_doljnost = doljnost.id '+
           'LEFT JOIN predmet ON tar_job.id_predmet = predmet.id '+
           'LEFT JOIN kategory ON tar_job.id_kategory = kategory.id '+
           'LEFT JOIN stavka ON tar_job.id_stavka = stavka.id '+

           'JOIN tar_job_summa ON tar_job.id = tar_job_summa.id '+
           'LEFT JOIN total_tar_comp_stim on tarifikaciya.id = total_tar_comp_stim.id_tarifikaciya '+
           'JOIN latest_tar ON tarifikaciya.id = latest_tar.id and latest_tar.MaxPersonDate = 1 '+
           'JOIN tar_number on tarifikaciya.id = tar_number.id '+
           'WHERE '+
           '      tarifikaciya.id_organization = '+SelectedOrganization+' '+
                  MainTarFilter+' '+
           'ORDER by tar_number.num_of_row',
           DsOtchetTar);

  // Запрос на получение полей Надбавок тарификации в выбранный период
  SQLQuery('WITH latest_tar as '+
           '(SELECT id, '+
           '        row_number() OVER (PARTITION by id_person ORDER by date DESC ) as MaxPersonDate '+
           'FROM tarifikaciya '+
           'where tarifikaciya.id_organization = ' + SelectedOrganization +
           '  and date between '+OtchetStartDate+' and '+OtchetEndDate+' '+
           ' ) '+ // Для отображения самых новых записей по дате

           'SELECT tar_nadbavka.id, '+
           'tar_nadbavka.id_tarifikaciya, '+
           'tar_job_summa.id as id_tar_job, '+
           'nadbavka.name, '+
           'tar_job_summa.nagruzka / 100 * ifnull(nadbavka.percent, 0) as nadbavka_summa '+
           'FROM tar_nadbavka '+
           'JOIN tarifikaciya ON tar_nadbavka.id_tarifikaciya = tarifikaciya.id '+
           'JOIN tar_job_summa ON tar_nadbavka.id_tarifikaciya = tar_job_summa.id_tarifikaciya '+
           'LEFT JOIN nadbavka ON tar_nadbavka.id_nadbavka = nadbavka.id '+
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
           'ROUND((ifnull(stavka.summa, 0)+(ifnull(stavka.summa, 0) * ifnull(oklad_plus_percent, 0) /100)), 2) as oklad, '+
           'tar_job.clock_coeff, '+
           'ROUND(tar_job_summa.nagruzka, 2) as nagruzka, '+
           'kategory.name as kategory_name, '+
           'ROUND(tar_job_summa.kategory_summa, 2) as kategory_summa, '+
           'ROUND(tar_job_summa.nadbavka_summa, 2) as nadbavka_summa, '+
           'ROUND(tar_job_summa.doplata_summa + tar_job_summa.doplata_persent_summa, 2) as doplata_summa, '+
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
           'ORDER by tar_job_summa.total_summa desc, doljnost.por, doljnost.name ',
           DsOtchetTarJobs);

  // Запрос на получение полей Доплат для должностей тарификации в выбранный период
  SQLQuery('select id from tar_job_doplata '+
           '',
           DsOtchetTarJobDoplaty);

  // Запрос на получение полей Пользователя
  SQLQuery('WITH head as '+
           '(select id_organization, '+
           'doljnost.name as doljnost_org_head, '+
           '(printf("%s %s %s", person.familyname, person.firstname, person.middlename)) as FIO_org_head '+
           'from org_head '+
           'JOIN person on org_head.id_person = person.id '+
           'JOIN doljnost on org_head.id_doljnost = doljnost.id '+
           'JOIN organization on org_head.id_organization = organization.id '+
           'where date(date) <= date('+OtchetEndDate+') ) '+  // Для отображения самых новых записей по дате

           'SELECT '+
           '(printf("%s %s %s", person.familyname, person.firstname, person.middlename)) as FIO_sotrudnika, '+
           'doljnost.name as doljnost_sotrudnika, '+
           'organization.short_name as organizaciya_short_name, '+
           'organization.full_name as organizaciya_full_name, '+
           'head.doljnost_org_head, '+
           'head.FIO_org_head '+
           'FROM _user '+
           'LEFT JOIN person ON _user.id_person = person.id '+
           'LEFT JOIN doljnost ON _user.id_doljnost = doljnost.id '+
           'LEFT JOIN organization ON _user.id_organization = organization.id '+
           'LEFT JOIN head on _user.id_organization = head.id_organization '+
           'WHERE _user.id = '+AppUserID,
           DsUser);


  // Запрос на получение полей Главы организации в выбранный период
  SQLQuery('SELECT '+
           '(printf("%s %s. %s.", person.familyname, substr(person.firstname, 1, 1), substr(person.middlename, 1, 1) )) as FIO, '+
           'doljnost.name as doljnost '+
           'from org_head '+
           'LEFT JOIN person on org_head.id_person = person.id '+
           'LEFT JOIN doljnost on org_head.id_doljnost = doljnost.id '+
           'LEFT JOIN organization on org_head.id_organization = organization.id '+
           'where organization.id = '+SelectedOrganization+' '+
           '  and date(date) <= date('+OtchetEndDate+') '+
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
