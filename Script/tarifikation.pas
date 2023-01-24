uses
  'service.pas',
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

  if Tarifikation.TableTarOrganizations.SelectedRow = -1 then begin
    Tarifikation.TableTarifikaciya.ClearRows;
    Tarifikation.TableTarNadbavky.ClearRows;
    Tarifikation.TableTarJobs.ClearRows;
    Tarifikation.TableTarJobDoblaty.ClearRows;
  end;
end;

// Фильтр таблицы Тарификации
procedure Tarifikation_DoFilterTableTarifikaciya;
begin
  if Tarifikation.TableTarOrganizations.SelectedRow = -1 then Exit;

  Tarifikation.BtnFilterTarifikaciya.Click;
  if Tarifikation.TableTarifikaciya.SelectedRow = -1 then begin
    Tarifikation.TableTarNadbavky.ClearRows;
    Tarifikation.TableTarJobs.ClearRows;
    Tarifikation.TableTarJobDoblaty.ClearRows;
  end;
end;

procedure Tarifikation_TableTarOrganizations_OnCellClick (Sender: TObject; ACol, ARow: Integer);
var
  itemId : Integer;
begin
// Сохранение выбранной организации
  itemId := Tarifikation.TableTarOrganizations.dbItemID;
  SQLExecute('update _user set id_organization1 = '+IntToStr(itemId)+' where id = '+IntToStr(Application.User.id));

  Tarifikation_DoFilterTableTarifikaciya;
end;

procedure Tarifikation_BtnClearFilterTarifikaciya_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.ListFilterTarFIO.ItemIndex := 0;
  Tarifikation.ListFilterTarObrazovanie.ItemIndex := 0;
  Tarifikation.EditFilterTarStaj.Clear;
  Tarifikation.DateFilterTarDate.Checked := False;
  Tarifikation_DoFilterTableTarifikaciya;
end;

procedure Tarifikation_CheckShowAllTarifikaions_OnClick (Sender: TObject);
begin
  Tarifikation.DateTarStart.Checked := not Tarifikation.CheckShowAllTarifikaions.Checked;
  Tarifikation.DateTarEnd.Checked := not Tarifikation.CheckShowAllTarifikaions.Checked;
  Tarifikation_DoFilterTableTarifikaciya;
end;
// Фильтр таблицы Тарификации

// Фильтр таблицы Надбавок тарификации
procedure Tarifikation_DoFilterTableTarNadbavky;
begin
  if Tarifikation.TableTarifikaciya.SelectedRow = -1 then Exit;

  Tarifikation.BtnFilterTarNadbavky.Click;
end;

procedure Tarifikation_BtnClearFilterTarNadbavky_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.ListFilterTarNadbavky.ItemIndex := 0;
  Tarifikation_DoFilterTableTarNadbavky;
end;
// Фильтр таблицы Надбавок тарификации

// Фильтр таблицы Должностей
procedure Tarifikation_DoFilterTableTarJobs;
begin
  if Tarifikation.TableTarifikaciya.SelectedRow = -1 then Exit;

  Tarifikation.BtnFilterTarJobs.Click;
  if Tarifikation.TableTarJobs.SelectedRow = -1 then
    Tarifikation.TableTarJobDoblaty.ClearRows;
end;

procedure Tarifikation_TableTarifikaciya_OnCellClick (Sender: TObject; ACol, ARow: Integer);
begin
  Tarifikation_DoFilterTableTarNadbavky;
  Tarifikation_DoFilterTableTarJobs;
end;

procedure Tarifikation_BtnClearFilterTarJobs_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.ListFilterTarJobDoljnosty.ItemIndex := 0;
  Tarifikation.ListFilterTarJobPredmety.ItemIndex := 0;
  Tarifikation_DoFilterTableTarJobs;
end;
// Фильтр таблицы Должностей

// Фильтр таблицы Доплат для Должностей
procedure Tarifikation_DoFilterTableTarJobDoblaty;
begin
  if Tarifikation.TableTarJobs.SelectedRow = -1 then Exit;

  Tarifikation.BtnFilterTarJobDoplaty.Click;
end;

