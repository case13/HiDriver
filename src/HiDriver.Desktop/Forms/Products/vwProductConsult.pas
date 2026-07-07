unit vwProductConsult;

interface

uses
  System.Classes,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Grids,
  Vcl.StdCtrls,
  GridFilterHelper,
  IProductDesktopService,
  ProductDto, Vcl.Buttons, Vcl.ComCtrls, Vcl.ToolWin, Vcl.ExtCtrls;

type
  TfvwProductConsult = class(TForm)
    Panel1: TPanel;
    lblTitle: TLabel;
    Panel4: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    Panel3: TPanel;
    gridProducts: TStringGrid;
    Panel5: TPanel;
    lblTotal: TLabel;
    SpeedButton4: TSpeedButton;
    Shape2: TShape;
    Shape1: TShape;
    Label1: TLabel;
    btnRefresh: TSpeedButton;
    edtSearch: TEdit;
    procedure btnCloseClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure edtSearchChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure gridProductsClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
  private
    FLoaded: Boolean;
    FGridFilter: TGridFilterHelper;
    FProducts: TProductDtoList;
    FProductService: IProductDesktopServiceContract;
    FSearchResult: TProductDtoReferenceList;
    FSelectedProductId: Integer;
    FSessionExpired: Boolean;
    procedure ApplyFilter;
    procedure ConfigureGrid;
    procedure ConfigureGridFilter;
    procedure FillGrid;
    procedure GridFilterChanged(Sender: TObject);
    procedure HandleLoadError;
    procedure HandleServiceError(const ADefaultMessage: string);
    procedure LoadProducts;
    function GetSessionExpired: Boolean;
    function SelectedProduct: TProductDto;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(
      const AProductService: IProductDesktopServiceContract);
    property SessionExpired: Boolean read GetSessionExpired;
  end;

var
  fvwProductConsult: TfvwProductConsult;

implementation

{$R *.dfm}

uses
  System.SysUtils,
  System.UITypes,
  Vcl.Dialogs,
  vwProductSave;

procedure TfvwProductConsult.ApplyFilter;
var
  FilterField: string;
  FilteredProducts: TProductDtoReferenceList;
  SortDirection: string;
  SortField: string;
begin
  FilterField := 'description';
  SortField := 'description';
  SortDirection := 'asc';
  if Assigned(FGridFilter) then
  begin
    FilterField := FGridFilter.SelectedFilterField;
    SortField := FGridFilter.SelectedSortField;
    SortDirection := FGridFilter.SelectedSortDirection;
  end;

  FilteredProducts := FProductService.SearchProductsLocal(
    FProducts,
    edtSearch.Text,
    FilterField,
    SortField,
    SortDirection);
  FSearchResult.Free;
  FSearchResult := FilteredProducts;
  FillGrid;
end;

procedure TfvwProductConsult.BitBtn1Click(Sender: TObject);
var
  EditForm: TfvwProductSave;
begin
  EditForm := TfvwProductSave.Create(Application);
  try
    EditForm.InitializeForCreate(FProductService);
    if EditForm.ShowModal = mrOk then
      LoadProducts;

    if EditForm.SessionExpired then
    begin
      FSessionExpired := True;
      ModalResult := mrCancel;
    end;
  finally
    EditForm.Free;
  end;
end;

procedure TfvwProductConsult.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfvwProductConsult.btnDeleteClick(Sender: TObject);
var
  ProductItem: TProductDto;
begin
  ProductItem := SelectedProduct;
  if not Assigned(ProductItem) then
  begin
    ShowMessage('Selecione um produto para excluir.');
    Exit;
  end;

  if MessageDlg(
    'Deseja realmente excluir este produto?',
    mtConfirmation,
    [mbYes, mbNo],
    0) <> mrYes then
    Exit;

  try
    if not FProductService.DeleteProduct(ProductItem.Id) then
    begin
      HandleServiceError('Nao foi possivel excluir o produto.');
      Exit;
    end;

    ShowMessage('Produto excluido com sucesso.');
    LoadProducts;
  except
    on E: Exception do
      ShowMessage('Ocorreu um erro inesperado ao excluir o produto.');
  end;
end;

procedure TfvwProductConsult.btnEditClick(Sender: TObject);
var
  EditForm: TfvwProductSave;
  ProductItem: TProductDto;
