object MainForm: TMainForm
  Left = 358
  Height = 720
  Top = 256
  Width = 1280
  BorderWidth = 5
  Caption = 'MainForm'
  ClientHeight = 720
  ClientWidth = 1280
  Constraints.MinHeight = 360
  Constraints.MinWidth = 640
  DockSite = True
  OnClose = FormClose
  OnCreate = FormCreate
  Position = poScreenCenter
  SessionProperties = 'WindowState;PQMainConnection.DatabaseName;PQMainConnection.HostName;PQMainConnection.Password;PQMainConnection.Role'
  UseDockManager = True
  LCLVersion = '7.9'
  Visible = True
  object PageControl1: TPageControl
    Left = 5
    Height = 710
    Top = 5
    Width = 1270
    ActivePage = Settings
    Align = alClient
    TabIndex = 3
    TabOrder = 0
    object Tarifikaciya: TTabSheet
      Caption = 'Тарификация'
      ClientHeight = 675
      ClientWidth = 1266
      object PairSplitter1: TPairSplitter
        AnchorSideRight.Side = asrBottom
        AnchorSideBottom.Side = asrBottom
        Left = 0
        Height = 674
        Top = 0
        Width = 1265
        Align = alClient
        BorderSpacing.Right = 1
        BorderSpacing.Bottom = 1
        Position = 300
        object PSSOrganizatons: TPairSplitterSide
          Cursor = crArrow
          Left = 0
          Height = 674
          Top = 0
          Width = 300
          ClientWidth = 300
          ClientHeight = 674
          Constraints.MaxWidth = 800
          Constraints.MinWidth = 300
          object Label1: TLabel
            AnchorSideRight.Side = asrBottom
            Left = 0
            Height = 30
            Top = 0
            Width = 300
            Align = alTop
            Alignment = taCenter
            AutoSize = False
            Caption = 'Организации'
            Constraints.MinHeight = 30
            Layout = tlCenter
            ParentFont = False
          end
          object DBListBox1: TDBListBox
            AnchorSideRight.Side = asrBottom
            AnchorSideBottom.Side = asrBottom
            Left = 0
            Height = 644
            Top = 30
            Width = 300
            Align = alClient
            ItemHeight = 0
            TabOrder = 0
          end
        end
        object PSSRight: TPairSplitterSide
          Cursor = crArrow
          Left = 305
          Height = 674
          Top = 0
          Width = 960
          ClientWidth = 960
          ClientHeight = 674
          object PairSplitter2: TPairSplitter
            Cursor = crVSplit
            Left = 0
            Height = 674
            Top = 0
            Width = 960
            Align = alClient
            Position = 350
            SplitterType = pstVertical
            object TPairSplitterSide
              Cursor = crArrow
              Left = 0
              Height = 350
              Top = 0
              Width = 960
              ClientWidth = 960
              ClientHeight = 350
              Constraints.MinHeight = 200
              object TabControl1: TTabControl
                Left = 0
                Height = 350
                Top = 0
                Width = 960
                TabIndex = 0
                Tabs.Strings = (
                  'Основные'
                  'Дополнительные'
                )
                Align = alClient
                TabOrder = 0
                object DBGrid2: TDBGrid
                  Left = 2
                  Height = 318
                  Top = 30
                  Width = 956
                  Align = alClient
                  BorderStyle = bsNone
                  Color = clWindow
                  Columns = <>
                  DataSource = DataSource1
                  Scrollbars = ssAutoBoth
                  TabOrder = 1
                end
              end
            end
            object TPairSplitterSide
              Cursor = crArrow
              Left = 0
              Height = 319
              Top = 355
              Width = 960
              ClientWidth = 960
              ClientHeight = 319
              object DBGrid3: TDBGrid
                Left = 0
                Height = 319
                Top = 0
                Width = 960
                Align = alClient
                BorderStyle = bsNone
                Color = clWindow
                Columns = <>
                Scrollbars = ssAutoBoth
                TabOrder = 0
              end
            end
          end
        end
      end
    end
    object Otchety: TTabSheet
      Caption = 'Отчёты'
    end
    object Spravochniki: TTabSheet
      Caption = 'Справочники'
      ClientHeight = 652
      ClientWidth = 1266
      object Panel1: TPanel
        Left = 0
        Height = 652
        Top = 0
        Width = 300
        Align = alLeft
        BevelOuter = bvNone
        ClientHeight = 652
        ClientWidth = 300
        TabOrder = 0
        object Label2: TLabel
          AnchorSideRight.Side = asrBottom
          Left = 0
          Height = 30
          Top = 0
          Width = 300
          Align = alTop
          Alignment = taCenter
          AutoSize = False
          Caption = 'Справочники'
          Constraints.MinHeight = 30
          Layout = tlCenter
          ParentFont = False
        end
        object BtnOrganizations: TButton
          AnchorSideRight.Side = asrBottom
          Left = 0
          Height = 30
          Top = 30
          Width = 300
          Align = alTop
          Caption = 'Организации'
          TabOrder = 0
        end
        object BtnPredmety: TButton
          AnchorSideRight.Side = asrBottom
          Left = 0
          Height = 30
          Top = 150
          Width = 300
          Align = alTop
          Caption = 'Предметы'
          TabOrder = 1
        end
        object BtnDoljnosty: TButton
          AnchorSideRight.Side = asrBottom
          Left = 0
          Height = 30
          Top = 120
          Width = 300
          Align = alTop
          Caption = 'Должности'
          TabOrder = 2
        end
        object BtnNadbavky: TButton
          AnchorSideRight.Side = asrBottom
          Left = 0
          Height = 30
          Top = 210
          Width = 300
          Align = alTop
          Caption = 'Надбавки'
          TabOrder = 3
        end
        object BtnPersons: TButton
          AnchorSideRight.Side = asrBottom
          Left = 0
          Height = 30
          Top = 90
          Width = 300
          Align = alTop
          Caption = 'Люди'
          TabOrder = 4
        end
        object BtnDoplaty: TButton
          AnchorSideRight.Side = asrBottom
          Left = 0
          Height = 30
          Top = 240
          Width = 300
          Align = alTop
          Caption = 'Доплаты'
          TabOrder = 5
        end
        object BtnStavky: TButton
          AnchorSideRight.Side = asrBottom
          Left = 0
          Height = 30
          Top = 180
          Width = 300
          Align = alTop
          Caption = 'Ставки'
          TabOrder = 6
        end
        object BtnOrgGrups: TButton
          AnchorSideRight.Side = asrBottom
          Left = 0
          Height = 30
          Top = 60
          Width = 300
          Align = alTop
          Caption = 'Орг. группы'
          TabOrder = 7
        end
      end
      object TabControl2: TTabControl
        AnchorSideRight.Side = asrBottom
        AnchorSideBottom.Side = asrBottom
        Left = 300
        Height = 652
        Top = 0
        Width = 966
        TabIndex = 0
        Tabs.Strings = (
          'Все'
          'Актуальные'
        )
        Align = alClient
        TabOrder = 1
        object DBGrid1: TDBGrid
          Left = 2
          Height = 620
          Top = 30
          Width = 962
          Align = alClient
          BorderStyle = bsNone
          Color = clWindow
          Columns = <>
          Scrollbars = ssAutoBoth
          TabOrder = 1
        end
      end
    end
    object Settings: TTabSheet
      Caption = 'настройки'
      ClientHeight = 676
      ClientWidth = 1266
      object GBLoginPassword: TGroupBox
        Left = 0
        Height = 152
        Top = 0
        Width = 256
        Caption = 'Подключение к БД'
        ClientHeight = 122
        ClientWidth = 252
        TabOrder = 0
        object Label3: TLabel
          Left = 8
          Height = 18
          Top = 40
          Width = 40
          Caption = 'Логин'
        end
        object Label4: TLabel
          AnchorSideTop.Side = asrBottom
          Left = 8
          Height = 18
          Top = 72
          Width = 48
          Caption = 'Пароль'
        end
        object EditDbLogin: TEdit
          Left = 63
          Height = 32
          Top = 32
          Width = 181
          TabOrder = 1
          TextHint = 'Логин'
        end
        object EditDbPassword: TEdit
          Left = 63
          Height = 32
          Top = 64
          Width = 181
          EchoMode = emPassword
          PasswordChar = '*'
          TabOrder = 2
          TextHint = 'Пароль'
        end
        object Label5: TLabel
          Left = 8
          Height = 18
          Top = 8
          Width = 28
          Caption = 'Хост'
        end
        object EditDbHost: TEdit
          Left = 63
          Height = 32
          Top = 0
          Width = 181
          TabOrder = 0
          TextHint = 'Хост'
        end
        object BtnConnectToDB: TButton
          Left = 0
          Height = 25
          Top = 97
          Width = 252
          Align = alBottom
          Caption = 'Подключиться'
          OnClick = BtnConnectToDBClick
          TabOrder = 3
        end
      end
      object GBDatabases: TGroupBox
        AnchorSideTop.Side = asrBottom
        Left = 512
        Height = 297
        Top = 0
        Width = 258
        Caption = 'Доступные базы данных'
        ClientHeight = 267
        ClientWidth = 254
        TabOrder = 1
        object NewDatabase: TButton
          AnchorSideTop.Side = asrBottom
          Left = 0
          Height = 28
          Top = 212
          Width = 254
          Align = alBottom
          Caption = 'Новая'
          TabOrder = 0
        end
        object DeleteDatabase: TButton
          Left = 0
          Height = 27
          Top = 240
          Width = 254
          Align = alBottom
          Caption = 'Удалить выделенные'
          TabOrder = 1
        end
        object ListDatabases: TListBox
          Left = 0
          Height = 212
          Top = 0
          Width = 254
          Align = alClient
          Items.Strings = (
            '1'
            '2'
            '3'
            '4'
            '5'
            '6'
            '7'
            '8'
            '9'
          )
          ItemHeight = 24
          MultiSelect = True
          TabOrder = 2
        end
      end
      object GBCurrentDatabase: TGroupBox
        Left = 256
        Height = 72
        Top = 0
        Width = 256
        Caption = 'Текущая база данных'
        ClientHeight = 42
        ClientWidth = 252
        TabOrder = 2
        object CurrentDatabase: TComboBox
          Left = 5
          Height = 32
          Top = 5
          Width = 242
          Align = alTop
          AutoComplete = True
          AutoCompleteText = [cbactEnabled, cbactEndOfLineComplete, cbactSearchAscending]
          AutoDropDown = True
          AutoSelect = False
          BorderSpacing.Around = 5
          ItemHeight = 24
          Items.Strings = (
            'tarifikaciya_2019'
            'tarifikaciya_2020'
            'tarifikaciya_2021'
            'tarifikaciya_2023'
          )
          TabOrder = 0
          TextHint = 'выбрать БД для подключения'
        end
      end
    end
  end
  object PQMainConnection: TPQConnection
    Connected = False
    LoginPrompt = False
    DatabaseName = 'postgres'
    KeepConnection = True
    Password = 'postgres'
    Transaction = SQLTransaction1
    HostName = 'localhost'
    Role = 'postgres'
    Left = 1248
    Top = 37
  end
  object SQLScript1: TSQLScript
    DataBase = PQMainConnection
    Transaction = SQLTransaction1
    Directives.Strings = (
      'SET TERM'
      'COMMIT WORK'
      'COMMIT RETAIN'
      'COMMIT'
      '#IFDEF'
      '#IFNDEF'
      '#ELSE'
      '#ENDIF'
      '#DEFINE'
      '#UNDEF'
      '#UNDEFINE'
    )
    Terminator = ';'
    Left = 1248
    Top = 66
  end
  object SQLTransaction1: TSQLTransaction
    Active = False
    Database = PQMainConnection
    Left = 1248
    Top = 95
  end
  object SQLQuery1: TSQLQuery
    FieldDefs = <>
    Database = PQMainConnection
    Transaction = SQLTransaction1
    Left = 1248
    Top = 124
  end
  object DataSource1: TDataSource
    DataSet = SQLQuery1
    Left = 1248
    Top = 153
  end
  object Dbf1: TDbf
    IndexDefs = <>
    TableLevel = 4
    UseAutoInc = True
    FilterOptions = []
    Left = 1248
    Top = 182
  end
  object IniPropStorage1: TIniPropStorage
    StoredValues = <>
    IniFileName = 'settings.ini'
    IniSection = 'settings'
    Left = 1248
    Top = 211
  end
end
