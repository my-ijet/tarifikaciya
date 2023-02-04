uses
  'service.pas',
  'tarifikation_forms.pas',
  'spravochniky.pas',
  'otchety.pas';

// Загрузка выбранной группы организаций и выбранной организации
procedure FillCurAppUserSelections;
var
  SelectedOrgId: String;
begin
  SetCurrentAppUserFieldToList(Tarifikation.ListFilterTarOrganizations, 'id_org_group');
  Tarifikation.BtnFilterTarOrganizations.Click;

  SelectedOrgId := SQLExecute('select id_organization1 from _user where id = '+IntToStr(Application.User.id));
  if SelectedOrgId <> '' then
    Tarifikation.TableTarOrganizations.dbItemID := StrToInt(SelectedOrgId);
  Tarifikation.BtnFilterTarifikaciya.Click;
end;

// Фильтр списка организаций Тарификации
procedure Tarifikation_ListFilterTarOrganizations_OnChange (Sender: TObject);
var
  itemId : String;
begin
// Сохранение выбранной группы организаций
  itemId := Tarifikation.ListFilterTarOrganizations.sqlValue;
  SQLExecute('update _user set id_org_group = '+itemId+' where id = '+IntToStr(Application.User.id));
end;
procedure Tarifikation_BtnFilterTarOrganizations_OnAfterChange (Sender: TObject; var Cancel: boolean);
begin
  // Очищаем зависимые таблицы когда не выбрана запись
  if Tarifikation.TableTarOrganizations.SelectedRow = -1 then begin
    Tarifikation.TableTarifikaciya.ClearRows;
    Tarifikation.TableTarNadbavky.ClearRows;
    Tarifikation.TableTarJobs.ClearRows;
    Tarifikation.TableTarJobDoblaty.ClearRows;
    Exit;
  end;
end;

procedure Tarifikation_TableTarOrganizations_OnCellClick (Sender: TObject; ACol, ARow: Integer);
var
  itemId : Integer;
begin
// Сохранение выбранной организации
  itemId := Tarifikation.TableTarOrganizations.dbItemID;
  SQLExecute('update _user set id_organization1 = '+IntToStr(itemId)+' where id = '+IntToStr(Application.User.id));

  Tarifikation.BtnFilterTarifikaciya.Click;
end;


// Клик на фильтр таблицы Тарификации
procedure Tarifikation_BtnFilterTarifikaciya_OnClick (Sender: TObject; var Cancel: boolean);
var
  SqlSelect, SqlFilter : String;
  SelectedOrganization, SelectedPerson,
  SelectedObrazovanie, SelectedStajYear,
  CurrentDate, StartDate, EndDate : String = ' ';
begin
  StartDate := Tarifikation.DateTarStart.sqlDate;
  EndDate := Tarifikation.DateTarEnd.sqlDate;

  SelectedOrganization := Tarifikation.TableTarOrganizations.sqlValue;

  if Tarifikation.ListFilterTarFIO.dbItemID > 0 then begin
    SelectedPerson := ' and person.id = '+Tarifikation.ListFilterTarFIO.sqlValue;
  end;

  if Tarifikation.ListFilterTarObrazovanie.dbItemID > 0 then begin
    SelectedObrazovanie := ' and obrazovanie.id = '+Tarifikation.ListFilterTarObrazovanie.sqlValue;
  end;

  if Tarifikation.EditFilterTarStaj.Text <> '' then begin
    SelectedStajYear := ' and staj_year = '+Tarifikation.EditFilterTarStaj.sqlValue;
  end;

  if Tarifikation.DateFilterTarDate.Checked then begin
    CurrentDate := ' and date(date) = date('+Tarifikation.DateFilterTarDate.sqlDate+') ';
  end;

  if Tarifikation.CheckShowAllTarifikaions.Checked then begin
    SqlFilter := ''   // Для отображения всех записей
  end else begin
    SqlFilter := ' and latest_tar.MaxPersonDate = 1 ' // Для отображения самых новых записей по дате
  end;

  SqlSelect := 'WITH latest_tar as '+
               '(SELECT id, '+
               '      row_number() OVER (PARTITION by id_person ORDER by date DESC ) as MaxPersonDate '+
               'FROM tarifikaciya '+
               'where tarifikaciya.id_organization = ' + SelectedOrganization +
               '  and date between '+StartDate+' and '+EndDate+' ) '+
           'SELECT '+
           'tarifikaciya.id, '+
           'strftime("%d.%m.%Y", date) as formated_date, '+
           'person.FIO, '+
           'obrazovanie.name as "obrazovanie.name", '+
           'staj_year, '+
           'staj_month, '+
           'ROUND(total_tar_job.total_summa, 2) '+
           'FROM tarifikaciya '+
           'JOIN organization ON tarifikaciya.id_organization = organization.id '+
           'LEFT JOIN person ON tarifikaciya.id_person = person.id '+
           'LEFT JOIN obrazovanie ON tarifikaciya.id_obrazovanie = obrazovanie.id '+
           'LEFT JOIN total_tar_job ON tarifikaciya.id = total_tar_job.id_tarifikaciya '+
           'JOIN latest_tar ON tarifikaciya.id = latest_tar.id '+SqlFilter+
           'WHERE '+
           '      tarifikaciya.id_organization = ' + SelectedOrganization +
                  SelectedPerson +
                  SelectedObrazovanie +
                  SelectedStajYear +
                  CurrentDate +' '+
           'ORDER by date desc, "person.FIO" ';

  Tarifikation.BtnFilterTarifikaciya.dbSQL := SqlSelect;
