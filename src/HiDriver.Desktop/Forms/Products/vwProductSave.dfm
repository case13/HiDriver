object fvwProductSave: TfvwProductSave
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'HiDriver - Novo Produto'
  ClientHeight = 536
  ClientWidth = 720
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 17
  object lblTitle: TLabel
    Left = 28
    Top = 20
    Width = 147
    Height = 32
    Caption = 'Novo Produto'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 10453282
    Font.Height = -24
    Font.Name = 'Segoe UI Semibold'
    Font.Style = []
    ParentFont = False
  end
  object lblInternalCode: TLabel
    Left = 28
    Top = 72
    Width = 86
    Height = 17
    Caption = 'C'#243'digo interno'
  end
  object lblBarCode: TLabel
    Left = 260
    Top = 72
    Width = 97
    Height = 17
    Caption = 'C'#243'digo de barras'
  end
  object lblOriginalCode: TLabel
    Left = 492
    Top = 72
    Width = 87
    Height = 17
    Caption = 'C'#243'digo original'
  end
  object lblDescription: TLabel
    Left = 28
    Top = 132
    Width = 57
    Height = 17
    Caption = 'Descri'#231#227'o'
  end
  object lblBrandName: TLabel
    Left = 28
    Top = 192
    Width = 35
    Height = 17
    Caption = 'Marca'
  end
  object lblCategoryName: TLabel
    Left = 260
    Top = 192
    Width = 55
    Height = 17
    Caption = 'Categoria'
  end
  object lblVehicleApplication: TLabel
    Left = 28
    Top = 252
    Width = 110
    Height = 17
    Caption = 'Aplica'#231#227'o veicular'
  end
  object lblCurrentStock: TLabel
    Left = 28
    Top = 312
    Width = 77
    Height = 17
    Caption = 'Estoque atual'
  end
  object lblMinimumStock: TLabel
    Left = 196
    Top = 312
    Width = 91
    Height = 17
    Caption = 'Estoque m'#237'nimo'
  end
  object lblCostPrice: TLabel
    Left = 364
    Top = 312
    Width = 85
    Height = 17
    Caption = 'Pre'#231'o de custo'
  end
  object lblSalePrice: TLabel
    Left = 532
    Top = 312
    Width = 90
    Height = 17
    Caption = 'Pre'#231'o de venda'
  end
  object edtInternalCode: TEdit
    Left = 28
    Top = 94
    Width = 204
    Height = 25
    TabOrder = 0
  end
  object edtBarCode: TEdit
    Left = 260
    Top = 94
    Width = 204
    Height = 25
    TabOrder = 1
  end
  object edtOriginalCode: TEdit
    Left = 492
    Top = 94
    Width = 200
    Height = 25
    TabOrder = 2
  end
  object edtDescription: TEdit
    Left = 28
    Top = 154
    Width = 664
    Height = 25
    TabOrder = 3
  end
  object edtBrandName: TEdit
    Left = 28
    Top = 214
    Width = 204
    Height = 25
    TabOrder = 4
  end
  object edtCategoryName: TEdit
    Left = 260
    Top = 214
    Width = 432
    Height = 25
    TabOrder = 5
  end
  object edtVehicleApplication: TEdit
    Left = 28
    Top = 274
    Width = 664
    Height = 25
    TabOrder = 6
  end
  object edtCurrentStock: TEdit
    Left = 28
    Top = 334
    Width = 140
    Height = 25
    TabOrder = 7
    Text = '0'
  end
  object edtMinimumStock: TEdit
    Left = 196
    Top = 334
    Width = 140
    Height = 25
    TabOrder = 8
    Text = '0'
  end
  object edtCostPrice: TEdit
    Left = 364
    Top = 334
    Width = 140
    Height = 25
    TabOrder = 9
    Text = '0'
  end
  object edtSalePrice: TEdit
    Left = 532
    Top = 334
    Width = 160
    Height = 25
    TabOrder = 10
    Text = '0'
  end
  object chkIsActive: TCheckBox
    Left = 28
    Top = 388
    Width = 97
    Height = 21
    Caption = 'Ativo'
    Checked = True
    State = cbChecked
    TabOrder = 11
  end
  object btnSave: TButton
    Left = 436
    Top = 472
    Width = 120
    Height = 38
    Caption = 'Salvar'
    Default = True
    TabOrder = 12
    OnClick = btnSaveClick
  end
  object btnCancel: TButton
    Left = 572
    Top = 472
    Width = 120
    Height = 38
    Cancel = True
    Caption = 'Cancelar'
    ModalResult = 2
    TabOrder = 13
    OnClick = btnCancelClick
  end
  object tmrInitialize: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmrInitializeTimer
    Left = 28
    Top = 476
  end
end
