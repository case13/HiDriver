unit ReportAppService;

interface

uses
  IReportAppService,
  IReportDomainService,
  IReportRepository,
  IReportValidator;

type
  TReportAppService = class(
    TInterfacedObject,
    IReportAppServiceContract)
  private
    FReportRepository: IReportRepositoryContract;
    FReportValidator: IReportValidatorContract;
    FReportDomainService: IReportDomainServiceContract;
  public
    constructor Create(
      const AReportRepository: IReportRepositoryContract;
      const AReportValidator: IReportValidatorContract;
      const AReportDomainService: IReportDomainServiceContract);
    function GetSalesSummary(
      const AStartDate,
      AEndDate: string): string;
    function GetSalesByPaymentMethod(
      const AStartDate,
      AEndDate: string): string;
    function GetLowStockProducts: string;
    function GetOpenAccountsReceivable: string;
    function GetCashSummary(
      const AStartDate,
      AEndDate: string): string;
    function GetStockMovementsByProduct(
      AProductId: Integer;
      const AStartDate,
      AEndDate: string): string;
  end;

implementation

uses
  System.Generics.Collections,
  System.JSON,
  ReportDtos;

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

function SalesSummaryToJson(
  AReport: TSalesSummaryReportDto): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('startDate', AReport.StartDate);
  Result.AddPair('endDate', AReport.EndDate);
  Result.AddPair(
    'totalSales',
    TJSONNumber.Create(AReport.TotalSales));
  Result.AddPair(
    'canceledSales',
    TJSONNumber.Create(AReport.CanceledSales));
  Result.AddPair(
    'netSales',
    TJSONNumber.Create(AReport.NetSales));
  Result.AddPair(
    'grossAmount',
    TJSONNumber.Create(Double(AReport.GrossAmount)));
  Result.AddPair(
    'discountAmount',
    TJSONNumber.Create(Double(AReport.DiscountAmount)));
  Result.AddPair(
    'netAmount',
    TJSONNumber.Create(Double(AReport.NetAmount)));
end;

function SalesByPaymentMethodToJson(
  AReport: TSalesByPaymentMethodReportDto): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('paymentMethod', AReport.PaymentMethod);
  Result.AddPair(
    'totalTransactions',
    TJSONNumber.Create(AReport.TotalTransactions));
  Result.AddPair(
    'totalAmount',
    TJSONNumber.Create(Double(AReport.TotalAmount)));
end;

function LowStockProductToJson(
  AReport: TLowStockProductReportDto): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair(
    'productId',
    TJSONNumber.Create(AReport.ProductId));
  Result.AddPair('internalCode', AReport.InternalCode);
  Result.AddPair('barcode', AReport.BarCode);
  Result.AddPair('description', AReport.Description);
  Result.AddPair('brandName', AReport.BrandName);
  Result.AddPair('categoryName', AReport.CategoryName);
  Result.AddPair(
    'currentStock',
    TJSONNumber.Create(AReport.CurrentStock));
  Result.AddPair(
    'minimumStock',
    TJSONNumber.Create(AReport.MinimumStock));
  Result.AddPair(
    'missingQuantity',
    TJSONNumber.Create(AReport.MissingQuantity));
end;

function OpenAccountReceivableToJson(
  AReport: TOpenAccountReceivableReportDto): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair(
    'accountReceivableId',
    TJSONNumber.Create(AReport.AccountReceivableId));
  Result.AddPair('saleId', TJSONNumber.Create(AReport.SaleId));
  Result.AddPair(
    'customerId',
    TJSONNumber.Create(AReport.CustomerId));
  Result.AddPair('customerName', AReport.CustomerName);
  Result.AddPair('issueDate', AReport.IssueDate);
  Result.AddPair('dueDate', AReport.DueDate);
  Result.AddPair(
    'totalAmount',
    TJSONNumber.Create(Double(AReport.TotalAmount)));
  Result.AddPair(
    'receivedAmount',
    TJSONNumber.Create(Double(AReport.ReceivedAmount)));
  Result.AddPair(
    'balanceAmount',
    TJSONNumber.Create(Double(AReport.BalanceAmount)));
  Result.AddPair('status', AReport.Status);
