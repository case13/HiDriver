unit StockMovementValidatorIntf;

interface

uses
  Product,
  StockMovementDto;

type
  IStockMovementValidator = interface
    function ValidateManualAdjustment(
      ARequest: TCreateStockAdjustmentRequestDto;
      AProduct: TProduct;
      out AErrorMessage: string): Boolean;
  end;

implementation

end.
