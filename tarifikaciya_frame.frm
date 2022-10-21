object TarifikaciyaFrame: TTarifikaciyaFrame
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
  object PairSplitter1: TPairSplitter
    AnchorSideRight.Side = asrBottom
    AnchorSideBottom.Side = asrBottom
    Left = 0
    Height = 719
    Top = 0
    Width = 1279
    Align = alClient
    BorderSpacing.Right = 1
    BorderSpacing.Bottom = 1
    Position = 300
    object PSSOrganizatons: TPairSplitterSide
      Cursor = crArrow
      Left = 0
      Height = 719
      Top = 0
      Width = 300
      ClientWidth = 300
      ClientHeight = 719
      Constraints.MaxWidth = 800
      Constraints.MinWidth = 300
      object GBOrganizations: TGroupBox
        Left = 0
        Height = 719
        Top = 0
        Width = 300
        Align = alClient
        Caption = 'Организации'
        ClientHeight = 689
        ClientWidth = 296
        TabOrder = 0
        object ListOrganizations: TListBox
          Left = 0
          Height = 689
          Top = 0
          Width = 296
          Align = alClient
          BorderStyle = bsNone
          ExtendedSelect = False
          ItemHeight = 0
          TabOrder = 0
        end
      end
    end
    object PSSRight: TPairSplitterSide
      Cursor = crArrow
      Left = 305
      Height = 719
      Top = 0
      Width = 974
      ClientWidth = 974
      ClientHeight = 719
      object PairSplitter2: TPairSplitter
        Cursor = crVSplit
        Left = 0
        Height = 719
        Top = 0
        Width = 974
        Align = alClient
        Position = 350
        SplitterType = pstVertical
        object PSUp: TPairSplitterSide
          Cursor = crArrow
          Left = 0
          Height = 350
          Top = 0
          Width = 974
          ClientWidth = 974
          ClientHeight = 350
          Constraints.MinHeight = 200
          object TabControl1: TTabControl
            AnchorSideRight.Side = asrBottom
            Left = 0
            Height = 350
            Top = 0
            Width = 832
            TabIndex = 0
            Tabs.Strings = (
              'Основные'
              'Дополнительные'
            )
            Align = alLeft
            TabOrder = 0
          end
        end
        object PSDown: TPairSplitterSide
          Cursor = crArrow
          Left = 0
          Height = 364
          Top = 355
          Width = 974
        end
      end
    end
  end
end