end;
procedure Tarifikation_BtnFilterTarifikaciya_OnAfterClick (Sender: TObject; var Cancel: boolean);
begin
   // Скрыть колонку ID
  Tarifikation.TableTarifikaciya.Columns[0].Visible := False;

  // Выделяем первую запись если она существует и не выбрана никакая другая
  if (Tarifikation.TableTarifikaciya.RowCount > 0)
  and (Tarifikation.TableTarifikaciya.SelectedRow = -1)
  then begin
    Tarifikation.TableTarifikaciya.SelectedRow := 0;
  end;

  // Очищаем зависимые таблицы когда не выбрана запись
  if Tarifikation.TableTarifikaciya.SelectedRow = -1 then begin
    Tarifikation.TableTarNadbavky.ClearRows;
    Tarifikation.TableTarJobs.ClearRows;
    Tarifikation.TableTarJobDoblaty.ClearRows;
    Exit;
  end;

  Tarifikation.BtnFilterTarNadbavky.Click;
  Tarifikation.BtnFilterTarJobs.Click;
end;

// Фильтр таблицы Тарификации
procedure Tarifikation_BtnClearFilterTarifikaciya_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.ListFilterTarFIO.ItemIndex := 0;
  Tarifikation.ListFilterTarObrazovanie.ItemIndex := 0;
  Tarifikation.EditFilterTarStaj.Clear;
  Tarifikation.DateFilterTarDate.Checked := False;

  Tarifikation.BtnFilterTarifikaciya.Click;
end;

procedure Tarifikation_CheckShowAllTarifikaions_OnClick (Sender: TObject);
var
  CurrentDate, DateStart, DateEnd : TDateTime;
  CurrentDateTimeChecked : Boolean;
begin
  DateStart := Tarifikation.DateTarStart.DateTime;
  DateEnd := Tarifikation.DateTarEnd.DateTime;

  CurrentDate := Tarifikation.DateFilterTarDate.DateTime;
  CurrentDateTimeChecked := Tarifikation.DateFilterTarDate.Checked;

  if Tarifikation.CheckShowAllTarifikaions.Checked then begin
  end else begin
    if CurrentDate < DateStart then
      Tarifikation.DateFilterTarDate.DateTime := DateStart;
    if CurrentDate > DateEnd then
      Tarifikation.DateFilterTarDate.DateTime := DateEnd;
    Tarifikation.DateFilterTarDate.Checked := CurrentDateTimeChecked;
  end;
end;
// Фильтр таблицы Тарификации

// Клик на фильтр таблицы Должностей
procedure Tarifikation_BtnFilterTarJobs_OnClick (Sender: TObject; var Cancel: boolean);
var
  SqlSelect : String;
  SelectedTarifikaciya,
  SelectedDoljnost, SelectedPredmet : String = ' ';
