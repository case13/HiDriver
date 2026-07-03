unit CashRegisterAppService;

interface

uses
  CashMovementRepositoryIntf,
  CashRegisterAppServiceIntf,
  CashRegisterDomainServiceIntf,
  CashRegisterDtos,
  CashRegisterRepositoryIntf,
  CashRegisterValidatorIntf,
  TransactionManagerIntf;

type
  TCashRegisterAppService = class(
    TInterfacedObject,
    ICashRegisterAppService)
  private
    FCashRegisterRepository: ICashRegisterRepository;
    FCashMovementRepository: ICashMovementRepository;
    FCashRegisterValidator: ICashRegisterValidator;
    FCashRegisterDomainService: ICashRegisterDomainService;
    FTransactionManager: ITransactionManager;
  public
    constructor Create(
      const ACashRegisterRepository: ICashRegisterRepository;
      const ACashMovementRepository: ICashMovementRepository;
      const ACashRegisterValidator: ICashRegisterValidator;
      const ACashRegisterDomainService: ICashRegisterDomainService;
      const ATransactionManager: ITransactionManager);
    function Open(ARequest: TCashOpenRequestDto): string;
    function Close(ARequest: TCashCloseRequestDto): string;
    function GetCurrent: string;
    function GetMovements: string;
  end;

implementation

uses
  System.DateUtils,
  System.Generics.Collections,
  System.JSON,
  CashMovement,
  CashMovementTypeEnum,
  CashRegister;

function DateTimeToText(AValue: TDateTime): string;
begin
  if AValue > 0 then
    Result := DateToISO8601(AValue, False)
  else
    Result := '';
end;

function CashRegisterToReadDto(
  ACashRegister: TCashRegister): TCashRegisterReadDto;
begin
  Result := TCashRegisterReadDto.Create;
  Result.Id := ACashRegister.Id;
  Result.UserId := ACashRegister.UserId;
  Result.Status := ACashRegister.Status;
  Result.OpeningAmount := ACashRegister.OpeningAmount;
  Result.ClosingAmount := ACashRegister.ClosingAmount;
  Result.ExpectedAmount := ACashRegister.ExpectedAmount;
  Result.DifferenceAmount := ACashRegister.DifferenceAmount;
  Result.OpenedAt := DateTimeToText(ACashRegister.OpenedAt);
  Result.ClosedAt := DateTimeToText(ACashRegister.ClosedAt);
end;

function CashMovementToReadDto(
  ACashMovement: TCashMovement): TCashMovementReadDto;
begin
  Result := TCashMovementReadDto.Create;
  Result.Id := ACashMovement.Id;
  Result.CashRegisterId := ACashMovement.CashRegisterId;
  Result.MovementType := ACashMovement.MovementType;
  Result.Description := ACashMovement.Description;
  Result.Amount := ACashMovement.Amount;
  Result.PaymentMethod := ACashMovement.PaymentMethod;
  Result.ReferenceType := ACashMovement.ReferenceType;
  Result.ReferenceId := ACashMovement.ReferenceId;
  Result.CreatedAt := DateTimeToText(ACashMovement.CreatedAt);
end;

function CashRegisterDtoToJson(
  ACashRegister: TCashRegisterReadDto): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(ACashRegister.Id));
  Result.AddPair('userId', TJSONNumber.Create(ACashRegister.UserId));
  Result.AddPair('status', ACashRegister.Status);
  Result.AddPair(
    'openingAmount',
    TJSONNumber.Create(Double(ACashRegister.OpeningAmount)));
  Result.AddPair(
    'closingAmount',
    TJSONNumber.Create(Double(ACashRegister.ClosingAmount)));
  Result.AddPair(
    'expectedAmount',
    TJSONNumber.Create(Double(ACashRegister.ExpectedAmount)));
  Result.AddPair(
    'differenceAmount',
    TJSONNumber.Create(Double(ACashRegister.DifferenceAmount)));
  Result.AddPair('openedAt', ACashRegister.OpenedAt);
  Result.AddPair('closedAt', ACashRegister.ClosedAt);
end;

function CashMovementDtoToJson(
  ACashMovement: TCashMovementReadDto): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(ACashMovement.Id));
  Result.AddPair(
    'cashRegisterId',
    TJSONNumber.Create(ACashMovement.CashRegisterId));
  Result.AddPair('movementType', ACashMovement.MovementType);
  Result.AddPair('description', ACashMovement.Description);
  Result.AddPair(
    'amount',
    TJSONNumber.Create(Double(ACashMovement.Amount)));
  Result.AddPair('paymentMethod', ACashMovement.PaymentMethod);
  Result.AddPair('referenceType', ACashMovement.ReferenceType);
  Result.AddPair(
    'referenceId',
    TJSONNumber.Create(ACashMovement.ReferenceId));
  Result.AddPair('createdAt', ACashMovement.CreatedAt);
end;

function CashRegisterToJson(
  ACashRegister: TCashRegister): TJSONObject;
var
  CashRegisterDto: TCashRegisterReadDto;
begin
  CashRegisterDto := CashRegisterToReadDto(ACashRegister);
  try
    Result := CashRegisterDtoToJson(CashRegisterDto);
  finally
    CashRegisterDto.Free;
  end;
end;

function CashMovementToJson(
  ACashMovement: TCashMovement): TJSONObject;
var
  CashMovementDto: TCashMovementReadDto;
begin
  CashMovementDto := CashMovementToReadDto(ACashMovement);
  try
    Result := CashMovementDtoToJson(CashMovementDto);
  finally
    CashMovementDto.Free;
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