begin
  ProductItem := SelectedProduct;
  if not Assigned(ProductItem) then
  begin
    ShowMessage('Selecione um produto para editar.');
    Exit;
  end;

  EditForm := TfvwProductSave.Create(Application);
  try
    if EditForm.InitializeForEdit(FProductService, ProductItem.Id) then
      if EditForm.ShowModal = mrOk then
        LoadProducts;

    if EditForm.SessionExpired then
    begin
      FSessionExpired := True;
      ModalResult := mrCancel;
    end;
  finally
    EditForm.Free;
  end;
end;

procedure TfvwProductConsult.btnNewClick(Sender: TObject);
var
  EditForm: TfvwProductSave;
begin
  EditForm := TfvwProductSave.Create(Application);
  try
    EditForm.InitializeForCreate(FProductService);
    if EditForm.ShowModal = mrOk then
      LoadProducts;

    if EditForm.SessionExpired then
    begin
      FSessionExpired := True;
      ModalResult := mrCancel;
    end;
  finally
    EditForm.Free;
  end;
end;

procedure TfvwProductConsult.ConfigureGrid;
begin
  gridProducts.ColCount := 9;
  gridProducts.FixedCols := 0;
  gridProducts.FixedRows := 1;
  gridProducts.Cells[0, 0] := 'Codigo';
  gridProducts.Cells[1, 0] := 'Descricao';
  gridProducts.Cells[2, 0] := 'Marca';
  gridProducts.Cells[3, 0] := 'Categoria';
  gridProducts.Cells[4, 0] := 'Aplicacao';
  gridProducts.Cells[5, 0] := 'Estoque atual';
  gridProducts.Cells[6, 0] := 'Estoque min.';
  gridProducts.Cells[7, 0] := 'Preco venda';
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

procedure TfvwProductConsult.ConfigureGridFilter;
begin
  if not Assigned(FGridFilter) then
  begin
    FGridFilter := TGridFilterHelper.Create(
      gridProducts,
      'description',
      1,
      gsdAscending);
    gridProducts.OnDrawCell := FGridFilter.HandleGridDrawCell;
    gridProducts.OnMouseDown := FGridFilter.HandleGridMouseDown;
  end
  else
    FGridFilter.ClearMappings;

  FGridFilter.OnFilterChanged := nil;
  FGridFilter.MapColumn(0, 'internalCode');
  FGridFilter.MapColumn(1, 'description');
  FGridFilter.MapColumn(2, 'brandName');
  FGridFilter.MapColumn(3, 'categoryName');
  FGridFilter.MapColumn(4, 'vehicleApplication');
  FGridFilter.MapColumn(5, 'currentStock');
  FGridFilter.MapColumn(6, 'minimumStock');
  FGridFilter.MapColumn(7, 'salePrice');
  FGridFilter.MapColumn(8, 'status');
  FGridFilter.SelectDefaultColumn;
  FGridFilter.OnFilterChanged := GridFilterChanged;
end;

constructor TfvwProductConsult.Create(AOwner: TComponent);
begin
  inherited;
  FProducts := TProductDtoList.Create(True);
  FSearchResult := TProductDtoReferenceList.Create;
  ConfigureGrid;
  ConfigureGridFilter;
  FillGrid;
end;

destructor TfvwProductConsult.Destroy;
begin
  gridProducts.OnDrawCell := nil;
  gridProducts.OnMouseDown := nil;
  FGridFilter.Free;
  FSearchResult.Free;
  FProducts.Free;
  inherited;
end;

procedure TfvwProductConsult.edtSearchChange(Sender: TObject);
begin
  if Assigned(FProductService) then
    ApplyFilter;
end;

procedure TfvwProductConsult.FillGrid;
var
  ColumnIndex: Integer;
  ProductItem: TProductDto;
  RowIndex: Integer;
begin
  FSelectedProductId := 0;
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

  if Assigned(FGridFilter) then
    FGridFilter.ApplySelectedHeaderStyle;
end;

procedure TfvwProductConsult.FormShow(Sender: TObject);
begin
  if not FLoaded then
  begin
    FLoaded := True;
    LoadProducts;
  end;
end;

function TfvwProductConsult.GetSessionExpired: Boolean;
begin
  Result := FSessionExpired;
end;

