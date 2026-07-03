unit ReportRepository;

interface

uses
  System.Generics.Collections,
  DatabaseConnectionIntf,
  IReportRepository,
  ReportDtos;

type
  TReportRepository = class(
    TInterfacedObject,
    IReportRepositoryContract)
  private
    FDatabaseConnection: IDatabaseConnection;
  public
    constructor Create(const ADatabaseConnection: IDatabaseConnection);
    function GetSalesSummary(
      AStartDate,
      AEndDate: TDateTime): TSalesSummaryReportDto;
    function GetSalesByPaymentMethod(
      AStartDate,
      AEndDate: TDateTime):
      TObjectList<TSalesByPaymentMethodReportDto>;
    function GetLowStockProducts:
      TObjectList<TLowStockProductReportDto>;
    function GetOpenAccountsReceivable:
      TObjectList<TOpenAccountReceivableReportDto>;
    function GetCashSummary(
      AStartDate,
      AEndDate: TDateTime): TObjectList<TCashSummaryReportDto>;
    function GetStockMovementsByProduct(
      AProductId: Integer;
      AStartDate,
      AEndDate: TDateTime): TObjectList<TStockMovementReportDto>;
  end;

implementation

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param;

function DateParameter(AValue: TDateTime): string;
begin
  Result := FormatDateTime('yyyy-mm-dd', AValue);
end;

function DatabaseDateToText(const AValue: string): string;
begin
  Result := StringReplace(AValue, ' ', 'T', [rfReplaceAll]);
end;

constructor TReportRepository.Create(
  const ADatabaseConnection: IDatabaseConnection);
begin
  inherited Create;
  FDatabaseConnection := ADatabaseConnection;
end;

function TReportRepository.GetSalesSummary(
  AStartDate,
  AEndDate: TDateTime): TSalesSummaryReportDto;
var
  Query: TFDQuery;
begin
  Result := TSalesSummaryReportDto.Create;
  try
    Result.StartDate := DateParameter(AStartDate);
    Result.EndDate := DateParameter(AEndDate);
    FDatabaseConnection.Connect;

    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FDatabaseConnection.Connection;
      Query.SQL.Text :=
        'SELECT COUNT(*) AS total_sales, ' +
        'COALESCE(SUM(CASE WHEN status = ''Canceled'' ' +
        'THEN 1 ELSE 0 END), 0) AS canceled_sales, ' +
        'COALESCE(SUM(CASE WHEN status <> ''Canceled'' ' +
        'THEN subtotal_amount ELSE 0 END), 0) AS gross_amount, ' +
        'COALESCE(SUM(CASE WHEN status <> ''Canceled'' ' +
        'THEN discount_amount ELSE 0 END), 0) AS discount_amount, ' +
        'COALESCE(SUM(CASE WHEN status <> ''Canceled'' ' +
        'THEN total_amount ELSE 0 END), 0) AS net_amount ' +
        'FROM sales WHERE date(sale_date) ' +
        'BETWEEN :start_date AND :end_date';
      Query.ParamByName('start_date').AsString :=
        DateParameter(AStartDate);
      Query.ParamByName('end_date').AsString :=
        DateParameter(AEndDate);
      Query.Open;

      Result.TotalSales :=
        Query.FieldByName('total_sales').AsInteger;
      Result.CanceledSales :=
        Query.FieldByName('canceled_sales').AsInteger;
      Result.GrossAmount :=
        Query.FieldByName('gross_amount').AsCurrency;
      Result.DiscountAmount :=
        Query.FieldByName('discount_amount').AsCurrency;
      Result.NetAmount :=
        Query.FieldByName('net_amount').AsCurrency;
    finally
      Query.Free;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TReportRepository.GetSalesByPaymentMethod(
  AStartDate,
  AEndDate: TDateTime):
  TObjectList<TSalesByPaymentMethodReportDto>;
var
  Item: TSalesByPaymentMethodReportDto;
  Query: TFDQuery;
begin
  Result := TObjectList<TSalesByPaymentMethodReportDto>.Create(True);
  try
    FDatabaseConnection.Connect;
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FDatabaseConnection.Connection;
      Query.SQL.Text :=
        'SELECT sp.payment_method, ' +
        'COUNT(DISTINCT sp.sale_id) AS total_transactions, ' +
        'COALESCE(SUM(sp.amount), 0) AS total_amount ' +
        'FROM sale_payments sp ' +
        'INNER JOIN sales s ON s.id = sp.sale_id ' +
        'WHERE s.status <> ''Canceled'' ' +
        'AND date(s.sale_date) BETWEEN :start_date AND :end_date ' +
        'GROUP BY sp.payment_method ORDER BY sp.payment_method';
      Query.ParamByName('start_date').AsString :=
        DateParameter(AStartDate);
      Query.ParamByName('end_date').AsString :=
        DateParameter(AEndDate);
      Query.Open;

      while not Query.Eof do
      begin
        Item := TSalesByPaymentMethodReportDto.Create;
        Item.PaymentMethod :=
          Query.FieldByName('payment_method').AsString;
        Item.TotalTransactions :=
          Query.FieldByName('total_transactions').AsInteger;
        Item.TotalAmount :=
          Query.FieldByName('total_amount').AsCurrency;
        Result.Add(Item);
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

