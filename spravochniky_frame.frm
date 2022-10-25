object SpravochnikyFrame: TSpravochnikyFrame
  Left = 0
  Height = 720
  Top = 0
  Width = 1280
  Align = alClient
  ClientHeight = 720
  ClientWidth = 1280
  TabOrder = 0
  DesignLeft = 86
  DesignTop = 85
  object GroupActive: TRadioGroup
    AnchorSideLeft.Side = asrBottom
    AnchorSideRight.Side = asrBottom
    Left = 121
    Height = 33
    Top = 0
    Width = 231
    AutoFill = True
    ChildSizing.LeftRightSpacing = 6
    ChildSizing.EnlargeHorizontal = crsHomogenousChildResize
    ChildSizing.EnlargeVertical = crsHomogenousChildResize
    ChildSizing.ShrinkHorizontal = crsScaleChilds
    ChildSizing.ShrinkVertical = crsScaleChilds
    ChildSizing.Layout = cclLeftToRightThenTopToBottom
    ChildSizing.ControlsPerLine = 2
    ClientHeight = 29
    ClientWidth = 227
    Columns = 2
    ItemIndex = 0
    Items.Strings = (
      'Актуальные'
      'Архивные'
    )
    OnSelectionChanged = GroupActiveSelectionChanged
    TabOrder = 0
  end
  object GBSpravochniki: TGroupBox
    Left = 0
    Height = 720
    Top = 0
    Width = 121
    Align = alLeft
    Caption = 'Справочники'
    ClientHeight = 690
    ClientWidth = 117
    TabOrder = 1
    object ListTables: TListBox
      Left = 0
      Height = 690
      Top = 0
      Width = 117
      Align = alClient
      BorderStyle = bsNone
      Items.Strings = (
        'Организации'
        'Орг. группы'
        'Люди'
        'Образование'
        'Рабочие группы'
        'Должности'
        'Категории'
        'Предметы'
        'Ставки'
        'Надбавки'
        'Доплаты'
      )
      ItemHeight = 24
      OnClick = ListTablesClick
      TabOrder = 0
    end
  end
  object PageControl: TPageControl
    Left = 121
    Height = 687
    Top = 33
    Width = 1159
    ActivePage = TabStavky
    Align = alClient
    BorderSpacing.Top = 33
    TabIndex = 8
    TabOrder = 2
    object TabOrganizations: TTabSheet
      Caption = 'Организации'
      ClientHeight = 652
      ClientWidth = 1155
      TabVisible = False
      object DBGrid2: TDBGrid
        Left = 0
        Height = 652
        Top = 0
        Width = 1155
        Align = alClient
        AutoFillColumns = True
        Color = clWindow
        Columns = <>
        DataSource = TarDataModule.DSSpravochniky
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColumnMove, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiselect]
        Scrollbars = ssAutoBoth
        TabOrder = 0
      end
    end
    object TabOrgGroups: TTabSheet
      Caption = 'Орг. группы'
      ClientHeight = 650
      ClientWidth = 1151
      TabVisible = False
      object DBGrid3: TDBGrid
        Left = 0
        Height = 652
        Top = 0
        Width = 1155
        Align = alClient
        AutoFillColumns = True
        Color = clWindow
        Columns = <>
        DataSource = TarDataModule.DSSpravochniky
        Scrollbars = ssAutoBoth
        TabOrder = 0
      end
    end
    object TabPersons: TTabSheet
      Caption = 'Люди'
      ClientHeight = 652
      ClientWidth = 1155
      TabVisible = False
      object DBGrid1: TDBGrid
        Left = 0
        Height = 652
        Top = 0
        Width = 1155
        Align = alClient
        AutoFillColumns = True
        Color = clWindow
        Columns = <>
        DataSource = TarDataModule.DSSpravochniky
        Flat = True
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColumnMove, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgRowHighlight]
        Scrollbars = ssAutoBoth
        TabOrder = 0
      end
    end
    object TabObrazovanie: TTabSheet
      Caption = 'Образования'
      ClientHeight = 652
      ClientWidth = 1155
      TabVisible = False
      object DBGrid4: TDBGrid
        Left = 0
        Height = 652
        Top = 0
        Width = 1155
        Align = alClient
        AutoFillColumns = True
        Color = clWindow
        Columns = <>
        DataSource = TarDataModule.DSSpravochniky
        Scrollbars = ssAutoBoth
        TabOrder = 0
      end
    end
    object TabPersonalGroups: TTabSheet
      Caption = 'Рабочие группы'
      ClientHeight = 652
      ClientWidth = 1155
      TabVisible = False
      object DBGrid5: TDBGrid
        Left = 0
        Height = 652
        Top = 0
        Width = 1155
        Align = alClient
        AutoFillColumns = True
        Color = clWindow
        Columns = <>
        DataSource = TarDataModule.DSSpravochniky
        Scrollbars = ssAutoBoth
        TabOrder = 0
      end
    end
    object TabDoljnost: TTabSheet
      Caption = 'Должности'
      ClientHeight = 652
      ClientWidth = 1155
      TabVisible = False
      object DBGrid6: TDBGrid
        Left = 0
        Height = 652
        Top = 0
        Width = 1155
        Align = alClient
        AutoFillColumns = True
        Color = clWindow
        Columns = <>
        DataSource = TarDataModule.DSSpravochniky
        Scrollbars = ssAutoBoth
        TabOrder = 0
      end
    end
    object TabKategories: TTabSheet
      Caption = 'Категории'
      ClientHeight = 652
      ClientWidth = 1155
      TabVisible = False
      object DBGrid7: TDBGrid
        Left = 0
        Height = 652
        Top = 0
        Width = 1155
        Align = alClient
        AutoFillColumns = True
        Color = clWindow
        Columns = <>
        DataSource = TarDataModule.DSSpravochniky
        Scrollbars = ssAutoBoth
        TabOrder = 0
      end
    end
    object TabPredmety: TTabSheet
      Caption = 'Предметы'
      ClientHeight = 652
      ClientWidth = 1155
      TabVisible = False
      object DBGrid8: TDBGrid
        Left = 0
        Height = 652
        Top = 0
        Width = 1155
        Align = alClient
        AutoFillColumns = True
        Color = clWindow
        Columns = <>
        DataSource = TarDataModule.DSSpravochniky
        Scrollbars = ssAutoBoth
        TabOrder = 0
      end
    end
    object TabStavky: TTabSheet
      Caption = 'Ставки'
      ClientHeight = 652
      ClientWidth = 1155
      TabVisible = False
      object DBGrid9: TDBGrid
        Left = 0
        Height = 652
        Top = 0
        Width = 1155
        Align = alClient
        AutoFillColumns = True
        Color = clWindow
        Columns = <>
        DataSource = TarDataModule.DSSpravochniky
        Scrollbars = ssAutoBoth
        TabOrder = 0
      end
    end
    object TabNadbavky: TTabSheet
      Caption = 'Надбавки'
      ClientHeight = 652
      ClientWidth = 1155
      TabVisible = False
      object DBGrid10: TDBGrid
        Left = 0
        Height = 652
        Top = 0
        Width = 1155
        Align = alClient
        AutoFillColumns = True
        Color = clWindow
        Columns = <>
        DataSource = TarDataModule.DSSpravochniky
        Scrollbars = ssAutoBoth
        TabOrder = 0
      end
    end
    object TabDoplaty: TTabSheet
      Caption = 'Доплаты'
      ClientHeight = 650
      ClientWidth = 1151
      TabVisible = False
      object DBGrid11: TDBGrid
        Left = 0
        Height = 652
        Top = 0
        Width = 1155
        Align = alClient
        AutoFillColumns = True
        Color = clWindow
        Columns = <>
        DataSource = TarDataModule.DSSpravochniky
        Scrollbars = ssAutoBoth
        TabOrder = 0
      end
    end
  end
  object DBNavigator1: TDBNavigator
    AnchorSideTop.Control = GroupActive
    AnchorSideTop.Side = asrCenter
    Left = 360
    Height = 20
    Top = 6
    Width = 200
    AutoSize = True
    BevelOuter = bvNone
    ChildSizing.EnlargeHorizontal = crsScaleChilds
    ChildSizing.EnlargeVertical = crsScaleChilds
    ChildSizing.ShrinkHorizontal = crsScaleChilds
    ChildSizing.ShrinkVertical = crsScaleChilds
    ChildSizing.Layout = cclLeftToRightThenTopToBottom
    ChildSizing.ControlsPerLine = 100
    ClientHeight = 20
    ClientWidth = 200
    ConfirmDelete = False
    DataSource = TarDataModule.DSSpravochniky
    Options = []
    TabOrder = 3
  end
end
