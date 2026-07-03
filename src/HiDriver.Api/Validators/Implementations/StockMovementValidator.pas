unit StockMovementValidator;

interface

uses
  Product,
  StockMovementDto,
  StockMovementValidatorIntf;

type
  TStockMovementValidator = class(
    TInterfacedObject,
    IStockMovementValidator)
  public
    function ValidateManualAdjustment(
      ARequest: TCreateStockAdjustmentRequestDto;
      AProduct: TProduct;
      out AErrorMessage: string): Boolean;
  end;

implementation

uses
  System.Math,
  StockMovementTypeEnum;

function TStockMovementValidator.ValidateManualAdjustment(
  ARequest: TCreateStockAdjustmentRequestDto;
  AProduct: TProduct;
  out AErrorMessage: string): Boolean;
var
  MovementType: TStockMovementTypeEnum;
begin
  AErrorMessage := '';

  if not Assigned(ARequest) then
    AErrorMessage := 'Stock adjustment data is required.'
  else if ARequest.ProductId <= 0 then
    AErrorMessage := 'Product id must be greater than zero.'
  else if ARequest.UserId <= 0 then
    AErrorMessage := 'User id must be greater than zero.'
  else if IsZero(ARequest.Quantity) then
    AErrorMessage := 'Quantity cannot be zero.'
  else if ARequest.MovementType = '' then
    AErrorMessage := 'Movement type is required.'
  else if not TryStringToStockMovementType(
    ARequest.MovementType,
    MovementType) then
    AErrorMessage := 'Movement type is invalid.'
  else if MovementType = smtReversal then
    AErrorMessage :=
      'Reversal is not allowed for a manual stock adjustment.'
  else if (MovementType in [smtIn, smtOut]) and
    (ARequest.Quantity <= 0) then
    AErrorMessage :=
      'Quantity must be greater than zero for stock input or output.'
  else if not Assigned(AProduct) then
    AErrorMessage := 'Product not found or inactive.'
  else if not AProduct.IsActive then
    AErrorMessage := 'Product is inactive.'
  else if (MovementType = smtOut) and
    (ARequest.Quantity > AProduct.CurrentStock) then
    AErrorMessage := 'Insufficient stock for manual output.'
  else if (MovementType = smtAdjustment) and
    (AProduct.CurrentStock + ARequest.Quantity < 0) then
    AErrorMessage := 'Stock adjustment cannot result in negative stock.';

  Result := AErrorMessage = '';
end;

end.
