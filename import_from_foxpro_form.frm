object ImportFromFoxProForm: TImportFromFoxProForm
  Left = 344
  Height = 250
  Top = 256
  Width = 330
  BorderStyle = bsDialog
  Caption = 'Импорт из старой базы данных'
  ClientHeight = 250
  ClientWidth = 330
  OnCreate = FormCreate
  PopupMode = pmExplicit
  PopupParent = MainForm.Owner
  Position = poOwnerFormCenter
  LCLVersion = '7.9'
  object EditDbName: TEdit
    AnchorSideTop.Side = asrCenter
    Left = 152
    Height = 32
    Top = 80
    Width = 168
    TabOrder = 0
  end
  object BtnOk: TButton
    AnchorSideBottom.Control = Owner
    AnchorSideBottom.Side = asrBottom
    Left = 40
    Height = 25
    Top = 220
    Width = 75
    Anchors = [akLeft, akBottom]
    BorderSpacing.Bottom = 5
    Caption = 'ОК'
    ModalResult = 1
    OnClick = BtnOkClick
    TabOrder = 1
  end
  object BtnCancel: TButton
    AnchorSideBottom.Control = Owner
    AnchorSideBottom.Side = asrBottom
    Left = 208
    Height = 25
    Top = 220
    Width = 75
    Anchors = [akLeft, akBottom]
    BorderSpacing.Bottom = 5
    Caption = 'Отмена'
    ModalResult = 2
    OnClick = BtnCancelClick
    TabOrder = 2
  end
  object DirFoxPro: TDirectoryEdit
    Left = 152
    Height = 32
    Top = 9
    Width = 168
    Directory = '/home/ijet/Applications/tar-22-07-01'
    DialogTitle = 'Выбор директории баз данных FoxPro'
    DialogOptions = [ofNoChangeDir, ofPathMustExist, ofEnableSizing, ofViewDetail]
    ShowHidden = False
    ButtonWidth = 23
    DirectInput = False
    NumGlyphs = 1
    MaxLength = 0
    TabOrder = 3
    Text = '/home/ijet/Applications/tar-22-07-01'
  end
  object LabelDbName: TLabel
    AnchorSideTop.Control = EditDbName
    AnchorSideTop.Side = asrCenter
    Left = 16
    Height = 18
    Top = 87
    Width = 129
    Caption = 'Название новой БД:'
  end
  object Log: TMemo
    Left = 10
    Height = 90
    Top = 120
    Width = 310
    Lines.Strings = (
      'Укажите название базы данных'
      'и путь до директории содержащей'
      'старые базы тарификации'
    )
    TabOrder = 4
  end
  object LabelPathToFoxPro: TLabel
    AnchorSideTop.Control = DirFoxPro
    AnchorSideTop.Side = asrCenter
    Left = 16
    Height = 18
    Top = 16
    Width = 120
    Caption = 'Путь до старой БД:'
  end
  object GNewOrCurrentDB: TRadioGroup
    Left = 10
    Height = 32
    Top = 48
    Width = 310
    AutoFill = True
    ChildSizing.LeftRightSpacing = 6
    ChildSizing.EnlargeHorizontal = crsHomogenousChildResize
    ChildSizing.EnlargeVertical = crsHomogenousChildResize
    ChildSizing.ShrinkHorizontal = crsScaleChilds
    ChildSizing.ShrinkVertical = crsScaleChilds
    ChildSizing.Layout = cclLeftToRightThenTopToBottom
    ChildSizing.ControlsPerLine = 2
    ClientHeight = 28
    ClientWidth = 306
    Columns = 2
    ItemIndex = 0
    Items.Strings = (
      'Создать новую'
      'Импорт в текущую'
    )
    TabOrder = 5
  end
  object FoxProDbf: TDbf
    IndexDefs = <>
    ReadOnly = True
    TableLevel = 25
    UseAutoInc = True
    FilterOptions = []
    Left = 10
    Top = 10
  end
  object QInsertFromFoxPro: TSQLQuery
    FieldDefs = <>
    Database = TarDataModule.MainConnection
    Transaction = TarDataModule.MainTransaction
    UpdateMode = upWhereChanged
    Left = 39
    Top = 10
  end
end
