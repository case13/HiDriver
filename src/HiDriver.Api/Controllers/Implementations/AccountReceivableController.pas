unit AccountReceivableController;

interface

uses
  AccountReceivableAppServiceIntf,
  AccountReceivableControllerIntf;

type
  TAccountReceivableController = class(
    TInterfacedObject,
    IAccountReceivableController)
  private
    FAccountReceivableAppService: IAccountReceivableAppService;
    class function BuildErrorResponse(const AMessage: string): string; static;
  public
    constructor Create(
      const AAccountReceivableAppService:
        IAccountReceivableAppService);
    procedure RegisterRoutes;
  end;

implementation

uses
  System.JSON,
  System.SysUtils,
  AccountReceivableDto,
  Horse;

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

function JsonCurrencyValue(
  AJson: TJSONObject;
  const AName: string): Currency;
var
  Value: TJSONValue;
begin
  Result := 0;
  Value := AJson.GetValue(AName);
  if Value is TJSONNumber then
    Result := TJSONNumber(Value).AsDouble;
end;

function JsonStringValue(
  AJson: TJSONObject;
  const AName: string): string;
var
  Value: TJSONValue;
begin
  Result := '';
  Value := AJson.GetValue(AName);
  if Value is TJSONString then
    Result := Value.Value;
end;

function ParseReceiveRequest(
  const ABody: string): TReceiveAccountReceivableRequestDto;
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
    Result := TReceiveAccountReceivableRequestDto.Create;
    try
      Result.UserId := JsonIntegerValue(Json, 'userId');
      Result.PaymentMethod :=
        JsonStringValue(Json, 'paymentMethod');
      Result.Amount := JsonCurrencyValue(Json, 'amount');
      Result.DiscountAmount :=
        JsonCurrencyValue(Json, 'discountAmount');
      Result.InterestAmount :=
        JsonCurrencyValue(Json, 'interestAmount');
      Result.Notes := JsonStringValue(Json, 'notes');
    except
      Result.Free;
      raise;
    end;
  finally
    JsonValue.Free;
  end;
end;

constructor TAccountReceivableController.Create(
  const AAccountReceivableAppService:
    IAccountReceivableAppService);
begin
  inherited Create;
  FAccountReceivableAppService :=
    AAccountReceivableAppService;
end;

class function TAccountReceivableController.BuildErrorResponse(
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

procedure TAccountReceivableController.RegisterRoutes;
begin
  THorse.Get('/api/accounts-receivable',
    procedure(Res: THorseResponse)
    begin
      Res
        .Status(200)
        .ContentType('application/json')
        .Send(FAccountReceivableAppService.GetAll);
    end);

  THorse.Get('/api/accounts-receivable/:id',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      AccountId: Integer;
    begin
      if not TryStrToInt(Req.Params['id'], AccountId) or
        (AccountId <= 0) then
      begin
        Res
          .Status(400)
          .ContentType('application/json')
          .Send(BuildErrorResponse(
            'Invalid account receivable id.'));
        Exit;
      end;

      try
        Res
          .Status(200)
          .ContentType('application/json')
          .Send(FAccountReceivableAppService.GetById(AccountId));
      except
        on E: EAccountReceivableNotFoundException do
          Res
            .Status(404)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
      end;
    end);

  THorse.Get('/api/accounts-receivable/:id/payments',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      AccountId: Integer;
    begin
      if not TryStrToInt(Req.Params['id'], AccountId) or
        (AccountId <= 0) then
      begin
        Res
          .Status(400)
          .ContentType('application/json')
          .Send(BuildErrorResponse(
            'Invalid account receivable id.'));
        Exit;
      end;

      try
        Res
          .Status(200)
          .ContentType('application/json')
          .Send(FAccountReceivableAppService.GetPayments(AccountId));
      except
        on E: EAccountReceivableNotFoundException do
          Res
            .Status(404)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
      end;
    end);

  THorse.Post('/api/accounts-receivable/:id/receive',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      AccountId: Integer;
      ReceiveRequest: TReceiveAccountReceivableRequestDto;
    begin
      if not TryStrToInt(Req.Params['id'], AccountId) or
        (AccountId <= 0) then
      begin
        Res
          .Status(400)
          .ContentType('application/json')
          .Send(BuildErrorResponse(
            'Invalid account receivable id.'));
        Exit;
      end;

      ReceiveRequest := ParseReceiveRequest(Req.Body);
      try
        if not Assigned(ReceiveRequest) then
        begin
          Res
            .Status(400)
            .ContentType('application/json')
            .Send(BuildErrorResponse('Invalid JSON body.'));
          Exit;
        end;

        ReceiveRequest.AccountReceivableId := AccountId;
        try
          Res
            .Status(200)
            .ContentType('application/json')
            .Send(FAccountReceivableAppService.Receive(
              ReceiveRequest));
        except
          on E: EAccountReceivableValidationException do
            Res
              .Status(400)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
          on E: EAccountReceivableNotFoundException do
            Res
              .Status(404)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
          on E: EAccountReceivableStateException do
            Res
              .Status(409)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
        end;
      finally
        ReceiveRequest.Free;
      end;
    end);
end;

end.
