unit ReceiptAppService;

interface

uses
  AccountReceivableRepositoryIntf,
  CustomerRepositoryIntf,
  Receipt,
  ReceiptAppServiceIntf,
  ReceiptDomainServiceIntf,
  ReceiptDto,
  ReceiptRepositoryIntf,
  ReceiptValidatorIntf,
  SaleItemRepositoryIntf,
  SalePaymentRepositoryIntf,
  SaleRepositoryIntf,
  TransactionManagerIntf;

type
  TReceiptAppService = class(TInterfacedObject, IReceiptAppService)
  private
    FReceiptRepository: IReceiptRepository;
    FReceiptValidator: IReceiptValidator;
    FReceiptDomainService: IReceiptDomainService;
    FSaleRepository: ISaleRepository;
    FSaleItemRepository: ISaleItemRepository;
    FSalePaymentRepository: ISalePaymentRepository;
    FAccountReceivableRepository: IAccountReceivableRepository;
    FCustomerRepository: ICustomerRepository;
    FTransactionManager: ITransactionManager;
    function ToDto(AReceipt: TReceipt): TReceiptDto;
  public
    constructor Create(
      const AReceiptRepository: IReceiptRepository;
      const AReceiptValidator: IReceiptValidator;
      const AReceiptDomainService: IReceiptDomainService;
      const ASaleRepository: ISaleRepository;
      const ASaleItemRepository: ISaleItemRepository;
      const ASalePaymentRepository: ISalePaymentRepository;
      const AAccountReceivableRepository:
        IAccountReceivableRepository;
      const ACustomerRepository: ICustomerRepository;
      const ATransactionManager: ITransactionManager);
    function GetAll: string;
    function GetById(AId: Integer): string;
    function GetByNumber(const AReceiptNumber: string): string;
    function IssueSaleReceipt(
      ARequest: TIssueSaleReceiptRequestDto): string;
    function IssueAccountReceivablePaymentReceipt(
      ARequest:
        TIssueAccountReceivablePaymentReceiptRequestDto): string;
    function Cancel(AId: Integer): string;
  end;

implementation

uses
  System.DateUtils,
  System.Generics.Collections,
  System.JSON,
  System.SysUtils,
  AccountReceivable,
  AccountReceivablePayment,
  Customer,
  ReceiptItem,
  ReceiptSourceTypeEnum,
  Sale,
  SaleItem,
  SalePayment;

function ReceiptItemDtoToJson(
  AItem: TReceiptItemDto): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(AItem.Id));
  if AItem.ProductId > 0 then
    Result.AddPair(
      'productId',
      TJSONNumber.Create(AItem.ProductId))
  else
    Result.AddPair('productId', TJSONNull.Create);
  Result.AddPair('description', AItem.Description);
  Result.AddPair('quantity', TJSONNumber.Create(AItem.Quantity));
  Result.AddPair(
    'unitPrice',
    TJSONNumber.Create(Double(AItem.UnitPrice)));
  Result.AddPair(
    'discountAmount',
    TJSONNumber.Create(Double(AItem.DiscountAmount)));
  Result.AddPair(
    'totalAmount',
    TJSONNumber.Create(Double(AItem.TotalAmount)));
end;

function ReceiptDtoToJson(AReceipt: TReceiptDto): TJSONObject;
var
  Item: TReceiptItemDto;
  Items: TJSONArray;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(AReceipt.Id));
  Result.AddPair('receiptNumber', AReceipt.ReceiptNumber);
  Result.AddPair('sourceType', AReceipt.SourceType);
  Result.AddPair('sourceId', TJSONNumber.Create(AReceipt.SourceId));
  if AReceipt.CustomerId > 0 then
    Result.AddPair(
      'customerId',
      TJSONNumber.Create(AReceipt.CustomerId))
  else
    Result.AddPair('customerId', TJSONNull.Create);
  Result.AddPair('customerName', AReceipt.CustomerName);
  Result.AddPair('customerDocument', AReceipt.CustomerDocument);
  Result.AddPair('issueDate', AReceipt.IssueDate);
  Result.AddPair(
    'subtotalAmount',
    TJSONNumber.Create(Double(AReceipt.SubtotalAmount)));
  Result.AddPair(
    'discountAmount',
    TJSONNumber.Create(Double(AReceipt.DiscountAmount)));
  Result.AddPair(
    'totalAmount',
    TJSONNumber.Create(Double(AReceipt.TotalAmount)));
  Result.AddPair('paymentSummary', AReceipt.PaymentSummary);
  Result.AddPair('notes', AReceipt.Notes);
  Result.AddPair('status', AReceipt.Status);

  Items := TJSONArray.Create;
  for Item in AReceipt.Items do
    Items.AddElement(ReceiptItemDtoToJson(Item));
  Result.AddPair('items', Items);
