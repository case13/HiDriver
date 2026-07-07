unit vwProductSave;

interface

uses
  Winapi.Windows,
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  IProductDesktopService,
  ProductDto,
  ProductSaveRequestDto;

type
  TfvwProductSave = class(TForm)
    lblTitle: TLabel;
    lblInternalCode: TLabel;
    edtInternalCode: TEdit;
    lblBarCode: TLabel;
    edtBarCode: TEdit;
    lblOriginalCode: TLabel;
    edtOriginalCode: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    lblBrandName: TLabel;
    edtBrandName: TEdit;
    lblCategoryName: TLabel;
    edtCategoryName: TEdit;
    lblVehicleApplication: TLabel;
    edtVehicleApplication: TEdit;
    lblCurrentStock: TLabel;
    edtCurrentStock: TEdit;
    lblMinimumStock: TLabel;
    edtMinimumStock: TEdit;
    lblCostPrice: TLabel;
    edtCostPrice: TEdit;
    lblSalePrice: TLabel;
    edtSalePrice: TEdit;
    chkIsActive: TCheckBox;
    btnSave: TButton;
    btnCancel: TButton;
    tmrInitialize: TTimer;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure tmrInitializeTimer(Sender: TObject);
  private
    FEditMode: Boolean;
    FLoaded: Boolean;
    FProductId: Integer;
    FProductToEdit: TProductDto;
    FProductService: IProductDesktopServiceContract;
    FSessionExpired: Boolean;
    function BuildRequest: TProductSaveRequestDto;
    procedure CopyProduct(
      ASource: TProductDto;
      ATarget: TProductDto);
    procedure EnsureInputHandles;
    procedure ConfigureForCreate;
    procedure FillFields(AProduct: TProductDto);
    procedure HandleServiceError(const ADefaultMessage: string);
    function LoadProduct: Boolean;
    procedure SetInputText(AEdit: TEdit; const AText: string);
    function TryReadNumber(
      AEdit: TEdit;
      const AFieldName: string;
      out AValue: Double): Boolean;
    function ValidateFields: Boolean;
  protected
    procedure DoShow; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure InitializeForCreate(
      const AProductService: IProductDesktopServiceContract);
    function InitializeForEdit(
      const AProductService: IProductDesktopServiceContract;
      AProductId: Integer): Boolean;
    property SessionExpired: Boolean read FSessionExpired;
  end;

var
  fvwProductSave: TfvwProductSave;

implementation

{$R *.dfm}

uses
  System.SysUtils,
  Vcl.Dialogs;

function TfvwProductSave.BuildRequest: TProductSaveRequestDto;
var
  NumericValue: Double;
begin
  Result := TProductSaveRequestDto.Create;
  try
    NumericValue := 0;
    Result.InternalCode := Trim(edtInternalCode.Text);
    Result.BarCode := Trim(edtBarCode.Text);
    Result.OriginalCode := Trim(edtOriginalCode.Text);
    Result.Description := Trim(edtDescription.Text);
    Result.BrandName := Trim(edtBrandName.Text);
    Result.CategoryName := Trim(edtCategoryName.Text);
    Result.VehicleApplication := Trim(edtVehicleApplication.Text);

    TryStrToFloat(Trim(edtCurrentStock.Text), NumericValue);
    Result.CurrentStock := NumericValue;
    TryStrToFloat(Trim(edtMinimumStock.Text), NumericValue);
    Result.MinimumStock := NumericValue;
    TryStrToFloat(Trim(edtCostPrice.Text), NumericValue);
    Result.CostPrice := NumericValue;
    TryStrToFloat(Trim(edtSalePrice.Text), NumericValue);
    Result.SalePrice := NumericValue;
    Result.IsActive := chkIsActive.Checked;
  except
    Result.Free;
    raise;
  end;
end;

procedure TfvwProductSave.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfvwProductSave.btnSaveClick(Sender: TObject);
var
  Request: TProductSaveRequestDto;
  Saved: Boolean;
