unit ReceiptRepository;

interface

uses
  System.Generics.Collections,
  DatabaseConnectionIntf,
  Receipt,
  ReceiptItem,
  ReceiptRepositoryIntf;

type
  TReceiptRepository = class(TInterfacedObject, IReceiptRepository)
  private
    FDatabaseConnection: IDatabaseConnection;
    procedure LoadItems(AReceipt: TReceipt);
  public
    constructor Create(const ADatabaseConnection: IDatabaseConnection);
    function GetAll: TObjectList<TReceipt>;
    function GetById(AId: Integer): TReceipt;
    function GetByNumber(const AReceiptNumber: string): TReceipt;
    function GetBySource(
      const ASourceType: string;
      ASourceId: Integer): TReceipt;
    function GetNextId: Integer;
    procedure Insert(AReceipt: TReceipt);
    procedure InsertItems(AItems: TObjectList<TReceiptItem>);
    procedure Cancel(AId: Integer);
  end;

implementation

uses
  System.DateUtils,
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param;

const
  SelectReceiptFields =
    'SELECT id, receipt_number, source_type, source_id, customer_id, ' +
    'customer_name, customer_document, issue_date, subtotal_amount, ' +
    'discount_amount, total_amount, payment_summary, notes, status, ' +
    'created_by_user_id, is_active, created_at, updated_at FROM receipts ';

function DatabaseTextToDateTime(const AValue: string): TDateTime;
begin
  Result := ISO8601ToDate(
    StringReplace(AValue, ' ', 'T', [rfReplaceAll]),
    False);
end;

function QueryToReceipt(AQuery: TFDQuery): TReceipt;
begin
  Result := TReceipt.Create;
  try
    Result.Id := AQuery.FieldByName('id').AsInteger;
    Result.ReceiptNumber :=
      AQuery.FieldByName('receipt_number').AsString;
    Result.SourceType := AQuery.FieldByName('source_type').AsString;
    Result.SourceId := AQuery.FieldByName('source_id').AsInteger;
    if not AQuery.FieldByName('customer_id').IsNull then
      Result.CustomerId := AQuery.FieldByName('customer_id').AsInteger;
    Result.CustomerName :=
      AQuery.FieldByName('customer_name').AsString;
    Result.CustomerDocument :=
      AQuery.FieldByName('customer_document').AsString;
    Result.IssueDate := DatabaseTextToDateTime(
      AQuery.FieldByName('issue_date').AsString);
    Result.SubtotalAmount :=
      AQuery.FieldByName('subtotal_amount').AsCurrency;
    Result.DiscountAmount :=
      AQuery.FieldByName('discount_amount').AsCurrency;
    Result.TotalAmount :=
      AQuery.FieldByName('total_amount').AsCurrency;
    Result.PaymentSummary :=
      AQuery.FieldByName('payment_summary').AsString;
    Result.Notes := AQuery.FieldByName('notes').AsString;
    Result.Status := AQuery.FieldByName('status').AsString;
    if not AQuery.FieldByName('created_by_user_id').IsNull then
      Result.CreatedByUserId :=
        AQuery.FieldByName('created_by_user_id').AsInteger;
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

function QueryToReceiptItem(AQuery: TFDQuery): TReceiptItem;
begin
  Result := TReceiptItem.Create;
  try
    Result.Id := AQuery.FieldByName('id').AsInteger;
    Result.ReceiptId := AQuery.FieldByName('receipt_id').AsInteger;
    if not AQuery.FieldByName('product_id').IsNull then
      Result.ProductId := AQuery.FieldByName('product_id').AsInteger;
    Result.Description := AQuery.FieldByName('description').AsString;
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

constructor TReceiptRepository.Create(
  const ADatabaseConnection: IDatabaseConnection);
begin
  inherited Create;
  FDatabaseConnection := ADatabaseConnection;
end;

procedure TReceiptRepository.LoadItems(AReceipt: TReceipt);
var
  Query: TFDQuery;
