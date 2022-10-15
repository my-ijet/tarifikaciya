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
    Images = ImageList
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
      ClientHeight = 675
      ClientWidth = 1266
      object Panel1: TPanel
        Left = 0
        Height = 675
        Top = 0
        Width = 300
        Align = alLeft
        BevelOuter = bvNone
        ClientHeight = 675
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
        Height = 675
        Top = 0
        Width = 966
        TabIndex = 0
        Tabs.Strings = (
          'Актуальные'
          'Архивные'
        )
        Align = alClient
        TabOrder = 1
        object DBGrid1: TDBGrid
          Left = 2
          Height = 643
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
      ClientHeight = 675
      ClientWidth = 1266
      object GBLoginPassword: TGroupBox
        Left = 0
        Height = 160
        Top = 0
        Width = 256
        Caption = 'Подключение к БД Postgres 10.22'
        ClientHeight = 130
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
        object BtnConnectToDB: TBitBtn
          AnchorSideLeft.Control = GBLoginPassword
          AnchorSideRight.Control = GBLoginPassword
          AnchorSideRight.Side = asrBottom
          AnchorSideBottom.Control = GBLoginPassword
          AnchorSideBottom.Side = asrBottom
          Left = 0
          Height = 28
          Top = 102
          Width = 252
          Anchors = [akLeft, akRight, akBottom]
          Caption = 'Подключиться'
          Images = ImageList
          ImageIndex = 0
          OnClick = BtnConnectToDBClick
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
        end
      end
      object GBDatabases: TGroupBox
        AnchorSideTop.Side = asrBottom
        Left = 0
        Height = 300
        Top = 168
        Width = 256
        Caption = 'Доступные базы данных'
        ClientHeight = 270
        ClientWidth = 252
        TabOrder = 1
        object ListDatabases: TListBox
          AnchorSideLeft.Control = GBDatabases
          AnchorSideTop.Control = GBDatabases
          AnchorSideRight.Control = GBDatabases
          AnchorSideRight.Side = asrBottom
          AnchorSideBottom.Control = GBDatabases
          AnchorSideBottom.Side = asrBottom
          Left = 0
          Height = 242
          Top = 0
          Width = 252
          Anchors = [akTop, akLeft, akRight, akBottom]
          BorderSpacing.Bottom = 28
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
          TabOrder = 0
        end
        object BtnNewDatabase: TBitBtn
          AnchorSideLeft.Control = GBDatabases
          AnchorSideBottom.Control = GBDatabases
          AnchorSideBottom.Side = asrBottom
          Left = 0
          Height = 28
          Hint = 'Новая'
          Top = 242
          Width = 28
          Anchors = [akLeft, akBottom]
          Images = ImageList
          ImageIndex = 5
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
        end
        object BtnDuplicateDatabase: TBitBtn
          AnchorSideLeft.Control = BtnRenameDatabase
          AnchorSideLeft.Side = asrBottom
          AnchorSideBottom.Control = GBDatabases
          AnchorSideBottom.Side = asrBottom
          Left = 56
          Height = 28
          Hint = 'Дублировать выделенные'
          Top = 242
          Width = 28
          Anchors = [akLeft, akBottom]
          Enabled = False
          Images = ImageList
          ImageIndex = 4
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
        object BtnImportFromFOXPRO: TBitBtn
          AnchorSideLeft.Control = BtnJoinWithCurrentDataBase
          AnchorSideLeft.Side = asrBottom
          AnchorSideBottom.Control = GBDatabases
          AnchorSideBottom.Side = asrBottom
          Left = 112
          Height = 28
          Hint = 'Импорт из старой программы'
          Top = 242
          Width = 28
          Anchors = [akLeft, akBottom]
          Images = ImageList
          ImageIndex = 3
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
        end
        object BtnJoinWithCurrentDataBase: TBitBtn
          AnchorSideLeft.Control = BtnDuplicateDatabase
          AnchorSideLeft.Side = asrBottom
          AnchorSideBottom.Control = GBDatabases
          AnchorSideBottom.Side = asrBottom
          Left = 84
          Height = 28
          Hint = 'Объеденить с текущей'
          Top = 242
          Width = 28
          Anchors = [akLeft, akBottom]
          Enabled = False
          Images = ImageList
          ImageIndex = 8
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
        end
        object BtnDeleteDatabase: TBitBtn
          AnchorSideRight.Control = GBDatabases
          AnchorSideRight.Side = asrBottom
          AnchorSideBottom.Control = GBDatabases
          AnchorSideBottom.Side = asrBottom
          Left = 224
          Height = 28
          Hint = 'Удалить выделенные'
          Top = 242
          Width = 28
          Anchors = [akRight, akBottom]
          Enabled = False
          Images = ImageList
          ImageIndex = 6
          ParentShowHint = False
          ShowHint = True
          TabOrder = 5
        end
        object BtnBackupDatabase: TBitBtn
          AnchorSideLeft.Control = BtnImportFromFOXPRO
          AnchorSideLeft.Side = asrBottom
          AnchorSideBottom.Control = GBDatabases
          AnchorSideBottom.Side = asrBottom
          Left = 140
          Height = 28
          Hint = 'Резервное копирование выделенных'
          Top = 242
          Width = 28
          Anchors = [akLeft, akBottom]
          Enabled = False
          Images = ImageList
          ImageIndex = 2
          ParentShowHint = False
          ShowHint = True
          TabOrder = 6
        end
        object BtnRenameDatabase: TBitBtn
          AnchorSideLeft.Control = BtnNewDatabase
          AnchorSideLeft.Side = asrBottom
          AnchorSideBottom.Control = GBDatabases
          AnchorSideBottom.Side = asrBottom
          Left = 28
          Height = 28
          Hint = 'Переименовать выделенные'
          Top = 242
          Width = 28
          Anchors = [akLeft, akBottom]
          Enabled = False
          Images = ImageList
          ImageIndex = 1
          ParentShowHint = False
          ShowHint = True
          TabOrder = 7
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
      object GBTarifikaciyaTables: TGroupBox
        AnchorSideTop.Side = asrBottom
        Left = 512
        Height = 280
        Top = 0
        Width = 256
        Caption = 'Таблицы тарификации'
        ClientHeight = 250
        ClientWidth = 252
        TabOrder = 3
        object ListTarTables: TListBox
          AnchorSideLeft.Control = GBTarifikaciyaTables
          AnchorSideTop.Control = GBTarifikaciyaTables
          AnchorSideRight.Control = GBTarifikaciyaTables
          AnchorSideRight.Side = asrBottom
          AnchorSideBottom.Control = GBTarifikaciyaTables
          AnchorSideBottom.Side = asrBottom
          Left = 0
          Height = 222
          Top = 0
          Width = 252
          Anchors = [akTop, akLeft, akRight, akBottom]
          BorderSpacing.Bottom = 28
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
          TabOrder = 0
        end
        object BtnDeleteTarTable: TBitBtn
          AnchorSideRight.Control = GBTarifikaciyaTables
          AnchorSideRight.Side = asrBottom
          AnchorSideBottom.Control = GBTarifikaciyaTables
          AnchorSideBottom.Side = asrBottom
          Left = 224
          Height = 28
          Hint = 'Удалить выделенные'
          Top = 222
          Width = 28
          Anchors = [akRight, akBottom]
          Enabled = False
          Images = ImageList
          ImageIndex = 6
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
        end
        object BtnNewTarTable: TBitBtn
          AnchorSideLeft.Control = GBTarifikaciyaTables
          AnchorSideTop.Side = asrBottom
          AnchorSideBottom.Control = GBTarifikaciyaTables
          AnchorSideBottom.Side = asrBottom
          Left = 0
          Height = 28
          Hint = 'Новая'
          Top = 222
          Width = 28
          Anchors = [akLeft, akBottom]
          Images = ImageList
          ImageIndex = 5
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
        object BtnDuplicateTarTable: TBitBtn
          AnchorSideLeft.Side = asrBottom
          AnchorSideTop.Side = asrBottom
          AnchorSideBottom.Control = GBTarifikaciyaTables
          AnchorSideBottom.Side = asrBottom
          Left = 28
          Height = 28
          Hint = 'Дублировать выделенные'
          Top = 222
          Width = 28
          Anchors = [akLeft, akBottom]
          Enabled = False
          Images = ImageList
          ImageIndex = 4
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
        end
      end
      object GBRestoreDatabases: TGroupBox
        AnchorSideTop.Side = asrBottom
        Left = 0
        Height = 200
        Top = 472
        Width = 256
        Caption = 'Резервные копии баз данных'
        ClientHeight = 170
        ClientWidth = 252
        TabOrder = 4
        object ListDatabases_3: TListBox
          AnchorSideLeft.Control = GBRestoreDatabases
          AnchorSideTop.Control = GBRestoreDatabases
          AnchorSideRight.Control = GBRestoreDatabases
          AnchorSideRight.Side = asrBottom
          AnchorSideBottom.Control = GBRestoreDatabases
          AnchorSideBottom.Side = asrBottom
          Left = 0
          Height = 142
          Top = 0
          Width = 252
          Anchors = [akTop, akLeft, akRight, akBottom]
          BorderSpacing.Bottom = 28
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
          TabOrder = 0
        end
        object BtnRestoreDatabase: TBitBtn
          AnchorSideLeft.Control = GBRestoreDatabases
          AnchorSideTop.Side = asrBottom
          AnchorSideBottom.Control = GBRestoreDatabases
          AnchorSideBottom.Side = asrBottom
          Left = 0
          Height = 26
          Hint = 'Восстановить выделенные'
          Top = 144
          Width = 28
          Anchors = [akLeft, akBottom]
          Enabled = False
          Images = ImageList
          ImageIndex = 7
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
        end
        object BtnDeleteBackup: TBitBtn
          AnchorSideRight.Control = GBRestoreDatabases
          AnchorSideRight.Side = asrBottom
          AnchorSideBottom.Control = GBRestoreDatabases
          AnchorSideBottom.Side = asrBottom
          Left = 224
          Height = 27
          Hint = 'Удалить выделенные'
          Top = 143
          Width = 28
          Anchors = [akRight, akBottom]
          Enabled = False
          Images = ImageList
          ImageIndex = 6
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
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
  object TaskDialog1: TTaskDialog
    Buttons = <>
    RadioButtons = <>
    Left = 1248
    Top = 240
  end
  object ImageList: TImageList
    Height = 24
    Width = 24
    Left = 1248
    Top = 269
    Bitmap = {
      4C7A090000001800000018000000BB0500000000000078DAED9A4D881C4514C7
      9FDD9D445C04410D11413CA8A087A0E6DB95A89B3566375E56113D28282468CC
      492FC1431CBDECCE6685C564E7237A08881FDD2D04F420280809DE4491AC6240
      E207BB6B8C7A50A6BB676513A77D35533DDBD376F75457556F363355F0989EA6
      EAF7AF7EAF3EDE540FC0EA2CBE0D6BFD4F605DF4FEE20770AB6BEBCF88B0B1FD
      B3AEA57B688BAEA93FD7C1B6F49FD11A755B1FE3617BA6BE0FDBFF8BE6536B38
      9676B06EC32D8EA9FF48EE7996FEC59F1FC1B5D9D9DAF3841762B735D0FEA0D7
      A7FD776020B3BF3F866BB0ED4F31EC65338DB33CECA0847D90604D5F89C43614
      C3440DB4A7B3F75D1F0B9E9D41E33C8BBFDB71B5B41768BF4EF905D0BA6A98C6
      0F696CF4F16358EF42DD5CB33DC46E906B065FB935CB184CF303D659A275EB49
      EC84E7701DCBD89938BE6D7D6F881D3263BAA35EEB994E75C4C3D4BE736CE381
      D4796FEABF24C4ABDDAFB0BF1C4B7F3CFA3CA97C4B5F4819132E798EE5F9ABBD
      C4B1B63C1AEF9FA869AFF0CE1F3A76D2343CF7FDB51BB9F936DC88EBDFB92ECF
      F06B787E6461E3B3CFD235F65CC2732CF1ACED6136C6F17BD7860D74BCFE2397
      ADCD92EFCB635D1FA5F3679EE8F1ED77C69E962F3AD9320BD1C88BAD4A8635A2
      355EE6BBAD11B8DEBDC6156706B68846D096A50E9D8BC57CF9D934F8F8EC1AFC
      7C360D317E7A3B56BE483B113EEEF7D5BCF8C87E9B3187E0E2FB3E5C25D38FF1
      6B8B7618DB7E99B6CEF3F049DF6B27E17AD7D6CED03DF09B245F65E51336FABE
      427E17B57E3B6A67708DFC5046FF29BB1A1AFFA7F137CECDFE715823CA276CEC
      E74CE77ADA7D0CB1F029BB9495CDC21761A7ED2FA179548DB0ABAC639FE6D023
      D86E2E892FC2CE32FFB2F8441595FFA8FC47E53FAB911FB74FA5ADAB3CFD48D3
      90E51F72761439B795C6AFD9C6FD78AF9647FFD3D852F8963118E137CF688378
      48F1CFB246C331B517C33197165FCBD889BCFD4939F32A9A5FCCFB4B8CCDF1E6
      3F2C6C72C6A3328C2B22FF5950F98FCA7F54FEB3327CF4EBB063EB4FA69DC7F0
      F2C9BED57A77A45F0ADE5B12366ABE29CA0FB183F8353508FBFFCFC8C1479FE0
      F5C598F7AFBE0C7E53C3D49F88D190C6A71A4FC5BD7797953F07FE96CD4F63CB
      F4CF1595FF309E0FC4B149EED42F79C47815468B15982F96C14FB3891270E511
      2C6C118DA02D4B1D62936528E6C9EFA611E5F1F0D33464F1933464F2E3DAF1F0
      B3C44DF1155FF17B889F617F8959DFE618FA3F42EAF1B0713FDBC3B39F8894DC
      F902FE4E5BF745FDCDCAEFA9BCAD0C0B2A6F5B99BC4D063F8B86ECBC4D269F65
      7EC95EF7157F65F853533040ECB2EF332ABED2F83C7B65EE7C86FD05F7B81DBC
      FD6239D7C07DEB58AFE567FD52B63DE48D6EDDE52EA0F9A936EC70E53FD876BE
      2B5B402368CB52875A31677E260D4E3EB386009F494390EFCBE08BB453FC7CF8
      1B77FB03C4F2E2CB7ECEA06C1FF2EEBD67C469FF5F9B5CE31AB949069F70B0EE
      DF5B87DC6F099718B96EDE7BD8DB2CCA0FF1FCE667E8FABEDDCE7A19FE211A5B
      76B9B341BB6D43EED92D0FBA1B64F93F8EBFE911EF26B1FDA5BE83D73F747F4C
      D718F68E45E34B78C4BAC537F378464EB8AF4D0D49EC7E2CFDF0DE6EA20C87F2
      3CFF11D1C892C7F36864FD9D905523893F3E037760EC0F10DE4405C60A27E0EA
      B606C699E7F7E96409EE3C7A14D621F72DBCD740BB88E605E7E4E3151814F9FD
      8B9FBF154B70123F97D05E267D2E14409BACC266D4FC1AEFD58E54E176017E30
      D65F8FD67BE338DC80F77F47DFBC2BCC2FC1059CD777C5D49D211ABC7C8CE570
      60474A70774CDD57D1EA399E3F7C8EF6152FDFB64147DF7C86DF3F9D9E86EB22
      F50E36D7A032EC13E93F396BC0EF7FA19D479B9AAC4081F69BD47B2FF89F9788
      7F708CDC86E3F1047DBFB1D81C9B25D81FFE0F59DF9C5F497E6F17D30FA9EFED
      54595D0563B557BDFF92C757EFBFB29D6BF7FCFA7C19F871F3281A4B5E7E90BB
      C6D50B6B70E557A1BCB8DB98E4CCDF0E75E563BE22E41FAA11EB1FCACE23BED1
      7B2AFF9197FFF068F46AFEF31FF4647F8F
    }
  end
end