begin
  if not ValidateFields then
    Exit;

  Request := BuildRequest;
  btnSave.Enabled := False;
  Screen.Cursor := crHourGlass;
  try
    try
      if FEditMode then
        Saved := FProductService.UpdateProduct(FProductId, Request)
      else
        Saved := FProductService.CreateProduct(Request);

      if not Saved then
      begin
        HandleServiceError('Nao foi possivel salvar o produto.');
        Exit;
      end;

      if FEditMode then
        ShowMessage('Produto atualizado com sucesso.')
      else
        ShowMessage('Produto criado com sucesso.');
      ModalResult := mrOk;
    except
      on E: Exception do
        ShowMessage('Ocorreu um erro inesperado ao salvar o produto.');
    end;
  finally
    Screen.Cursor := crDefault;
    btnSave.Enabled := True;
    Request.Free;
  end;
end;

procedure TfvwProductSave.ConfigureForCreate;
begin
  FEditMode := False;
  FProductId := 0;
  Caption := 'HiDriver - Novo Produto';
  lblTitle.Caption := 'Novo Produto';
  edtInternalCode.Clear;
  edtBarCode.Clear;
  edtOriginalCode.Clear;
  edtDescription.Clear;
  edtBrandName.Clear;
  edtCategoryName.Clear;
  edtVehicleApplication.Clear;
  edtCurrentStock.Text := '0';
  edtMinimumStock.Text := '0';
  edtCostPrice.Text := '0';
  edtSalePrice.Text := '0';
  chkIsActive.Checked := True;
end;

procedure TfvwProductSave.CopyProduct(
  ASource: TProductDto;
  ATarget: TProductDto);
begin
  ATarget.Id := ASource.Id;
  ATarget.InternalCode := ASource.InternalCode;
  ATarget.BarCode := ASource.BarCode;
  ATarget.OriginalCode := ASource.OriginalCode;
  ATarget.Description := ASource.Description;
  ATarget.BrandName := ASource.BrandName;
  ATarget.CategoryName := ASource.CategoryName;
  ATarget.VehicleApplication := ASource.VehicleApplication;
  ATarget.CurrentStock := ASource.CurrentStock;
  ATarget.MinimumStock := ASource.MinimumStock;
  ATarget.CostPrice := ASource.CostPrice;
  ATarget.SalePrice := ASource.SalePrice;
  ATarget.IsActive := ASource.IsActive;
end;

constructor TfvwProductSave.Create(AOwner: TComponent);
begin
  inherited;
  ConfigureForCreate;
end;

destructor TfvwProductSave.Destroy;
begin
  FProductToEdit.Free;
  inherited;
end;

procedure TfvwProductSave.FillFields(AProduct: TProductDto);
begin
  SetInputText(edtInternalCode, AProduct.InternalCode);
  SetInputText(edtBarCode, AProduct.BarCode);
  SetInputText(edtOriginalCode, AProduct.OriginalCode);
  SetInputText(edtDescription, AProduct.Description);
  SetInputText(edtBrandName, AProduct.BrandName);
  SetInputText(edtCategoryName, AProduct.CategoryName);
  SetInputText(edtVehicleApplication, AProduct.VehicleApplication);
  SetInputText(
    edtCurrentStock,
    FormatFloat('0.###', AProduct.CurrentStock));
  SetInputText(
    edtMinimumStock,
    FormatFloat('0.###', AProduct.MinimumStock));
  SetInputText(edtCostPrice, FormatCurr('0.00', AProduct.CostPrice));
  SetInputText(edtSalePrice, FormatCurr('0.00', AProduct.SalePrice));
  chkIsActive.Checked := AProduct.IsActive;
end;

procedure TfvwProductSave.DoShow;
begin
  inherited;
  tmrInitialize.Enabled := True;
end;

procedure TfvwProductSave.EnsureInputHandles;
begin
  if edtInternalCode.Handle = 0 then Exit;
  if edtBarCode.Handle = 0 then Exit;
  if edtOriginalCode.Handle = 0 then Exit;
  if edtDescription.Handle = 0 then Exit;
  if edtBrandName.Handle = 0 then Exit;
  if edtCategoryName.Handle = 0 then Exit;
  if edtVehicleApplication.Handle = 0 then Exit;
  if edtCurrentStock.Handle = 0 then Exit;
  if edtMinimumStock.Handle = 0 then Exit;
  if edtCostPrice.Handle = 0 then Exit;
  if edtSalePrice.Handle = 0 then Exit;
  if chkIsActive.Handle = 0 then Exit;
