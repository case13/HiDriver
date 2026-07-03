unit ReportDomainService;

interface

uses
  System.Generics.Collections,
  IReportDomainService,
  ReportDtos;

type
  TReportDomainService = class(
    TInterfacedObject,
    IReportDomainServiceContract)
  public
    procedure CompleteSalesSummary(AReport: TSalesSummaryReportDto);
    procedure CompleteLowStockProducts(
      AProducts: TObjectList<TLowStockProductReportDto>);
    procedure CompleteCashSummary(
      ACashRegisters: TObjectList<TCashSummaryReportDto>);
  end;

implementation

procedure TReportDomainService.CompleteSalesSummary(
  AReport: TSalesSummaryReportDto);
begin
  if not Assigned(AReport) then
    Exit;

  AReport.NetSales := AReport.TotalSales - AReport.CanceledSales;
  if AReport.NetSales < 0 then
    AReport.NetSales := 0;
end;

procedure TReportDomainService.CompleteLowStockProducts(
  AProducts: TObjectList<TLowStockProductReportDto>);
var
  Product: TLowStockProductReportDto;
begin
  if not Assigned(AProducts) then
    Exit;

  for Product in AProducts do
    if Product.MinimumStock > Product.CurrentStock then
      Product.MissingQuantity :=
        Product.MinimumStock - Product.CurrentStock
    else
      Product.MissingQuantity := 0;
end;

procedure TReportDomainService.CompleteCashSummary(
  ACashRegisters: TObjectList<TCashSummaryReportDto>);
var
  CashRegister: TCashSummaryReportDto;
begin
  if not Assigned(ACashRegisters) then
    Exit;

  for CashRegister in ACashRegisters do
    CashRegister.ExpectedAmount :=
      CashRegister.OpeningAmount +
      CashRegister.TotalIn -
      CashRegister.TotalOut;
end;

end.
