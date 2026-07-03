unit StockMovementAppService;

interface

uses
  ProductRepositoryIntf,
  StockMovement,
  StockMovementAppServiceIntf,
  StockMovementDto,
  StockMovementDomainServiceIntf,
  StockMovementRepositoryIntf,
  StockMovementValidatorIntf,
  TransactionManagerIntf;

type
  TStockMovementAppService = class(
    TInterfacedObject,
    IStockMovementAppService)
  private
    FStockMovementRepository: IStockMovementRepository;
    FStockMovementValidator: IStockMovementValidator;
    FStockMovementDomainService: IStockMovementDomainService;
    FProductRepository: IProductRepository;
    FTransactionManager: ITransactionManager;
    function ToDto(
      AStockMovement: TStockMovement): TStockMovementDto;
  public
    constructor Create(
      const AStockMovementRepository: IStockMovementRepository;
      const AStockMovementValidator: IStockMovementValidator;
      const AStockMovementDomainService: IStockMovementDomainService;
      const AProductRepository: IProductRepository;
      const ATransactionManager: ITransactionManager);
    function GetAll: string;
    function GetById(AId: Integer): string;
    function GetByProductId(AProductId: Integer): string;
    procedure RegisterSaleOut(
      AProductId: Integer;
      AQuantity: Double;
      ASaleId,
      AUserId: Integer);
    procedure RegisterSaleCancellationReversal(
      AProductId: Integer;
      AQuantity: Double;
      ASaleId,
      AUserId: Integer);
    function RegisterManualAdjustment(
      ARequest: TCreateStockAdjustmentRequestDto): string;
  end;

implementation

uses
  System.DateUtils,
  System.Generics.Collections,
  System.JSON,
  System.SysUtils,
  Product,
  StockMovementSourceTypeEnum,
  StockMovementTypeEnum;

function StockMovementDtoToJson(
  AStockMovement: TStockMovementDto): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(AStockMovement.Id));
  Result.AddPair(
    'productId',
    TJSONNumber.Create(AStockMovement.ProductId));
  Result.AddPair(
    'productDescription',
    AStockMovement.ProductDescription);
  Result.AddPair('movementDate', AStockMovement.MovementDate);
  Result.AddPair('movementType', AStockMovement.MovementType);
  Result.AddPair('sourceType', AStockMovement.SourceType);
  if AStockMovement.SourceId > 0 then
    Result.AddPair(
      'sourceId',
      TJSONNumber.Create(AStockMovement.SourceId))
  else
    Result.AddPair('sourceId', TJSONNull.Create);
  Result.AddPair(
    'quantity',
    TJSONNumber.Create(AStockMovement.Quantity));
  Result.AddPair(
    'previousStock',
    TJSONNumber.Create(AStockMovement.PreviousStock));
  Result.AddPair(
    'newStock',
    TJSONNumber.Create(AStockMovement.NewStock));
  Result.AddPair(
    'unitCost',
    TJSONNumber.Create(Double(AStockMovement.UnitCost)));
  Result.AddPair('notes', AStockMovement.Notes);
  if AStockMovement.UserId > 0 then
    Result.AddPair(
      'userId',
      TJSONNumber.Create(AStockMovement.UserId))
  else
    Result.AddPair('userId', TJSONNull.Create);
end;

function StockAdjustmentResponseDtoToJson(
  AResponse: TStockAdjustmentResponseDto): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair(
    'productId',
    TJSONNumber.Create(AResponse.ProductId));
  Result.AddPair(
    'previousStock',
    TJSONNumber.Create(AResponse.PreviousStock));
  Result.AddPair(
    'newStock',
    TJSONNumber.Create(AResponse.NewStock));
  Result.AddPair('movementType', AResponse.MovementType);
  Result.AddPair(
    'quantity',
    TJSONNumber.Create(AResponse.Quantity));
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

constructor TStockMovementAppService.Create(
  const AStockMovementRepository: IStockMovementRepository;
  const AStockMovementValidator: IStockMovementValidator;
  const AStockMovementDomainService: IStockMovementDomainService;
  const AProductRepository: IProductRepository;
  const ATransactionManager: ITransactionManager);
