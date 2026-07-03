unit ProductAppService;

interface

uses
  ProductAppServiceIntf,
  ProductDtos,
  ProductRepositoryIntf,
  ProductValidatorIntf;

type
  TProductAppService = class(TInterfacedObject, IProductAppService)
  private
    FProductRepository: IProductRepository;
    FProductValidator: IProductValidator;
  protected
    function IProductAppService.Create = CreateProduct;
    function CreateProduct(AProduct: TProductCreateDto): string;
  public
    constructor Create(
      const AProductRepository: IProductRepository;
      const AProductValidator: IProductValidator);
    function GetAll: string;
    function GetById(AId: Integer): string;
    function Update(AId: Integer; AProduct: TProductUpdateDto): string;
    function Delete(AId: Integer): string;
  end;

implementation

uses
  System.Generics.Collections,
  System.JSON,
  System.SysUtils,
  Product;

function ProductToReadDto(AProduct: TProduct): TProductReadDto;
begin
  Result := TProductReadDto.Create;
  Result.Id := AProduct.Id;
  Result.InternalCode := AProduct.InternalCode;
  Result.BarCode := AProduct.BarCode;
  Result.OriginalCode := AProduct.OriginalCode;
  Result.Description := AProduct.Description;
  Result.BrandName := AProduct.BrandName;
  Result.CategoryName := AProduct.CategoryName;
  Result.VehicleApplication := AProduct.VehicleApplication;
  Result.CurrentStock := AProduct.CurrentStock;
  Result.MinimumStock := AProduct.MinimumStock;
  Result.CostPrice := AProduct.CostPrice;
  Result.SalePrice := AProduct.SalePrice;
  Result.IsActive := AProduct.IsActive;
end;

function ProductDtoToJson(AProduct: TProductReadDto): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(AProduct.Id));
  Result.AddPair('internalCode', AProduct.InternalCode);
  Result.AddPair('barCode', AProduct.BarCode);
  Result.AddPair('originalCode', AProduct.OriginalCode);
  Result.AddPair('description', AProduct.Description);
  Result.AddPair('brandName', AProduct.BrandName);
  Result.AddPair('categoryName', AProduct.CategoryName);
  Result.AddPair('vehicleApplication', AProduct.VehicleApplication);
  Result.AddPair('currentStock', TJSONNumber.Create(AProduct.CurrentStock));
  Result.AddPair('minimumStock', TJSONNumber.Create(AProduct.MinimumStock));
  Result.AddPair('costPrice', TJSONNumber.Create(Double(AProduct.CostPrice)));
  Result.AddPair('salePrice', TJSONNumber.Create(Double(AProduct.SalePrice)));
  Result.AddPair('isActive', TJSONBool.Create(AProduct.IsActive));
end;

function ProductToJson(AProduct: TProduct): TJSONObject;
var
  ProductDto: TProductReadDto;
begin
  ProductDto := ProductToReadDto(AProduct);
  try
    Result := ProductDtoToJson(ProductDto);
  finally
    ProductDto.Free;
  end;
end;

function BuildSuccessResponse(
  const AMessage: string;
  AData: TJSONValue): string;
var
  Json: TJSONObject;
begin
  Json := TJSONObject.Create;
  try
    Json.AddPair('success', TJSONBool.Create(True));
    Json.AddPair('message', AMessage);
    if Assigned(AData) then
      Json.AddPair('data', AData)
    else
      Json.AddPair('data', TJSONNull.Create);
    Result := Json.ToJSON;
  finally
    Json.Free;
  end;
end;

procedure MapCreateDtoToProduct(
  ASource: TProductCreateDto;
  ATarget: TProduct);
begin
  ATarget.InternalCode := Trim(ASource.InternalCode);
  ATarget.BarCode := Trim(ASource.BarCode);
  ATarget.OriginalCode := Trim(ASource.OriginalCode);
  ATarget.Description := Trim(ASource.Description);
  ATarget.BrandName := Trim(ASource.BrandName);
  ATarget.CategoryName := Trim(ASource.CategoryName);
  ATarget.VehicleApplication := Trim(ASource.VehicleApplication);
  ATarget.CurrentStock := ASource.CurrentStock;
  ATarget.MinimumStock := ASource.MinimumStock;
  ATarget.CostPrice := ASource.CostPrice;
  ATarget.SalePrice := ASource.SalePrice;
  ATarget.IsActive := ASource.IsActive;
