unit ProductDesktopService;

interface

uses
  System.JSON,
  IApiClient,
  IProductDesktopService,
  ProductDto,
  ProductSaveRequestDto;

type
  TProductDesktopService = class(
    TInterfacedObject,
    IProductDesktopServiceContract)
  private
    FApiClient: IApiClientContract;
    FLastError: string;
    function BuildProductJson(
      const AProduct: TProductSaveRequestDto): string;
    function ExecuteWriteResponse(
      const AResponseBody,
      ADefaultError: string): Boolean;
    function GetLastError: string;
    function GetLastStatusCode: Integer;
    function ProductFromJson(AJson: TJSONObject): TProductDto;
    procedure SetRequestError(const ADefaultError: string);
  public
    constructor Create(const AApiClient: IApiClientContract);
    function GetProducts: TProductDtoList;
    function GetProductById(AProductId: Integer): TProductDto;
    function CreateProduct(
      const AProduct: TProductSaveRequestDto): Boolean;
    function UpdateProduct(
      AProductId: Integer;
      const AProduct: TProductSaveRequestDto): Boolean;
    function DeleteProduct(AProductId: Integer): Boolean;
    function SearchProductsLocal(
      const AProducts: TProductDtoList;
      const ASearchText: string): TProductDtoReferenceList; overload;
    function SearchProductsLocal(
      const AProducts: TProductDtoList;
      const ASearchText,
      AFilterField: string): TProductDtoReferenceList; overload;
    function SearchProductsLocal(
      const AProducts: TProductDtoList;
      const ASearchText,
      AFilterField,
      ASortField,
      ASortDirection: string): TProductDtoReferenceList; overload;
  end;

implementation

uses
  System.Generics.Collections,
  System.Generics.Defaults,
  System.StrUtils,
  System.SysUtils;

function JsonTextValue(
  AJson: TJSONObject;
  const AName: string): string;
var
  Text: string;
  Value: TJSONValue;
begin
  Result := '';
  Value := AJson.GetValue(AName);
  if Value is TJSONString then
  begin
    Text := TJSONString(Value).Value;
    SetLength(Result, Length(Text));
    if Text <> '' then
      Move(Text[1], Result[1], Length(Text) * SizeOf(Char));
  end;
end;

function NormalizeProductFilterField(const AFilterField: string): string;
begin
  Result := LowerCase(Trim(AFilterField));
  Result := StringReplace(Result, '_', '', [rfReplaceAll]);
  Result := StringReplace(Result, '-', '', [rfReplaceAll]);
  if Result = '' then
    Result := 'description';
end;

function ProductStatusText(AProduct: TProductDto): string;
begin
  if AProduct.IsActive then
    Result := 'Ativo'
  else
    Result := 'Inativo';
end;

function IsStatusFilterField(const AFilterField: string): Boolean;
var
  FieldName: string;
begin
  FieldName := NormalizeProductFilterField(AFilterField);
  Result := (FieldName = 'isactive') or
    (FieldName = 'status') or
    (FieldName = 'statustext');
end;

function StatusFieldMatches(
  AProduct: TProductDto;
  const ASearchText: string): Boolean;
begin
  if SameText(ASearchText, 'ativo') then
    Exit(AProduct.IsActive);

  if SameText(ASearchText, 'inativo') then
    Exit(not AProduct.IsActive);

  Result := ContainsText(ProductStatusText(AProduct), ASearchText) or
    ContainsText(BoolToStr(AProduct.IsActive, True), ASearchText);
end;

function ProductFilterText(
  AProduct: TProductDto;
  const AFilterField: string): string;
var
  FieldName: string;
begin
  Result := '';
  if not Assigned(AProduct) then
    Exit;

  FieldName := NormalizeProductFilterField(AFilterField);
  if FieldName = 'internalcode' then
    Result := AProduct.InternalCode
  else if FieldName = 'barcode' then
    Result := AProduct.BarCode
  else if FieldName = 'originalcode' then
    Result := AProduct.OriginalCode
  else if FieldName = 'brandname' then
    Result := AProduct.BrandName
  else if FieldName = 'categoryname' then
    Result := AProduct.CategoryName
  else if FieldName = 'vehicleapplication' then
    Result := AProduct.VehicleApplication
  else if FieldName = 'currentstock' then
    Result := FormatFloat('0.###', AProduct.CurrentStock)
  else if FieldName = 'minimumstock' then
    Result := FormatFloat('0.###', AProduct.MinimumStock)
  else if FieldName = 'costprice' then
    Result := FormatCurr('0.00', AProduct.CostPrice)
  else if FieldName = 'saleprice' then
    Result := FormatCurr('0.00', AProduct.SalePrice)
  else if IsStatusFilterField(AFilterField) then
    Result := ProductStatusText(AProduct)
  else
    Result := AProduct.Description;