end;

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

constructor TReceiptAppService.Create(
  const AReceiptRepository: IReceiptRepository;
  const AReceiptValidator: IReceiptValidator;
  const AReceiptDomainService: IReceiptDomainService;
  const ASaleRepository: ISaleRepository;
  const ASaleItemRepository: ISaleItemRepository;
  const ASalePaymentRepository: ISalePaymentRepository;
  const AAccountReceivableRepository: IAccountReceivableRepository;
  const ACustomerRepository: ICustomerRepository;
  const ATransactionManager: ITransactionManager);
begin
  inherited Create;
  FReceiptRepository := AReceiptRepository;
  FReceiptValidator := AReceiptValidator;
  FReceiptDomainService := AReceiptDomainService;
  FSaleRepository := ASaleRepository;
  FSaleItemRepository := ASaleItemRepository;
  FSalePaymentRepository := ASalePaymentRepository;
  FAccountReceivableRepository := AAccountReceivableRepository;
  FCustomerRepository := ACustomerRepository;
  FTransactionManager := ATransactionManager;
end;

function TReceiptAppService.ToDto(AReceipt: TReceipt): TReceiptDto;
var
  Item: TReceiptItem;
  ItemDto: TReceiptItemDto;
begin
  Result := TReceiptDto.Create;
  try
    Result.Id := AReceipt.Id;
    Result.ReceiptNumber := AReceipt.ReceiptNumber;
    Result.SourceType := AReceipt.SourceType;
    Result.SourceId := AReceipt.SourceId;
    Result.CustomerId := AReceipt.CustomerId;
    Result.CustomerName := AReceipt.CustomerName;
    Result.CustomerDocument := AReceipt.CustomerDocument;
    Result.IssueDate := DateToISO8601(AReceipt.IssueDate, False);
    Result.SubtotalAmount := AReceipt.SubtotalAmount;
    Result.DiscountAmount := AReceipt.DiscountAmount;
    Result.TotalAmount := AReceipt.TotalAmount;
    Result.PaymentSummary := AReceipt.PaymentSummary;
    Result.Notes := AReceipt.Notes;
    Result.Status := AReceipt.Status;

    for Item in AReceipt.Items do
    begin
      ItemDto := TReceiptItemDto.Create;
      ItemDto.Id := Item.Id;
      ItemDto.ProductId := Item.ProductId;
      ItemDto.Description := Item.Description;
      ItemDto.Quantity := Item.Quantity;
      ItemDto.UnitPrice := Item.UnitPrice;
      ItemDto.DiscountAmount := Item.DiscountAmount;
      ItemDto.TotalAmount := Item.TotalAmount;
      Result.Items.Add(ItemDto);
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TReceiptAppService.GetAll: string;
var
  Dto: TReceiptDto;
  JsonArray: TJSONArray;
  Receipt: TReceipt;
  Receipts: TObjectList<TReceipt>;
begin
  Receipts := FReceiptRepository.GetAll;
  try
    JsonArray := TJSONArray.Create;
    try
      for Receipt in Receipts do
      begin
        Dto := ToDto(Receipt);
        try
          JsonArray.AddElement(ReceiptDtoToJson(Dto));
        finally
          Dto.Free;
        end;
      end;
      Result := BuildSuccessResponse('', JsonArray);
      JsonArray := nil;
    finally
      JsonArray.Free;
    end;
  finally
    Receipts.Free;
  end;
end;

function TReceiptAppService.GetById(AId: Integer): string;
var
  Dto: TReceiptDto;
  Receipt: TReceipt;
