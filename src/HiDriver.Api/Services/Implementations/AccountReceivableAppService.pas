unit AccountReceivableAppService;

interface

uses
  AccountReceivableAppServiceIntf,
  AccountReceivableDomainServiceIntf,
  AccountReceivableDto,
  AccountReceivableRepositoryIntf,
  AccountReceivableValidatorIntf,
  CashMovementRepositoryIntf,
  CashRegisterRepositoryIntf,
  CustomerRepositoryIntf,
  TransactionManagerIntf;

type
  TAccountReceivableAppService = class(
    TInterfacedObject,
    IAccountReceivableAppService)
  private
    FAccountReceivableRepository: IAccountReceivableRepository;
    FAccountReceivableValidator: IAccountReceivableValidator;
    FAccountReceivableDomainService: IAccountReceivableDomainService;
    FCashRegisterRepository: ICashRegisterRepository;
    FCashMovementRepository: ICashMovementRepository;
    FCustomerRepository: ICustomerRepository;
    FTransactionManager: ITransactionManager;
  public
    constructor Create(
      const AAccountReceivableRepository: IAccountReceivableRepository;
      const AAccountReceivableValidator: IAccountReceivableValidator;
      const AAccountReceivableDomainService:
        IAccountReceivableDomainService;
      const ACashRegisterRepository: ICashRegisterRepository;
      const ACashMovementRepository: ICashMovementRepository;
      const ACustomerRepository: ICustomerRepository;
      const ATransactionManager: ITransactionManager);
    function GetAll: string;
    function GetById(AId: Integer): string;
    function GetPayments(AId: Integer): string;
    procedure CreateFromCreditSale(
      ASaleId,
      ACustomerId: Integer;
      AAmount: Currency);
    function Receive(
      ARequest: TReceiveAccountReceivableRequestDto): string;
    procedure ValidateSaleCancellation(ASaleId: Integer);
    procedure CancelBySaleId(ASaleId: Integer);
  end;

implementation

uses
  System.DateUtils,
  System.Generics.Collections,
  System.JSON,
  System.SysUtils,
  AccountReceivable,
  AccountReceivablePayment,
  AccountReceivableStatusEnum,
  CashMovement,
  CashMovementTypeEnum,
  CashRegister,
  Customer,
  PaymentMethodEnum;

function DateTimeToText(AValue: TDateTime): string;
begin
  if AValue > 0 then
    Result := DateToISO8601(AValue, False)
  else
    Result := '';
end;

function AccountDtoToJson(
  AAccount: TAccountReceivableDto): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(AAccount.Id));
  Result.AddPair('saleId', TJSONNumber.Create(AAccount.SaleId));
  Result.AddPair('customerId', TJSONNumber.Create(AAccount.CustomerId));
  Result.AddPair('customerName', AAccount.CustomerName);
  Result.AddPair('issueDate', AAccount.IssueDate);
  Result.AddPair('dueDate', AAccount.DueDate);
  Result.AddPair(
    'totalAmount',
    TJSONNumber.Create(Double(AAccount.TotalAmount)));
  Result.AddPair(
    'receivedAmount',
    TJSONNumber.Create(Double(AAccount.ReceivedAmount)));
  Result.AddPair(
    'balanceAmount',
    TJSONNumber.Create(Double(AAccount.BalanceAmount)));
  Result.AddPair('status', AAccount.Status);
  Result.AddPair('notes', AAccount.Notes);
end;

function PaymentDtoToJson(
  APayment: TAccountReceivablePaymentDto): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(APayment.Id));
  Result.AddPair(
    'accountReceivableId',
    TJSONNumber.Create(APayment.AccountReceivableId));
  Result.AddPair(
    'cashRegisterId',
    TJSONNumber.Create(APayment.CashRegisterId));
  Result.AddPair(
    'cashMovementId',
    TJSONNumber.Create(APayment.CashMovementId));
  Result.AddPair('paymentDate', APayment.PaymentDate);
  Result.AddPair('paymentMethod', APayment.PaymentMethod);
  Result.AddPair(
    'amount',
    TJSONNumber.Create(Double(APayment.Amount)));
  Result.AddPair(
    'discountAmount',
    TJSONNumber.Create(Double(APayment.DiscountAmount)));
  Result.AddPair(
    'interestAmount',
    TJSONNumber.Create(Double(APayment.InterestAmount)));
  Result.AddPair(
    'totalReceived',
    TJSONNumber.Create(Double(APayment.TotalReceived)));
  Result.AddPair('notes', APayment.Notes);