procedure Tarifikation_BtnClearFilterTarJobDoplaty_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.ListFilterTarJobDoplaty.ItemIndex := 0;
  Tarifikation_DoFilterTableTarJobDoblaty;
end;
// Фильтр таблицы Доплат для Должностей


// Новая Тарификация
procedure Tarifikation_BtnNewTarifikaciya_OnClick (Sender: TObject; var Cancel: boolean);
begin
  if Tarifikation.TableTarOrganizations.SelectedRow = -1 then begin
    MessageDlg('Не выбрана организация ', mtInformation, mbOK, 0);
    Exit;
  end;
  NewRecord(frmEditTarifikation);
end;
// При открытии формы редактирования тарификации подставляется
// ранее выбранная организация и текущая дата тарификации
procedure frmEditTarifikation_OnShow (Sender: TObject; Action: string);
begin
  frmEditTarifikation.ListOrganizations.dbItemID := Tarifikation.TableTarOrganizations.dbItemID;

  if not frmEditTarifikation.DateTarDate.Checked then
    frmEditTarifikation.DateTarDate.DateTime := Tarifikation.DateFilterTarDate.DateTime;

  frmEditTarifikation.DateTarDate.MinDate := Tarifikation.DateTarStart.DateTime;
  frmEditTarifikation.DateTarDate.MaxDate := Tarifikation.DateTarEnd.DateTime;
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

// Новая Должность тарификации
procedure Tarifikation_BtnNewTarJob_OnClick (Sender: TObject; var Cancel: boolean);
begin
  if Tarifikation.TableTarifikaciya.SelectedRow = -1 then begin
    MessageDlg('Не выбрана запись тарификации', mtInformation, mbOK, 0);
    Exit;
  end;
  NewRecord(frmEditTarJob,'tarifikaciya', Tarifikation.TableTarifikaciya.dbItemID);
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


// Кнопки удаления на главной
procedure Tarifikation_BtnDeleteTarOrganization_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TableTarOrganizations);
end;

procedure Tarifikation_BtnDeleteTarifikaciya_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TableTarifikaciya);
end;

procedure Tarifikation_BtnDeleteTarNadbavka_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TableTarNadbavky);
end;

procedure Tarifikation_BtnDeleteTarJob_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TableTarJobs);
end;

procedure Tarifikation_BtnDeleteTarJobDoplata_OnClick (Sender: TObject; var Cancel: boolean);
begin
  DeleteRecordFromTable(Tarifikation.TableTarJobDoblaty);
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
  if Tarifikation.TableTarOrganizations.CanFocus then
    Tarifikation.TableTarOrganizations.SetFocus;
end;

procedure Tarifikation_TableTarifikaciya_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
  if Tarifikation.TableTarifikaciya.CanFocus then
    Tarifikation.TableTarifikaciya.SetFocus;
end;

procedure Tarifikation_TableTarJobs_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
  if Tarifikation.TableTarJobs.CanFocus then
    Tarifikation.TableTarJobs.SetFocus;
end;

procedure Tarifikation_TableTarNadbavky_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
  if Tarifikation.TableTarNadbavky.CanFocus then
    Tarifikation.TableTarNadbavky.SetFocus;
end;

procedure Tarifikation_TableTarJobDoblaty_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
  if Tarifikation.TableTarJobDoblaty.CanFocus then
    Tarifikation.TableTarJobDoblaty.SetFocus;
end;

procedure Tarifikation_TableUsers_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
  if Tarifikation.TableUsers.CanFocus then
    Tarifikation.TableUsers.SetFocus;
end;

procedure Tarifikation_TableDbBackups_OnMouseEnter (Sender: TObject);
begin
  Tarifikation_HideGroupsEditButtons;
  if Tarifikation.TableDbBackups.CanFocus then
    Tarifikation.TableDbBackups.SetFocus;
end;
// Логика показа кнопок добавления, редактирования и удаления

// Подготовка всех таблиц на главной
procedure Tarifikation_PrepareTarTables;
begin
  Tarifikation.BtnFilterTarOrganizations.Click;
  Tarifikation_DoFilterTableTarifikaciya;
  Tarifikation_DoFilterTableTarNadbavky;
  Tarifikation_DoFilterTableTarJobs;
  Tarifikation_DoFilterTableTarJobDoblaty;
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
