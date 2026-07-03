unit SaleAppService;

interface

uses
  AccountReceivableAppServiceIntf,
  CashMovementRepositoryIntf,
  CashRegisterRepositoryIntf,
  CustomerRepositoryIntf,
  ProductRepositoryIntf,
  SaleAppServiceIntf,
  SaleDomainServiceIntf,
  SaleDtos,
  SaleItemRepositoryIntf,
  SalePaymentRepositoryIntf,
  SaleRepositoryIntf,
  SaleValidatorIntf,
  TransactionManagerIntf;

type
  TSaleAppService = class(TInterfacedObject, ISaleAppService)
  private
    FSaleRepository: ISaleRepository;
    FSaleItemRepository: ISaleItemRepository;
    FSalePaymentRepository: ISalePaymentRepository;
    FProductRepository: IProductRepository;
    FCustomerRepository: ICustomerRepository;
    FCashRegisterRepository: ICashRegisterRepository;
    FCashMovementRepository: ICashMovementRepository;
    FSaleValidator: ISaleValidator;
    FSaleDomainService: ISaleDomainService;
    FTransactionManager: ITransactionManager;
    FAccountReceivableAppService: IAccountReceivableAppService;
  protected
    function ISaleAppService.Create = CreateSale;
    function CreateSale(ASale: TSaleCreateDto): string;
  public
    constructor Create(
      const ASaleRepository: ISaleRepository;
      const ASaleItemRepository: ISaleItemRepository;
      const ASalePaymentRepository: ISalePaymentRepository;
      const AProductRepository: IProductRepository;
      const ACustomerRepository: ICustomerRepository;
      const ACashRegisterRepository: ICashRegisterRepository;
      const ACashMovementRepository: ICashMovementRepository;
      const ASaleValidator: ISaleValidator;
      const ASaleDomainService: ISaleDomainService;
      const ATransactionManager: ITransactionManager;
      const AAccountReceivableAppService:
        IAccountReceivableAppService);
    function GetAll: string;
    function GetById(AId: Integer): string;
    function Cancel(AId: Integer): string;
  end;

implementation

uses
  System.DateUtils,
  System.Generics.Collections,
  System.JSON,
  System.SysUtils,
  CashMovement,
  CashMovementTypeEnum,
  CashRegister,
  Customer,
  PaymentMethodEnum,
  Product,
  Sale,
  SaleItem,
  SalePayment;

function DateTimeToText(AValue: TDateTime): string;
begin
  if AValue > 0 then
    Result := DateToISO8601(AValue, False)
  else
    Result := '';
end;

function SaleToReadDto(ASale: TSale): TSaleReadDto;
begin
  Result := TSaleReadDto.Create;
  Result.Id := ASale.Id;
  Result.CustomerId := ASale.CustomerId;
  Result.CashRegisterId := ASale.CashRegisterId;
  Result.SaleDate := DateTimeToText(ASale.SaleDate);
  Result.SubtotalAmount := ASale.SubtotalAmount;
  Result.DiscountAmount := ASale.DiscountAmount;
  Result.TotalAmount := ASale.TotalAmount;
  Result.Status := ASale.Status;
  Result.Notes := ASale.Notes;
end;

function SaleItemToReadDto(ASaleItem: TSaleItem): TSaleItemReadDto;
begin
  Result := TSaleItemReadDto.Create;
  Result.Id := ASaleItem.Id;
  Result.ProductId := ASaleItem.ProductId;
  Result.ProductDescription := ASaleItem.ProductDescription;
  Result.Quantity := ASaleItem.Quantity;
  Result.UnitPrice := ASaleItem.UnitPrice;
  Result.DiscountAmount := ASaleItem.DiscountAmount;
  Result.TotalAmount := ASaleItem.TotalAmount;
end;

function SalePaymentToReadDto(
  ASalePayment: TSalePayment): TSalePaymentReadDto;
begin
  Result := TSalePaymentReadDto.Create;
  Result.Id := ASalePayment.Id;
  Result.PaymentMethod := ASalePayment.PaymentMethod;
  Result.Amount := ASalePayment.Amount;
end;

function SaleItemDtoToJson(ASaleItem: TSaleItemReadDto): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(ASaleItem.Id));
  Result.AddPair('productId', TJSONNumber.Create(ASaleItem.ProductId));
  Result.AddPair('productDescription', ASaleItem.ProductDescription);
  Result.AddPair('quantity', TJSONNumber.Create(ASaleItem.Quantity));
  Result.AddPair(
    'unitPrice',
    TJSONNumber.Create(Double(ASaleItem.UnitPrice)));
  Result.AddPair(
    'discountAmount',
    TJSONNumber.Create(Double(ASaleItem.DiscountAmount)));
  Result.AddPair(
    'totalAmount',
    TJSONNumber.Create(Double(ASaleItem.TotalAmount)));