end;

function ReceiveResponseDtoToJson(
  AResponse: TReceiveAccountReceivableResponseDto): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair(
    'accountReceivableId',
    TJSONNumber.Create(AResponse.AccountReceivableId));
  Result.AddPair('status', AResponse.Status);
  Result.AddPair(
    'totalAmount',
    TJSONNumber.Create(Double(AResponse.TotalAmount)));
  Result.AddPair(
    'receivedAmount',
    TJSONNumber.Create(Double(AResponse.ReceivedAmount)));
  Result.AddPair(
    'balanceAmount',
    TJSONNumber.Create(Double(AResponse.BalanceAmount)));
  Result.AddPair('message', AResponse.Message);
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

constructor TAccountReceivableAppService.Create(
  const AAccountReceivableRepository: IAccountReceivableRepository;
  const AAccountReceivableValidator: IAccountReceivableValidator;
  const AAccountReceivableDomainService:
    IAccountReceivableDomainService;
  const ACashRegisterRepository: ICashRegisterRepository;
  const ACashMovementRepository: ICashMovementRepository;
  const ACustomerRepository: ICustomerRepository;
  const ATransactionManager: ITransactionManager);
begin
  inherited Create;
  FAccountReceivableRepository := AAccountReceivableRepository;
  FAccountReceivableValidator := AAccountReceivableValidator;
  FAccountReceivableDomainService :=
    AAccountReceivableDomainService;
  FCashRegisterRepository := ACashRegisterRepository;
  FCashMovementRepository := ACashMovementRepository;
  FCustomerRepository := ACustomerRepository;
  FTransactionManager := ATransactionManager;
end;

function TAccountReceivableAppService.GetAll: string;
var
  Account: TAccountReceivable;
  AccountDto: TAccountReceivableDto;
  Accounts: TObjectList<TAccountReceivable>;
  Customer: TCustomer;
  JsonArray: TJSONArray;
begin
  Accounts := FAccountReceivableRepository.GetAll;
  try
    JsonArray := TJSONArray.Create;
    try
      for Account in Accounts do
      begin
        AccountDto := TAccountReceivableDto.Create;
        try
          AccountDto.Id := Account.Id;
          AccountDto.SaleId := Account.SaleId;
          AccountDto.CustomerId := Account.CustomerId;
          Customer := FCustomerRepository.FindById(Account.CustomerId);
          try
            if Assigned(Customer) then
              AccountDto.CustomerName := Customer.Name;
          finally
            Customer.Free;
          end;
          AccountDto.IssueDate := DateTimeToText(Account.IssueDate);
          AccountDto.DueDate := DateTimeToText(Account.DueDate);
          AccountDto.TotalAmount := Account.TotalAmount;
          AccountDto.ReceivedAmount := Account.ReceivedAmount;
          AccountDto.BalanceAmount := Account.BalanceAmount;
          AccountDto.Status := Account.Status;
          AccountDto.Notes := Account.Notes;
          JsonArray.AddElement(AccountDtoToJson(AccountDto));
        finally
          AccountDto.Free;
        end;
      end;

      Result := BuildSuccessResponse('', JsonArray);
      JsonArray := nil;
    finally
      JsonArray.Free;
    end;
  finally
    Accounts.Free;
  end;
end;

function TAccountReceivableAppService.GetById(AId: Integer): string;
var
  Account: TAccountReceivable;
  AccountDto: TAccountReceivableDto;
  Customer: TCustomer;
begin
  Account := FAccountReceivableRepository.GetById(AId);
  try
    if not Assigned(Account) then
      raise EAccountReceivableNotFoundException.Create(
        'Account receivable not found.');

    AccountDto := TAccountReceivableDto.Create;
    try
      AccountDto.Id := Account.Id;
      AccountDto.SaleId := Account.SaleId;
      AccountDto.CustomerId := Account.CustomerId;
      Customer := FCustomerRepository.FindById(Account.CustomerId);
      try
        if Assigned(Customer) then
          AccountDto.CustomerName := Customer.Name;
      finally
        Customer.Free;
      end;
      AccountDto.IssueDate := DateTimeToText(Account.IssueDate);
      AccountDto.DueDate := DateTimeToText(Account.DueDate);
      AccountDto.TotalAmount := Account.TotalAmount;
      AccountDto.ReceivedAmount := Account.ReceivedAmount;
      AccountDto.BalanceAmount := Account.BalanceAmount;
      AccountDto.Status := Account.Status;
      AccountDto.Notes := Account.Notes;

      Result := BuildSuccessResponse('', AccountDtoToJson(AccountDto));
    finally
      AccountDto.Free;
    end;
  finally
    Account.Free;
  end;