constructor TCashRegisterAppService.Create(
  const ACashRegisterRepository: ICashRegisterRepository;
  const ACashMovementRepository: ICashMovementRepository;
  const ACashRegisterValidator: ICashRegisterValidator;
  const ACashRegisterDomainService: ICashRegisterDomainService;
  const ATransactionManager: ITransactionManager);
begin
  inherited Create;
  FCashRegisterRepository := ACashRegisterRepository;
  FCashMovementRepository := ACashMovementRepository;
  FCashRegisterValidator := ACashRegisterValidator;
  FCashRegisterDomainService := ACashRegisterDomainService;
  FTransactionManager := ATransactionManager;
end;

function TCashRegisterAppService.Open(
  ARequest: TCashOpenRequestDto): string;
var
  CashMovement: TCashMovement;
  CashRegister: TCashRegister;
  ErrorMessage: string;
begin
  if not FCashRegisterValidator.ValidateOpen(
    ARequest,
    ErrorMessage) then
    raise ECashRegisterValidationException.Create(ErrorMessage);

  CashRegister := TCashRegister.Create;
  try
    FTransactionManager.StartTransaction;
    try
      if not FCashRegisterDomainService.CanOpenCashRegister(
        FCashRegisterRepository.HasOpenCashRegister,
        ErrorMessage) then
        raise ECashRegisterStateException.Create(ErrorMessage);

      CashRegister.UserId := ARequest.UserId;
      CashRegister.OpeningAmount := ARequest.OpeningAmount;
      CashRegister.Open;
      CashRegister.Id := FCashRegisterRepository.Insert(CashRegister);

      CashMovement := TCashMovement.Create;
      try
        CashMovement.CashRegisterId := CashRegister.Id;
        CashMovement.MovementType :=
          CashMovementTypeToString(cmtOpening);
        CashMovement.Description := 'Cash register opening.';
        CashMovement.Amount := CashRegister.OpeningAmount;
        CashMovement.CreatedAt := CashRegister.OpenedAt;
        FCashMovementRepository.Insert(CashMovement);
      finally
        CashMovement.Free;
      end;

      FTransactionManager.Commit;
    except
      FTransactionManager.Rollback;
      raise;
    end;

    Result := BuildSuccessResponse(
      'Cash register opened successfully.',
      CashRegisterToJson(CashRegister));
  finally
    CashRegister.Free;
  end;
end;

function TCashRegisterAppService.Close(
  ARequest: TCashCloseRequestDto): string;
var
  AdditionalMovementsTotal: Currency;
  CashRegister: TCashRegister;
  DifferenceAmount: Currency;
  ErrorMessage: string;
  ExpectedAmount: Currency;
  MovementsTotal: Currency;
begin
  if not FCashRegisterValidator.ValidateClose(
    ARequest,
    ErrorMessage) then
    raise ECashRegisterValidationException.Create(ErrorMessage);

  CashRegister := nil;
  try
    FTransactionManager.StartTransaction;
    try
      CashRegister := FCashRegisterRepository.FindOpen;
      if not FCashRegisterDomainService.CanCloseCashRegister(
        CashRegister,
        ErrorMessage) then
      begin
        if not Assigned(CashRegister) then
          raise ECashRegisterNotFoundException.Create(ErrorMessage);
        raise ECashRegisterStateException.Create(ErrorMessage);
      end;

      MovementsTotal := FCashMovementRepository.SumByCashRegisterId(
        CashRegister.Id);
      AdditionalMovementsTotal :=
        MovementsTotal - CashRegister.OpeningAmount;
      ExpectedAmount :=
        FCashRegisterDomainService.CalculateExpectedAmount(
          CashRegister.OpeningAmount,
          AdditionalMovementsTotal);
      DifferenceAmount :=
        FCashRegisterDomainService.CalculateDifference(
          ARequest.ClosingAmount,
          ExpectedAmount);

      CashRegister.Close(ARequest.ClosingAmount, ExpectedAmount);
      CashRegister.DifferenceAmount := DifferenceAmount;
      FCashRegisterRepository.Close(CashRegister);

      FTransactionManager.Commit;
    except
      FTransactionManager.Rollback;
      raise;
    end;

    Result := BuildSuccessResponse(
      'Cash register closed successfully.',
      CashRegisterToJson(CashRegister));
  finally
    CashRegister.Free;
  end;
end;

function TCashRegisterAppService.GetCurrent: string;
var
  CashRegister: TCashRegister;
begin
  CashRegister := FCashRegisterRepository.FindOpen;
  try
    if not Assigned(CashRegister) then
      raise ECashRegisterNotFoundException.Create(
        'There is no open cash register.');

    Result := BuildSuccessResponse('', CashRegisterToJson(CashRegister));
  finally
    CashRegister.Free;
  end;
end;

function TCashRegisterAppService.GetMovements: string;
var
  CashMovement: TCashMovement;
  CashMovements: TObjectList<TCashMovement>;
  CashRegister: TCashRegister;
  JsonArray: TJSONArray;
begin
  CashRegister := FCashRegisterRepository.FindOpen;
  try
    if not Assigned(CashRegister) then
      raise ECashRegisterNotFoundException.Create(
        'There is no open cash register.');

    CashMovements :=
      FCashMovementRepository.FindByCashRegisterId(CashRegister.Id);
    try
      JsonArray := TJSONArray.Create;
      try
        for CashMovement in CashMovements do
          JsonArray.AddElement(CashMovementToJson(CashMovement));
        Result := BuildSuccessResponse('', JsonArray);
        JsonArray := nil;
      finally
        JsonArray.Free;
      end;
    finally
      CashMovements.Free;
    end;
  finally
    CashRegister.Free;
  end;
end;

end.
