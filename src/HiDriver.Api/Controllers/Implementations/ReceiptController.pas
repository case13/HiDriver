unit ReceiptController;

interface

uses
  ReceiptAppServiceIntf,
  ReceiptControllerIntf;

type
  TReceiptController = class(
    TInterfacedObject,
    IReceiptController)
  private
    FReceiptAppService: IReceiptAppService;
    class function BuildErrorResponse(
      const AMessage: string): string; static;
  public
    constructor Create(const AReceiptAppService: IReceiptAppService);
    procedure RegisterRoutes;
  end;

implementation

uses
  System.JSON,
  System.SysUtils,
  Horse,
  ReceiptDto;

function JsonIntegerValue(
  AJson: TJSONObject;
  const AName: string): Integer;
var
  Value: TJSONValue;
begin
  Result := 0;
  Value := AJson.GetValue(AName);
  if Value is TJSONNumber then
    Result := TJSONNumber(Value).AsInt;
end;

function JsonStringValue(
  AJson: TJSONObject;
  const AName: string): string;
var
  Value: TJSONValue;
begin
  Result := '';
  Value := AJson.GetValue(AName);
  if Assigned(Value) and (Value.ClassType = TJSONString) then
    Result := Value.Value;
end;

function ParseSaleReceiptRequest(
  const ABody: string): TIssueSaleReceiptRequestDto;
var
  Json: TJSONObject;
  JsonValue: TJSONValue;
begin
  Result := nil;
  JsonValue := TJSONObject.ParseJSONValue(ABody);
  try
    if not (JsonValue is TJSONObject) then
      Exit;
    Json := TJSONObject(JsonValue);
    Result := TIssueSaleReceiptRequestDto.Create;
    Result.SaleId := JsonIntegerValue(Json, 'saleId');
    Result.UserId := JsonIntegerValue(Json, 'userId');
    Result.Notes := JsonStringValue(Json, 'notes');
  finally
    JsonValue.Free;
  end;
end;

function ParseAccountPaymentReceiptRequest(
  const ABody: string):
  TIssueAccountReceivablePaymentReceiptRequestDto;
var
  Json: TJSONObject;
  JsonValue: TJSONValue;
begin
  Result := nil;
  JsonValue := TJSONObject.ParseJSONValue(ABody);
  try
    if not (JsonValue is TJSONObject) then
      Exit;
    Json := TJSONObject(JsonValue);
    Result :=
      TIssueAccountReceivablePaymentReceiptRequestDto.Create;
    Result.AccountReceivablePaymentId := JsonIntegerValue(
      Json,
      'accountReceivablePaymentId');
    Result.UserId := JsonIntegerValue(Json, 'userId');
    Result.Notes := JsonStringValue(Json, 'notes');
  finally
    JsonValue.Free;
  end;
end;

constructor TReceiptController.Create(
  const AReceiptAppService: IReceiptAppService);
begin
  inherited Create;
  FReceiptAppService := AReceiptAppService;
end;

class function TReceiptController.BuildErrorResponse(
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

procedure TReceiptController.RegisterRoutes;
begin
  THorse.Get('/api/receipts',
    procedure(Res: THorseResponse)
    begin
      Res
        .Status(200)
        .ContentType('application/json')
        .Send(FReceiptAppService.GetAll);
    end);

  THorse.Get('/api/receipts/number/:number',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      try
        Res
          .Status(200)
          .ContentType('application/json')
          .Send(FReceiptAppService.GetByNumber(
            Req.Params['number']));
      except
        on E: EReceiptValidationException do
          Res
            .Status(400)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
        on E: EReceiptNotFoundException do
          Res
            .Status(404)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
      end;
    end);

  THorse.Get('/api/receipts/:id',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      ReceiptId: Integer;
    begin
      if not TryStrToInt(Req.Params['id'], ReceiptId) or
        (ReceiptId <= 0) then
      begin
        Res
          .Status(400)
          .ContentType('application/json')
          .Send(BuildErrorResponse('Invalid receipt id.'));
        Exit;
      end;

      try
        Res
          .Status(200)
          .ContentType('application/json')
          .Send(FReceiptAppService.GetById(ReceiptId));
      except
        on E: EReceiptNotFoundException do
          Res
            .Status(404)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
      end;
    end);

  THorse.Post('/api/receipts/sale',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      RequestDto: TIssueSaleReceiptRequestDto;
    begin
      RequestDto := ParseSaleReceiptRequest(Req.Body);
      try
        if not Assigned(RequestDto) then
        begin
          Res
            .Status(400)
            .ContentType('application/json')
            .Send(BuildErrorResponse('Invalid JSON body.'));
          Exit;
        end;

        try
          Res
            .Status(201)
            .ContentType('application/json')
            .Send(FReceiptAppService.IssueSaleReceipt(RequestDto));
        except
          on E: EReceiptValidationException do
            Res
              .Status(400)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
          on E: EReceiptNotFoundException do
            Res
              .Status(404)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
          on E: EReceiptStateException do
            Res
              .Status(409)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
        end;
      finally
        RequestDto.Free;
      end;
    end);

  THorse.Post('/api/receipts/accounts-receivable-payment',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      RequestDto:
        TIssueAccountReceivablePaymentReceiptRequestDto;
    begin
      RequestDto := ParseAccountPaymentReceiptRequest(Req.Body);
      try
        if not Assigned(RequestDto) then
        begin
          Res
            .Status(400)
            .ContentType('application/json')
            .Send(BuildErrorResponse('Invalid JSON body.'));
          Exit;
        end;

        try
          Res
            .Status(201)
            .ContentType('application/json')
            .Send(
              FReceiptAppService.
                IssueAccountReceivablePaymentReceipt(RequestDto));
        except
          on E: EReceiptValidationException do
            Res
              .Status(400)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
          on E: EReceiptNotFoundException do
            Res
              .Status(404)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
          on E: EReceiptStateException do
            Res
              .Status(409)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
        end;
      finally
        RequestDto.Free;
      end;
    end);

  THorse.Post('/api/receipts/:id/cancel',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      ReceiptId: Integer;
    begin
      if not TryStrToInt(Req.Params['id'], ReceiptId) or
        (ReceiptId <= 0) then
      begin
        Res
          .Status(400)
          .ContentType('application/json')
          .Send(BuildErrorResponse('Invalid receipt id.'));
        Exit;
      end;

      try
        Res
          .Status(200)
          .ContentType('application/json')
          .Send(FReceiptAppService.Cancel(ReceiptId));
      except
        on E: EReceiptValidationException do
          Res
            .Status(400)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
        on E: EReceiptNotFoundException do
          Res
            .Status(404)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
        on E: EReceiptStateException do
          Res
            .Status(409)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
      end;
    end);
end;

end.