end;

function TAccountReceivableAppService.GetPayments(
  AId: Integer): string;
var
  Account: TAccountReceivable;
  JsonArray: TJSONArray;
  Payment: TAccountReceivablePayment;
  PaymentDto: TAccountReceivablePaymentDto;
  Payments: TObjectList<TAccountReceivablePayment>;
begin
  Account := FAccountReceivableRepository.GetById(AId);
  try
    if not Assigned(Account) then
      raise EAccountReceivableNotFoundException.Create(
        'Account receivable not found.');
  finally
    Account.Free;
  end;

  Payments :=
    FAccountReceivableRepository.GetPaymentsByAccountReceivableId(AId);
  try
    JsonArray := TJSONArray.Create;
    try
      for Payment in Payments do
      begin
        PaymentDto := TAccountReceivablePaymentDto.Create;
        try
          PaymentDto.Id := Payment.Id;
          PaymentDto.AccountReceivableId :=
            Payment.AccountReceivableId;
          PaymentDto.CashRegisterId := Payment.CashRegisterId;
          PaymentDto.CashMovementId := Payment.CashMovementId;
          PaymentDto.PaymentDate :=
            DateTimeToText(Payment.PaymentDate);
          PaymentDto.PaymentMethod := Payment.PaymentMethod;
          PaymentDto.Amount := Payment.Amount;
          PaymentDto.DiscountAmount := Payment.DiscountAmount;
          PaymentDto.InterestAmount := Payment.InterestAmount;
          PaymentDto.TotalReceived := Payment.TotalReceived;
          PaymentDto.Notes := Payment.Notes;
          JsonArray.AddElement(PaymentDtoToJson(PaymentDto));
        finally
          PaymentDto.Free;
        end;
      end;

      Result := BuildSuccessResponse('', JsonArray);
      JsonArray := nil;
    finally
      JsonArray.Free;
    end;
  finally
    Payments.Free;
  end;
end;

procedure TAccountReceivableAppService.CreateFromCreditSale(
  ASaleId,
  ACustomerId: Integer;
  AAmount: Currency);
var
  Account: TAccountReceivable;
  ExistingAccount: TAccountReceivable;
begin
  if AAmount <= 0 then
    Exit;

  ExistingAccount :=
    FAccountReceivableRepository.GetBySaleId(ASaleId);
  try
    if Assigned(ExistingAccount) then
      raise EAccountReceivableStateException.Create(
        'Sale already has an account receivable.');
  finally
    ExistingAccount.Free;
  end;

  Account := TAccountReceivable.Create;
  try
    Account.SaleId := ASaleId;
    Account.CustomerId := ACustomerId;
    Account.IssueDate := Now;
    Account.TotalAmount := AAmount;
    Account.ReceivedAmount := 0;
    Account.BalanceAmount := AAmount;
    Account.Status :=
      AccountReceivableStatusToString(arsOpen);
    Account.Notes := '';
    Account.IsActive := True;
    Account.CreatedAt := Account.IssueDate;
    Account.Id := FAccountReceivableRepository.Insert(Account);
  finally
    Account.Free;
  end;
end;

function TAccountReceivableAppService.Receive(
  ARequest: TReceiveAccountReceivableRequestDto): string;
var
  Account: TAccountReceivable;
  CashMovement: TCashMovement;
  CashRegister: TCashRegister;
  ErrorMessage: string;
  Payment: TAccountReceivablePayment;
  PaymentMethod: TPaymentMethodEnum;
  ResponseDto: TReceiveAccountReceivableResponseDto;
