unit AccountReceivableRepository;

interface

uses
  System.Generics.Collections,
  AccountReceivable,
  AccountReceivablePayment,
  AccountReceivableRepositoryIntf,
  DatabaseConnectionIntf;

type
  TAccountReceivableRepository = class(
    TInterfacedObject,
    IAccountReceivableRepository)
  private
    FDatabaseConnection: IDatabaseConnection;
  public
    constructor Create(const ADatabaseConnection: IDatabaseConnection);
    function GetAll: TObjectList<TAccountReceivable>;
    function GetById(AId: Integer): TAccountReceivable;
    function GetBySaleId(ASaleId: Integer): TAccountReceivable;
    function Insert(AAccountReceivable: TAccountReceivable): Integer;
    procedure Update(AAccountReceivable: TAccountReceivable);
    procedure InsertPayment(APayment: TAccountReceivablePayment);
    function GetPaymentById(AId: Integer): TAccountReceivablePayment;
    function GetPaymentsByAccountReceivableId(
      AAccountReceivableId: Integer):
      TObjectList<TAccountReceivablePayment>;
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

function QueryToAccountReceivable(
  AQuery: TFDQuery): TAccountReceivable;
begin
  Result := TAccountReceivable.Create;
  try
    Result.Id := AQuery.FieldByName('id').AsInteger;
    Result.SaleId := AQuery.FieldByName('sale_id').AsInteger;
    Result.CustomerId := AQuery.FieldByName('customer_id').AsInteger;
    Result.IssueDate := DatabaseTextToDateTime(
      AQuery.FieldByName('issue_date').AsString);
    if not AQuery.FieldByName('due_date').IsNull then
      Result.DueDate := DatabaseTextToDateTime(
        AQuery.FieldByName('due_date').AsString);
    Result.TotalAmount :=
      AQuery.FieldByName('total_amount').AsCurrency;
    Result.ReceivedAmount :=
      AQuery.FieldByName('received_amount').AsCurrency;
    Result.BalanceAmount :=
      AQuery.FieldByName('balance_amount').AsCurrency;
    Result.Status := AQuery.FieldByName('status').AsString;
    Result.Notes := AQuery.FieldByName('notes').AsString;
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

function QueryToAccountReceivablePayment(
  AQuery: TFDQuery): TAccountReceivablePayment;
begin
  Result := TAccountReceivablePayment.Create;
  try
    Result.Id := AQuery.FieldByName('id').AsInteger;
    Result.AccountReceivableId :=
      AQuery.FieldByName('account_receivable_id').AsInteger;
    Result.CashRegisterId :=
      AQuery.FieldByName('cash_register_id').AsInteger;
    if not AQuery.FieldByName('cash_movement_id').IsNull then
      Result.CashMovementId :=
        AQuery.FieldByName('cash_movement_id').AsInteger;
    Result.PaymentDate := DatabaseTextToDateTime(
      AQuery.FieldByName('payment_date').AsString);
    Result.PaymentMethod :=
      AQuery.FieldByName('payment_method').AsString;
    Result.Amount := AQuery.FieldByName('amount').AsCurrency;
    Result.DiscountAmount :=
      AQuery.FieldByName('discount_amount').AsCurrency;
    Result.InterestAmount :=
      AQuery.FieldByName('interest_amount').AsCurrency;
    Result.TotalReceived :=
      AQuery.FieldByName('total_received').AsCurrency;
    Result.Notes := AQuery.FieldByName('notes').AsString;
    Result.CreatedAt := DatabaseTextToDateTime(
      AQuery.FieldByName('created_at').AsString);
  except
    Result.Free;
    raise;
  end;
end;

constructor TAccountReceivableRepository.Create(
  const ADatabaseConnection: IDatabaseConnection);
begin
  inherited Create;
  FDatabaseConnection := ADatabaseConnection;
end;

function TAccountReceivableRepository.GetAll:
  TObjectList<TAccountReceivable>;
var
  Query: TFDQuery;