begin
  if not Assigned(AReceipt) then
    Exit;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT id, receipt_id, product_id, description, quantity, ' +
      'unit_price, discount_amount, total_amount, created_at ' +
      'FROM receipt_items WHERE receipt_id = :receipt_id ORDER BY id';
    Query.ParamByName('receipt_id').AsInteger := AReceipt.Id;
    Query.Open;

    while not Query.Eof do
    begin
      AReceipt.Items.Add(QueryToReceiptItem(Query));
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TReceiptRepository.GetAll: TObjectList<TReceipt>;
var
  Query: TFDQuery;
  Receipt: TReceipt;
begin
  Result := TObjectList<TReceipt>.Create(True);
  try
    FDatabaseConnection.Connect;

    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FDatabaseConnection.Connection;
      Query.SQL.Text :=
        SelectReceiptFields +
        'WHERE is_active = 1 ORDER BY issue_date DESC, id DESC';
      Query.Open;

      while not Query.Eof do
      begin
        Result.Add(QueryToReceipt(Query));
        Query.Next;
      end;
    finally
      Query.Free;
    end;

    for Receipt in Result do
      LoadItems(Receipt);
  except
    Result.Free;
    raise;
  end;
end;

function TReceiptRepository.GetById(AId: Integer): TReceipt;
var
  Query: TFDQuery;
begin
  Result := nil;
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      SelectReceiptFields +
      'WHERE id = :id AND is_active = 1 LIMIT 1';
    Query.ParamByName('id').AsInteger := AId;
    Query.Open;
    if not Query.IsEmpty then
      Result := QueryToReceipt(Query);
  finally
    Query.Free;
  end;

  if Assigned(Result) then
    try
      LoadItems(Result);
    except
      Result.Free;
      raise;
    end;
end;

function TReceiptRepository.GetByNumber(
  const AReceiptNumber: string): TReceipt;
var
  Query: TFDQuery;
begin
  Result := nil;
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      SelectReceiptFields +
      'WHERE receipt_number = :receipt_number ' +
      'AND is_active = 1 LIMIT 1';
    Query.ParamByName('receipt_number').AsString := AReceiptNumber;
    Query.Open;
    if not Query.IsEmpty then
      Result := QueryToReceipt(Query);
  finally
    Query.Free;
  end;

  if Assigned(Result) then
    try
      LoadItems(Result);
    except
      Result.Free;
      raise;
    end;
end;

function TReceiptRepository.GetBySource(
  const ASourceType: string;
  ASourceId: Integer): TReceipt;
var
  Query: TFDQuery;
begin
  Result := nil;
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      SelectReceiptFields +
      'WHERE source_type = :source_type AND source_id = :source_id ' +
      'AND status = :status AND is_active = 1 LIMIT 1';
    Query.ParamByName('source_type').AsString := ASourceType;
    Query.ParamByName('source_id').AsInteger := ASourceId;
    Query.ParamByName('status').AsString := 'Issued';
    Query.Open;
    if not Query.IsEmpty then
      Result := QueryToReceipt(Query);
  finally
    Query.Free;
  end;

  if Assigned(Result) then
    try
      LoadItems(Result);
    except
      Result.Free;
      raise;
    end;
end;

function TReceiptRepository.GetNextId: Integer;
var
  Query: TFDQuery;