begin
  SelectedTarifikaciya := Tarifikation.TableTarifikaciya.sqlValue;

  if Tarifikation.ListFilterTarJobDoljnosty.dbItemID > 0 then begin
    SelectedDoljnost := ' and doljnost.id = '+Tarifikation.ListFilterTarJobDoljnosty.sqlValue;
  end;

  if Tarifikation.ListFilterTarJobPredmety.dbItemID > 0 then begin
    SelectedPredmet := ' and predmet.id = '+Tarifikation.ListFilterTarJobPredmety.sqlValue;
  end;

  SqlSelect := ''+
           'SELECT '+
           'tar_job.id, '+
           'doljnost.name, '+
           'predmet.name, '+
           'ROUND(tar_job_summa.oklad, 2), '+
           'tar_job.clock, '+
           'ROUND(tar_job_summa.nagruzka, 2), '+
           'kategory.name, '+
           'ROUND(tar_job_summa.kategory_summa, 2), '+
           'ROUND(tar_job_summa.nadbavka_summa, 2), '+
           'ROUND(tar_job_summa.doplata_summa, 2), '+
           'ROUND(tar_job_summa.doplata_persent_summa, 2), '+
           'ROUND(tar_job_summa.total_percent_summa, 2), '+
           'ROUND(tar_job_summa.total_summa, 2) '+
           'FROM tar_job '+
           'JOIN tarifikaciya ON tar_job.id_tarifikaciya = tarifikaciya.id '+
           'LEFT JOIN doljnost ON tar_job.id_doljnost = doljnost.id '+
           'LEFT JOIN predmet ON tar_job.id_predmet = predmet.id '+
           'LEFT JOIN kategory ON tar_job.id_kategory = kategory.id '+
           'LEFT JOIN stavka ON tar_job.id_stavka = stavka.id '+
           'LEFT JOIN tar_job_summa ON tar_job.id = tar_job_summa.id '+
           'WHERE '+
           '      tarifikaciya.id = ' + SelectedTarifikaciya +
                  SelectedDoljnost +
                  SelectedPredmet+' ' +
           'ORDER by tar_job_summa.total_summa desc, doljnost.por, doljnost.name ';

  Tarifikation.BtnFilterTarJobs.dbSQL := SqlSelect;
end;
procedure Tarifikation_BtnFilterTarJobs_OnAfterClick (Sender: TObject; var Cancel: boolean);
begin
  // Скрыть первую колонку
  Tarifikation.TableTarJobs.Columns[0].Visible := False;

  // Выделяем первую запись если она существует и не выбрана никакая другая
  if (Tarifikation.TableTarJobs.RowCount > 0)
  and (Tarifikation.TableTarJobs.SelectedRow = -1)
  then begin
    Tarifikation.TableTarJobs.SelectedRow := 0;
  end;

  // Очищаем зависимые таблицы когда не выбрана запись
  if Tarifikation.TableTarJobs.SelectedRow = -1 then begin
    Tarifikation.TableTarJobDoblaty.ClearRows;
    Exit;
  end;

  Tarifikation.BtnFilterTarJobDoplaty.Click;
end;

// Фильтр таблицы Должностей
procedure Tarifikation_TableTarifikaciya_OnCellClick (Sender: TObject; ACol, ARow: Integer);
begin
  Tarifikation.BtnFilterTarJobs.Click;
  Tarifikation.BtnFilterTarNadbavky.Click;
end;

procedure Tarifikation_BtnClearFilterTarJobs_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.ListFilterTarJobDoljnosty.ItemIndex := 0;
  Tarifikation.ListFilterTarJobPredmety.ItemIndex := 0;
  Tarifikation.BtnFilterTarJobs.Click;
end;
// Фильтр таблицы Должностей

// Клик на фильтр таблицы Надбавок тарификации
procedure Tarifikation_BtnFilterTarNadbavky_OnClick (Sender: TObject; var Cancel: boolean);
var
  SqlSelect : String;
  SelectedTarifikaciya,
  SelectedNadbavka : String = ' ';