end;

function SalePaymentDtoToJson(
  ASalePayment: TSalePaymentReadDto): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(ASalePayment.Id));
  Result.AddPair('paymentMethod', ASalePayment.PaymentMethod);
  Result.AddPair(
    'amount',
    TJSONNumber.Create(Double(ASalePayment.Amount)));
end;

function SaleDtoToJson(ASale: TSaleReadDto): TJSONObject;
var
  Item: TSaleItemReadDto;
  Items: TJSONArray;
  Payment: TSalePaymentReadDto;
  Payments: TJSONArray;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(ASale.Id));
  Result.AddPair('customerId', TJSONNumber.Create(ASale.CustomerId));
  Result.AddPair(
    'cashRegisterId',
    TJSONNumber.Create(ASale.CashRegisterId));
  Result.AddPair('saleDate', ASale.SaleDate);
  Result.AddPair(
    'subtotalAmount',
    TJSONNumber.Create(Double(ASale.SubtotalAmount)));
  Result.AddPair(
    'discountAmount',
    TJSONNumber.Create(Double(ASale.DiscountAmount)));
  Result.AddPair(
    'totalAmount',
    TJSONNumber.Create(Double(ASale.TotalAmount)));
  Result.AddPair('status', ASale.Status);
  Result.AddPair('notes', ASale.Notes);

  Items := TJSONArray.Create;
  for Item in ASale.Items do
    Items.AddElement(SaleItemDtoToJson(Item));
  Result.AddPair('items', Items);

  Payments := TJSONArray.Create;
  for Payment in ASale.Payments do
    Payments.AddElement(SalePaymentDtoToJson(Payment));
  Result.AddPair('payments', Payments);
end;

function SaleToJson(
  ASale: TSale;
  AItems: TObjectList<TSaleItem>;
  APayments: TObjectList<TSalePayment>): TJSONObject;
var
  Item: TSaleItem;
  Payment: TSalePayment;
  SaleDto: TSaleReadDto;
begin
  SaleDto := SaleToReadDto(ASale);
  try
    if Assigned(AItems) then
      for Item in AItems do
        SaleDto.Items.Add(SaleItemToReadDto(Item));
    if Assigned(APayments) then
      for Payment in APayments do
        SaleDto.Payments.Add(SalePaymentToReadDto(Payment));
    Result := SaleDtoToJson(SaleDto);
  finally
    SaleDto.Free;
  end;
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

constructor TSaleAppService.Create(
  const ASaleRepository: ISaleRepository;
  const ASaleItemRepository: ISaleItemRepository;
  const ASalePaymentRepository: ISalePaymentRepository;
  const AProductRepository: IProductRepository;
  const ACustomerRepository: ICustomerRepository;
  const ACashRegisterRepository: ICashRegisterRepository;
  const ACashMovementRepository: ICashMovementRepository;
  const ASaleValidator: ISaleValidator;
  const ASaleDomainService: ISaleDomainService;
  const ATransactionManager: ITransactionManager;
  const AAccountReceivableAppService:
    IAccountReceivableAppService);
begin
  inherited Create;
  FSaleRepository := ASaleRepository;
  FSaleItemRepository := ASaleItemRepository;
  FSalePaymentRepository := ASalePaymentRepository;
  FProductRepository := AProductRepository;
  FCustomerRepository := ACustomerRepository;
  FCashRegisterRepository := ACashRegisterRepository;
  FCashMovementRepository := ACashMovementRepository;
  FSaleValidator := ASaleValidator;
  FSaleDomainService := ASaleDomainService;
  FTransactionManager := ATransactionManager;
  FAccountReceivableAppService :=
    AAccountReceivableAppService;
end;

function TSaleAppService.CreateSale(ASale: TSaleCreateDto): string;
var
  CashMovement: TCashMovement;
  CashRegister: TCashRegister;
  CreditSaleTotal: Currency;
  Customer: TCustomer;
  ErrorMessage: string;
  ExistingQuantity: Double;
  Item: TSaleItem;
  ItemDto: TSaleItemCreateDto;
  Items: TObjectList<TSaleItem>;
  Payment: TSalePayment;
  PaymentDto: TSalePaymentCreateDto;
  PaymentMethod: TPaymentMethodEnum;
  Payments: TObjectList<TSalePayment>;
  PaymentsTotal: Currency;
  Product: TProduct;
  RequestedQuantities: TDictionary<Integer, Double>;
  Sale: TSale;