end;

function CashSummaryToJson(
  AReport: TCashSummaryReportDto): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair(
    'cashRegisterId',
    TJSONNumber.Create(AReport.CashRegisterId));
  Result.AddPair('openedAt', AReport.OpenedAt);
  Result.AddPair('closedAt', AReport.ClosedAt);
  Result.AddPair(
    'openingAmount',
    TJSONNumber.Create(Double(AReport.OpeningAmount)));
  Result.AddPair(
    'totalIn',
    TJSONNumber.Create(Double(AReport.TotalIn)));
  Result.AddPair(
    'totalOut',
    TJSONNumber.Create(Double(AReport.TotalOut)));
  Result.AddPair(
    'expectedAmount',
    TJSONNumber.Create(Double(AReport.ExpectedAmount)));
  Result.AddPair(
    'closingAmount',
    TJSONNumber.Create(Double(AReport.ClosingAmount)));
  Result.AddPair(
    'differenceAmount',
    TJSONNumber.Create(Double(AReport.DifferenceAmount)));
  Result.AddPair('status', AReport.Status);
end;

function StockMovementToJson(
  AReport: TStockMovementReportDto): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(AReport.Id));
  Result.AddPair(
    'productId',
    TJSONNumber.Create(AReport.ProductId));
  Result.AddPair(
    'productDescription',
    AReport.ProductDescription);
  Result.AddPair('movementDate', AReport.MovementDate);
  Result.AddPair('movementType', AReport.MovementType);
  Result.AddPair('sourceType', AReport.SourceType);
  if AReport.SourceId > 0 then
    Result.AddPair(
      'sourceId',
      TJSONNumber.Create(AReport.SourceId))
  else
    Result.AddPair('sourceId', TJSONNull.Create);
  Result.AddPair(
    'quantity',
    TJSONNumber.Create(AReport.Quantity));
  Result.AddPair(
    'previousStock',
    TJSONNumber.Create(AReport.PreviousStock));
  Result.AddPair(
    'newStock',
    TJSONNumber.Create(AReport.NewStock));
  Result.AddPair('notes', AReport.Notes);
end;

constructor TReportAppService.Create(
  const AReportRepository: IReportRepositoryContract;
  const AReportValidator: IReportValidatorContract;
  const AReportDomainService: IReportDomainServiceContract);
begin
  inherited Create;
  FReportRepository := AReportRepository;
  FReportValidator := AReportValidator;
  FReportDomainService := AReportDomainService;
end;

function TReportAppService.GetSalesSummary(
  const AStartDate,
  AEndDate: string): string;
var
  EndDate: TDateTime;
  ErrorMessage: string;
  Report: TSalesSummaryReportDto;
  StartDate: TDateTime;
begin
  if not FReportValidator.ValidateRequiredPeriod(
    AStartDate,
    AEndDate,
    StartDate,
    EndDate,
    ErrorMessage) then
    raise EReportValidationException.Create(ErrorMessage);

  Report := FReportRepository.GetSalesSummary(StartDate, EndDate);
  try
    FReportDomainService.CompleteSalesSummary(Report);
    Result := BuildSuccessResponse('', SalesSummaryToJson(Report));
  finally
    Report.Free;
  end;
end;

function TReportAppService.GetSalesByPaymentMethod(
  const AStartDate,
  AEndDate: string): string;
var
  EndDate: TDateTime;
  ErrorMessage: string;
  Item: TSalesByPaymentMethodReportDto;
  JsonArray: TJSONArray;
  Reports: TObjectList<TSalesByPaymentMethodReportDto>;
  StartDate: TDateTime;