begin
  SelectedTarifikaciya := Tarifikation.TableTarifikaciya.sqlValue;

  if Tarifikation.ListFilterTarNadbavky.dbItemID > 0 then begin
    SelectedNadbavka := ' and nadbavka.id = '+Tarifikation.ListFilterTarNadbavky.sqlValue;
  end;

  SqlSelect := ''+
           'SELECT '+
           'tar_nadbavka.id, '+
           'nadbavka.name, '+
           'tar_nadbavka.nad_percent, '+
           'ROUND(tar_nadbavka_summa.total_nadbavka_summa, 2) as total_nadbavka_summa '+
           'FROM tar_nadbavka '+
           'JOIN tarifikaciya ON tar_nadbavka.id_tarifikaciya = tarifikaciya.id '+
           'LEFT JOIN nadbavka ON tar_nadbavka.id_nadbavka = nadbavka.id '+
           'JOIN tar_nadbavka_summa ON tar_nadbavka.id = tar_nadbavka_summa.id '+
           'WHERE '+
           '      tarifikaciya.id = ' + SelectedTarifikaciya +
                  SelectedNadbavka +' ' +
           'ORDER by tar_nadbavka_summa.total_nadbavka_summa desc, nadbavka.name ';

  Tarifikation.BtnFilterTarNadbavky.dbSQL := SqlSelect;
end;
procedure Tarifikation_BtnFilterTarNadbavky_OnAfterClick (Sender: TObject; var Cancel: boolean);
begin
  // Скрыть первую колонку
  Tarifikation.TableTarNadbavky.Columns[0].Visible := False;

  // Выделяем первую запись если она существует и не выбрана никакая другая
  if (Tarifikation.TableTarNadbavky.RowCount > 0)
  and (Tarifikation.TableTarNadbavky.SelectedRow = -1)
  then begin
    Tarifikation.TableTarNadbavky.SelectedRow := 0;
  end;
end;

// Фильтр таблицы Надбавок тарификации
procedure Tarifikation_BtnClearFilterTarNadbavky_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.ListFilterTarNadbavky.ItemIndex := 0;
  Tarifikation.BtnFilterTarNadbavky.Click;;
end;
// Фильтр таблицы Надбавок тарификации

// Клик на фильтр таблицы Доплат для Должностей
procedure Tarifikation_BtnFilterTarJobDoplaty_OnClick (Sender: TObject; var Cancel: boolean);
var
  SqlSelect : String;
  SelectedTarJob,
  SelectedDoplata : String = ' ';
begin
  SelectedTarJob := Tarifikation.TableTarJobs.sqlValue;

  if Tarifikation.ListFilterTarJobDoplaty.dbItemID > 0 then begin
    SelectedDoplata := ' and doplata.id = '+Tarifikation.ListFilterTarJobDoplaty.sqlValue;
  end;

  SqlSelect := ''+
           'SELECT '+
           'tar_job_doplata.id, '+
           'doplata.name, '+
           'tar_job_doplata_summa.total_summa, '+
           'tar_job_doplata_summa.total_percent, '+
           'ROUND(tar_job_doplata_summa.total_percent_summa, 2), '+
           'ROUND(tar_job_doplata_summa.total_doplata_summa, 2) '+
           'FROM tar_job_doplata '+
           'JOIN tar_job ON tar_job_doplata.id_tar_job = tar_job.id '+
           'LEFT JOIN doplata ON tar_job_doplata.id_doplata = doplata.id '+
           'JOIN tar_job_doplata_summa ON tar_job_doplata.id = tar_job_doplata_summa.id '+
           'WHERE '+
           '      tar_job.id = ' + SelectedTarJob +
                  SelectedDoplata +' '+
           'ORDER by tar_job_doplata_summa.total_doplata_summa desc, doplata.name ';

  Tarifikation.BtnFilterTarJobDoplaty.dbSQL := SqlSelect;
end;
procedure Tarifikation_BtnFilterTarJobDoplaty_OnAfterClick (Sender: TObject; var Cancel: boolean);
begin
  // Скрыть первую колонку
  Tarifikation.TableTarJobDoblaty.Columns[0].Visible := False;

  // Выделяем первую запись если она существует и не выбрана никакая другая
  if (Tarifikation.TableTarJobDoblaty.RowCount > 0)
  and (Tarifikation.TableTarJobDoblaty.SelectedRow = -1)
  then begin
    Tarifikation.TableTarJobDoblaty.SelectedRow := 0;
  end;
end;

// Фильтр таблицы Доплат для Должностей
procedure Tarifikation_TableTarJobs_OnCellClick (Sender: TObject; ACol, ARow: Integer);
begin
  Tarifikation.BtnFilterTarJobDoplaty.Click;
end;

procedure Tarifikation_BtnClearFilterTarJobDoplaty_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.ListFilterTarJobDoplaty.ItemIndex := 0;
  Tarifikation.BtnFilterTarJobDoplaty.Click;
end;
// Фильтр таблицы Доплат для Должностей

