unit CashRegisterController;

interface

uses
  CashRegisterAppServiceIntf,
  CashRegisterControllerIntf;

type
  TCashRegisterController = class(
    TInterfacedObject,
    ICashRegisterController)
  private
    FCashRegisterAppService: ICashRegisterAppService;
    class function BuildErrorResponse(const AMessage: string): string; static;
  public
    constructor Create(
      const ACashRegisterAppService: ICashRegisterAppService);
    procedure RegisterRoutes;
  end;

implementation

uses
  System.JSON,
  CashRegisterDtos,
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

function ParseOpenRequest(
  const ABody: string): TCashOpenRequestDto;
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
    Result := TCashOpenRequestDto.Create;
    try
      Result.UserId := JsonIntegerValue(Json, 'userId');
      Result.OpeningAmount :=
        JsonCurrencyValue(Json, 'openingAmount');
    except
      Result.Free;
      raise;
    end;
  finally
    JsonValue.Free;
  end;
end;

function ParseCloseRequest(
  const ABody: string): TCashCloseRequestDto;
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
    Result := TCashCloseRequestDto.Create;
    try
      Result.ClosingAmount :=
        JsonCurrencyValue(Json, 'closingAmount');
    except
      Result.Free;
      raise;
    end;
  finally
    JsonValue.Free;
  end;
end;

constructor TCashRegisterController.Create(
  const ACashRegisterAppService: ICashRegisterAppService);
begin
  inherited Create;
  FCashRegisterAppService := ACashRegisterAppService;
end;

class function TCashRegisterController.BuildErrorResponse(
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

procedure TCashRegisterController.RegisterRoutes;
begin
  THorse.Post('/api/cash/open',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      OpenRequest: TCashOpenRequestDto;
    begin
      OpenRequest := ParseOpenRequest(Req.Body);
      try
        if not Assigned(OpenRequest) then
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
            .Send(FCashRegisterAppService.Open(OpenRequest));
        except
          on E: ECashRegisterValidationException do
            Res
              .Status(400)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
          on E: ECashRegisterStateException do
            Res
              .Status(409)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
        end;
      finally
        OpenRequest.Free;
      end;
    end);

  THorse.Post('/api/cash/close',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      CloseRequest: TCashCloseRequestDto;
    begin
      CloseRequest := ParseCloseRequest(Req.Body);
      try
        if not Assigned(CloseRequest) then
        begin
          Res
            .Status(400)
            .ContentType('application/json')
            .Send(BuildErrorResponse('Invalid JSON body.'));
          Exit;
        end;

        try
          Res
            .Status(200)
            .ContentType('application/json')
            .Send(FCashRegisterAppService.Close(CloseRequest));
        except
          on E: ECashRegisterValidationException do
            Res
              .Status(400)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
          on E: ECashRegisterNotFoundException do
            Res
              .Status(404)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
          on E: ECashRegisterStateException do
            Res
              .Status(409)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
        end;
      finally
        CloseRequest.Free;
      end;
    end);

  THorse.Get('/api/cash/current',
    procedure(Res: THorseResponse)
    begin
      try
        Res
          .Status(200)
          .ContentType('application/json')
          .Send(FCashRegisterAppService.GetCurrent);
      except
        on E: ECashRegisterNotFoundException do
          Res
            .Status(404)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
      end;
    end);

  THorse.Get('/api/cash/movements',
    procedure(Res: THorseResponse)
    begin
      try
        Res
          .Status(200)
          .ContentType('application/json')
          .Send(FCashRegisterAppService.GetMovements);
      except
        on E: ECashRegisterNotFoundException do
          Res
            .Status(404)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
      end;
    end);
end;

end.