end;

procedure TfvwProductSave.HandleServiceError(
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

procedure TfvwProductSave.InitializeForCreate(
  const AProductService: IProductDesktopServiceContract);
begin
  FProductService := AProductService;
  ConfigureForCreate;
end;

function TfvwProductSave.InitializeForEdit(
  const AProductService: IProductDesktopServiceContract;
  AProductId: Integer): Boolean;
begin
  FProductService := AProductService;
  FEditMode := True;
  FProductId := AProductId;
  FLoaded := False;
  Caption := 'HiDriver - Editar Produto';
  lblTitle.Caption := 'Editar Produto';
  Result := LoadProduct;
end;

function TfvwProductSave.LoadProduct: Boolean;
var
  ProductItem: TProductDto;
begin
  Result := False;
  btnSave.Enabled := False;
  Screen.Cursor := crHourGlass;
  try
    try
      ProductItem := FProductService.GetProductById(FProductId);
      try
        if not Assigned(ProductItem) then
        begin
          HandleServiceError('Produto nao encontrado.');
          Exit;
        end;

        FProductToEdit.Free;
        FProductToEdit := TProductDto.Create;
        CopyProduct(ProductItem, FProductToEdit);
        Result := True;
      finally
        ProductItem.Free;
      end;
    except
      on E: Exception do
        ShowMessage('Ocorreu um erro inesperado ao carregar o produto.');
    end;
  finally
    Screen.Cursor := crDefault;
    btnSave.Enabled := True;
  end;
end;

procedure TfvwProductSave.SetInputText(
  AEdit: TEdit;
  const AText: string);
begin
  AEdit.Text := AText;
  SetWindowText(AEdit.Handle, PChar(AText));
end;

function TfvwProductSave.TryReadNumber(
  AEdit: TEdit;
  const AFieldName: string;
  out AValue: Double): Boolean;
begin
  Result := TryStrToFloat(Trim(AEdit.Text), AValue);
  if Result then
    Exit;

  ShowMessage(AFieldName + ' deve ser um numero valido.');
  AEdit.SetFocus;
end;

function TfvwProductSave.ValidateFields: Boolean;
var
  Value: Double;
begin
  Result := False;
  if Trim(edtDescription.Text) = '' then
  begin
    ShowMessage('A descricao e obrigatoria.');
    edtDescription.SetFocus;
    Exit;
  end;

  if not TryReadNumber(edtCurrentStock, 'Estoque atual', Value) then
    Exit;
  if Value < 0 then
  begin
    ShowMessage('O estoque atual nao pode ser negativo.');
    edtCurrentStock.SetFocus;
    Exit;
  end;

  if not TryReadNumber(edtMinimumStock, 'Estoque minimo', Value) then
    Exit;
  if Value < 0 then
  begin
    ShowMessage('O estoque minimo nao pode ser negativo.');
    edtMinimumStock.SetFocus;
    Exit;
  end;

  if not TryReadNumber(edtCostPrice, 'Preco de custo', Value) then
    Exit;
  if Value < 0 then
  begin
    ShowMessage('O preco de custo nao pode ser negativo.');
    edtCostPrice.SetFocus;
    Exit;
  end;

  if not TryReadNumber(edtSalePrice, 'Preco de venda', Value) then
    Exit;
  if Value < 0 then
  begin
    ShowMessage('O preco de venda nao pode ser negativo.');
    edtSalePrice.SetFocus;
    Exit;
  end;

  Result := True;
end;

procedure TfvwProductSave.tmrInitializeTimer(Sender: TObject);
begin
  tmrInitialize.Enabled := False;
  EnsureInputHandles;
  if FEditMode and Assigned(FProductToEdit) then
  begin
    FillFields(FProductToEdit);
    FLoaded := True;
  end;

  if edtInternalCode.CanFocus then
    edtInternalCode.SetFocus;
end;

end.