function TReportRepository.GetLowStockProducts:
  TObjectList<TLowStockProductReportDto>;
var
  Item: TLowStockProductReportDto;
  Query: TFDQuery;
begin
  Result := TObjectList<TLowStockProductReportDto>.Create(True);
  try
    FDatabaseConnection.Connect;
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FDatabaseConnection.Connection;
      Query.SQL.Text :=
        'SELECT id, internal_code, barcode, description, brand_name, ' +
        'category_name, current_stock, minimum_stock FROM products ' +
        'WHERE is_active = 1 AND current_stock <= minimum_stock ' +
        'ORDER BY description';
      Query.Open;

      while not Query.Eof do
      begin
        Item := TLowStockProductReportDto.Create;
        Item.ProductId := Query.FieldByName('id').AsInteger;
        Item.InternalCode :=
          Query.FieldByName('internal_code').AsString;
        Item.BarCode := Query.FieldByName('barcode').AsString;
        Item.Description :=
          Query.FieldByName('description').AsString;
        Item.BrandName := Query.FieldByName('brand_name').AsString;
        Item.CategoryName :=
          Query.FieldByName('category_name').AsString;
        Item.CurrentStock :=
          Query.FieldByName('current_stock').AsFloat;
        Item.MinimumStock :=
          Query.FieldByName('minimum_stock').AsFloat;
        Result.Add(Item);
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

function TReportRepository.GetOpenAccountsReceivable:
  TObjectList<TOpenAccountReceivableReportDto>;
var
  Item: TOpenAccountReceivableReportDto;
  Query: TFDQuery;