end;

procedure MapUpdateDtoToProduct(
  ASource: TProductUpdateDto;
  ATarget: TProduct);
begin
  ATarget.InternalCode := Trim(ASource.InternalCode);
  ATarget.BarCode := Trim(ASource.BarCode);
  ATarget.OriginalCode := Trim(ASource.OriginalCode);
  ATarget.Description := Trim(ASource.Description);
  ATarget.BrandName := Trim(ASource.BrandName);
  ATarget.CategoryName := Trim(ASource.CategoryName);
  ATarget.VehicleApplication := Trim(ASource.VehicleApplication);
  ATarget.CurrentStock := ASource.CurrentStock;
  ATarget.MinimumStock := ASource.MinimumStock;
  ATarget.CostPrice := ASource.CostPrice;
  ATarget.SalePrice := ASource.SalePrice;
  ATarget.IsActive := ASource.IsActive;
end;

constructor TProductAppService.Create(
  const AProductRepository: IProductRepository;
  const AProductValidator: IProductValidator);
begin
  inherited Create;
  FProductRepository := AProductRepository;
  FProductValidator := AProductValidator;
end;

function TProductAppService.GetAll: string;
var
  JsonArray: TJSONArray;
  ProductItem: TProduct;
  Products: TObjectList<TProduct>;
begin
  Products := FProductRepository.FindAllActive;
  try
    JsonArray := TJSONArray.Create;
    try
      for ProductItem in Products do
        JsonArray.AddElement(ProductToJson(ProductItem));
      Result := BuildSuccessResponse('', JsonArray);
      JsonArray := nil;
    finally
      JsonArray.Free;
    end;
  finally
    Products.Free;
  end;
end;

function TProductAppService.GetById(AId: Integer): string;
var
  ProductItem: TProduct;
begin
  ProductItem := FProductRepository.FindById(AId);
  try
    if not Assigned(ProductItem) then
      raise EProductNotFoundException.Create('Product not found.');

    Result := BuildSuccessResponse('', ProductToJson(ProductItem));
  finally
    ProductItem.Free;
  end;
end;

function TProductAppService.CreateProduct(
  AProduct: TProductCreateDto): string;
var
  ErrorMessage: string;
  ProductItem: TProduct;
begin
  if not FProductValidator.ValidateCreate(AProduct, ErrorMessage) then
    raise EProductValidationException.Create(ErrorMessage);

  if FProductRepository.ExistsByInternalCode(
    Trim(AProduct.InternalCode)) then
    raise EProductDuplicateException.Create(
      'A product with this internal code already exists.');

  ProductItem := TProduct.Create;
  try
    MapCreateDtoToProduct(AProduct, ProductItem);
    ProductItem.CreatedAt := Now;
    ProductItem.Id := FProductRepository.Insert(ProductItem);
    Result := BuildSuccessResponse(
      'Product created successfully.',
      ProductToJson(ProductItem));
  finally
    ProductItem.Free;
  end;
end;

function TProductAppService.Update(
  AId: Integer;
  AProduct: TProductUpdateDto): string;
var
  ErrorMessage: string;
  ProductItem: TProduct;
begin
  if not FProductValidator.ValidateUpdate(AProduct, ErrorMessage) then
    raise EProductValidationException.Create(ErrorMessage);

  ProductItem := FProductRepository.FindById(AId);
  try
    if not Assigned(ProductItem) then
      raise EProductNotFoundException.Create('Product not found.');

    AProduct.Id := AId;
    if FProductRepository.ExistsByInternalCode(
      Trim(AProduct.InternalCode),
      AId) then
      raise EProductDuplicateException.Create(
        'A product with this internal code already exists.');

    MapUpdateDtoToProduct(AProduct, ProductItem);
    ProductItem.UpdatedAt := Now;
    FProductRepository.Update(ProductItem);
    Result := BuildSuccessResponse(
      'Product updated successfully.',
      ProductToJson(ProductItem));
  finally
    ProductItem.Free;
  end;
end;

function TProductAppService.Delete(AId: Integer): string;
begin
  if not FProductRepository.ExistsById(AId) then
    raise EProductNotFoundException.Create('Product not found.');

  FProductRepository.Deactivate(AId);
  Result := BuildSuccessResponse(
    'Product deleted successfully.',
    nil);
end;

end.