end;

function CompareFloatValues(
  const ALeft,
  ARight: Double): Integer;
begin
  if ALeft < ARight then
    Result := -1
  else if ALeft > ARight then
    Result := 1
  else
    Result := 0;
end;

function CompareIntegerValues(
  ALeft,
  ARight: Integer): Integer;
begin
  if ALeft < ARight then
    Result := -1
  else if ALeft > ARight then
    Result := 1
  else
    Result := 0;
end;

function CompareProductByField(
  ALeft,
  ARight: TProductDto;
  const ASortField: string): Integer;
var
  FieldName: string;
begin
  Result := 0;
  if (not Assigned(ALeft)) and (not Assigned(ARight)) then
    Exit;
  if not Assigned(ALeft) then
    Exit(-1);
  if not Assigned(ARight) then
    Exit(1);

  FieldName := NormalizeProductFilterField(ASortField);
  if FieldName = 'internalcode' then
    Result := CompareText(ALeft.InternalCode, ARight.InternalCode)
  else if FieldName = 'barcode' then
    Result := CompareText(ALeft.BarCode, ARight.BarCode)
  else if FieldName = 'originalcode' then
    Result := CompareText(ALeft.OriginalCode, ARight.OriginalCode)
  else if FieldName = 'brandname' then
    Result := CompareText(ALeft.BrandName, ARight.BrandName)
  else if FieldName = 'categoryname' then
    Result := CompareText(ALeft.CategoryName, ARight.CategoryName)
  else if FieldName = 'vehicleapplication' then
    Result := CompareText(
      ALeft.VehicleApplication,
      ARight.VehicleApplication)
  else if FieldName = 'currentstock' then
    Result := CompareFloatValues(
      ALeft.CurrentStock,
      ARight.CurrentStock)
  else if FieldName = 'minimumstock' then
    Result := CompareFloatValues(
      ALeft.MinimumStock,
      ARight.MinimumStock)
  else if FieldName = 'costprice' then
    Result := CompareFloatValues(
      ALeft.CostPrice,
      ARight.CostPrice)
  else if FieldName = 'saleprice' then
    Result := CompareFloatValues(
      ALeft.SalePrice,
      ARight.SalePrice)
  else if IsStatusFilterField(ASortField) then
    Result := CompareText(
      ProductStatusText(ALeft),
      ProductStatusText(ARight))
  else
    Result := CompareText(ALeft.Description, ARight.Description);
end;

function IsDescendingSortDirection(
  const ASortDirection: string): Boolean;
begin
  Result := SameText(Trim(ASortDirection), 'desc') or
    SameText(Trim(ASortDirection), 'descending') or
    SameText(Trim(ASortDirection), 'd');
end;

procedure SortProductReferences(
  AProducts: TProductDtoReferenceList;
  const ASortField,
  ASortDirection: string);
var
  SortDescending: Boolean;
  SortField: string;
begin
  if not Assigned(AProducts) then
    Exit;

  SortField := ASortField;
  if Trim(SortField) = '' then
    SortField := 'description';
  SortDescending := IsDescendingSortDirection(ASortDirection);

  AProducts.Sort(
    TComparer<TProductDto>.Construct(
      function(
        const ALeft,
        ARight: TProductDto): Integer
      begin
        Result := CompareProductByField(ALeft, ARight, SortField);
        if Result = 0 then
          Result := CompareProductByField(
            ALeft,
            ARight,
            'description');
        if Result = 0 then
          Result := CompareProductByField(
            ALeft,
            ARight,
            'internalCode');
        if Result = 0 then
        begin
          if Assigned(ALeft) and Assigned(ARight) then
            Result := CompareIntegerValues(ALeft.Id, ARight.Id);
        end;

        if SortDescending then
          Result := -Result;
      end));
end;

function TProductDesktopService.BuildProductJson(
  const AProduct: TProductSaveRequestDto): string;
var
  Json: TJSONObject;
begin
  Json := TJSONObject.Create;
  try
    Json.AddPair('internalCode', AProduct.InternalCode);
    Json.AddPair('barCode', AProduct.BarCode);
    Json.AddPair('originalCode', AProduct.OriginalCode);
    Json.AddPair('description', AProduct.Description);
    Json.AddPair('brandName', AProduct.BrandName);
    Json.AddPair('categoryName', AProduct.CategoryName);
    Json.AddPair('vehicleApplication', AProduct.VehicleApplication);
    Json.AddPair(
      'currentStock',
      TJSONNumber.Create(AProduct.CurrentStock));
    Json.AddPair(
      'minimumStock',
      TJSONNumber.Create(AProduct.MinimumStock));
    Json.AddPair(
      'costPrice',
      TJSONNumber.Create(Double(AProduct.CostPrice)));
    Json.AddPair(
      'salePrice',
      TJSONNumber.Create(Double(AProduct.SalePrice)));
    Json.AddPair('isActive', TJSONBool.Create(AProduct.IsActive));
    Result := Json.ToJSON;
  finally
    Json.Free;
  end;