begin
  if not FSaleValidator.ValidateCreate(ASale, ErrorMessage) then
    raise ESaleValidationException.Create(ErrorMessage);

  if not FSaleDomainService.ValidateCreditSaleRequiresCustomer(
    ASale,
    ErrorMessage) then
    raise ESaleValidationException.Create(ErrorMessage);

  CashRegister := nil;
  Customer := nil;
  Items := TObjectList<TSaleItem>.Create(True);
  Payments := TObjectList<TSalePayment>.Create(True);
  RequestedQuantities := TDictionary<Integer, Double>.Create;
  Sale := TSale.Create;
  CreditSaleTotal := 0;
  try
    FTransactionManager.StartTransaction;
    try
      CashRegister := FCashRegisterRepository.FindOpen;
      if not FSaleDomainService.ValidateCashRegisterIsOpen(
        CashRegister,
        ErrorMessage) then
        raise ESaleStateException.Create(ErrorMessage);

      if ASale.CustomerId > 0 then
      begin
        Customer := FCustomerRepository.FindById(ASale.CustomerId);
        if not Assigned(Customer) then
          raise ESaleValidationException.Create('Customer not found.');
      end;

      for ItemDto in ASale.Items do
      begin
        if not RequestedQuantities.TryGetValue(
          ItemDto.ProductId,
          ExistingQuantity) then
          ExistingQuantity := 0;
        ExistingQuantity := ExistingQuantity + ItemDto.Quantity;

        Product := FProductRepository.FindById(ItemDto.ProductId);
        try
          if not FSaleDomainService.ValidateProductForSale(
            Product,
            ExistingQuantity,
            ErrorMessage) then
            raise ESaleStateException.Create(ErrorMessage);

          RequestedQuantities.AddOrSetValue(
            ItemDto.ProductId,
            ExistingQuantity);

          Item := TSaleItem.Create;
          Item.ProductId := Product.Id;
          Item.ProductDescription := Product.Description;
          Item.Quantity := ItemDto.Quantity;
          Item.UnitPrice := ItemDto.UnitPrice;
          Item.DiscountAmount := ItemDto.DiscountAmount;
          Item.TotalAmount := FSaleDomainService.CalculateItemTotal(
            Item.Quantity,
            Item.UnitPrice,
            Item.DiscountAmount);
          if Item.TotalAmount < 0 then
          begin
            Item.Free;
            raise ESaleValidationException.Create(
              'Item discount cannot exceed item gross amount.');
          end;
          Item.CreatedAt := Now;
          Items.Add(Item);
        finally
          Product.Free;
        end;
      end;

      Sale.CustomerId := ASale.CustomerId;
      Sale.CashRegisterId := CashRegister.Id;
      Sale.SubtotalAmount := FSaleDomainService.CalculateSubtotal(Items);
      Sale.DiscountAmount := ASale.DiscountAmount;
      Sale.TotalAmount := FSaleDomainService.CalculateTotal(
        Sale.SubtotalAmount,
        Sale.DiscountAmount);
      if Sale.TotalAmount < 0 then
        raise ESaleValidationException.Create(
          'Sale discount cannot exceed subtotal.');
      Sale.Notes := Trim(ASale.Notes);
      Sale.Complete;

      PaymentsTotal := FSaleDomainService.CalculatePaymentsTotal(
        ASale.Payments);
      if not FSaleDomainService.ValidatePayments(
        Sale.TotalAmount,
        PaymentsTotal,
        ErrorMessage) then
        raise ESaleValidationException.Create(ErrorMessage);

      Sale.Id := FSaleRepository.Insert(Sale);

      for Item in Items do
      begin
        Item.SaleId := Sale.Id;
        FSaleItemRepository.Insert(Item);
        FProductRepository.DecreaseStock(Item.ProductId, Item.Quantity);
      end;

      for PaymentDto in ASale.Payments do
      begin
        TryStringToPaymentMethod(
          PaymentDto.PaymentMethod,
          PaymentMethod);

        Payment := TSalePayment.Create;
        Payment.SaleId := Sale.Id;
        Payment.PaymentMethod := PaymentMethodToString(PaymentMethod);
        Payment.Amount := PaymentDto.Amount;
        Payment.CreatedAt := Now;
        Payments.Add(Payment);
        FSalePaymentRepository.Insert(Payment);

        if PaymentMethod = pmCreditSale then
          CreditSaleTotal := CreditSaleTotal + Payment.Amount
        else if Payment.AffectsCashRegister then
        begin
          CashMovement := TCashMovement.Create;
          try
            CashMovement.CashRegisterId := CashRegister.Id;
            CashMovement.MovementType :=
              CashMovementTypeToString(cmtSale);
            CashMovement.Description := 'Sale payment.';
            CashMovement.Amount := Payment.Amount;
            CashMovement.PaymentMethod := Payment.PaymentMethod;
            CashMovement.ReferenceType := 'Sale';
            CashMovement.ReferenceId := Sale.Id;
            CashMovement.CreatedAt := Now;
            FCashMovementRepository.Insert(CashMovement);
          finally
            CashMovement.Free;
          end;
        end;
      end;

      FAccountReceivableAppService.CreateFromCreditSale(
        Sale.Id,
        Sale.CustomerId,
        CreditSaleTotal);

      FTransactionManager.Commit;
    except
      FTransactionManager.Rollback;
      raise;
    end;

    Result := BuildSuccessResponse(
      'Sale created successfully.',
      SaleToJson(Sale, Items, Payments));
  finally
    Sale.Free;
    RequestedQuantities.Free;
    Payments.Free;
    Items.Free;
    Customer.Free;
    CashRegister.Free;
  end;