begin
  Result := TObjectList<TAccountReceivable>.Create(True);
  try
    FDatabaseConnection.Connect;

    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FDatabaseConnection.Connection;
      Query.SQL.Text :=
        'SELECT id, sale_id, customer_id, issue_date, due_date, ' +
        'total_amount, received_amount, balance_amount, status, notes, ' +
        'is_active, created_at, updated_at FROM accounts_receivable ' +
        'WHERE is_active = 1 ORDER BY issue_date DESC, id DESC';
      Query.Open;

      while not Query.Eof do
      begin
        Result.Add(QueryToAccountReceivable(Query));
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

function TAccountReceivableRepository.GetById(
  AId: Integer): TAccountReceivable;
var
  Query: TFDQuery;
begin
  Result := nil;
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT id, sale_id, customer_id, issue_date, due_date, ' +
      'total_amount, received_amount, balance_amount, status, notes, ' +
      'is_active, created_at, updated_at FROM accounts_receivable ' +
      'WHERE id = :id AND is_active = 1 LIMIT 1';
    Query.ParamByName('id').AsInteger := AId;
    Query.Open;

    if not Query.IsEmpty then
      Result := QueryToAccountReceivable(Query);
  finally
    Query.Free;
  end;
end;

function TAccountReceivableRepository.GetBySaleId(
  ASaleId: Integer): TAccountReceivable;
var
  Query: TFDQuery;
begin
  Result := nil;
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT id, sale_id, customer_id, issue_date, due_date, ' +
      'total_amount, received_amount, balance_amount, status, notes, ' +
      'is_active, created_at, updated_at FROM accounts_receivable ' +
      'WHERE sale_id = :sale_id AND is_active = 1 LIMIT 1';
    Query.ParamByName('sale_id').AsInteger := ASaleId;
    Query.Open;

    if not Query.IsEmpty then
      Result := QueryToAccountReceivable(Query);
  finally
    Query.Free;
  end;
end;

function TAccountReceivableRepository.Insert(
  AAccountReceivable: TAccountReceivable): Integer;
var
  Query: TFDQuery;
begin
  if not Assigned(AAccountReceivable) then
    raise EArgumentNilException.Create(
      'Account receivable is required.');

  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'INSERT INTO accounts_receivable (' +
      'sale_id, customer_id, issue_date, due_date, total_amount, ' +
      'received_amount, balance_amount, status, notes, is_active, ' +
      'created_at) VALUES (' +
      ':sale_id, :customer_id, datetime(''now''), NULL, :total_amount, ' +
      ':received_amount, :balance_amount, :status, :notes, :is_active, ' +
      'datetime(''now''))';
    Query.ParamByName('sale_id').AsInteger :=
      AAccountReceivable.SaleId;
    Query.ParamByName('customer_id').AsInteger :=
      AAccountReceivable.CustomerId;
    Query.ParamByName('total_amount').AsCurrency :=
      AAccountReceivable.TotalAmount;
    Query.ParamByName('received_amount').AsCurrency :=
      AAccountReceivable.ReceivedAmount;
    Query.ParamByName('balance_amount').AsCurrency :=
      AAccountReceivable.BalanceAmount;
    Query.ParamByName('status').AsString :=
      AAccountReceivable.Status;
    Query.ParamByName('notes').AsString :=
      AAccountReceivable.Notes;
    Query.ParamByName('is_active').AsInteger :=
      Ord(AAccountReceivable.IsActive);
    Query.ExecSQL;

    Result :=
      Query.Connection.GetLastAutoGenValue('accounts_receivable');
    AAccountReceivable.Id := Result;
  finally
    Query.Free;
  end;
end;

procedure TAccountReceivableRepository.Update(
  AAccountReceivable: TAccountReceivable);
var
  Query: TFDQuery;