begin
  inherited Create;
  FStockMovementRepository := AStockMovementRepository;
  FStockMovementValidator := AStockMovementValidator;
  FStockMovementDomainService := AStockMovementDomainService;
  FProductRepository := AProductRepository;
  FTransactionManager := ATransactionManager;
end;

function TStockMovementAppService.ToDto(
  AStockMovement: TStockMovement): TStockMovementDto;
var
  Product: TProduct;
begin
  Result := TStockMovementDto.Create;
  try
    Result.Id := AStockMovement.Id;
    Result.ProductId := AStockMovement.ProductId;
    Product := FProductRepository.FindById(AStockMovement.ProductId);
    try
      if Assigned(Product) then
        Result.ProductDescription := Product.Description;
    finally
      Product.Free;
    end;
    Result.MovementDate :=
      DateToISO8601(AStockMovement.MovementDate, False);
    Result.MovementType := AStockMovement.MovementType;
    Result.SourceType := AStockMovement.SourceType;
    Result.SourceId := AStockMovement.SourceId;
    Result.Quantity := AStockMovement.Quantity;
    Result.PreviousStock := AStockMovement.PreviousStock;
    Result.NewStock := AStockMovement.NewStock;
    Result.UnitCost := AStockMovement.UnitCost;
    Result.Notes := AStockMovement.Notes;
    Result.UserId := AStockMovement.UserId;
  except
    Result.Free;
    raise;
  end;
end;

function TStockMovementAppService.GetAll: string;
var
  Dto: TStockMovementDto;
  JsonArray: TJSONArray;
  Movement: TStockMovement;
  Movements: TObjectList<TStockMovement>;
begin
  Movements := FStockMovementRepository.GetAll;
  try
    JsonArray := TJSONArray.Create;
    try
      for Movement in Movements do
      begin
        Dto := ToDto(Movement);
        try
          JsonArray.AddElement(StockMovementDtoToJson(Dto));
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
    Movements.Free;
  end;
end;

function TStockMovementAppService.GetById(AId: Integer): string;
var
  Dto: TStockMovementDto;
  Movement: TStockMovement;
begin
  Movement := FStockMovementRepository.GetById(AId);
  try
    if not Assigned(Movement) then
      raise EStockMovementNotFoundException.Create(
        'Stock movement not found.');

    Dto := ToDto(Movement);
    try
      Result := BuildSuccessResponse(
        '',
        StockMovementDtoToJson(Dto));
    finally
      Dto.Free;
    end;
  finally
    Movement.Free;
  end;
end;

function TStockMovementAppService.GetByProductId(
  AProductId: Integer): string;
var
  Dto: TStockMovementDto;
  JsonArray: TJSONArray;
  Movement: TStockMovement;
  Movements: TObjectList<TStockMovement>;
begin
  Movements := FStockMovementRepository.GetByProductId(AProductId);
  try
    JsonArray := TJSONArray.Create;
    try
      for Movement in Movements do
      begin
        Dto := ToDto(Movement);
        try
          JsonArray.AddElement(StockMovementDtoToJson(Dto));
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
    Movements.Free;
  end;
end;

procedure TStockMovementAppService.RegisterSaleOut(
  AProductId: Integer;
  AQuantity: Double;
  ASaleId,
  AUserId: Integer);
var
  Movement: TStockMovement;
  Product: TProduct;
begin
  if not FTransactionManager.InTransaction then
    raise EStockMovementStateException.Create(
      'Sale stock output requires an active transaction.');

  Product := FProductRepository.FindById(AProductId);
  try
    if not Assigned(Product) then
      raise EStockMovementStateException.Create(
        'Product not found or inactive.');

    try
      Movement := FStockMovementDomainService.CreateMovement(
        Product,
        smtOut,
        smstSale,
        AQuantity,
        ASaleId,
        AUserId,
        Format('Sale stock output - Sale #%d', [ASaleId]));
    except
      on E: EArgumentException do
        raise EStockMovementValidationException.Create(E.Message);
      on E: EInvalidOpException do
        raise EStockMovementStateException.Create(E.Message);
    end;
    try
      FProductRepository.DecreaseStock(AProductId, AQuantity);
      FStockMovementRepository.Insert(Movement);
    finally
      Movement.Free;
    end;
  finally
    Product.Free;
  end;
