var
  sHello: string;

procedure Tarifikation_BtnNewTarifikaciyaDop_OnClick (Sender: TObject; var Cancel: boolean);
begin
  if Tarifikation.TableTarifikaciya.SelectedRow = -1 then begin
    MessageDlg('Не выбрана запись тарификации', mtInformation, mbOK, 0);
    Exit;
  end;
  NewRecord(frmEditTarifikaciyaDop,'tarifikaciya', Tarifikation.TableTarifikaciya.dbItemID);
end;

procedure Tarifikation_TableTarifikaciya_OnCellClick (Sender: TObject; ACol, ARow: Integer);
begin
  Tarifikation.TableTarifikaciyaDop.dbParentTableId := Tarifikation.TableTarifikaciya.dbItemID;
  Tarifikation.BtnFilterTarifikaciyaDop.Click;
end;

procedure Tarifikation_ListFilterTarFIO_OnChange (Sender: TObject);
begin
  Tarifikation.BtnFilterTarifikaciya.Click;
  if Tarifikation.TableTarifikaciya.SelectedRow = -1 then
    Tarifikation.TableTarifikaciyaDop.ClearRows;
end;

procedure Tarifikation_TableTarOrganizations_OnCellClick (Sender: TObject; ACol, ARow: Integer);
begin
  Tarifikation.BtnFilterTarifikaciya.Click;
  if Tarifikation.TableTarifikaciya.SelectedRow = -1 then
    Tarifikation.TableTarifikaciyaDop.ClearRows;
end;

procedure Tarifikation_ListFilterTarOrganizations_OnChange (Sender: TObject);
begin
  Tarifikation.BtnFilterTarOrganizations.Click;
  if Tarifikation.TableTarOrganizations.SelectedRow = -1 then begin
    Tarifikation.TableTarifikaciya.ClearRows;
    Tarifikation.TableTarifikaciyaDop.ClearRows;
  end;
end;

procedure Tarifikation_CheckPersonArchived_OnClick (Sender: TObject);
begin
  if Tarifikation.CheckPersonArchived.Checked then
  begin
  Tarifikation.TablePersons.dbFilter := 'archived = 1';
  end
  else begin
  Tarifikation.TablePersons.dbFilter := 'archived = 0';
  end;
  UpdateDatabase('person');
end;

begin
  Tarifikation.TableTarifikaciyaDop.dbParentTable := 'tarifikaciya';
  Tarifikation.mniAbout.Visible := False;
end.
