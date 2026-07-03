unit ProductRepository;

interface

uses
  System.Generics.Collections,
  DatabaseConnectionIntf,
  Product,
  ProductRepositoryIntf;

type
  TProductRepository = class(TInterfacedObject, IProductRepository)
  private
    FDatabaseConnection: IDatabaseConnection;
  public
    constructor Create(const ADatabaseConnection: IDatabaseConnection);
    function FindAllActive: TObjectList<TProduct>;
    function FindById(AId: Integer): TProduct;
    function ExistsByInternalCode(
      const AInternalCode: string;
      AIgnoreId: Integer = 0): Boolean;
    function Insert(AProduct: TProduct): Integer;
    procedure Update(AProduct: TProduct);
    procedure Deactivate(AId: Integer);
    function ExistsById(AId: Integer): Boolean;
  end;

implementation

uses
  System.DateUtils,
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param;

function DatabaseTextToDateTime(const AValue: string): TDateTime;
begin
  Result := ISO8601ToDate(
    StringReplace(AValue, ' ', 'T', [rfReplaceAll]),
    False);
end;

function QueryToProduct(AQuery: TFDQuery): TProduct;
begin
  Result := TProduct.Create;
  try
    Result.Id := AQuery.FieldByName('id').AsInteger;
    Result.InternalCode := AQuery.FieldByName('internal_code').AsString;
    Result.BarCode := AQuery.FieldByName('barcode').AsString;
    Result.OriginalCode := AQuery.FieldByName('original_code').AsString;
    Result.Description := AQuery.FieldByName('description').AsString;
    Result.BrandName := AQuery.FieldByName('brand_name').AsString;
    Result.CategoryName := AQuery.FieldByName('category_name').AsString;
    Result.VehicleApplication :=
      AQuery.FieldByName('vehicle_application').AsString;
    Result.CurrentStock := AQuery.FieldByName('current_stock').AsFloat;
    Result.MinimumStock := AQuery.FieldByName('minimum_stock').AsFloat;
    Result.CostPrice := AQuery.FieldByName('cost_price').AsCurrency;
    Result.SalePrice := AQuery.FieldByName('sale_price').AsCurrency;
    Result.IsActive := AQuery.FieldByName('is_active').AsInteger = 1;
    Result.CreatedAt := DatabaseTextToDateTime(
      AQuery.FieldByName('created_at').AsString);
    if not AQuery.FieldByName('updated_at').IsNull then
      Result.UpdatedAt := DatabaseTextToDateTime(
        AQuery.FieldByName('updated_at').AsString);
  except
    Result.Free;
    raise;
  end;
end;

constructor TProductRepository.Create(
  const ADatabaseConnection: IDatabaseConnection);
begin
  inherited Create;
  FDatabaseConnection := ADatabaseConnection;
end;

function TProductRepository.FindAllActive: TObjectList<TProduct>;
var
  Query: TFDQuery;
begin
  Result := TObjectList<TProduct>.Create(True);
  try
    FDatabaseConnection.Connect;

    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FDatabaseConnection.Connection;
      Query.SQL.Text :=
        'SELECT id, internal_code, barcode, original_code, description, ' +
        'brand_name, category_name, vehicle_application, current_stock, ' +
        'minimum_stock, cost_price, sale_price, is_active, created_at, ' +
        'updated_at FROM products WHERE is_active = 1 ' +
        'ORDER BY description';
      Query.Open;

      while not Query.Eof do
      begin
        Result.Add(QueryToProduct(Query));
        Query.Next;
      end;
    finally
      Query.Free;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TProductRepository.FindById(AId: Integer): TProduct;
var
  Query: TFDQuery;
begin
  Result := nil;
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT id, internal_code, barcode, original_code, description, ' +
      'brand_name, category_name, vehicle_application, current_stock, ' +
      'minimum_stock, cost_price, sale_price, is_active, created_at, ' +
      'updated_at FROM products WHERE id = :id AND is_active = 1 LIMIT 1';
    Query.ParamByName('id').AsInteger := AId;
    Query.Open;

    if not Query.IsEmpty then
      Result := QueryToProduct(Query);
  finally
    Query.Free;
  end;
end;

function TProductRepository.ExistsByInternalCode(
  const AInternalCode: string;
  AIgnoreId: Integer): Boolean;
var
  Query: TFDQuery;
