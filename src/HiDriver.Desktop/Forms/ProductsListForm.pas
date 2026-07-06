unit ProductsListForm;

interface

uses
  System.Classes,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Grids,
  Vcl.StdCtrls,
  IProductDesktopService,
  ProductDto;

type
  TProductsListForm = class(TForm)
    lblTitle: TLabel;
    lblSearch: TLabel;
    edtSearch: TEdit;
    btnRefresh: TButton;
    btnClose: TButton;
    gridProducts: TStringGrid;
    lblTotal: TLabel;
    lblSearchHint: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure edtSearchChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FLoaded: Boolean;
    FProducts: TProductDtoList;
    FProductService: IProductDesktopServiceContract;
    FSearchResult: TProductDtoReferenceList;
    FSessionExpired: Boolean;
    procedure ApplyFilter;
    procedure ConfigureGrid;
    procedure FillGrid;
    procedure HandleLoadError;
    procedure LoadProducts;
    function GetSessionExpired: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(
      const AProductService: IProductDesktopServiceContract);
    property SessionExpired: Boolean read GetSessionExpired;
  end;

implementation

{$R *.dfm}

uses
  System.SysUtils,
  Vcl.Dialogs;

procedure TProductsListForm.ApplyFilter;
var
  FilteredProducts: TProductDtoReferenceList;
begin
  FilteredProducts := FProductService.SearchProductsLocal(
    FProducts,
    edtSearch.Text);
  FSearchResult.Free;
  FSearchResult := FilteredProducts;
  FillGrid;
end;

procedure TProductsListForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TProductsListForm.btnRefreshClick(Sender: TObject);
begin
  LoadProducts;
end;

procedure TProductsListForm.ConfigureGrid;
begin
  gridProducts.ColCount := 9;
  gridProducts.FixedCols := 0;
  gridProducts.FixedRows := 1;
  gridProducts.Cells[0, 0] := 'Código';
  gridProducts.Cells[1, 0] := 'Descrição';
  gridProducts.Cells[2, 0] := 'Marca';
  gridProducts.Cells[3, 0] := 'Categoria';
  gridProducts.Cells[4, 0] := 'Aplicação';
  gridProducts.Cells[5, 0] := 'Estoque atual';
  gridProducts.Cells[6, 0] := 'Estoque mín.';
  gridProducts.Cells[7, 0] := 'Preço venda';
  gridProducts.Cells[8, 0] := 'Status';
  gridProducts.ColWidths[0] := 90;
  gridProducts.ColWidths[1] := 230;
  gridProducts.ColWidths[2] := 120;
  gridProducts.ColWidths[3] := 120;
  gridProducts.ColWidths[4] := 220;
  gridProducts.ColWidths[5] := 90;
  gridProducts.ColWidths[6] := 90;
  gridProducts.ColWidths[7] := 95;
  gridProducts.ColWidths[8] := 75;
end;

constructor TProductsListForm.Create(AOwner: TComponent);
begin
  inherited;
  FProducts := TProductDtoList.Create(True);
  FSearchResult := TProductDtoReferenceList.Create;
  ConfigureGrid;
  FillGrid;
end;

destructor TProductsListForm.Destroy;
begin
  FSearchResult.Free;
  FProducts.Free;
  inherited;
end;

procedure TProductsListForm.edtSearchChange(Sender: TObject);
begin
  if Assigned(FProductService) then
    ApplyFilter;
end;

procedure TProductsListForm.FillGrid;
var
  ColumnIndex: Integer;
  ProductItem: TProductDto;
  RowIndex: Integer;
begin
  if FSearchResult.Count = 0 then
    gridProducts.RowCount := 2
  else
    gridProducts.RowCount := FSearchResult.Count + 1;

  for RowIndex := 1 to gridProducts.RowCount - 1 do
    for ColumnIndex := 0 to gridProducts.ColCount - 1 do
      gridProducts.Cells[ColumnIndex, RowIndex] := '';

  RowIndex := 1;
  for ProductItem in FSearchResult do
  begin
    gridProducts.Cells[0, RowIndex] := ProductItem.InternalCode;
    gridProducts.Cells[1, RowIndex] := ProductItem.Description;
    gridProducts.Cells[2, RowIndex] := ProductItem.BrandName;
    gridProducts.Cells[3, RowIndex] := ProductItem.CategoryName;
    gridProducts.Cells[4, RowIndex] := ProductItem.VehicleApplication;
    gridProducts.Cells[5, RowIndex] := FormatFloat(
      '0.###',
      ProductItem.CurrentStock);
    gridProducts.Cells[6, RowIndex] := FormatFloat(
      '0.###',
      ProductItem.MinimumStock);
    gridProducts.Cells[7, RowIndex] := FormatCurr(
      '0.00',
      ProductItem.SalePrice);
    if ProductItem.IsActive then
      gridProducts.Cells[8, RowIndex] := 'Ativo'
    else
      gridProducts.Cells[8, RowIndex] := 'Inativo';
    Inc(RowIndex);
  end;

  lblTotal.Caption := Format(
    'Total: %d produto(s)',
    [FSearchResult.Count]);
end;

procedure TProductsListForm.FormShow(Sender: TObject);
begin
  if not FLoaded then
  begin
    FLoaded := True;
    LoadProducts;
  end;
end;

function TProductsListForm.GetSessionExpired: Boolean;
begin
  Result := FSessionExpired;
end;

procedure TProductsListForm.HandleLoadError;
begin
  if FProductService.LastStatusCode = 401 then
  begin
    FSessionExpired := True;
    ShowMessage(
      'Sua sessão expirou ou o token é inválido. Faça login novamente.');
    ModalResult := mrCancel;
    Exit;
  end;

  if FProductService.LastStatusCode = 0 then
    ShowMessage(
      'Não foi possível conectar à API. Verifique se ela está em execução.')
  else if FProductService.LastError <> '' then
    ShowMessage(FProductService.LastError)
  else
    ShowMessage('Não foi possível carregar os produtos.');
end;

procedure TProductsListForm.Initialize(
  const AProductService: IProductDesktopServiceContract);
begin
  FProductService := AProductService;
end;

procedure TProductsListForm.LoadProducts;
var
  LoadedProducts: TProductDtoList;
begin
  btnRefresh.Enabled := False;
  Screen.Cursor := crHourGlass;
  try
    try
      LoadedProducts := FProductService.GetProducts;
      if not Assigned(LoadedProducts) then
      begin
        HandleLoadError;
        Exit;
      end;

      FSearchResult.Free;
      FSearchResult := nil;
      FProducts.Free;
      FProducts := LoadedProducts;
      FSearchResult := TProductDtoReferenceList.Create;
      ApplyFilter;

      if FProducts.Count = 0 then
        ShowMessage('Nenhum produto foi encontrado.');
    except
      on E: Exception do
        ShowMessage('Ocorreu um erro inesperado ao carregar os produtos.');
    end;
  finally
    Screen.Cursor := crDefault;
    btnRefresh.Enabled := True;
  end;
end;

end.
