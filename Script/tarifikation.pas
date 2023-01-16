uses
  'service.pas',
  'spravochniky.pas',
  'otchety.pas';

// Фильтр списка организаций Тарификации
procedure Tarifikation_ListFilterTarOrganizations_OnChange (Sender: TObject);
begin
  Tarifikation.BtnFilterTarOrganizations.Click;
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
begin
  Tarifikation_DoFilterTableTarifikaciya;
end;

procedure Tarifikation_ListFilterTarFIO_OnChange (Sender: TObject);
begin
  Tarifikation_DoFilterTableTarifikaciya;
end;

procedure Tarifikation_ListFilterTarObrazovanie_OnChange (Sender: TObject);
begin
  Tarifikation_DoFilterTableTarifikaciya;
end;

procedure Tarifikation_EditFilterTarStaj_OnChange (Sender: TObject);
begin
  Tarifikation_DoFilterTableTarifikaciya;
end;

procedure Tarifikation_DateFilterTarDate_OnChange (Sender: TObject);
begin
  Tarifikation_DoFilterTableTarifikaciya;
end;

procedure Tarifikation_BtnClearFilterTarifikaciya_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.ListFilterTarFIO.ItemIndex := 0;
  Tarifikation.ListFilterTarObrazovanie.ItemIndex := 0;
  Tarifikation.EditFilterTarStaj.Clear;
  Tarifikation.DateFilterTarDate.DateTime := Now;
  Tarifikation.DateFilterTarDate.Checked := False;
  Tarifikation_DoFilterTableTarifikaciya;
end;
// Фильтр таблицы Тарификации

// Фильтр таблицы Надбавок тарификации
procedure Tarifikation_DoFilterTableTarNadbavky;
begin
  if Tarifikation.TableTarifikaciya.SelectedRow = -1 then Exit;

  Tarifikation.BtnFilterTarNadbavky.Click;
end;

procedure Tarifikation_ListFilterTarNadbavky_OnChange (Sender: TObject);
begin
  Tarifikation_DoFilterTableTarNadbavky;
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

procedure Tarifikation_ListFilterTarJobDoljnosty_OnChange (Sender: TObject);
begin
  Tarifikation_DoFilterTableTarJobs;
end;

procedure Tarifikation_ListFilterTarJobPredmety_OnChange (Sender: TObject);
begin
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

procedure Tarifikation_TableTarJobs_OnCellClick (Sender: TObject; ACol, ARow: Integer);
begin
  Tarifikation_DoFilterTableTarJobDoblaty;
end;

procedure Tarifikation_ListFilterTarJobDoplaty_OnChange (Sender: TObject);
begin
  Tarifikation_DoFilterTableTarJobDoblaty;
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
// При открытии формы редактирования тарификации подставляется ранее выбранная организация
procedure frmEditTarifikation_OnShow (Sender: TObject; Action: string);
begin
  frmEditTarifikation.ListOrganizations.dbItemID := Tarifikation.TableTarOrganizations.dbItemID;
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
end;

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
// Логика показа кнопок добавления, редактирования и удаления

// Запуск всех фильтров на главной
procedure Tarifikation_FilterTarTables;
begin
  Tarifikation.BtnFilterTarOrganizations.Click;
  Tarifikation_DoFilterTableTarifikaciya;
  Tarifikation_DoFilterTableTarNadbavky;
  Tarifikation_DoFilterTableTarJobs;
  Tarifikation_DoFilterTableTarJobDoblaty;
end;

// Подготовка всех таблиц на главной
procedure Tarifikation_PrepareTarTables;
begin
  Tarifikation.BtnFilterTarOrganizations.Click;
  Tarifikation.BtnFilterTarifikaciya.Click;
  Tarifikation.BtnFilterTarNadbavky.Click;
  Tarifikation.BtnFilterTarJobs.Click;
  Tarifikation.BtnFilterTarJobDoplaty.Click;

  Tarifikation.TableTarifikaciya.ClearRows;
  Tarifikation.TableTarNadbavky.ClearRows;
  Tarifikation.TableTarJobs.ClearRows;
  Tarifikation.TableTarJobDoblaty.ClearRows;
end;

procedure Tarifikation_OnShow (Sender: TObject; Action: string);
begin
  Tarifikation.MainTabs.ActivePageIndex := 0;
  Tarifikation_PrepareTarTables;

  UserLogin(True);

  Tarifikation.Menu.Items.Remove(Tarifikation.mniAbout);
end;

procedure Tarifikation_OnClose (Sender: TObject; Action: string);
begin
  SQLExecute('pragma optimize;');
end;

begin
  // MessageDlg('Тарификация загружена!', mtInformation, mbOK, 0);
end.
