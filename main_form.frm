object MainForm: TMainForm
  Left = 358
  Height = 720
  Top = 256
  Width = 1280
  HorzScrollBar.Page = 842
  HorzScrollBar.Tracking = True
  VertScrollBar.Page = 708
  VertScrollBar.Tracking = True
  AutoScroll = True
  BorderWidth = 5
  ClientHeight = 720
  ClientWidth = 1280
  Constraints.MinHeight = 360
  Constraints.MinWidth = 640
  DefaultMonitor = dmDesktop
  DoubleBuffered = False
  OnClose = FormClose
  OnCreate = FormCreate
  ParentDoubleBuffered = False
  Position = poScreenCenter
  SessionProperties = 'WindowState'
  LCLVersion = '7.9'
  Visible = True
  object MainPageControl: TPageControl
    Left = 5
    Height = 710
    Top = 5
    Width = 1270
    ActivePage = Service
    Align = alClient
    Images = ImageList
    TabIndex = 3
    TabOrder = 0
    OnChange = MainPageControlChange
    object TarifikaciyaTab: TTabSheet
      Caption = 'Тарификация'
    end
    object OtchetyTab: TTabSheet
      Caption = 'Отчёты'
    end
    object SpravochnikyTab: TTabSheet
      Caption = 'Справочники'
    end
    object Service: TTabSheet
      Caption = 'Сервис'
      ClientHeight = 675
      ClientWidth = 1266
      object Panel1: TPanel
        Left = 0
        Height = 28
        Top = 647
        Width = 1266
        Align = alBottom
        BevelOuter = bvNone
        ClientHeight = 28
        ClientWidth = 1266
        TabOrder = 0
        object InfoTarDbConnection: TCheckBox
          Left = 0
          Height = 28
          Top = 0
          Width = 255
          Align = alLeft
          BidiMode = bdRightToLeft
          Caption = 'Состояние подключения к серверу:'
          Enabled = False
          ParentFont = False
          ParentBidiMode = False
          TabOrder = 0
          TabStop = False
        end
      end
      object ServicePageControl: TPageControl
        Left = 0
        Height = 647
        Top = 0
        Width = 1266
        ActivePage = TabSheet2
        Align = alClient
        TabIndex = 0
        TabOrder = 1
        object TabSheet2: TTabSheet
          Caption = 'Базы данных'
          ClientHeight = 612
          ClientWidth = 1262
          object GBRestoreDatabases: TGroupBox
            AnchorSideRight.Side = asrBottom
            Left = 0
            Height = 300
            Top = 300
            Width = 270
            Caption = 'Резервные копии баз данных'
            ClientHeight = 270
            ClientWidth = 266
            TabOrder = 0
            object BtnDeleteBackup: TBitBtn
              AnchorSideRight.Control = GBRestoreDatabases
              AnchorSideRight.Side = asrBottom
              AnchorSideBottom.Control = GBRestoreDatabases
              AnchorSideBottom.Side = asrBottom
              Left = 238
              Height = 27
              Hint = 'Удалить выделенные'
              Top = 243
              Width = 28
              Anchors = [akRight, akBottom]
              Images = ImageList
              ImageIndex = 6
              OnClick = BtnDeleteBackupClick
              ParentShowHint = False
              ShowHint = True
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
              Top = 244
              Width = 28
              Anchors = [akLeft, akBottom]
              Images = ImageList
              ImageIndex = 7
              OnClick = BtnRestoreDatabaseClick
              ParentShowHint = False
              ShowHint = True
              TabOrder = 1
            end
            object ListDatabaseBackups: TListBox
              AnchorSideLeft.Control = GBRestoreDatabases
              AnchorSideTop.Control = GBRestoreDatabases
              AnchorSideRight.Control = GBRestoreDatabases
              AnchorSideRight.Side = asrBottom
              AnchorSideBottom.Control = GBRestoreDatabases
              AnchorSideBottom.Side = asrBottom
              Left = 0
              Height = 242
              Top = 0
              Width = 266
              Anchors = [akTop, akLeft, akRight, akBottom]
              BorderSpacing.Bottom = 28
              ItemHeight = 0
              MultiSelect = True
              TabOrder = 2
            end
          end
          object GBDatabases: TGroupBox
            Left = 0
            Height = 300
            Top = 0
            Width = 272
            Caption = 'Доступные базы данных'
            ClientHeight = 270
            ClientWidth = 268
            TabOrder = 1
            object ListDatabases: TDBLookupListBox
              Left = 0
              Height = 242
              Top = 0
              Width = 268
              Align = alClient
              BorderSpacing.Bottom = 28
              KeyField = 'databases'
              ListFieldIndex = 0
              ListSource = TarDataModule.DSAllDatabases
              LookupCache = False
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
              OnClick = BtnNewDatabaseClick
              ParentShowHint = False
              ShowHint = True
              TabOrder = 1
            end
            object BtnDuplicateDatabase: TBitBtn
              AnchorSideLeft.Side = asrBottom
              AnchorSideBottom.Control = GBDatabases
              AnchorSideBottom.Side = asrBottom
              Left = 56
              Height = 28
              Hint = 'Дублировать выделенную'
              Top = 242
              Width = 28
              Anchors = [akLeft, akBottom]
              Images = ImageList
              ImageIndex = 4
              OnClick = BtnDuplicateDatabaseClick
              ParentShowHint = False
              ShowHint = True
              TabOrder = 2
            end
            object BtnImportFromFOXPRO: TBitBtn
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
              OnClick = BtnImportFromFOXPROClick
              ParentShowHint = False
              ShowHint = True
              TabOrder = 3
            end
            object BtnJoinWithCurrentDataBase: TBitBtn
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
              Left = 240
              Height = 28
              Hint = 'Удалить выделенную'
              Top = 242
              Width = 28
              Anchors = [akRight, akBottom]
              Images = ImageList
              ImageIndex = 6
              OnClick = BtnDeleteDatabaseClick
              ParentShowHint = False
              ShowHint = True
              TabOrder = 5
            end
            object BtnBackupDatabase: TBitBtn
              AnchorSideLeft.Side = asrBottom
              AnchorSideBottom.Control = GBDatabases
              AnchorSideBottom.Side = asrBottom
              Left = 140
              Height = 28
              Hint = 'Резервное копирование выделенной'
              Top = 242
              Width = 28
              Anchors = [akLeft, akBottom]
              Images = ImageList
              ImageIndex = 2
              OnClick = BtnBackupDatabaseClick
              ParentShowHint = False
              ShowHint = True
              TabOrder = 6
            end
            object BtnRenameDatabase: TBitBtn
              AnchorSideLeft.Side = asrBottom
              AnchorSideBottom.Control = GBDatabases
              AnchorSideBottom.Side = asrBottom
              Left = 28
              Height = 28
              Hint = 'Переименовать выделенную'
              Top = 242
              Width = 28
              Anchors = [akLeft, akBottom]
              Images = ImageList
              ImageIndex = 1
              OnClick = BtnRenameDatabaseClick
              ParentShowHint = False
              ShowHint = True
              TabOrder = 7
            end
          end
          object GBCurrentDatabase: TGroupBox
            AnchorSideLeft.Side = asrCenter
            Left = 272
            Height = 72
            Top = 0
            Width = 296
            Caption = 'Текущая база данных'
            ClientHeight = 42
            ClientWidth = 292
            TabOrder = 2
            object ListCurrentDatabase: TDBLookupComboBox
              Left = 5
              Height = 32
              Hint = 'выбрать БД для подключения'
              Top = 5
              Width = 282
              Align = alTop
              BorderSpacing.Around = 5
              KeyField = 'databases'
              ListFieldIndex = 0
              ListSource = TarDataModule.DSAllDatabases
              LookupCache = False
              OnChange = ListCurrentDatabaseChange
              ParentShowHint = False
              ShowHint = True
              Style = csDropDownList
              TabOrder = 0
            end
          end
          object GBTarifikaciyaTables: TGroupBox
            AnchorSideTop.Side = asrBottom
            Left = 568
            Height = 312
            Top = 0
            Width = 256
            Caption = 'Даты тарификаций'
            ClientHeight = 282
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
              Height = 254
              Top = 0
              Width = 252
              Anchors = [akTop, akLeft, akRight, akBottom]
              BorderSpacing.Bottom = 28
              ItemHeight = 0
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
              Top = 254
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
              Top = 254
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
              Top = 254
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
        end
        object TabSheet3: TTabSheet
          Caption = 'Настройки подключения'
          ClientHeight = 612
          ClientWidth = 1262
          ParentBiDiMode = False
          object GBLoginPassword: TGroupBox
            AnchorSideLeft.Control = TabSheet3
            AnchorSideLeft.Side = asrCenter
            AnchorSideTop.Control = TabSheet3
            AnchorSideRight.Side = asrBottom
            Left = 503
            Height = 192
            Top = 5
            Width = 256
            BorderSpacing.Top = 5
            Caption = 'Подключение к БД Postgres 10.22'
            ClientHeight = 162
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
            object EditHostLogin: TEdit
              Left = 63
              Height = 32
              Top = 32
              Width = 181
              OnEditingDone = EditHostLoginEditingDone
              TabOrder = 1
              TextHint = 'Логин'
            end
            object EditHostPassword: TEdit
              Left = 63
              Height = 32
              Top = 64
              Width = 181
              OnEditingDone = EditHostPasswordEditingDone
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
            object EditHostIP: TEdit
              Left = 63
              Height = 32
              Top = 0
              Width = 181
              OnEditingDone = EditHostIPEditingDone
              TabOrder = 0
              TextHint = 'Хост'
            end
            object Label6: TLabel
              AnchorSideTop.Side = asrBottom
              Left = 8
              Height = 18
              Top = 104
              Width = 17
              Caption = 'БД'
            end
            object EditHostDbName: TEdit
              Left = 63
              Height = 32
              Top = 96
              Width = 181
              OnEditingDone = EditHostDbNameEditingDone
              TabOrder = 3
              TextHint = 'База данных'
            end
            object BtnConnectToHost: TButton
              AnchorSideLeft.Control = GBLoginPassword
              AnchorSideRight.Control = GBLoginPassword
              AnchorSideRight.Side = asrBottom
              AnchorSideBottom.Control = GBLoginPassword
              AnchorSideBottom.Side = asrBottom
              Left = 0
              Height = 28
              Top = 134
              Width = 252
              Anchors = [akLeft, akRight, akBottom]
              Caption = 'Подключиться'
              OnClick = BtnConnectToHostClick
              ParentShowHint = False
              ShowHint = True
              TabOrder = 4
            end
          end
        end
      end
    end
  end
  object ListCurrentTarifikationDate: TDBLookupComboBox
    AnchorSideTop.Control = Owner
    AnchorSideRight.Side = asrBottom
    Left = 480
    Height = 32
    Hint = 'Дата основной тарификации'
    Top = 5
    Width = 99
    ListFieldIndex = 0
    LookupCache = False
    OnChange = ListCurrentTarifikationDateChange
    ParentShowHint = False
    ReadOnly = True
    ShowHint = True
    Style = csDropDownList
    TabOrder = 1
  end
  object Ini: TIniPropStorage
    StoredValues = <>
    IniFileName = 'settings.ini'
    IniSection = 'settings'
    Left = 1248
    Top = 211
  end
  object ImageList: TImageList
    Height = 24
    Width = 24
    Left = 1248
    Top = 240
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
  object CalendarDialog1: TCalendarDialog
    Date = 44853
    OKCaption = '&ОК'
    CancelCaption = 'Отмена'
    Left = 1248
    Top = 269
  end
end