begin
  FDatabaseConnection.Connect;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT COALESCE((' +
      'SELECT seq + 1 FROM sqlite_sequence WHERE name = ''receipts''' +
      '), 1) AS next_id';
    Query.Open;
    Result := Query.FieldByName('next_id').AsInteger;
  finally
    Query.Free;
  end;
end;

procedure TReceiptRepository.Insert(AReceipt: TReceipt);
var
  Query: TFDQuery;
begin
  if not Assigned(AReceipt) then
    raise EArgumentNilException.Create('Receipt is required.');

  FDatabaseConnection.Connect;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'INSERT INTO receipts (' +
      'receipt_number, source_type, source_id, customer_id, ' +
      'customer_name, customer_document, issue_date, subtotal_amount, ' +
      'discount_amount, total_amount, payment_summary, notes, status, ' +
      'created_by_user_id, is_active, created_at) VALUES (' +
      ':receipt_number, :source_type, :source_id, ' +
      'NULLIF(:customer_id, 0), :customer_name, :customer_document, ' +
      ':issue_date, :subtotal_amount, :discount_amount, :total_amount, ' +
      ':payment_summary, :notes, :status, ' +
      'NULLIF(:created_by_user_id, 0), :is_active, :created_at)';
    Query.ParamByName('receipt_number').AsString :=
      AReceipt.ReceiptNumber;
    Query.ParamByName('source_type').AsString := AReceipt.SourceType;
    Query.ParamByName('source_id').AsInteger := AReceipt.SourceId;
    Query.ParamByName('customer_id').AsInteger := AReceipt.CustomerId;
    Query.ParamByName('customer_name').AsString :=
      AReceipt.CustomerName;
    Query.ParamByName('customer_document').AsString :=
      AReceipt.CustomerDocument;
    Query.ParamByName('issue_date').AsString :=
      DateToISO8601(AReceipt.IssueDate, False);
    Query.ParamByName('subtotal_amount').AsCurrency :=
      AReceipt.SubtotalAmount;
    Query.ParamByName('discount_amount').AsCurrency :=
      AReceipt.DiscountAmount;
    Query.ParamByName('total_amount').AsCurrency :=
      AReceipt.TotalAmount;
    Query.ParamByName('payment_summary').AsString :=
      AReceipt.PaymentSummary;
    Query.ParamByName('notes').AsString := AReceipt.Notes;
    Query.ParamByName('status').AsString := AReceipt.Status;
    Query.ParamByName('created_by_user_id').AsInteger :=
      AReceipt.CreatedByUserId;
    Query.ParamByName('is_active').AsInteger :=
      Ord(AReceipt.IsActive);
    Query.ParamByName('created_at').AsString :=
      DateToISO8601(AReceipt.CreatedAt, False);
    Query.ExecSQL;
    AReceipt.Id :=
      Query.Connection.GetLastAutoGenValue('receipts');
  finally
    Query.Free;
  end;
end;

procedure TReceiptRepository.InsertItems(
  AItems: TObjectList<TReceiptItem>);
var
  Item: TReceiptItem;
  Query: TFDQuery;
begin
  if not Assigned(AItems) then
    raise EArgumentNilException.Create('Receipt items are required.');

  FDatabaseConnection.Connect;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'INSERT INTO receipt_items (' +
      'receipt_id, product_id, description, quantity, unit_price, ' +
      'discount_amount, total_amount, created_at) VALUES (' +
      ':receipt_id, NULLIF(:product_id, 0), :description, :quantity, ' +
      ':unit_price, :discount_amount, :total_amount, :created_at)';

    for Item in AItems do
    begin
      Query.ParamByName('receipt_id').AsInteger := Item.ReceiptId;
      Query.ParamByName('product_id').AsInteger := Item.ProductId;
      Query.ParamByName('description').AsString := Item.Description;
      Query.ParamByName('quantity').AsFloat := Item.Quantity;
      Query.ParamByName('unit_price').AsCurrency := Item.UnitPrice;
      Query.ParamByName('discount_amount').AsCurrency :=
        Item.DiscountAmount;
      Query.ParamByName('total_amount').AsCurrency := Item.TotalAmount;
      Query.ParamByName('created_at').AsString :=
        DateToISO8601(Item.CreatedAt, False);
      Query.ExecSQL;
      Item.Id :=
        Query.Connection.GetLastAutoGenValue('receipt_items');
    end;
  finally
    Query.Free;
  end;
end;

procedure TReceiptRepository.Cancel(AId: Integer);
var
  Query: TFDQuery;
begin
  FDatabaseConnection.Connect;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'UPDATE receipts SET status = :status, ' +
      'updated_at = datetime(''now'') WHERE id = :id';
    Query.ParamByName('status').AsString := 'Canceled';
    Query.ParamByName('id').AsInteger := AId;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

end.
