unit StockMovementAppServiceIntf;

interface

uses
  System.SysUtils,
  StockMovementDto;

type
  EStockMovementValidationException = class(Exception);
  EStockMovementNotFoundException = class(Exception);
  EStockMovementStateException = class(Exception);

  IStockMovementAppService = interface
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

end.
