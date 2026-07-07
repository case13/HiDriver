object fvwCustomerSave: TfvwCustomerSave
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'HiDriver - Novo Cliente'
  ClientHeight = 456
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
    Width = 128
    Height = 32
    Caption = 'Novo Cliente'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 10453282
    Font.Height = -24
    Font.Name = 'Segoe UI Semibold'
    Font.Style = []
    ParentFont = False
  end
  object lblName: TLabel
    Left = 28
    Top = 72
    Width = 35
    Height = 17
    Caption = 'Nome'
  end
  object lblDocument: TLabel
    Left = 492
    Top = 72
    Width = 71
    Height = 17
    Caption = 'Documento'
  end
  object lblPhone: TLabel
    Left = 28
    Top = 132
    Width = 51
    Height = 17
    Caption = 'Telefone'
  end
  object lblEmail: TLabel
    Left = 260
    Top = 132
    Width = 35
    Height = 17
    Caption = 'Email'
  end
  object lblAddress: TLabel
    Left = 28
    Top = 192
    Width = 56
    Height = 17
    Caption = 'Endere'#231'o'
  end
  object lblCity: TLabel
    Left = 28
    Top = 252
    Width = 43
    Height = 17
    Caption = 'Cidade'
  end
  object lblState: TLabel
    Left = 492
    Top = 252
    Width = 39
    Height = 17
    Caption = 'Estado'
  end
  object lblZipCode: TLabel
    Left = 588
    Top = 252
    Width = 24
    Height = 17
    Caption = 'CEP'
  end
  object edtName: TEdit
    Left = 28
    Top = 94
    Width = 436
    Height = 25
    TabOrder = 0
  end
  object edtDocument: TEdit
    Left = 492
    Top = 94
    Width = 200
    Height = 25
    TabOrder = 1
  end
  object edtPhone: TEdit
    Left = 28
    Top = 154
    Width = 204
    Height = 25
    TabOrder = 2
  end
  object edtEmail: TEdit
    Left = 260
    Top = 154
    Width = 432
    Height = 25
    TabOrder = 3
  end
  object edtAddress: TEdit
    Left = 28
    Top = 214
    Width = 664
    Height = 25
    TabOrder = 4
  end
  object edtCity: TEdit
    Left = 28
    Top = 274
    Width = 436
    Height = 25
    TabOrder = 5
  end
  object edtState: TEdit
    Left = 492
    Top = 274
    Width = 68
    Height = 25
    MaxLength = 2
    TabOrder = 6
  end
  object edtZipCode: TEdit
    Left = 588
    Top = 274
    Width = 104
    Height = 25
    TabOrder = 7
  end
  object chkIsActive: TCheckBox
    Left = 28
    Top = 328
    Width = 97
    Height = 21
    Caption = 'Ativo'
    Checked = True
    State = cbChecked
    TabOrder = 8
  end
  object btnSave: TButton
    Left = 436
    Top = 392
    Width = 120
    Height = 38
    Caption = 'Salvar'
    Default = True
    TabOrder = 9
    OnClick = btnSaveClick
  end
  object btnCancel: TButton
    Left = 572
    Top = 392
    Width = 120
    Height = 38
    Cancel = True
    Caption = 'Cancelar'
    ModalResult = 2
    TabOrder = 10
    OnClick = btnCancelClick
  end
  object tmrInitialize: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmrInitializeTimer
    Left = 28
    Top = 396
  end
end
