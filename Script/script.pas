uses
  'service.pas',
  'spravochniky.pas',
  'otchety.pas',
  'tarifikation.pas';

procedure Tarifikation_MainTabs_OnChange (Sender: TObject);
begin

  case Tarifikation.MainTabs.ActivePageIndex of
    0: begin Tarifikation_FilterTarTables; end;
    1: begin FillRequisites; end;
    2: begin PrepareSpravochniky; end;
    3: begin end;
  end;

end;


// Переключения пользователя
procedure UserLogin;
begin
  frmDbCoreLogin.ShowModal;
  mniUser.Caption := 'Пользователь: '+Application.User.Username;
  FillRequisites;
end;

procedure mniUser_OnClick (sender: string);
begin
  UserLogin;
end;

begin
end.