begin
  Receipt := FReceiptRepository.GetById(AId);
  try
    if not Assigned(Receipt) then
      raise EReceiptNotFoundException.Create('Receipt not found.');
    Dto := ToDto(Receipt);
    try
      Result := BuildSuccessResponse('', ReceiptDtoToJson(Dto));
    finally
      Dto.Free;
    end;
  finally
    Receipt.Free;
  end;
end;

function TReceiptAppService.GetByNumber(
  const AReceiptNumber: string): string;
var
  Dto: TReceiptDto;
  Receipt: TReceipt;
begin
  if Trim(AReceiptNumber) = '' then
    raise EReceiptValidationException.Create(
      'Receipt number is required.');

  Receipt := FReceiptRepository.GetByNumber(Trim(AReceiptNumber));
  try
    if not Assigned(Receipt) then
      raise EReceiptNotFoundException.Create('Receipt not found.');
    Dto := ToDto(Receipt);
    try
      Result := BuildSuccessResponse('', ReceiptDtoToJson(Dto));
    finally
      Dto.Free;
    end;
  finally
    Receipt.Free;
  end;
end;

function TReceiptAppService.IssueSaleReceipt(
  ARequest: TIssueSaleReceiptRequestDto): string;
var
  Customer: TCustomer;
  Dto: TReceiptDto;
  ErrorMessage: string;
  ExistingReceipt: TReceipt;
  Item: TReceiptItem;
  Items: TObjectList<TSaleItem>;
  Payments: TObjectList<TSalePayment>;
  Receipt: TReceipt;
  Sale: TSale;
  Sequence: Integer;
begin
  Customer := nil;
  ExistingReceipt := nil;
  Items := nil;
  Payments := nil;
  Receipt := nil;
  Sale := nil;
  try
    FTransactionManager.StartTransaction;
    try
      if Assigned(ARequest) and (ARequest.SaleId > 0) then
      begin
        Sale := FSaleRepository.FindById(ARequest.SaleId);
        ExistingReceipt := FReceiptRepository.GetBySource(
          ReceiptSourceTypeToString(rstSale),
          ARequest.SaleId);
      end;

      if not FReceiptValidator.ValidateIssueSale(
        ARequest,
        Sale,
        ExistingReceipt,
        ErrorMessage) then
      begin
        if Assigned(ARequest) and (ARequest.SaleId > 0) and
          not Assigned(Sale) then
          raise EReceiptNotFoundException.Create(ErrorMessage);
        if Assigned(Sale) and
          (Sale.IsCanceled or Assigned(ExistingReceipt)) then
          raise EReceiptStateException.Create(ErrorMessage);
        raise EReceiptValidationException.Create(ErrorMessage);
      end;

      Items := FSaleItemRepository.FindBySaleId(Sale.Id);
      Payments := FSalePaymentRepository.FindBySaleId(Sale.Id);
      if Sale.CustomerId > 0 then
        Customer := FCustomerRepository.FindById(Sale.CustomerId);

      Sequence := FReceiptRepository.GetNextId;
      Receipt := FReceiptDomainService.BuildSaleReceipt(
        Sequence,
        Sale,
        Items,
        Payments,
        Customer,
        ARequest.UserId,
        ARequest.Notes);
      FReceiptRepository.Insert(Receipt);
      if Receipt.Id <> Sequence then
        raise EReceiptStateException.Create(
          'Unable to generate a sequential receipt number.');

      for Item in Receipt.Items do
        Item.ReceiptId := Receipt.Id;
      FReceiptRepository.InsertItems(Receipt.Items);
      FTransactionManager.Commit;
    except
      FTransactionManager.Rollback;
      raise;
    end;

    Dto := ToDto(Receipt);
    try
      Result := BuildSuccessResponse(
        'Sale receipt issued successfully.',
        ReceiptDtoToJson(Dto));
    finally
      Dto.Free;
    end;
  finally
    Sale.Free;
    Receipt.Free;
    Payments.Free;
    Items.Free;
    ExistingReceipt.Free;
    Customer.Free;
  end;
end;

function TReceiptAppService.IssueAccountReceivablePaymentReceipt(
  ARequest:
    TIssueAccountReceivablePaymentReceiptRequestDto): string;