// Формат таблиц и футера
procedure Tarifikation_TableTarifikaciya_OnChange (Sender: TObject);
var
  Column : Integer;
begin
  for Column:=6 to 6 do begin
    if Tarifikation.TableTarifikaciya.Columns[Column] is TNxNumberColumn then begin
      TNxNumberColumn(Tarifikation.TableTarifikaciya.Columns[Column]).FormatMask := '#,###,##0.00'; // Маска для колонки с деньгами
      Tarifikation.TableTarifikaciya.Columns[Column].Footer.FormatMaskKind := mkFloat;
      Tarifikation.TableTarifikaciya.Columns[Column].Footer.FormulaKind := fkSum;
      Tarifikation.TableTarifikaciya.Columns[Column].Footer.TextBefore := ' ';
      Tarifikation.TableTarifikaciya.Columns[Column].Footer.FormatMask := '#,###,##0.00';
    end;
  end;
  Tarifikation.TableTarifikaciya.CalculateFooter;
end;

procedure Tarifikation_TableTarJobs_OnChange (Sender: TObject);
var
  Column : Integer;
begin
  for Column:=1 to 12 do begin
    if Tarifikation.TableTarJobs.Columns[Column] is TNxNumberColumn then begin
      TNxNumberColumn(Tarifikation.TableTarJobs.Columns[Column]).FormatMask := '#,###,##0.00'; // Маска для колонки с деньгами
      Tarifikation.TableTarJobs.Columns[Column].Footer.FormatMaskKind := mkFloat;
      Tarifikation.TableTarJobs.Columns[Column].Footer.FormulaKind := fkSum;
      Tarifikation.TableTarJobs.Columns[Column].Footer.TextBefore := ' ';
      Tarifikation.TableTarJobs.Columns[Column].Footer.FormatMask := '#,###,##0.00';
    end;
  end;
  Tarifikation.TableTarJobs.CalculateFooter;
end;

procedure Tarifikation_TableTarNadbavky_OnChange (Sender: TObject);
var
  Column : Integer;
begin
  for Column:=1 to 3 do begin
    if Tarifikation.TableTarNadbavky.Columns[Column] is TNxNumberColumn then begin
      TNxNumberColumn(Tarifikation.TableTarNadbavky.Columns[Column]).FormatMask := '#,###,##0.00'; // Маска для колонки с деньгами
      Tarifikation.TableTarNadbavky.Columns[Column].Footer.FormatMaskKind := mkFloat;
      Tarifikation.TableTarNadbavky.Columns[Column].Footer.FormulaKind := fkSum;
      Tarifikation.TableTarNadbavky.Columns[Column].Footer.TextBefore := ' ';
      Tarifikation.TableTarNadbavky.Columns[Column].Footer.FormatMask := '#,###,##0.00';
    end;
  end;
  Tarifikation.TableTarNadbavky.CalculateFooter;
end;

procedure Tarifikation_TableTarJobDoblaty_OnChange (Sender: TObject);
var
  Column : Integer;
begin
  for Column:=1 to 5 do begin
    if Tarifikation.TableTarJobDoblaty.Columns[Column] is TNxNumberColumn then begin
      TNxNumberColumn(Tarifikation.TableTarJobDoblaty.Columns[Column]).FormatMask := '#,###,##0.00'; // Маска для колонки с деньгами
      Tarifikation.TableTarJobDoblaty.Columns[Column].Footer.FormatMaskKind := mkFloat;
      Tarifikation.TableTarJobDoblaty.Columns[Column].Footer.FormulaKind := fkSum;
      Tarifikation.TableTarJobDoblaty.Columns[Column].Footer.TextBefore := ' ';
      Tarifikation.TableTarJobDoblaty.Columns[Column].Footer.FormatMask := '#,###,##0.00';
    end;
  end;
  Tarifikation.TableTarJobDoblaty.CalculateFooter;
end;
// Формат таблиц и футера

// Новая Тарификация
procedure Tarifikation_BtnNewTarifikaciya_OnClick (Sender: TObject; var Cancel: boolean);
begin
  if Tarifikation.TableTarOrganizations.SelectedRow = -1 then begin
    MessageDlg('Не выбрана организация ', mtInformation, mbOK, 0);
    Exit;
  end;
  NewRecord(frmEditTarifikation);
end;