begin
  Result := TObjectList<TOpenAccountReceivableReportDto>.Create(True);
  try
    FDatabaseConnection.Connect;
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FDatabaseConnection.Connection;
      Query.SQL.Text :=
        'SELECT ar.id, ar.sale_id, ar.customer_id, ' +
        'COALESCE(c.name, '''') AS customer_name, ar.issue_date, ' +
        'ar.due_date, ar.total_amount, ar.received_amount, ' +
        'ar.balance_amount, ar.status FROM accounts_receivable ar ' +
        'LEFT JOIN customers c ON c.id = ar.customer_id ' +
        'WHERE ar.is_active = 1 AND ar.status IN (''Open'', ''Partial'') ' +
        'ORDER BY COALESCE(ar.due_date, ar.issue_date), ar.id';
      Query.Open;

      while not Query.Eof do
      begin
        Item := TOpenAccountReceivableReportDto.Create;
        Item.AccountReceivableId :=
          Query.FieldByName('id').AsInteger;
        Item.SaleId := Query.FieldByName('sale_id').AsInteger;
        Item.CustomerId :=
          Query.FieldByName('customer_id').AsInteger;
        Item.CustomerName :=
          Query.FieldByName('customer_name').AsString;
        Item.IssueDate := DatabaseDateToText(
          Query.FieldByName('issue_date').AsString);
        if not Query.FieldByName('due_date').IsNull then
          Item.DueDate := DatabaseDateToText(
            Query.FieldByName('due_date').AsString);
        Item.TotalAmount :=
          Query.FieldByName('total_amount').AsCurrency;
        Item.ReceivedAmount :=
          Query.FieldByName('received_amount').AsCurrency;
        Item.BalanceAmount :=
          Query.FieldByName('balance_amount').AsCurrency;
        Item.Status := Query.FieldByName('status').AsString;
        Result.Add(Item);
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

function TReportRepository.GetCashSummary(
  AStartDate,
  AEndDate: TDateTime): TObjectList<TCashSummaryReportDto>;
var
  Item: TCashSummaryReportDto;
  Query: TFDQuery;
begin
  Result := TObjectList<TCashSummaryReportDto>.Create(True);
  try
    FDatabaseConnection.Connect;
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FDatabaseConnection.Connection;
      Query.SQL.Text :=
        'SELECT cr.id, cr.opened_at, cr.closed_at, cr.opening_amount, ' +
        'cr.expected_amount, cr.closing_amount, cr.difference_amount, ' +
        'cr.status, ' +
        'COALESCE(SUM(CASE WHEN cm.movement_type <> ''Opening'' ' +
        'AND cm.amount > 0 THEN cm.amount ELSE 0 END), 0) AS total_in, ' +
        'COALESCE(SUM(CASE WHEN cm.amount < 0 ' +
        'THEN -cm.amount ELSE 0 END), 0) AS total_out ' +
        'FROM cash_registers cr ' +
        'LEFT JOIN cash_movements cm ON cm.cash_register_id = cr.id ' +
        'WHERE date(cr.opened_at) BETWEEN :start_date AND :end_date ' +
        'GROUP BY cr.id, cr.opened_at, cr.closed_at, cr.opening_amount, ' +
        'cr.expected_amount, cr.closing_amount, cr.difference_amount, ' +
        'cr.status ORDER BY cr.opened_at DESC, cr.id DESC';
      Query.ParamByName('start_date').AsString :=
        DateParameter(AStartDate);
      Query.ParamByName('end_date').AsString :=
        DateParameter(AEndDate);
      Query.Open;

      while not Query.Eof do
      begin
        Item := TCashSummaryReportDto.Create;
        Item.CashRegisterId := Query.FieldByName('id').AsInteger;
        Item.OpenedAt := DatabaseDateToText(
          Query.FieldByName('opened_at').AsString);
        if not Query.FieldByName('closed_at').IsNull then
          Item.ClosedAt := DatabaseDateToText(
            Query.FieldByName('closed_at').AsString);
        Item.OpeningAmount :=
          Query.FieldByName('opening_amount').AsCurrency;
        Item.TotalIn := Query.FieldByName('total_in').AsCurrency;
        Item.TotalOut := Query.FieldByName('total_out').AsCurrency;
        if not Query.FieldByName('expected_amount').IsNull then
          Item.ExpectedAmount :=
            Query.FieldByName('expected_amount').AsCurrency;
        if not Query.FieldByName('closing_amount').IsNull then
          Item.ClosingAmount :=
            Query.FieldByName('closing_amount').AsCurrency;
        if not Query.FieldByName('difference_amount').IsNull then
          Item.DifferenceAmount :=
            Query.FieldByName('difference_amount').AsCurrency;
        Item.Status := Query.FieldByName('status').AsString;
        Result.Add(Item);
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

function TReportRepository.GetStockMovementsByProduct(
  AProductId: Integer;
  AStartDate,
  AEndDate: TDateTime): TObjectList<TStockMovementReportDto>;
var
  Item: TStockMovementReportDto;
  Query: TFDQuery;
begin
  Result := TObjectList<TStockMovementReportDto>.Create(True);
  try
    FDatabaseConnection.Connect;
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FDatabaseConnection.Connection;
      Query.SQL.Text :=
        'SELECT sm.id, sm.product_id, p.description AS product_description, ' +
        'sm.movement_date, sm.movement_type, sm.source_type, sm.source_id, ' +
        'sm.quantity, sm.previous_stock, sm.new_stock, sm.notes ' +
        'FROM stock_movements sm ' +
        'INNER JOIN products p ON p.id = sm.product_id ' +
        'WHERE sm.is_active = 1 AND sm.product_id = :product_id';
      if AStartDate > 0 then
        Query.SQL.Add(
          'AND date(sm.movement_date) >= :start_date');
      if AEndDate > 0 then
        Query.SQL.Add(
          'AND date(sm.movement_date) <= :end_date');
      Query.SQL.Add(
        'ORDER BY sm.movement_date DESC, sm.id DESC');
      Query.ParamByName('product_id').AsInteger := AProductId;
      if AStartDate > 0 then
        Query.ParamByName('start_date').AsString :=
          DateParameter(AStartDate);
      if AEndDate > 0 then
        Query.ParamByName('end_date').AsString :=
          DateParameter(AEndDate);
      Query.Open;

      while not Query.Eof do
      begin
        Item := TStockMovementReportDto.Create;
        Item.Id := Query.FieldByName('id').AsInteger;
        Item.ProductId :=
          Query.FieldByName('product_id').AsInteger;
        Item.ProductDescription :=
          Query.FieldByName('product_description').AsString;
        Item.MovementDate := DatabaseDateToText(
          Query.FieldByName('movement_date').AsString);
        Item.MovementType :=
          Query.FieldByName('movement_type').AsString;
        Item.SourceType :=
          Query.FieldByName('source_type').AsString;
        if not Query.FieldByName('source_id').IsNull then
          Item.SourceId := Query.FieldByName('source_id').AsInteger;
        Item.Quantity := Query.FieldByName('quantity').AsFloat;
        Item.PreviousStock :=
          Query.FieldByName('previous_stock').AsFloat;
        Item.NewStock := Query.FieldByName('new_stock').AsFloat;
        Item.Notes := Query.FieldByName('notes').AsString;
        Result.Add(Item);
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
