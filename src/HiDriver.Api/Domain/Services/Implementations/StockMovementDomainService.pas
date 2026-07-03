unit StockMovementDomainService;

interface

uses
  Product,
  StockMovement,
  StockMovementDomainServiceIntf,
  StockMovementSourceTypeEnum,
  StockMovementTypeEnum;

type
  TStockMovementDomainService = class(
    TInterfacedObject,
    IStockMovementDomainService)
  public
    function CalculateNewStock(
      APreviousStock,
      AQuantity: Double;
      AMovementType: TStockMovementTypeEnum): Double;
    function ValidateNewStock(
      ANewStock: Double;
      out AErrorMessage: string): Boolean;
    function CreateMovement(
      AProduct: TProduct;
      AMovementType: TStockMovementTypeEnum;
      ASourceType: TStockMovementSourceTypeEnum;
      AQuantity: Double;
      ASourceId,
      AUserId: Integer;
      const ANotes: string): TStockMovement;
  end;

implementation

uses
  System.Math,
  System.SysUtils;

function TStockMovementDomainService.CalculateNewStock(
  APreviousStock,
  AQuantity: Double;
  AMovementType: TStockMovementTypeEnum): Double;
begin
  if (AMovementType = smtAdjustment) and IsZero(AQuantity) then
    raise EArgumentOutOfRangeException.Create(
      'Adjustment quantity cannot be zero.');

  if (AMovementType <> smtAdjustment) and (AQuantity <= 0) then
    raise EArgumentOutOfRangeException.Create(
      'Movement quantity must be greater than zero.');

  case AMovementType of
    smtIn,
    smtReversal:
      Result := APreviousStock + AQuantity;
    smtOut:
      Result := APreviousStock - AQuantity;
    smtAdjustment:
      Result := APreviousStock + AQuantity;
  else
    Result := APreviousStock;
  end;

  if SameValue(Result, 0, 0.000000001) then
    Result := 0;
end;

function TStockMovementDomainService.ValidateNewStock(
  ANewStock: Double;
  out AErrorMessage: string): Boolean;
begin
  AErrorMessage := '';
  if ANewStock < 0 then
    AErrorMessage := 'Stock movement cannot result in negative stock.';
  Result := AErrorMessage = '';
end;

function TStockMovementDomainService.CreateMovement(
  AProduct: TProduct;
  AMovementType: TStockMovementTypeEnum;
  ASourceType: TStockMovementSourceTypeEnum;
  AQuantity: Double;
  ASourceId,
  AUserId: Integer;
  const ANotes: string): TStockMovement;
var
  ErrorMessage: string;
  NewStock: Double;
begin
  if not Assigned(AProduct) then
    raise EArgumentNilException.Create('Product is required.');
  if not AProduct.IsActive then
    raise EInvalidOpException.Create('Product is inactive.');

  NewStock := CalculateNewStock(
    AProduct.CurrentStock,
    AQuantity,
    AMovementType);
  if not ValidateNewStock(NewStock, ErrorMessage) then
    raise EInvalidOpException.Create(ErrorMessage);

  Result := TStockMovement.Create;
  try
    Result.ProductId := AProduct.Id;
    Result.MovementDate := Now;
    Result.MovementType :=
      StockMovementTypeToString(AMovementType);
    Result.SourceType :=
      StockMovementSourceTypeToString(ASourceType);
    Result.SourceId := ASourceId;
    Result.Quantity := AQuantity;
    Result.PreviousStock := AProduct.CurrentStock;
    Result.NewStock := NewStock;
    Result.UnitCost := AProduct.CostPrice;
    Result.Notes := Trim(ANotes);
    Result.UserId := AUserId;
    Result.IsActive := True;
    Result.CreatedAt := Result.MovementDate;
  except
    Result.Free;
    raise;
  end;
end;

end.