end;

constructor TProductDesktopService.Create(
  const AApiClient: IApiClientContract);
begin
  inherited Create;
  if not Assigned(AApiClient) then
    raise EArgumentNilException.Create('API client is required.');

  FApiClient := AApiClient;
end;

function TProductDesktopService.CreateProduct(
  const AProduct: TProductSaveRequestDto): Boolean;
var
  ResponseBody: string;
begin
  Result := False;
  FLastError := '';
  if not Assigned(AProduct) then
  begin
    FLastError := 'Product data is required.';
    Exit;
  end;

  ResponseBody := FApiClient.Post(
    '/api/products',
    BuildProductJson(AProduct));
  Result := ExecuteWriteResponse(
    ResponseBody,
    'Unable to create the product.');
end;

function TProductDesktopService.DeleteProduct(
  AProductId: Integer): Boolean;
var
  ResponseBody: string;
begin
  FLastError := '';
  ResponseBody := FApiClient.Delete(
    Format('/api/products/%d', [AProductId]));
  Result := ExecuteWriteResponse(
    ResponseBody,
    'Unable to delete the product.');
end;

function TProductDesktopService.ExecuteWriteResponse(
  const AResponseBody,
  ADefaultError: string): Boolean;
var
  JsonObject: TJSONObject;
  RootValue: TJSONValue;
begin
  Result := False;
  if (FApiClient.LastStatusCode < 200) or
    (FApiClient.LastStatusCode >= 300) then
  begin
    SetRequestError(ADefaultError);
    Exit;
  end;

  RootValue := nil;
  try
    try
      RootValue := TJSONObject.ParseJSONValue(AResponseBody);
      if not (RootValue is TJSONObject) then
      begin
        FLastError := 'The API returned an invalid response.';
        Exit;
      end;

      JsonObject := TJSONObject(RootValue);
      if not JsonObject.GetValue<Boolean>('success', False) then
      begin
        FLastError := JsonObject.GetValue<string>(
          'message',
          ADefaultError);
        Exit;
      end;

      Result := True;
    except
      on E: Exception do
        FLastError := 'The API returned unexpected product data.';
    end;
  finally
    RootValue.Free;
  end;
end;

function TProductDesktopService.GetLastError: string;
begin
  Result := FLastError;
end;

function TProductDesktopService.GetLastStatusCode: Integer;
begin
  Result := FApiClient.LastStatusCode;
end;

function TProductDesktopService.GetProducts: TProductDtoList;
var
  DataArray: TJSONArray;
  DataValue: TJSONValue;
  Index: Integer;
  JsonObject: TJSONObject;
  Products: TProductDtoList;
  ResponseBody: string;
  RootValue: TJSONValue;
begin
  Result := nil;
  FLastError := '';

  ResponseBody := FApiClient.Get('/api/products');
  if (FApiClient.LastStatusCode < 200) or
    (FApiClient.LastStatusCode >= 300) then
  begin
    SetRequestError('Unable to load products.');
    Exit;
  end;

  RootValue := nil;
  Products := nil;
  try
    try
      RootValue := TJSONObject.ParseJSONValue(ResponseBody);
      if not (RootValue is TJSONObject) then
      begin
        FLastError := 'The API returned an invalid products response.';
        Exit;
      end;

      JsonObject := TJSONObject(RootValue);
      if not JsonObject.GetValue<Boolean>('success', False) then
      begin
        FLastError := JsonObject.GetValue<string>(
          'message',
          'Unable to load products.');
        Exit;
      end;

      DataValue := JsonObject.GetValue('data');
      if not (DataValue is TJSONArray) then
      begin
        FLastError := 'The API returned invalid product data.';
        Exit;
      end;

      DataArray := TJSONArray(DataValue);
      Products := TProductDtoList.Create(True);
      for Index := 0 to DataArray.Count - 1 do
      begin
        if not (DataArray.Items[Index] is TJSONObject) then
        begin
          FLastError := 'The API returned an invalid product item.';
          Exit;
        end;

        Products.Add(ProductFromJson(
          TJSONObject(DataArray.Items[Index])));
      end;

      Result := Products;
      Products := nil;
    except
      on E: Exception do
        FLastError := 'The API returned unexpected product data.';
    end;
  finally
    Products.Free;
    RootValue.Free;
  end;
end;

function TProductDesktopService.GetProductById(
  AProductId: Integer): TProductDto;
var
  DataValue: TJSONValue;
  JsonObject: TJSONObject;
  ResponseBody: string;
  RootValue: TJSONValue;