end;

procedure TStockMovementAppService.RegisterSaleCancellationReversal(
  AProductId: Integer;
  AQuantity: Double;
  ASaleId,
  AUserId: Integer);
var
  Movement: TStockMovement;
  Product: TProduct;
begin
  if not FTransactionManager.InTransaction then
    raise EStockMovementStateException.Create(
      'Sale cancellation reversal requires an active transaction.');

  Product := FProductRepository.FindById(AProductId);
  try
    if not Assigned(Product) then
      raise EStockMovementStateException.Create(
        'Product not found or inactive.');

    try
      Movement := FStockMovementDomainService.CreateMovement(
        Product,
        smtReversal,
        smstSaleCancellation,
        AQuantity,
        ASaleId,
        AUserId,
        Format(
          'Sale cancellation stock reversal - Sale #%d',
          [ASaleId]));
    except
      on E: EArgumentException do
        raise EStockMovementValidationException.Create(E.Message);
      on E: EInvalidOpException do
        raise EStockMovementStateException.Create(E.Message);
    end;
    try
      FProductRepository.IncreaseStock(AProductId, AQuantity);
      FStockMovementRepository.Insert(Movement);
    finally
      Movement.Free;
    end;
  finally
    Product.Free;
  end;
end;

function TStockMovementAppService.RegisterManualAdjustment(
  ARequest: TCreateStockAdjustmentRequestDto): string;
var
  ErrorMessage: string;
  Movement: TStockMovement;
  MovementType: TStockMovementTypeEnum;
  Product: TProduct;
  ResponseDto: TStockAdjustmentResponseDto;
begin
  Movement := nil;
  Product := nil;
  ResponseDto := nil;
  try
    FTransactionManager.StartTransaction;
    try
      if Assigned(ARequest) then
        Product := FProductRepository.FindById(ARequest.ProductId);

      if not FStockMovementValidator.ValidateManualAdjustment(
        ARequest,
        Product,
        ErrorMessage) then
        raise EStockMovementValidationException.Create(ErrorMessage);

      TryStringToStockMovementType(
        ARequest.MovementType,
        MovementType);
      Movement := FStockMovementDomainService.CreateMovement(
        Product,
        MovementType,
        smstManualAdjustment,
        ARequest.Quantity,
        0,
        ARequest.UserId,
        ARequest.Notes);

      case MovementType of
        smtIn:
          FProductRepository.IncreaseStock(
            Product.Id,
            ARequest.Quantity);
        smtOut:
          FProductRepository.DecreaseStock(
            Product.Id,
            ARequest.Quantity);
        smtAdjustment:
          if ARequest.Quantity > 0 then
            FProductRepository.IncreaseStock(
              Product.Id,
              ARequest.Quantity)
          else
            FProductRepository.DecreaseStock(
              Product.Id,
              -ARequest.Quantity);
      end;

      FStockMovementRepository.Insert(Movement);
      FTransactionManager.Commit;
    except
      FTransactionManager.Rollback;
      raise;
    end;

    ResponseDto := TStockAdjustmentResponseDto.Create;
    ResponseDto.ProductId := Movement.ProductId;
    ResponseDto.PreviousStock := Movement.PreviousStock;
    ResponseDto.NewStock := Movement.NewStock;
    ResponseDto.MovementType := Movement.MovementType;
    ResponseDto.Quantity := Movement.Quantity;
    ResponseDto.Message := 'Stock adjustment registered successfully.';
    Result := BuildSuccessResponse(
      'Stock adjustment registered successfully.',
      StockAdjustmentResponseDtoToJson(ResponseDto));
  finally
    ResponseDto.Free;
    Movement.Free;
    Product.Free;
  end;
end;

end.
