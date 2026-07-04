object LoginForm: TLoginForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'HiDriver - Sign in'
  ClientHeight = 356
  ClientWidth = 476
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object lblTitle: TLabel
    Left = 40
    Top = 28
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
  object lblSubtitle: TLabel
    Left = 40
    Top = 65
    Width = 277
    Height = 17
    Caption = 'Sign in to access the desktop application'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object lblUserName: TLabel
    Left = 40
    Top = 110
    Width = 60
    Height = 17
    Caption = 'Username'
  end
  object lblPassword: TLabel
    Left = 40
    Top = 174
    Width = 57
    Height = 17
    Caption = 'Password'
  end
  object lblHint: TLabel
    Left = 40
    Top = 322
    Width = 308
    Height = 15
    Caption = 'Credentials are sent only to the API and are never stored.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object edtUserName: TEdit
    Left = 40
    Top = 132
    Width = 396
    Height = 25
    TabOrder = 0
  end
  object edtPassword: TEdit
    Left = 40
    Top = 196
    Width = 396
    Height = 25
    PasswordChar = '*'
    TabOrder = 1
  end
  object btnLogin: TButton
    Left = 40
    Top = 246
    Width = 122
    Height = 34
    Caption = 'Sign in'
    Default = True
    TabOrder = 2
    OnClick = btnLoginClick
  end
  object btnTestApi: TButton
    Left = 177
    Top = 246
    Width = 122
    Height = 34
    Caption = 'Test API'
    TabOrder = 3
    OnClick = btnTestApiClick
  end
  object btnExit: TButton
    Left = 314
    Top = 246
    Width = 122
    Height = 34
    Cancel = True
    Caption = 'Exit'
    TabOrder = 4
    OnClick = btnExitClick
  end
end