begin
  if not FReportValidator.ValidateRequiredPeriod(
    AStartDate,
    AEndDate,
    StartDate,
    EndDate,
    ErrorMessage) then
    raise EReportValidationException.Create(ErrorMessage);

  Reports := FReportRepository.GetSalesByPaymentMethod(
    StartDate,
    EndDate);
  try
    JsonArray := TJSONArray.Create;
    try
      for Item in Reports do
        JsonArray.AddElement(SalesByPaymentMethodToJson(Item));
      Result := BuildSuccessResponse('', JsonArray);
      JsonArray := nil;
    finally
      JsonArray.Free;
    end;
  finally
    Reports.Free;
  end;
end;

function TReportAppService.GetLowStockProducts: string;
var
  Item: TLowStockProductReportDto;
  JsonArray: TJSONArray;
  Reports: TObjectList<TLowStockProductReportDto>;
begin
  Reports := FReportRepository.GetLowStockProducts;
  try
    FReportDomainService.CompleteLowStockProducts(Reports);
    JsonArray := TJSONArray.Create;
    try
      for Item in Reports do
        JsonArray.AddElement(LowStockProductToJson(Item));
      Result := BuildSuccessResponse('', JsonArray);
      JsonArray := nil;
    finally
      JsonArray.Free;
    end;
  finally
    Reports.Free;
  end;
end;

function TReportAppService.GetOpenAccountsReceivable: string;
var
  Item: TOpenAccountReceivableReportDto;
  JsonArray: TJSONArray;
  Reports: TObjectList<TOpenAccountReceivableReportDto>;
begin
  Reports := FReportRepository.GetOpenAccountsReceivable;
  try
    JsonArray := TJSONArray.Create;
    try
      for Item in Reports do
        JsonArray.AddElement(OpenAccountReceivableToJson(Item));
      Result := BuildSuccessResponse('', JsonArray);
      JsonArray := nil;
    finally
      JsonArray.Free;
    end;
  finally
    Reports.Free;
  end;
end;

function TReportAppService.GetCashSummary(
  const AStartDate,
  AEndDate: string): string;
var
  EndDate: TDateTime;
  ErrorMessage: string;
  Item: TCashSummaryReportDto;
  JsonArray: TJSONArray;
  Reports: TObjectList<TCashSummaryReportDto>;
  StartDate: TDateTime;
begin
  if not FReportValidator.ValidateRequiredPeriod(
    AStartDate,
    AEndDate,
    StartDate,
    EndDate,
    ErrorMessage) then
    raise EReportValidationException.Create(ErrorMessage);

  Reports := FReportRepository.GetCashSummary(StartDate, EndDate);
  try
    FReportDomainService.CompleteCashSummary(Reports);
    JsonArray := TJSONArray.Create;
    try
      for Item in Reports do
        JsonArray.AddElement(CashSummaryToJson(Item));
      Result := BuildSuccessResponse('', JsonArray);
      JsonArray := nil;
    finally
      JsonArray.Free;
    end;
  finally
    Reports.Free;
  end;
end;

function TReportAppService.GetStockMovementsByProduct(
  AProductId: Integer;
  const AStartDate,
  AEndDate: string): string;
var
  EndDate: TDateTime;
  ErrorMessage: string;
  Item: TStockMovementReportDto;
  JsonArray: TJSONArray;
  Reports: TObjectList<TStockMovementReportDto>;
  StartDate: TDateTime;
begin
  if not FReportValidator.ValidateStockMovementFilter(
    AProductId,
    AStartDate,
    AEndDate,
    StartDate,
    EndDate,
    ErrorMessage) then
    raise EReportValidationException.Create(ErrorMessage);

  Reports := FReportRepository.GetStockMovementsByProduct(
    AProductId,
    StartDate,
    EndDate);
  try
    JsonArray := TJSONArray.Create;
    try
      for Item in Reports do
        JsonArray.AddElement(StockMovementToJson(Item));
      Result := BuildSuccessResponse('', JsonArray);
      JsonArray := nil;
    finally
      JsonArray.Free;
    end;
  finally
    Reports.Free;
  end;
end;

end.
