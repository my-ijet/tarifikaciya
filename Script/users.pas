uses
  'service.pas',
  'spravochniky.pas',
  'otchety.pas',
  'tarifikation.pas';

var
  mniUser: TMenuItem;
  UserChanged : Boolean;

// Переключение пользователя
procedure UserLogin;
var
  NumOfUsers : String;
begin
  // TODO Загрузка из конфига пользователя
  frmUserLogin.ListUsers.dbItemID := Application.User.Id;

  // Если нет пользователей создаём стандартного и выходим
  NumOfUsers := SQLExecute('select count(*) from _user');
  if NumOfUsers = '0' then begin
    ApplyFixesOnNewDatabase;
    CreateDefaultUser;
    UpdateDatabase('_user');
    Exit;
  end;

  // frmDbCoreLogin.ShowModal;
  frmUserLogin.ShowModal;
end;

procedure UpdateCurrentAppUser(id: Integer; username: String);
begin
  Application.User.Id := id;
  Application.User.UserName := username;
  mniUser.Caption := 'Пользователь: '+Application.User.Username;

  FillRequisites;
end;

function GenerateUserPassword(username, password : String) : String;
begin
  Result := strToMD5(password+username);
end;

procedure CreateDefaultUser;
var
  id : Integer = 0; userSqlId : String;
  username, password : String = 'admin';
  currentDateTime : String;
  SQLCreateDefaultUser : String;
begin
  password := GenerateUserPassword(username, password);
  currentDateTime := '"'+DateTimeToStr(Now)+'"';
  SQLExecute('insert into _user (username, password, is_admin, is_active, date_joined) values ("admin", "'+password+'", 1, 1, '+currentDateTime+');');

  userSqlId := SQLExecute('select id from _user where username = "admin";');
  if userSqlId <> '' then id := StrToInt(userSqlId);

  Application.User.Id := id;
  Application.User.UserName := username;
  UpdateCurrentAppUser(id, username);
end;

procedure mniUser_OnClick (sender: string);
begin
  UserLogin;
end;

// Форма входа
procedure frmUserLogin_OnShow (Sender: TObject; Action: string);
begin
  frmUserLogin.ListUsers.dbSQLExecute('select id, username from _user;');
end;

procedure frmUserLogin_BtnOK_OnClick (Sender: TObject; var Cancel: boolean);
begin
  if frmUserLogin.ListUsers.dbItemID = -1 then Exit;

  UpdateCurrentAppUser(frmUserLogin.ListUsers.dbItemID,
                       frmUserLogin.ListUsers.Text
                      );
end;

procedure frmUserLogin_BtnCancel_OnClick (Sender: TObject; var Cancel: boolean);
begin
end;

procedure frmUserLogin_OnClose (Sender: TObject; Action: string);
begin
  if Application.User.Id = -1 then Tarifikation.Close;
end;
// Форма входа

// Редактирование пользователя
procedure frmEditUser_BtnOK_OnClick (Sender: TObject; var Cancel: boolean);
begin
  UserChanged := True;
end;

procedure frmEditUser_OnClose (Sender: TObject; Action: string);
var
  UpdateSQL, username, password : String;
begin
  if not UserChanged then Exit;

  username := frmEditUser.EditUserName.Text;
  password := frmEditUser.EditUserName.Text;

  password := GenerateUserPassword(username, password);

  username := '"'+username+'"';
  UpdateSQL := 'update _user set password = "'+password+'" where username = '+username;
  SQLExecute(UpdateSQL);

  UserChanged := False;
end;
// Редактирование пользователя

begin
  // MessageDlg('Пользователь: '+IntToStr(Application.User.Id), mtInformation, mbOK, 0);
  mniUser := TMenuItem.Create (Tarifikation);
  mniUser.OnClick := @mniUser_OnClick;

  Tarifikation.Menu.Items.Add(mniUser);
end.