begin
  if not Assigned(AAccountReceivable) then
    raise EArgumentNilException.Create(
      'Account receivable is required.');

  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'UPDATE accounts_receivable SET received_amount = :received_amount, ' +
      'balance_amount = :balance_amount, status = :status, notes = :notes, ' +
      'is_active = :is_active, updated_at = datetime(''now'') ' +
      'WHERE id = :id';
    Query.ParamByName('received_amount').AsCurrency :=
      AAccountReceivable.ReceivedAmount;
    Query.ParamByName('balance_amount').AsCurrency :=
      AAccountReceivable.BalanceAmount;
    Query.ParamByName('status').AsString :=
      AAccountReceivable.Status;
    Query.ParamByName('notes').AsString :=
      AAccountReceivable.Notes;
    Query.ParamByName('is_active').AsInteger :=
      Ord(AAccountReceivable.IsActive);
    Query.ParamByName('id').AsInteger := AAccountReceivable.Id;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TAccountReceivableRepository.InsertPayment(
  APayment: TAccountReceivablePayment);
var
  Query: TFDQuery;
begin
  if not Assigned(APayment) then
    raise EArgumentNilException.Create(
      'Account receivable payment is required.');

  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'INSERT INTO account_receivable_payments (' +
      'account_receivable_id, cash_register_id, cash_movement_id, ' +
      'payment_date, payment_method, amount, discount_amount, ' +
      'interest_amount, total_received, notes, created_at) VALUES (' +
      ':account_receivable_id, :cash_register_id, ' +
      'NULLIF(:cash_movement_id, 0), datetime(''now''), ' +
      ':payment_method, :amount, :discount_amount, :interest_amount, ' +
      ':total_received, :notes, datetime(''now''))';
    Query.ParamByName('account_receivable_id').AsInteger :=
      APayment.AccountReceivableId;
    Query.ParamByName('cash_register_id').AsInteger :=
      APayment.CashRegisterId;
    Query.ParamByName('cash_movement_id').AsInteger :=
      APayment.CashMovementId;
    Query.ParamByName('payment_method').AsString :=
      APayment.PaymentMethod;
    Query.ParamByName('amount').AsCurrency := APayment.Amount;
    Query.ParamByName('discount_amount').AsCurrency :=
      APayment.DiscountAmount;
    Query.ParamByName('interest_amount').AsCurrency :=
      APayment.InterestAmount;
    Query.ParamByName('total_received').AsCurrency :=
      APayment.TotalReceived;
    Query.ParamByName('notes').AsString := APayment.Notes;
    Query.ExecSQL;
    APayment.Id := Query.Connection.GetLastAutoGenValue(
      'account_receivable_payments');
  finally
    Query.Free;
  end;
end;

function TAccountReceivableRepository.GetPaymentById(
  AId: Integer): TAccountReceivablePayment;
var
  Query: TFDQuery;
begin
  Result := nil;
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT id, account_receivable_id, cash_register_id, ' +
      'cash_movement_id, payment_date, payment_method, amount, ' +
      'discount_amount, interest_amount, total_received, notes, ' +
      'created_at FROM account_receivable_payments ' +
      'WHERE id = :id LIMIT 1';
    Query.ParamByName('id').AsInteger := AId;
    Query.Open;

    if not Query.IsEmpty then
      Result := QueryToAccountReceivablePayment(Query);
  finally
    Query.Free;
  end;
end;

function TAccountReceivableRepository.
  GetPaymentsByAccountReceivableId(
  AAccountReceivableId: Integer):
  TObjectList<TAccountReceivablePayment>;
var
  Query: TFDQuery;
begin
  Result := TObjectList<TAccountReceivablePayment>.Create(True);
  try
    FDatabaseConnection.Connect;

    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FDatabaseConnection.Connection;
      Query.SQL.Text :=
        'SELECT id, account_receivable_id, cash_register_id, ' +
        'cash_movement_id, payment_date, payment_method, amount, ' +
        'discount_amount, interest_amount, total_received, notes, ' +
        'created_at FROM account_receivable_payments ' +
        'WHERE account_receivable_id = :account_receivable_id ' +
        'ORDER BY payment_date, id';
      Query.ParamByName('account_receivable_id').AsInteger :=
        AAccountReceivableId;
      Query.Open;

      while not Query.Eof do
      begin
        Result.Add(QueryToAccountReceivablePayment(Query));
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

end.
