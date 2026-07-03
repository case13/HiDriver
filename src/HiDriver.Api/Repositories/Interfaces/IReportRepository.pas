unit IReportRepository;

interface

uses
  System.Generics.Collections,
  ReportDtos;

type
  IReportRepositoryContract = interface
    // The caller owns the returned report.
    function GetSalesSummary(
      AStartDate,
      AEndDate: TDateTime): TSalesSummaryReportDto;
    // The caller owns the returned list and its DTOs.
    function GetSalesByPaymentMethod(
      AStartDate,
      AEndDate: TDateTime):
      TObjectList<TSalesByPaymentMethodReportDto>;
    // The caller owns the returned list and its DTOs.
    function GetLowStockProducts:
      TObjectList<TLowStockProductReportDto>;
    // The caller owns the returned list and its DTOs.
    function GetOpenAccountsReceivable:
      TObjectList<TOpenAccountReceivableReportDto>;
    // The caller owns the returned list and its DTOs.
    function GetCashSummary(
      AStartDate,
      AEndDate: TDateTime): TObjectList<TCashSummaryReportDto>;
    // Zero dates disable that side of the optional period.
    // The caller owns the returned list and its DTOs.
    function GetStockMovementsByProduct(
      AProductId: Integer;
      AStartDate,
      AEndDate: TDateTime): TObjectList<TStockMovementReportDto>;
  end;

implementation

end.
