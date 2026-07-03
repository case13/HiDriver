unit StockMovementDomainServiceIntf;

interface

uses
  Product,
  StockMovement,
  StockMovementSourceTypeEnum,
  StockMovementTypeEnum;

type
  IStockMovementDomainService = interface
    function CalculateNewStock(
      APreviousStock,
      AQuantity: Double;
      AMovementType: TStockMovementTypeEnum): Double;
    function ValidateNewStock(
      ANewStock: Double;
      out AErrorMessage: string): Boolean;
    // The caller owns the returned stock movement.
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

end.
