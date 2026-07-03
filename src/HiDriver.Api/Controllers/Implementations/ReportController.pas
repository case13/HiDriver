unit ReportController;

interface

uses
  IReportAppService,
  IReportController;

type
  TReportController = class(
    TInterfacedObject,
    IReportControllerContract)
  private
    FReportAppService: IReportAppServiceContract;
    class function BuildErrorResponse(
      const AMessage: string): string; static;
  public
    constructor Create(
      const AReportAppService: IReportAppServiceContract);
    procedure RegisterRoutes;
  end;

implementation

uses
  System.JSON,
  System.SysUtils,
  Horse;

constructor TReportController.Create(
  const AReportAppService: IReportAppServiceContract);
begin
  inherited Create;
  FReportAppService := AReportAppService;
end;

class function TReportController.BuildErrorResponse(
  const AMessage: string): string;
var
  Json: TJSONObject;
begin
  Json := TJSONObject.Create;
  try
    Json.AddPair('success', TJSONBool.Create(False));
    Json.AddPair('message', AMessage);
    Json.AddPair('data', TJSONNull.Create);
    Result := Json.ToJSON;
  finally
    Json.Free;
  end;
end;

procedure TReportController.RegisterRoutes;
begin
  THorse.Get('/api/reports/sales-summary',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      try
        Res
          .Status(200)
          .ContentType('application/json')
          .Send(FReportAppService.GetSalesSummary(
            Req.Query['startDate'],
            Req.Query['endDate']));
      except
        on E: EReportValidationException do
          Res
            .Status(400)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
      end;
    end);

  THorse.Get('/api/reports/sales-by-payment-method',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      try
        Res
          .Status(200)
          .ContentType('application/json')
          .Send(FReportAppService.GetSalesByPaymentMethod(
            Req.Query['startDate'],
            Req.Query['endDate']));
      except
        on E: EReportValidationException do
          Res
            .Status(400)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
      end;
    end);

  THorse.Get('/api/reports/low-stock-products',
    procedure(Res: THorseResponse)
    begin
      Res
        .Status(200)
        .ContentType('application/json')
        .Send(FReportAppService.GetLowStockProducts);
    end);

  THorse.Get('/api/reports/open-accounts-receivable',
    procedure(Res: THorseResponse)
    begin
      Res
        .Status(200)
        .ContentType('application/json')
        .Send(FReportAppService.GetOpenAccountsReceivable);
    end);

  THorse.Get('/api/reports/cash-summary',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      try
        Res
          .Status(200)
          .ContentType('application/json')
          .Send(FReportAppService.GetCashSummary(
            Req.Query['startDate'],
            Req.Query['endDate']));
      except
        on E: EReportValidationException do
          Res
            .Status(400)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
      end;
    end);

  THorse.Get('/api/reports/products/:id/stock-movements',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      ProductId: Integer;
    begin
      if not TryStrToInt(Req.Params['id'], ProductId) then
      begin
        Res
          .Status(400)
          .ContentType('application/json')
          .Send(BuildErrorResponse('Invalid product id.'));
        Exit;
      end;

      try
        Res
          .Status(200)
          .ContentType('application/json')
          .Send(FReportAppService.GetStockMovementsByProduct(
            ProductId,
            Req.Query['startDate'],
            Req.Query['endDate']));
      except
        on E: EReportValidationException do
          Res
            .Status(400)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
      end;
    end);
end;

end.
