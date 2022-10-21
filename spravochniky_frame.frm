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
  object GBSpravochniki: TGroupBox
    Left = 0
    Height = 720
    Top = 0
    Width = 153
    Align = alLeft
    Caption = 'Справочники'
    ClientHeight = 690
    ClientWidth = 149
    TabOrder = 0
    object BtnOrganizations: TButton
      AnchorSideRight.Side = asrBottom
      Left = 0
      Height = 30
      Top = 0
      Width = 149
      Align = alTop
      Caption = 'Организации'
      TabOrder = 0
    end
    object BtnPredmety: TButton
      AnchorSideRight.Side = asrBottom
      Left = 0
      Height = 30
      Top = 120
      Width = 149
      Align = alTop
      Caption = 'Предметы'
      TabOrder = 1
    end
    object BtnDoljnosty: TButton
      AnchorSideRight.Side = asrBottom
      Left = 0
      Height = 30
      Top = 90
      Width = 149
      Align = alTop
      Caption = 'Должности'
      TabOrder = 2
    end
    object BtnNadbavky: TButton
      AnchorSideRight.Side = asrBottom
      Left = 0
      Height = 30
      Top = 180
      Width = 149
      Align = alTop
      Caption = 'Надбавки'
      TabOrder = 3
    end
    object BtnPersons: TButton
      AnchorSideRight.Side = asrBottom
      Left = 0
      Height = 30
      Top = 60
      Width = 149
      Align = alTop
      Caption = 'Люди'
      TabOrder = 4
    end
    object BtnDoplaty: TButton
      AnchorSideRight.Side = asrBottom
      Left = 0
      Height = 30
      Top = 210
      Width = 149
      Align = alTop
      Caption = 'Доплаты'
      TabOrder = 5
    end
    object BtnStavky: TButton
      AnchorSideRight.Side = asrBottom
      Left = 0
      Height = 30
      Top = 150
      Width = 149
      Align = alTop
      Caption = 'Ставки'
      TabOrder = 6
    end
    object BtnOrgGrups: TButton
      AnchorSideRight.Side = asrBottom
      Left = 0
      Height = 30
      Top = 30
      Width = 149
      Align = alTop
      Caption = 'Орг. группы'
      TabOrder = 7
    end
  end
  object DBGrid1: TDBGrid
    Left = 153
    Height = 720
    Top = 0
    Width = 1127
    Align = alClient
    AutoFillColumns = True
    Color = clWindow
    Columns = <    
      item
        Title.Caption = 'id'
        Width = 273
        FieldName = 'id'
      end    
      item
        Title.Caption = 'firstname'
        Width = 273
        FieldName = 'firstname'
      end    
      item
        Title.Caption = 'middlename'
        Width = 272
        FieldName = 'middlename'
      end    
      item
        Title.Caption = 'familyname'
        Width = 272
        FieldName = 'familyname'
      end>
    DataSource = TarDataModule.DataSource1
    TabOrder = 1
  end
end
