unit IReportAppService;

interface

uses
  System.SysUtils;

type
  EReportValidationException = class(Exception);

  IReportAppServiceContract = interface
    function GetSalesSummary(
      const AStartDate,
      AEndDate: string): string;
    function GetSalesByPaymentMethod(
      const AStartDate,
      AEndDate: string): string;
    function GetLowStockProducts: string;
    function GetOpenAccountsReceivable: string;
    function GetCashSummary(
      const AStartDate,
      AEndDate: string): string;
    function GetStockMovementsByProduct(
      AProductId: Integer;
      const AStartDate,
      AEndDate: string): string;
  end;

implementation

end.
