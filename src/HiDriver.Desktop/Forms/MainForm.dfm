object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'HiDriver'
  ClientHeight = 494
  ClientWidth = 744
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 17
  object lblTitle: TLabel
    Left = 32
    Top = 24
    Width = 103
    Height = 32
    Caption = 'HiDriver'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 10453282
    Font.Height = -24
    Font.Name = 'Segoe UI Semibold'
    Font.Style = []
    ParentFont = False
  end
  object lblWelcome: TLabel
    Left = 32
    Top = 76
    Width = 70
    Height = 17
    Caption = 'Signed in as'
  end
  object lblRole: TLabel
    Left = 32
    Top = 101
    Width = 27
    Height = 17
    Caption = 'Role'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object lblResult: TLabel
    Left = 32
    Top = 175
    Width = 120
    Height = 17
    Caption = 'API response (JSON)'
  end
  object btnProtectedRequest: TButton
    Left = 432
    Top = 130
    Width = 188
    Height = 34
    Caption = 'Test protected endpoint'
    TabOrder = 2
    OnClick = btnProtectedRequestClick
  end
  object btnProducts: TButton
    Left = 32
    Top = 130
    Width = 188
    Height = 34
    Caption = 'Produtos'
    TabOrder = 0
    OnClick = btnProductsClick
  end
  object btnCustomers: TButton
    Left = 232
    Top = 130
    Width = 188
    Height = 34
    Caption = 'Clientes'
    TabOrder = 1
    OnClick = btnCustomersClick
  end
  object btnLogout: TButton
    Left = 600
    Top = 24
    Width = 112
    Height = 34
    Caption = 'Sign out'
    TabOrder = 3
    OnClick = btnLogoutClick
  end
  object mmResult: TMemo
    Left = 32
    Top = 198
    Width = 680
    Height = 264
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 4
    WordWrap = False
  end
end