end;

function TSaleAppService.GetAll: string;
var
  JsonArray: TJSONArray;
  Sale: TSale;
  Sales: TObjectList<TSale>;
begin
  Sales := FSaleRepository.FindAll;
  try
    JsonArray := TJSONArray.Create;
    try
      for Sale in Sales do
        JsonArray.AddElement(SaleToJson(Sale, nil, nil));
      Result := BuildSuccessResponse('', JsonArray);
      JsonArray := nil;
    finally
      JsonArray.Free;
    end;
  finally
    Sales.Free;
  end;
end;

function TSaleAppService.GetById(AId: Integer): string;
var
  Items: TObjectList<TSaleItem>;
  Payments: TObjectList<TSalePayment>;
  Sale: TSale;
begin
  Sale := FSaleRepository.FindById(AId);
  try
    if not Assigned(Sale) then
      raise ESaleNotFoundException.Create('Sale not found.');

    Items := FSaleItemRepository.FindBySaleId(Sale.Id);
    try
      Payments := FSalePaymentRepository.FindBySaleId(Sale.Id);
      try
        Result := BuildSuccessResponse(
          '',
          SaleToJson(Sale, Items, Payments));
      finally
        Payments.Free;
      end;
    finally
      Items.Free;
    end;
  finally
    Sale.Free;
  end;
end;

function TSaleAppService.Cancel(AId: Integer): string;
var
  CashMovement: TCashMovement;
  CashRegister: TCashRegister;
  Items: TObjectList<TSaleItem>;
  Item: TSaleItem;
  Payments: TObjectList<TSalePayment>;
  Payment: TSalePayment;
  Sale: TSale;
begin
  CashRegister := nil;
  Items := nil;
  Payments := nil;
  Sale := nil;
  try
    FTransactionManager.StartTransaction;
    try
      Sale := FSaleRepository.FindById(AId);
      if not Assigned(Sale) then
        raise ESaleNotFoundException.Create('Sale not found.');

      if Sale.IsCanceled or FSaleRepository.IsCanceled(AId) then
        raise ESaleStateException.Create('Sale is already canceled.');

      CashRegister := FCashRegisterRepository.FindOpen;
      if not Assigned(CashRegister) then
        raise ESaleStateException.Create(
          'Sale cannot be canceled because its cash register is closed.');
      if CashRegister.Id <> Sale.CashRegisterId then
        raise ESaleStateException.Create(
          'Sale can only be canceled in its original open cash register.');

      Items := FSaleItemRepository.FindBySaleId(Sale.Id);
      Payments := FSalePaymentRepository.FindBySaleId(Sale.Id);

      try
        FAccountReceivableAppService.ValidateSaleCancellation(
          Sale.Id);
      except
        on E: EAccountReceivableStateException do
          raise ESaleStateException.Create(E.Message);
      end;

      Sale.Cancel;
      FSaleRepository.Cancel(Sale.Id);
      FAccountReceivableAppService.CancelBySaleId(Sale.Id);

      for Item in Items do
        FProductRepository.IncreaseStock(Item.ProductId, Item.Quantity);

      for Payment in Payments do
        if Payment.AffectsCashRegister then
        begin
          CashMovement := TCashMovement.Create;
          try
            CashMovement.CashRegisterId := CashRegister.Id;
            CashMovement.MovementType :=
              CashMovementTypeToString(cmtSaleCancel);
            CashMovement.Description := 'Sale cancellation.';
            CashMovement.Amount := -Payment.Amount;
            CashMovement.PaymentMethod := Payment.PaymentMethod;
            CashMovement.ReferenceType := 'Sale';
            CashMovement.ReferenceId := Sale.Id;
            CashMovement.CreatedAt := Now;
            FCashMovementRepository.Insert(CashMovement);
          finally
            CashMovement.Free;
          end;
        end;

      FTransactionManager.Commit;
    except
      FTransactionManager.Rollback;
      raise;
    end;

    Result := BuildSuccessResponse(
      'Sale canceled successfully.',
      SaleToJson(Sale, Items, Payments));
  finally
    Payments.Free;
    Items.Free;
    CashRegister.Free;
    Sale.Free;
  end;
end;

end.
