object ProductsListForm: TProductsListForm
  Left = 0
  Top = 0
  Caption = 'HiDriver - Produtos'
  ClientHeight = 640
  ClientWidth = 1180
  Color = clWhite
  Constraints.MinHeight = 480
  Constraints.MinWidth = 900
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object lblTitle: TLabel
    Left = 24
    Top = 20
    Width = 100
    Height = 32
    Caption = 'Produtos'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 10453282
    Font.Height = -24
    Font.Name = 'Segoe UI Semibold'
    Font.Style = []
    ParentFont = False
  end
  object lblSearch: TLabel
    Left = 24
    Top = 72
    Width = 40
    Height = 17
    Caption = 'Buscar'
  end
  object lblSearchHint: TLabel
    Left = 24
    Top = 118
    Width = 361
    Height = 15
    Caption = 'Filtro local por descrição, códigos, marca, categoria ou aplicação'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object lblTotal: TLabel
    Left = 24
    Top = 607
    Width = 104
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Total: 0 produto(s)'
  end
  object edtSearch: TEdit
    Left = 24
    Top = 91
    Width = 520
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnChange = edtSearchChange
  end
  object btnRefresh: TButton
    Left = 911
    Top = 82
    Width = 110
    Height = 34
    Anchors = [akTop, akRight]
    Caption = 'Atualizar'
    TabOrder = 1
    OnClick = btnRefreshClick
  end
  object btnClose: TButton
    Left = 1037
    Top = 82
    Width = 110
    Height = 34
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = 'Fechar'
    TabOrder = 2
    OnClick = btnCloseClick
  end
  object gridProducts: TStringGrid
    Left = 24
    Top = 142
    Width = 1123
    Height = 449
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 9
    DefaultRowHeight = 23
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
    TabOrder = 3
  end
end
