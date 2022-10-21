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
  object RadioGroup1: TRadioGroup
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
        'Должности'
        'Предметы'
        'Ставки'
        'Надбавки'
        'Доплаты'
      )
      ItemHeight = 24
      ItemIndex = 0
      OnClick = ListTablesClick
      TabOrder = 0
    end
  end
  object PageControl1: TPageControl
    Left = 121
    Height = 687
    Top = 33
    Width = 1159
    ActivePage = TabOrganizations
    Align = alClient
    BorderSpacing.Top = 33
    TabIndex = 0
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
        Color = clWindow
        Columns = <>
        Scrollbars = ssAutoBoth
        TabOrder = 0
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Орг. группы'
      TabVisible = False
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
        Columns = <        
          item
            Title.Caption = 'id'
            Width = 285
            FieldName = 'id'
          end        
          item
            Title.Caption = 'familyname'
            Width = 285
            FieldName = 'familyname'
          end        
          item
            Title.Caption = 'firstname'
            Width = 285
            FieldName = 'firstname'
          end        
          item
            Title.Caption = 'middlename'
            Width = 284
            FieldName = 'middlename'
          end>
        DataSource = TarDataModule.DSSprPersons
        Scrollbars = ssAutoBoth
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Должности'
      TabVisible = False
    end
    object TabSheet3: TTabSheet
      Caption = 'Предметы'
      TabVisible = False
    end
    object TabSheet4: TTabSheet
      Caption = 'TabSheet4'
      TabVisible = False
    end
    object TabSheet5: TTabSheet
      Caption = 'TabSheet5'
      TabVisible = False
    end
    object TabSheet6: TTabSheet
      Caption = 'TabSheet6'
      TabVisible = False
    end
    object TabSheet7: TTabSheet
      Caption = 'TabSheet7'
      TabVisible = False
    end
  end
end
