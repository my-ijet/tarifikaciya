uses
  'spravochniky.pas';

procedure DoFilterTableTarifikaciya;
begin
  if Tarifikation.TableTarOrganizations.SelectedRow = -1 then begin
    Tarifikation.TableTarifikaciya.ClearRows;
    Tarifikation.TableTarNadbavky.ClearRows;
    Exit;
  end;

  Tarifikation.BtnFilterTarifikaciya.Click;
  if Tarifikation.TableTarifikaciya.SelectedRow = -1 then
    Tarifikation.TableTarNadbavky.ClearRows;
end;

procedure DoFilterTableTarNadbavky;
begin
  if Tarifikation.TableTarifikaciya.SelectedRow = -1 then begin
    Tarifikation.TableTarNadbavky.ClearRows;
    Exit;
  end;

  Tarifikation.BtnFilterTarNadbavky.Click;
end;

//=====================================================================\\

// Фильтр списка организаций Тарификации
procedure Tarifikation_ListFilterTarOrganizations_OnChange (Sender: TObject);
begin
  Tarifikation.BtnFilterTarOrganizations.Click;
  if Tarifikation.TableTarOrganizations.SelectedRow = -1 then begin
    Tarifikation.TableTarifikaciya.ClearRows;
    Tarifikation.TableTarNadbavky.ClearRows;
  end;
end;

// Фильтр таблицы Тарификации
procedure Tarifikation_TableTarOrganizations_OnCellClick (Sender: TObject; ACol, ARow: Integer);
begin
  DoFilterTableTarifikaciya;
end;

procedure Tarifikation_ListFilterTarFIO_OnChange (Sender: TObject);
begin
  DoFilterTableTarifikaciya;
end;

procedure Tarifikation_BtnClearFilterTarifikaciya_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.ListFilterTarFIO.ItemIndex := 0;
  DoFilterTableTarifikaciya;
end;

// Фильтр таблицы Надбавок тарификации
procedure Tarifikation_TableTarifikaciya_OnCellClick (Sender: TObject; ACol, ARow: Integer);
begin
  DoFilterTableTarNadbavky;
end;

procedure Tarifikation_ListFilterTarNadbavky_OnChange (Sender: TObject);
begin
  DoFilterTableTarNadbavky;
end;

procedure Tarifikation_BtnClearFilterTarNadbavky_OnClick (Sender: TObject; var Cancel: boolean);
begin
  Tarifikation.ListFilterTarNadbavky.ItemIndex := 0;
  DoFilterTableTarNadbavky;
end;


procedure Tarifikation_BtnNewTarNadbavka_OnClick (Sender: TObject; var Cancel: boolean);
begin
  if Tarifikation.TableTarifikaciya.SelectedRow = -1 then begin
    MessageDlg('Не выбрана запись тарификации', mtInformation, mbOK, 0);
    Exit;
  end;
  NewRecord(frmEditTarNadbavka,'tarifikaciya', Tarifikation.TableTarifikaciya.dbItemID);
end;



procedure Tarifikation_OnShow (Sender: TObject; Action: string);
begin
  PrepareSpravochniky;
end;

begin
end.
