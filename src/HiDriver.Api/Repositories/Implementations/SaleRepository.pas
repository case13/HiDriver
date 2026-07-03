unit SaleRepository;

interface

uses
  System.Generics.Collections,
  DatabaseConnectionIntf,
  Sale,
  SaleRepositoryIntf;

type
  TSaleRepository = class(TInterfacedObject, ISaleRepository)
  private
    FDatabaseConnection: IDatabaseConnection;
  public
    constructor Create(const ADatabaseConnection: IDatabaseConnection);
    function FindAll: TObjectList<TSale>;
    function FindById(AId: Integer): TSale;
    function Insert(ASale: TSale): Integer;
    procedure Cancel(ASaleId: Integer);
    function ExistsById(AId: Integer): Boolean;
    function IsCanceled(ASaleId: Integer): Boolean;
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

function QueryToSale(AQuery: TFDQuery): TSale;
begin
  Result := TSale.Create;
  try
    Result.Id := AQuery.FieldByName('id').AsInteger;
    if not AQuery.FieldByName('customer_id').IsNull then
      Result.CustomerId := AQuery.FieldByName('customer_id').AsInteger;
    Result.CashRegisterId :=
      AQuery.FieldByName('cash_register_id').AsInteger;
    Result.SaleDate := DatabaseTextToDateTime(
      AQuery.FieldByName('sale_date').AsString);
    Result.SubtotalAmount :=
      AQuery.FieldByName('subtotal_amount').AsCurrency;
    Result.DiscountAmount :=
      AQuery.FieldByName('discount_amount').AsCurrency;
    Result.TotalAmount :=
      AQuery.FieldByName('total_amount').AsCurrency;
    Result.Status := AQuery.FieldByName('status').AsString;
    Result.Notes := AQuery.FieldByName('notes').AsString;
    Result.CreatedAt := DatabaseTextToDateTime(
      AQuery.FieldByName('created_at').AsString);
    if not AQuery.FieldByName('updated_at').IsNull then
      Result.UpdatedAt := DatabaseTextToDateTime(
        AQuery.FieldByName('updated_at').AsString);
    if not AQuery.FieldByName('canceled_at').IsNull then
      Result.CanceledAt := DatabaseTextToDateTime(
        AQuery.FieldByName('canceled_at').AsString);
  except
    Result.Free;
    raise;
  end;
end;

constructor TSaleRepository.Create(
  const ADatabaseConnection: IDatabaseConnection);
begin
  inherited Create;
  FDatabaseConnection := ADatabaseConnection;
end;

function TSaleRepository.FindAll: TObjectList<TSale>;
var
  Query: TFDQuery;
begin
  Result := TObjectList<TSale>.Create(True);
  try
    FDatabaseConnection.Connect;

    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FDatabaseConnection.Connection;
      Query.SQL.Text :=
        'SELECT id, customer_id, cash_register_id, sale_date, ' +
        'subtotal_amount, discount_amount, total_amount, status, notes, ' +
        'created_at, updated_at, canceled_at FROM sales ' +
        'ORDER BY sale_date DESC, id DESC';
      Query.Open;

      while not Query.Eof do
      begin
        Result.Add(QueryToSale(Query));
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

function TSaleRepository.FindById(AId: Integer): TSale;
var
  Query: TFDQuery;
begin
  Result := nil;
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT id, customer_id, cash_register_id, sale_date, ' +
      'subtotal_amount, discount_amount, total_amount, status, notes, ' +
      'created_at, updated_at, canceled_at FROM sales ' +
      'WHERE id = :id LIMIT 1';
    Query.ParamByName('id').AsInteger := AId;
    Query.Open;

    if not Query.IsEmpty then
      Result := QueryToSale(Query);
  finally
    Query.Free;
  end;
end;

function TSaleRepository.Insert(ASale: TSale): Integer;
var
  Query: TFDQuery;
begin
  if not Assigned(ASale) then
    raise EArgumentNilException.Create('Sale is required.');

  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'INSERT INTO sales (' +
      'customer_id, cash_register_id, sale_date, subtotal_amount, ' +
      'discount_amount, total_amount, status, notes, created_at) VALUES (' +
      'NULLIF(:customer_id, 0), :cash_register_id, datetime(''now''), ' +
      ':subtotal_amount, :discount_amount, :total_amount, :status, ' +
      ':notes, datetime(''now''))';
    Query.ParamByName('customer_id').AsInteger := ASale.CustomerId;
    Query.ParamByName('cash_register_id').AsInteger :=
      ASale.CashRegisterId;
    Query.ParamByName('subtotal_amount').AsCurrency :=
      ASale.SubtotalAmount;
    Query.ParamByName('discount_amount').AsCurrency :=
      ASale.DiscountAmount;
    Query.ParamByName('total_amount').AsCurrency := ASale.TotalAmount;
    Query.ParamByName('status').AsString := ASale.Status;
    Query.ParamByName('notes').AsString := ASale.Notes;
    Query.ExecSQL;

    Result := Query.Connection.GetLastAutoGenValue('sales');
    ASale.Id := Result;
  finally
    Query.Free;
  end;
end;

procedure TSaleRepository.Cancel(ASaleId: Integer);
var
  Query: TFDQuery;
begin
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'UPDATE sales SET status = :status, canceled_at = datetime(''now''), ' +
      'updated_at = datetime(''now'') WHERE id = :id';
    Query.ParamByName('status').AsString := 'Canceled';
    Query.ParamByName('id').AsInteger := ASaleId;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

function TSaleRepository.ExistsById(AId: Integer): Boolean;
var
  Query: TFDQuery;
begin
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text := 'SELECT 1 FROM sales WHERE id = :id LIMIT 1';
    Query.ParamByName('id').AsInteger := AId;
    Query.Open;
    Result := not Query.IsEmpty;
  finally
    Query.Free;
  end;
end;

function TSaleRepository.IsCanceled(ASaleId: Integer): Boolean;
var
  Query: TFDQuery;
begin
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT 1 FROM sales WHERE id = :id AND status = :status LIMIT 1';
    Query.ParamByName('id').AsInteger := ASaleId;
    Query.ParamByName('status').AsString := 'Canceled';
    Query.Open;
    Result := not Query.IsEmpty;
  finally
    Query.Free;
  end;
end;

end.