begin
  Account := nil;
  CashRegister := nil;
  Payment := nil;
  try
    FTransactionManager.StartTransaction;
    try
      if Assigned(ARequest) then
        Account := FAccountReceivableRepository.GetById(
          ARequest.AccountReceivableId);

      if not Assigned(Account) then
        raise EAccountReceivableNotFoundException.Create(
          'Account receivable not found.');

      if not FAccountReceivableValidator.ValidateReceive(
        ARequest,
        Account,
        ErrorMessage) then
        raise EAccountReceivableValidationException.Create(
          ErrorMessage);

      CashRegister := FCashRegisterRepository.FindOpen;
      if not Assigned(CashRegister) then
        raise EAccountReceivableStateException.Create(
          'There is no open cash register.');

      TryStringToPaymentMethod(
        ARequest.PaymentMethod,
        PaymentMethod);

      FAccountReceivableDomainService.ApplyReceipt(
        Account,
        ARequest.Amount,
        ARequest.DiscountAmount,
        ARequest.InterestAmount);

      CashMovement := TCashMovement.Create;
      try
        CashMovement.CashRegisterId := CashRegister.Id;
        CashMovement.MovementType :=
          CashMovementTypeToString(cmtAccountReceivable);
        CashMovement.Description := Format(
          'Accounts receivable payment - Sale #%d',
          [Account.SaleId]);
        CashMovement.Amount := ARequest.Amount;
        CashMovement.PaymentMethod :=
          PaymentMethodToString(PaymentMethod);
        CashMovement.ReferenceType := 'AccountReceivable';
        CashMovement.ReferenceId := Account.Id;
        CashMovement.CreatedAt := Now;
        FCashMovementRepository.Insert(CashMovement);

        Payment := TAccountReceivablePayment.Create;
        Payment.AccountReceivableId := Account.Id;
        Payment.CashRegisterId := CashRegister.Id;
        Payment.CashMovementId := CashMovement.Id;
        Payment.PaymentDate := Now;
        Payment.PaymentMethod :=
          PaymentMethodToString(PaymentMethod);
        Payment.Amount := ARequest.Amount;
        Payment.DiscountAmount := ARequest.DiscountAmount;
        Payment.InterestAmount := ARequest.InterestAmount;
        Payment.TotalReceived :=
          ARequest.Amount +
          ARequest.DiscountAmount -
          ARequest.InterestAmount;
        Payment.Notes := Trim(ARequest.Notes);
        Payment.CreatedAt := Payment.PaymentDate;
        FAccountReceivableRepository.InsertPayment(Payment);
      finally
        CashMovement.Free;
      end;

      FAccountReceivableRepository.Update(Account);
      FTransactionManager.Commit;
    except
      FTransactionManager.Rollback;
      raise;
    end;

    ResponseDto := TReceiveAccountReceivableResponseDto.Create;
    try
      ResponseDto.AccountReceivableId := Account.Id;
      ResponseDto.Status := Account.Status;
      ResponseDto.TotalAmount := Account.TotalAmount;
      ResponseDto.ReceivedAmount := Account.ReceivedAmount;
      ResponseDto.BalanceAmount := Account.BalanceAmount;
      ResponseDto.Message := 'Account receivable received successfully.';
      Result := BuildSuccessResponse(
        ResponseDto.Message,
        ReceiveResponseDtoToJson(ResponseDto));
    finally
      ResponseDto.Free;
    end;
  finally
    Payment.Free;
    CashRegister.Free;
    Account.Free;
  end;
end;

procedure TAccountReceivableAppService.ValidateSaleCancellation(
  ASaleId: Integer);
var
  Account: TAccountReceivable;
  ErrorMessage: string;
begin
  Account := FAccountReceivableRepository.GetBySaleId(ASaleId);
  try
    if not FAccountReceivableDomainService.CanCancelFromSale(
      Account,
      ErrorMessage) then
      raise EAccountReceivableStateException.Create(ErrorMessage);
  finally
    Account.Free;
  end;
end;

procedure TAccountReceivableAppService.CancelBySaleId(
  ASaleId: Integer);
var
  Account: TAccountReceivable;
  ErrorMessage: string;
begin
  Account := FAccountReceivableRepository.GetBySaleId(ASaleId);
  try
    if not Assigned(Account) then
      Exit;

    if not FAccountReceivableDomainService.CanCancelFromSale(
      Account,
      ErrorMessage) then
      raise EAccountReceivableStateException.Create(ErrorMessage);

    Account.Cancel;
    FAccountReceivableRepository.Update(Account);
  finally
    Account.Free;
  end;
end;

end.