var
  Account: TAccountReceivable;
  Customer: TCustomer;
  Dto: TReceiptDto;
  ErrorMessage: string;
  ExistingReceipt: TReceipt;
  Item: TReceiptItem;
  Payment: TAccountReceivablePayment;
  Receipt: TReceipt;
  Sequence: Integer;
begin
  Account := nil;
  Customer := nil;
  ExistingReceipt := nil;
  Payment := nil;
  Receipt := nil;
  try
    FTransactionManager.StartTransaction;
    try
      if Assigned(ARequest) and
        (ARequest.AccountReceivablePaymentId > 0) then
      begin
        Payment := FAccountReceivableRepository.GetPaymentById(
          ARequest.AccountReceivablePaymentId);
        ExistingReceipt := FReceiptRepository.GetBySource(
          ReceiptSourceTypeToString(
            rstAccountReceivablePayment),
          ARequest.AccountReceivablePaymentId);
      end;

      if not FReceiptValidator.
        ValidateIssueAccountReceivablePayment(
          ARequest,
          Payment,
          ExistingReceipt,
          ErrorMessage) then
      begin
        if Assigned(ARequest) and
          (ARequest.AccountReceivablePaymentId > 0) and
          not Assigned(Payment) then
          raise EReceiptNotFoundException.Create(ErrorMessage);
        if Assigned(ExistingReceipt) then
          raise EReceiptStateException.Create(ErrorMessage);
        raise EReceiptValidationException.Create(ErrorMessage);
      end;

      Account := FAccountReceivableRepository.GetById(
        Payment.AccountReceivableId);
      if not Assigned(Account) then
        raise EReceiptStateException.Create(
          'Account receivable for payment was not found.');
      if Account.CustomerId > 0 then
        Customer := FCustomerRepository.FindById(Account.CustomerId);

      Sequence := FReceiptRepository.GetNextId;
      Receipt := FReceiptDomainService.
        BuildAccountReceivablePaymentReceipt(
          Sequence,
          Payment,
          Account,
          Customer,
          ARequest.UserId,
          ARequest.Notes);
      FReceiptRepository.Insert(Receipt);
      if Receipt.Id <> Sequence then
        raise EReceiptStateException.Create(
          'Unable to generate a sequential receipt number.');

      for Item in Receipt.Items do
        Item.ReceiptId := Receipt.Id;
      FReceiptRepository.InsertItems(Receipt.Items);
      FTransactionManager.Commit;
    except
      FTransactionManager.Rollback;
      raise;
    end;

    Dto := ToDto(Receipt);
    try
      Result := BuildSuccessResponse(
        'Account receivable payment receipt issued successfully.',
        ReceiptDtoToJson(Dto));
    finally
      Dto.Free;
    end;
  finally
    Receipt.Free;
    Payment.Free;
    ExistingReceipt.Free;
    Customer.Free;
    Account.Free;
  end;
end;

function TReceiptAppService.Cancel(AId: Integer): string;
var
  Dto: TReceiptDto;
  ErrorMessage: string;
  Receipt: TReceipt;
begin
  Receipt := nil;
  try
    FTransactionManager.StartTransaction;
    try
      if AId > 0 then
        Receipt := FReceiptRepository.GetById(AId);
      if not FReceiptValidator.ValidateCancel(
        AId,
        Receipt,
        ErrorMessage) then
      begin
        if (AId > 0) and not Assigned(Receipt) then
          raise EReceiptNotFoundException.Create(ErrorMessage);
        if Assigned(Receipt) and Receipt.IsCanceled then
          raise EReceiptStateException.Create(ErrorMessage);
        raise EReceiptValidationException.Create(ErrorMessage);
      end;

      Receipt.Cancel;
      FReceiptRepository.Cancel(Receipt.Id);
      FTransactionManager.Commit;
    except
      FTransactionManager.Rollback;
      raise;
    end;

    Dto := ToDto(Receipt);
    try
      Result := BuildSuccessResponse(
        'Receipt canceled successfully.',
        ReceiptDtoToJson(Dto));
    finally
      Dto.Free;
    end;
  finally
    Receipt.Free;
  end;
end;

end.