begin
  Result := nil;
  FLastError := '';
  ResponseBody := FApiClient.Get(
    Format('/api/products/%d', [AProductId]));
  if (FApiClient.LastStatusCode < 200) or
    (FApiClient.LastStatusCode >= 300) then
  begin
    SetRequestError('Unable to load the product.');
    Exit;
  end;

  RootValue := nil;
  try
    try
      RootValue := TJSONObject.ParseJSONValue(ResponseBody);
      if not (RootValue is TJSONObject) then
      begin
        FLastError := 'The API returned an invalid product response.';
        Exit;
      end;

      JsonObject := TJSONObject(RootValue);
      if not JsonObject.GetValue<Boolean>('success', False) then
      begin
        FLastError := JsonObject.GetValue<string>(
          'message',
          'Unable to load the product.');
        Exit;
      end;

      DataValue := JsonObject.GetValue('data');
      if not (DataValue is TJSONObject) then
      begin
        FLastError := 'The API returned invalid product data.';
        Exit;
      end;

      Result := ProductFromJson(TJSONObject(DataValue));
    except
      on E: Exception do
      begin
        Result.Free;
        Result := nil;
        FLastError := 'The API returned unexpected product data.';
      end;
    end;
  finally
    RootValue.Free;
  end;
end;

function TProductDesktopService.ProductFromJson(
  AJson: TJSONObject): TProductDto;
begin
  Result := TProductDto.Create;
  try
    Result.Id := AJson.GetValue<Integer>('id', 0);
    Result.InternalCode := JsonTextValue(AJson, 'internalCode');
    Result.BarCode := JsonTextValue(AJson, 'barCode');
    Result.OriginalCode := JsonTextValue(AJson, 'originalCode');
    Result.Description := JsonTextValue(AJson, 'description');
    Result.BrandName := JsonTextValue(AJson, 'brandName');
    Result.CategoryName := JsonTextValue(AJson, 'categoryName');
    Result.VehicleApplication := JsonTextValue(
      AJson,
      'vehicleApplication');
    Result.CurrentStock := AJson.GetValue<Double>('currentStock', 0);
    Result.MinimumStock := AJson.GetValue<Double>('minimumStock', 0);
    Result.CostPrice := AJson.GetValue<Double>('costPrice', 0);
    Result.SalePrice := AJson.GetValue<Double>('salePrice', 0);
    Result.IsActive := AJson.GetValue<Boolean>('isActive', False);
  except
    Result.Free;
    raise;
  end;
end;

function TProductDesktopService.SearchProductsLocal(
  const AProducts: TProductDtoList;
  const ASearchText: string): TProductDtoReferenceList;
begin
  Result := SearchProductsLocal(
    AProducts,
    ASearchText,
    'description',
    'description',
    'asc');
end;

function TProductDesktopService.SearchProductsLocal(
  const AProducts: TProductDtoList;
  const ASearchText,
  AFilterField: string): TProductDtoReferenceList;
begin
  Result := SearchProductsLocal(
    AProducts,
    ASearchText,
    AFilterField,
    AFilterField,
    'asc');
end;

function TProductDesktopService.SearchProductsLocal(
  const AProducts: TProductDtoList;
  const ASearchText,
  AFilterField,
  ASortField,
  ASortDirection: string): TProductDtoReferenceList;
var
  ProductItem: TProductDto;
  SearchText: string;
begin
  Result := TProductDtoReferenceList.Create;
  if not Assigned(AProducts) then
    Exit;

  SearchText := Trim(ASearchText);
  for ProductItem in AProducts do
    if (SearchText = '') or
      (IsStatusFilterField(AFilterField) and
        StatusFieldMatches(ProductItem, SearchText)) or
      (not IsStatusFilterField(AFilterField) and
        ContainsText(
          ProductFilterText(ProductItem, AFilterField),
          SearchText)) then
      Result.Add(ProductItem);

  SortProductReferences(Result, ASortField, ASortDirection);
end;

procedure TProductDesktopService.SetRequestError(
  const ADefaultError: string);
begin
  FLastError := FApiClient.LastError;
  if FLastError = '' then
    FLastError := ADefaultError;
end;

function TProductDesktopService.UpdateProduct(
  AProductId: Integer;
  const AProduct: TProductSaveRequestDto): Boolean;
var
  ResponseBody: string;
begin
  Result := False;
  FLastError := '';
  if not Assigned(AProduct) then
  begin
    FLastError := 'Product data is required.';
    Exit;
  end;

  ResponseBody := FApiClient.Put(
    Format('/api/products/%d', [AProductId]),
    BuildProductJson(AProduct));
  Result := ExecuteWriteResponse(
    ResponseBody,
    'Unable to update the product.');
end;

end.
