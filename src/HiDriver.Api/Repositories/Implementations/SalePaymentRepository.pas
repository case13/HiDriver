unit SalePaymentRepository;

interface

uses
  System.Generics.Collections,
  DatabaseConnectionIntf,
  SalePayment,
  SalePaymentRepositoryIntf;

type
  TSalePaymentRepository = class(
    TInterfacedObject,
    ISalePaymentRepository)
  private
    FDatabaseConnection: IDatabaseConnection;
  public
    constructor Create(const ADatabaseConnection: IDatabaseConnection);
    function FindBySaleId(
      ASaleId: Integer): TObjectList<TSalePayment>;
    procedure Insert(ASalePayment: TSalePayment);
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

function QueryToSalePayment(AQuery: TFDQuery): TSalePayment;
begin
  Result := TSalePayment.Create;
  try
    Result.Id := AQuery.FieldByName('id').AsInteger;
    Result.SaleId := AQuery.FieldByName('sale_id').AsInteger;
    Result.PaymentMethod :=
      AQuery.FieldByName('payment_method').AsString;
    Result.Amount := AQuery.FieldByName('amount').AsCurrency;
    Result.CreatedAt := DatabaseTextToDateTime(
      AQuery.FieldByName('created_at').AsString);
  except
    Result.Free;
    raise;
  end;
end;

constructor TSalePaymentRepository.Create(
  const ADatabaseConnection: IDatabaseConnection);
begin
  inherited Create;
  FDatabaseConnection := ADatabaseConnection;
end;

function TSalePaymentRepository.FindBySaleId(
  ASaleId: Integer): TObjectList<TSalePayment>;
var
  Query: TFDQuery;
begin
  Result := TObjectList<TSalePayment>.Create(True);
  try
    FDatabaseConnection.Connect;

    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FDatabaseConnection.Connection;
      Query.SQL.Text :=
        'SELECT id, sale_id, payment_method, amount, created_at ' +
        'FROM sale_payments WHERE sale_id = :sale_id ORDER BY id';
      Query.ParamByName('sale_id').AsInteger := ASaleId;
      Query.Open;

      while not Query.Eof do
      begin
        Result.Add(QueryToSalePayment(Query));
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

procedure TSalePaymentRepository.Insert(
  ASalePayment: TSalePayment);
var
  Query: TFDQuery;
begin
  if not Assigned(ASalePayment) then
    raise EArgumentNilException.Create('Sale payment is required.');

  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'INSERT INTO sale_payments (' +
      'sale_id, payment_method, amount, created_at) VALUES (' +
      ':sale_id, :payment_method, :amount, datetime(''now''))';
    Query.ParamByName('sale_id').AsInteger := ASalePayment.SaleId;
    Query.ParamByName('payment_method').AsString :=
      ASalePayment.PaymentMethod;
    Query.ParamByName('amount').AsCurrency := ASalePayment.Amount;
    Query.ExecSQL;
    ASalePayment.Id :=
      Query.Connection.GetLastAutoGenValue('sale_payments');
  finally
    Query.Free;
  end;
end;

end.
