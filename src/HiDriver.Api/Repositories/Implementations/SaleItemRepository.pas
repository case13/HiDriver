unit SaleItemRepository;

interface

uses
  System.Generics.Collections,
  DatabaseConnectionIntf,
  SaleItem,
  SaleItemRepositoryIntf;

type
  TSaleItemRepository = class(
    TInterfacedObject,
    ISaleItemRepository)
  private
    FDatabaseConnection: IDatabaseConnection;
  public
    constructor Create(const ADatabaseConnection: IDatabaseConnection);
    function FindBySaleId(
      ASaleId: Integer): TObjectList<TSaleItem>;
    procedure Insert(ASaleItem: TSaleItem);
  end;

implementation

uses
  System.DateUtils,
  System.SysUtils,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param;

function DatabaseTextToDateTime(const AValue: string): TDateTime;
begin
  Result := ISO8601ToDate(
    StringReplace(AValue, ' ', 'T', [rfReplaceAll]),
    False);
end;

function QueryToSaleItem(AQuery: TFDQuery): TSaleItem;
begin
  Result := TSaleItem.Create;
  try
    Result.Id := AQuery.FieldByName('id').AsInteger;
    Result.SaleId := AQuery.FieldByName('sale_id').AsInteger;
    Result.ProductId := AQuery.FieldByName('product_id').AsInteger;
    Result.ProductDescription :=
      AQuery.FieldByName('product_description').AsString;
    Result.Quantity := AQuery.FieldByName('quantity').AsFloat;
    Result.UnitPrice := AQuery.FieldByName('unit_price').AsCurrency;
    Result.DiscountAmount :=
      AQuery.FieldByName('discount_amount').AsCurrency;
    Result.TotalAmount :=
      AQuery.FieldByName('total_amount').AsCurrency;
    Result.CreatedAt := DatabaseTextToDateTime(
      AQuery.FieldByName('created_at').AsString);
  except
    Result.Free;
    raise;
  end;
end;

constructor TSaleItemRepository.Create(
  const ADatabaseConnection: IDatabaseConnection);
begin
  inherited Create;
  FDatabaseConnection := ADatabaseConnection;
end;

function TSaleItemRepository.FindBySaleId(
  ASaleId: Integer): TObjectList<TSaleItem>;
var
  Query: TFDQuery;
begin
  Result := TObjectList<TSaleItem>.Create(True);
  try
    FDatabaseConnection.Connect;

    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FDatabaseConnection.Connection;
      Query.SQL.Text :=
        'SELECT id, sale_id, product_id, product_description, quantity, ' +
        'unit_price, discount_amount, total_amount, created_at ' +
        'FROM sale_items WHERE sale_id = :sale_id ORDER BY id';
      Query.ParamByName('sale_id').AsInteger := ASaleId;
      Query.Open;

      while not Query.Eof do
      begin
        Result.Add(QueryToSaleItem(Query));
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

procedure TSaleItemRepository.Insert(ASaleItem: TSaleItem);
var
  Query: TFDQuery;
begin
  if not Assigned(ASaleItem) then
    raise EArgumentNilException.Create('Sale item is required.');

  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'INSERT INTO sale_items (' +
      'sale_id, product_id, product_description, quantity, unit_price, ' +
      'discount_amount, total_amount, created_at) VALUES (' +
      ':sale_id, :product_id, :product_description, :quantity, ' +
      ':unit_price, :discount_amount, :total_amount, datetime(''now''))';
    Query.ParamByName('sale_id').AsInteger := ASaleItem.SaleId;
    Query.ParamByName('product_id').AsInteger := ASaleItem.ProductId;
    Query.ParamByName('product_description').AsString :=
      ASaleItem.ProductDescription;
    Query.ParamByName('quantity').AsFloat := ASaleItem.Quantity;
    Query.ParamByName('unit_price').AsCurrency := ASaleItem.UnitPrice;
    Query.ParamByName('discount_amount').AsCurrency :=
      ASaleItem.DiscountAmount;
    Query.ParamByName('total_amount').AsCurrency :=
      ASaleItem.TotalAmount;
    Query.ExecSQL;
    ASaleItem.Id := Query.Connection.GetLastAutoGenValue('sale_items');
  finally
    Query.Free;
  end;
end;

end.
