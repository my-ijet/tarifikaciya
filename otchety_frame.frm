object OtchetyFrame: TOtchetyFrame
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
  object PageControl1: TPageControl
    Left = 0
    Height = 720
    Top = 0
    Width = 1280
    ActivePage = RequisiteTab
    Align = alClient
    TabIndex = 1
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Отчёт'
    end
    object RequisiteTab: TTabSheet
      Caption = 'Реквизиты'
      ClientHeight = 685
      ClientWidth = 1276
      object GroupBox1: TGroupBox
        AnchorSideLeft.Control = RequisiteTab
        AnchorSideLeft.Side = asrCenter
        AnchorSideTop.Control = RequisiteTab
        Left = 314
        Height = 281
        Top = 0
        Width = 649
        Caption = 'Реквизиты'
        ClientHeight = 251
        ClientWidth = 645
        TabOrder = 0
        object Label7: TLabel
          Left = 10
          Height = 18
          Top = 10
          Width = 86
          Caption = 'Организация'
        end
        object Label8: TLabel
          Left = 10
          Height = 18
          Top = 72
          Width = 89
          Caption = 'Руководитель'
        end
        object Label9: TLabel
          Left = 10
          Height = 18
          Top = 104
          Width = 85
          Caption = 'Исполнитель'
        end
      end
    end
  end
end