begin
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT 1 FROM products ' +
      'WHERE lower(internal_code) = lower(:internal_code) ' +
      'AND (:ignore_id = 0 OR id <> :ignore_id) LIMIT 1';
    Query.ParamByName('internal_code').AsString := AInternalCode;
    Query.ParamByName('ignore_id').AsInteger := AIgnoreId;
    Query.Open;
    Result := not Query.IsEmpty;
  finally
    Query.Free;
  end;
end;

function TProductRepository.Insert(AProduct: TProduct): Integer;
var
  Query: TFDQuery;
begin
  if not Assigned(AProduct) then
    raise EArgumentNilException.Create('Product is required.');

  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'INSERT INTO products (' +
      'internal_code, barcode, original_code, description, brand_name, ' +
      'category_name, vehicle_application, current_stock, minimum_stock, ' +
      'cost_price, sale_price, is_active, created_at) VALUES (' +
      ':internal_code, :barcode, :original_code, :description, :brand_name, ' +
      ':category_name, :vehicle_application, :current_stock, :minimum_stock, ' +
      ':cost_price, :sale_price, :is_active, datetime(''now''))';
    Query.ParamByName('internal_code').AsString := AProduct.InternalCode;
    Query.ParamByName('barcode').AsString := AProduct.BarCode;
    Query.ParamByName('original_code').AsString := AProduct.OriginalCode;
    Query.ParamByName('description').AsString := AProduct.Description;
    Query.ParamByName('brand_name').AsString := AProduct.BrandName;
    Query.ParamByName('category_name').AsString := AProduct.CategoryName;
    Query.ParamByName('vehicle_application').AsString :=
      AProduct.VehicleApplication;
    Query.ParamByName('current_stock').AsFloat := AProduct.CurrentStock;
    Query.ParamByName('minimum_stock').AsFloat := AProduct.MinimumStock;
    Query.ParamByName('cost_price').AsCurrency := AProduct.CostPrice;
    Query.ParamByName('sale_price').AsCurrency := AProduct.SalePrice;
    Query.ParamByName('is_active').AsInteger := Ord(AProduct.IsActive);
    Query.ExecSQL;

    Result := Query.Connection.GetLastAutoGenValue('products');
    AProduct.Id := Result;
  finally
    Query.Free;
  end;
end;

procedure TProductRepository.Update(AProduct: TProduct);
var
  Query: TFDQuery;
begin
  if not Assigned(AProduct) then
    raise EArgumentNilException.Create('Product is required.');

  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'UPDATE products SET internal_code = :internal_code, ' +
      'barcode = :barcode, original_code = :original_code, ' +
      'description = :description, brand_name = :brand_name, ' +
      'category_name = :category_name, ' +
      'vehicle_application = :vehicle_application, ' +
      'current_stock = :current_stock, minimum_stock = :minimum_stock, ' +
      'cost_price = :cost_price, sale_price = :sale_price, ' +
      'is_active = :is_active, updated_at = datetime(''now'') ' +
      'WHERE id = :id';
    Query.ParamByName('internal_code').AsString := AProduct.InternalCode;
    Query.ParamByName('barcode').AsString := AProduct.BarCode;
    Query.ParamByName('original_code').AsString := AProduct.OriginalCode;
    Query.ParamByName('description').AsString := AProduct.Description;
    Query.ParamByName('brand_name').AsString := AProduct.BrandName;
    Query.ParamByName('category_name').AsString := AProduct.CategoryName;
    Query.ParamByName('vehicle_application').AsString :=
      AProduct.VehicleApplication;
    Query.ParamByName('current_stock').AsFloat := AProduct.CurrentStock;
    Query.ParamByName('minimum_stock').AsFloat := AProduct.MinimumStock;
    Query.ParamByName('cost_price').AsCurrency := AProduct.CostPrice;
    Query.ParamByName('sale_price').AsCurrency := AProduct.SalePrice;
    Query.ParamByName('is_active').AsInteger := Ord(AProduct.IsActive);
    Query.ParamByName('id').AsInteger := AProduct.Id;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TProductRepository.Deactivate(AId: Integer);
var
  Query: TFDQuery;
begin
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'UPDATE products SET is_active = 0, updated_at = datetime(''now'') ' +
      'WHERE id = :id';
    Query.ParamByName('id').AsInteger := AId;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

function TProductRepository.ExistsById(AId: Integer): Boolean;
var
  Query: TFDQuery;
begin
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT 1 FROM products WHERE id = :id AND is_active = 1 LIMIT 1';
    Query.ParamByName('id').AsInteger := AId;
    Query.Open;
    Result := not Query.IsEmpty;
  finally
    Query.Free;
  end;
end;

end.