procedure TfvwProductConsult.GridFilterChanged(Sender: TObject);
begin
  if Assigned(FProductService) then
    ApplyFilter
  else if Assigned(FGridFilter) then
    FGridFilter.ApplySelectedHeaderStyle;
end;

procedure TfvwProductConsult.HandleLoadError;
begin
  HandleServiceError('Nao foi possivel carregar os produtos.');
end;

procedure TfvwProductConsult.HandleServiceError(
  const ADefaultMessage: string);
begin
  if FProductService.LastStatusCode = 401 then
  begin
    FSessionExpired := True;
    ShowMessage(
      'Sua sessao expirou ou o token e invalido. Faca login novamente.');
    ModalResult := mrCancel;
    Exit;
  end;

  if FProductService.LastStatusCode = 0 then
    ShowMessage(
      'Nao foi possivel conectar a API. Verifique se ela esta em execucao.')
  else if FProductService.LastError <> '' then
    ShowMessage(FProductService.LastError)
  else
    ShowMessage(ADefaultMessage);
end;

procedure TfvwProductConsult.Initialize(
  const AProductService: IProductDesktopServiceContract);
begin
  FProductService := AProductService;
end;

procedure TfvwProductConsult.LoadProducts;
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
      if Assigned(FGridFilter) then
        FGridFilter.EnsureSelectedColumnExists;
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

procedure TfvwProductConsult.gridProductsClick(Sender: TObject);
var
  ProductIndex: Integer;
begin
  ProductIndex := gridProducts.Row - 1;
  if (ProductIndex >= 0) and
    (ProductIndex < FSearchResult.Count) then
    FSelectedProductId := FSearchResult[ProductIndex].Id
  else
    FSelectedProductId := 0;
end;

function TfvwProductConsult.SelectedProduct: TProductDto;
var
  ProductItem: TProductDto;
begin
  Result := nil;
  if FSelectedProductId <= 0 then
    Exit;

  for ProductItem in FSearchResult do
    if ProductItem.Id = FSelectedProductId then
      Exit(ProductItem);
end;

procedure TfvwProductConsult.SpeedButton1Click(Sender: TObject);
var
  EditForm: TfvwProductSave;
begin
  EditForm := TfvwProductSave.Create(Application);
  try
    EditForm.InitializeForCreate(FProductService);
    if EditForm.ShowModal = mrOk then
      LoadProducts;

    if EditForm.SessionExpired then
    begin
      FSessionExpired := True;
      ModalResult := mrCancel;
    end;
  finally
    EditForm.Free;
  end;
end;

procedure TfvwProductConsult.SpeedButton2Click(Sender: TObject);
var
  EditForm: TfvwProductSave;
  ProductItem: TProductDto;
begin
  ProductItem := SelectedProduct;
  if not Assigned(ProductItem) then
  begin
    ShowMessage('Selecione um produto para editar.');
    Exit;
  end;

  EditForm := TfvwProductSave.Create(Application);
  try
    if EditForm.InitializeForEdit(FProductService, ProductItem.Id) then
      if EditForm.ShowModal = mrOk then
        LoadProducts;

    if EditForm.SessionExpired then
    begin
      FSessionExpired := True;
      ModalResult := mrCancel;
    end;
  finally
    EditForm.Free;
  end;
end;

procedure TfvwProductConsult.SpeedButton3Click(Sender: TObject);
var
  ProductItem: TProductDto;
begin
  ProductItem := SelectedProduct;
  if not Assigned(ProductItem) then
  begin
    ShowMessage('Selecione um produto para excluir.');
    Exit;
  end;

  if MessageDlg(
    'Deseja realmente excluir este produto?',
    mtConfirmation,
    [mbYes, mbNo],
    0) <> mrYes then
    Exit;

  try
    if not FProductService.DeleteProduct(ProductItem.Id) then
    begin
      HandleServiceError('Nao foi possivel excluir o produto.');
      Exit;
    end;

    ShowMessage('Produto excluido com sucesso.');
    LoadProducts;
  except
    on E: Exception do
      ShowMessage('Ocorreu um erro inesperado ao excluir o produto.');
  end;
end;

procedure TfvwProductConsult.SpeedButton4Click(Sender: TObject);
begin
 close;
end;

procedure TfvwProductConsult.btnRefreshClick(Sender: TObject);
begin
  LoadProducts;
end;

end.
