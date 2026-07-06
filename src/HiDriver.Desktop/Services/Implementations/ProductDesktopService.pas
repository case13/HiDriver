unit ProductDesktopService;

interface

uses
  System.JSON,
  IApiClient,
  IProductDesktopService,
  ProductDto;

type
  TProductDesktopService = class(
    TInterfacedObject,
    IProductDesktopServiceContract)
  private
    FApiClient: IApiClientContract;
    FLastError: string;
    function GetLastError: string;
    function GetLastStatusCode: Integer;
    function ProductFromJson(AJson: TJSONObject): TProductDto;
  public
    constructor Create(const AApiClient: IApiClientContract);
    function GetProducts: TProductDtoList;
    function SearchProductsLocal(
      const AProducts: TProductDtoList;
      const ASearchText: string): TProductDtoReferenceList;
  end;

implementation

uses
  System.Generics.Collections,
  System.StrUtils,
  System.SysUtils;

constructor TProductDesktopService.Create(
  const AApiClient: IApiClientContract);
begin
  inherited Create;
  if not Assigned(AApiClient) then
    raise EArgumentNilException.Create('API client is required.');

  FApiClient := AApiClient;
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
    FLastError := FApiClient.LastError;
    if FLastError = '' then
      FLastError := 'Unable to load products.';
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

function TProductDesktopService.ProductFromJson(
  AJson: TJSONObject): TProductDto;
begin
  Result := TProductDto.Create;
  try
    Result.Id := AJson.GetValue<Integer>('id', 0);
    Result.InternalCode := AJson.GetValue<string>('internalCode', '');
    Result.BarCode := AJson.GetValue<string>('barCode', '');
    Result.OriginalCode := AJson.GetValue<string>('originalCode', '');
    Result.Description := AJson.GetValue<string>('description', '');
    Result.BrandName := AJson.GetValue<string>('brandName', '');
    Result.CategoryName := AJson.GetValue<string>('categoryName', '');
    Result.VehicleApplication := AJson.GetValue<string>(
      'vehicleApplication',
      '');
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
      ContainsText(ProductItem.Description, SearchText) or
      ContainsText(ProductItem.InternalCode, SearchText) or
      ContainsText(ProductItem.BarCode, SearchText) or
      ContainsText(ProductItem.OriginalCode, SearchText) or
      ContainsText(ProductItem.BrandName, SearchText) or
      ContainsText(ProductItem.CategoryName, SearchText) or
      ContainsText(ProductItem.VehicleApplication, SearchText) then
      Result.Add(ProductItem);
end;

end.
