unit IReportDomainService;

interface

uses
  System.Generics.Collections,
  ReportDtos;

type
  IReportDomainServiceContract = interface
    procedure CompleteSalesSummary(AReport: TSalesSummaryReportDto);
    procedure CompleteLowStockProducts(
      AProducts: TObjectList<TLowStockProductReportDto>);
    procedure CompleteCashSummary(
      ACashRegisters: TObjectList<TCashSummaryReportDto>);
  end;

implementation

end.