// Новая Должность тарификации
procedure Tarifikation_BtnNewTarJob_OnClick (Sender: TObject; var Cancel: boolean);
begin
  if Tarifikation.TableTarifikaciya.SelectedRow = -1 then begin
    MessageDlg('Не выбрана запись тарификации', mtInformation, mbOK, 0);
    Exit;
  end;
  NewRecord(frmEditTarJob,'tarifikaciya', Tarifikation.TableTarifikaciya.dbItemID);
end;

// Новая Надбавка тарификации
procedure Tarifikation_BtnNewTarNadbavka_OnClick (Sender: TObject; var Cancel: boolean);
begin
  if Tarifikation.TableTarifikaciya.SelectedRow = -1 then begin
    MessageDlg('Не выбрана запись тарификации', mtInformation, mbOK, 0);
    Exit;
  end;
  NewRecord(frmEditTarNadbavka,'tarifikaciya', Tarifikation.TableTarifikaciya.dbItemID);
end;

// Новая Доплата для должности тарификации
procedure Tarifikation_BtnNewTarJobDoplata_OnClick (Sender: TObject; var Cancel: boolean);
begin
  if Tarifikation.TableTarJobs.SelectedRow = -1 then begin
    MessageDlg('Не выбрана запись должности', mtInformation, mbOK, 0);
    Exit;
  end;
  NewRecord(frmEditTarJobDoplata,'tar_job', Tarifikation.TableTarJobs.dbItemID);
end;

// Кнопки редактирования на главной
procedure Tarifikation_BtnEditTarifikaciya_OnAfterClick (Sender: TObject; var Cancel: boolean);
begin
end;

procedure Tarifikation_BtnEditTarJob_OnAfterClick (Sender: TObject; var Cancel: boolean);
begin
end;

procedure Tarifikation_BtnEditTarNadbavka_OnAfterClick (Sender: TObject; var Cancel: boolean);
begin
end;

procedure Tarifikation_BtnEditTarJobDoplata_OnAfterClick (Sender: TObject; var Cancel: boolean);
begin
end;
// Кнопки редактирования на главной

// Кнопки удаления на главной
procedure Tarifikation_BtnDeleteTarOrganization_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TableTarOrganizations);
  Tarifikation.BtnFilterTarOrganizations.Click;
end;

procedure Tarifikation_BtnDeleteTarifikaciya_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TableTarifikaciya);
  Tarifikation.BtnFilterTarifikaciya.Click;
end;

procedure Tarifikation_BtnDeleteTarJob_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TableTarJobs);
  Tarifikation.BtnFilterTarJobs.Click;
end;

procedure Tarifikation_BtnDeleteTarNadbavka_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TableTarNadbavky);
  Tarifikation.BtnFilterTarNadbavky.Click;
end;

procedure Tarifikation_BtnDeleteTarJobDoplata_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TableTarJobDoblaty);
  Tarifikation.BtnFilterTarJobs.Click;
end;

// Обработка нажатия стрелочек
procedure Tarifikation_TableTarOrganizations_OnKeyUp (Sender: TObject; var Key: Word; Shift, Alt, Ctrl: boolean);
begin
  if (Key = VK_UP) or (Key = VK_DOWN) then begin
    Tarifikation.BtnFilterTarifikaciya.Click;
  end;
end;

procedure Tarifikation_TableTarifikaciya_OnKeyUp (Sender: TObject; var Key: Word; Shift, Alt, Ctrl: boolean);
begin
  if (Key = VK_UP) or (Key = VK_DOWN) then begin
    Tarifikation.BtnFilterTarJobs.Click;
    Tarifikation.BtnFilterTarNadbavky.Click;
  end;
end;

procedure Tarifikation_TableTarJob_OnKeyUp (Sender: TObject; var Key: Word; Shift, Alt, Ctrl: boolean);
begin
  if (Key = VK_UP) or (Key = VK_DOWN) then begin
    Tarifikation.BtnFilterTarJobDoplaty.Click;
  end;
end;
// Обработка нажатия стрелочек

// Обработка нажатия Del
procedure Tarifikation_TableTarOrganizations_OnKeyDown (Sender: TObject; var Key: Word; Shift, Alt, Ctrl: boolean);
begin
  if Key = VK_DELETE then
    Tarifikation_BtnDeleteTarOrganization_OnClick(Sender, False);
end;

