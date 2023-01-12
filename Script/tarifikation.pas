uses
  'otchety.pas',
  'spravochniky.pas';

var
   mniUser: TMenuItem;

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


// Показ кнопок добавления, редактирования и удаления на главной
procedure Tarifikation_TableTarOrganizations_OnMouseEnter (Sender: TObject);
begin
  Tarifikation.GroupBtnTarOrganizations.Visible := True;

  Tarifikation.GroupBtnTarifikaciya.Visible := False;
  Tarifikation.GroupBtnTarJobs.Visible := False;
  Tarifikation.GroupBtnTarNadbavky.Visible := False;
  Tarifikation.GroupBtnTarJobDoblaty.Visible := False;
end;

procedure Tarifikation_TableTarifikaciya_OnMouseEnter (Sender: TObject);
begin
  Tarifikation.GroupBtnTarifikaciya.Visible := True;

  Tarifikation.GroupBtnTarOrganizations.Visible := False;
  Tarifikation.GroupBtnTarJobs.Visible := False;
  Tarifikation.GroupBtnTarNadbavky.Visible := False;
  Tarifikation.GroupBtnTarJobDoblaty.Visible := False;
end;

procedure Tarifikation_TableTarJobs_OnMouseEnter (Sender: TObject);
begin
  Tarifikation.GroupBtnTarJobs.Visible := True;

  Tarifikation.GroupBtnTarOrganizations.Visible := False;
  Tarifikation.GroupBtnTarifikaciya.Visible := False;
  Tarifikation.GroupBtnTarNadbavky.Visible := False;
  Tarifikation.GroupBtnTarJobDoblaty.Visible := False;
end;

procedure Tarifikation_TableTarNadbavky_OnMouseEnter (Sender: TObject);
begin
  Tarifikation.GroupBtnTarNadbavky.Visible := True;

  Tarifikation.GroupBtnTarOrganizations.Visible := False;
  Tarifikation.GroupBtnTarifikaciya.Visible := False;
  Tarifikation.GroupBtnTarJobs.Visible := False;
  Tarifikation.GroupBtnTarJobDoblaty.Visible := False;
end;

procedure Tarifikation_TableTarJobDoblaty_OnMouseEnter (Sender: TObject);
begin
  Tarifikation.GroupBtnTarJobDoblaty.Visible := True;

  Tarifikation.GroupBtnTarOrganizations.Visible := False;
  Tarifikation.GroupBtnTarifikaciya.Visible := False;
  Tarifikation.GroupBtnTarJobs.Visible := False;
  Tarifikation.GroupBtnTarNadbavky.Visible := False;
end;


// Подготовка всех таблиц тарификации
procedure Tarifikation_PrepareTarTables;
begin
  Tarifikation.BtnFilterTarifikaciya.Click;
  Tarifikation.BtnFilterTarNadbavky.Click;
  Tarifikation.BtnFilterTarJobs.Click;
  Tarifikation.BtnFilterTarJobDoplaty.Click;

  Tarifikation.TableTarifikaciya.ClearRows;
  Tarifikation.TableTarNadbavky.ClearRows;
  Tarifikation.TableTarJobs.ClearRows;
  Tarifikation.TableTarJobDoblaty.ClearRows;
end;

// Обработка переключения пользователя
procedure mniUser_OnClick (sender: string);
begin
  frmDbCoreLogin.ShowModal;
  mniUser.Caption := 'Пользователь: '+Application.User.Username;
  FillRequisites;
end;

procedure Tarifikation_OnShow (Sender: TObject; Action: string);
begin
// Меню пользователя
  mniUser := TMenuItem.Create (Tarifikation);
  mniUser.Caption := 'Пользователь: '+Application.User.Username;
  mniUser.OnClick := @mniUser_OnClick;

  Tarifikation.Menu.Items.Add(mniUser);

  Tarifikation_PrepareTarTables;      // Подготовка всех таблиц тарификации
  FillRequisites;                     // Заполнение реквизитов из otchety.pas
  PrepareSpravochniky;                // Подготовка справочников из spravochniky.pas

  Tarifikation.Menu.Items.Remove(Tarifikation.mniAbout);
end;

begin
end.