procedure Tarifikation_TableTarifikaciya_OnKeyDown (Sender: TObject; var Key: Word; Shift, Alt, Ctrl: boolean);
begin
  if Key = VK_DELETE then
    Tarifikation_BtnDeleteTarifikaciya_OnClick(Sender, False);
end;

procedure Tarifikation_TableTarJobs_OnKeyDown (Sender: TObject; var Key: Word; Shift, Alt, Ctrl: boolean);
begin
  if Key = VK_DELETE then
    Tarifikation_BtnDeleteTarJob_OnClick(Sender, False);
end;

procedure Tarifikation_TableTarNadbavky_OnKeyDown (Sender: TObject; var Key: Word; Shift, Alt, Ctrl: boolean);
begin
  if Key = VK_DELETE then
    Tarifikation_BtnDeleteTarNadbavka_OnClick(Sender, False);
end;

procedure Tarifikation_TableTarJobDoblaty_OnKeyDown (Sender: TObject; var Key: Word; Shift, Alt, Ctrl: boolean);
begin
  if Key = VK_DELETE then
    Tarifikation_BtnDeleteTarJobDoplata_OnClick(Sender, False);
end;
// Кнопки удаления на главной


// Логика показа кнопок добавления, редактирования и удаления
procedure Tarifikation_HideGroupsEditButtons;
begin
  Tarifikation.GroupBtnTarOrganizations.Visible := False;
  Tarifikation.GroupBtnTarifikaciya.Visible := False;
  Tarifikation.GroupBtnTarJobs.Visible := False;
  Tarifikation.GroupBtnTarNadbavky.Visible := False;
  Tarifikation.GroupBtnTarJobDoblaty.Visible := False;

  Tarifikation.GroupBtnUsers.Visible := False;
  Tarifikation.GroupBtnDbBackups.Visible := False;
end;
// Проверка кнопок
procedure Tarifikation_BtnShowGroupBtnTarOrganizations_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
  Tarifikation.GroupBtnTarOrganizations.Visible := True;
end;

procedure Tarifikation_BtnShowGroupBtnTarifikaciya_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
  Tarifikation.GroupBtnTarifikaciya.Visible := True;
end;

procedure Tarifikation_BtnShowGroupBtnTarJobs_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
  Tarifikation.GroupBtnTarJobs.Visible := True;
end;

procedure Tarifikation_BtnShowGroupBtnTarNadbavky_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
  Tarifikation.GroupBtnTarNadbavky.Visible := True;
end;

procedure Tarifikation_BtnShowGroupBtnTarJobDoblaty_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
  Tarifikation.GroupBtnTarJobDoblaty.Visible := True;
end;

procedure Tarifikation_BtnShowGroupBtnUsers_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
  Tarifikation.GroupBtnUsers.Visible := True;
end;

procedure Tarifikation_BtnShowGroupBtnDbBackups_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
  Tarifikation.GroupBtnDbBackups.Visible := True;
end;
// Проверка таблиц
procedure Tarifikation_TableTarOrganizations_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
end;

procedure Tarifikation_TableTarifikaciya_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
end;

procedure Tarifikation_TableTarJobs_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
end;

procedure Tarifikation_TableTarNadbavky_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
end;

procedure Tarifikation_TableTarJobDoblaty_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
end;

procedure Tarifikation_TableUsers_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
end;

procedure Tarifikation_TableDbBackups_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
end;
// Логика показа кнопок добавления, редактирования и удаления

// Подготовка всех таблиц на главной
procedure Tarifikation_PrepareTarTables;
begin
  Tarifikation.BtnFilterTarOrganizations.Click;
  Tarifikation.BtnFilterTarifikaciya.Click;
  Tarifikation.BtnFilterTarNadbavky.Click;
  Tarifikation.BtnFilterTarJobs.Click;
  Tarifikation.BtnFilterTarJobDoplaty.Click;
end;

procedure Tarifikation_OnShow (Sender: TObject; Action: string);
begin
  Tarifikation.MainTabs.ActivePageIndex := 0;

  UserLogin(True);
  Tarifikation_PrepareTarTables;

  Tarifikation.Menu.Items.Remove(Tarifikation.mniAbout);
end;

procedure Tarifikation_OnClose (Sender: TObject; Action: string);
begin
  OptimizeDatabase;
end;

begin
  // MessageDlg('Тарификация загружена!', mtInformation, mbOK, 0);
end.
