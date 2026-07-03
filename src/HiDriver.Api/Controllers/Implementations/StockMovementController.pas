unit StockMovementController;

interface

uses
  StockMovementAppServiceIntf,
  StockMovementControllerIntf;

type
  TStockMovementController = class(
    TInterfacedObject,
    IStockMovementController)
  private
    FStockMovementAppService: IStockMovementAppService;
    class function BuildErrorResponse(
      const AMessage: string): string; static;
  public
    constructor Create(
      const AStockMovementAppService: IStockMovementAppService);
    procedure RegisterRoutes;
  end;

implementation

uses
  System.JSON,
  System.SysUtils,
  Horse,
  StockMovementDto;

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

function JsonDoubleValue(
  AJson: TJSONObject;
  const AName: string): Double;
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

function ParseAdjustmentRequest(
  const ABody: string): TCreateStockAdjustmentRequestDto;
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
    Result := TCreateStockAdjustmentRequestDto.Create;
    try
      Result.ProductId := JsonIntegerValue(Json, 'productId');
      Result.UserId := JsonIntegerValue(Json, 'userId');
      Result.MovementType :=
        JsonStringValue(Json, 'movementType');
      Result.Quantity := JsonDoubleValue(Json, 'quantity');
      Result.Notes := JsonStringValue(Json, 'notes');
    except
      Result.Free;
      raise;
    end;
  finally
    JsonValue.Free;
  end;
end;

constructor TStockMovementController.Create(
  const AStockMovementAppService: IStockMovementAppService);
begin
  inherited Create;
  FStockMovementAppService := AStockMovementAppService;
end;

class function TStockMovementController.BuildErrorResponse(
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

procedure TStockMovementController.RegisterRoutes;
begin
  THorse.Get('/api/stock-movements',
    procedure(Res: THorseResponse)
    begin
      Res
        .Status(200)
        .ContentType('application/json')
        .Send(FStockMovementAppService.GetAll);
    end);

  THorse.Get('/api/stock-movements/:id',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      MovementId: Integer;
    begin
      if not TryStrToInt(Req.Params['id'], MovementId) or
        (MovementId <= 0) then
      begin
        Res
          .Status(400)
          .ContentType('application/json')
          .Send(BuildErrorResponse('Invalid stock movement id.'));
        Exit;
      end;

      try
        Res
          .Status(200)
          .ContentType('application/json')
          .Send(FStockMovementAppService.GetById(MovementId));
      except
        on E: EStockMovementNotFoundException do
          Res
            .Status(404)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
      end;
    end);

  THorse.Get('/api/products/:id/stock-movements',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      ProductId: Integer;
    begin
      if not TryStrToInt(Req.Params['id'], ProductId) or
        (ProductId <= 0) then
      begin
        Res
          .Status(400)
          .ContentType('application/json')
          .Send(BuildErrorResponse('Invalid product id.'));
        Exit;
      end;

      Res
        .Status(200)
        .ContentType('application/json')
        .Send(FStockMovementAppService.GetByProductId(ProductId));
    end);

  THorse.Post('/api/stock-movements/adjustment',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      RequestDto: TCreateStockAdjustmentRequestDto;
    begin
      RequestDto := ParseAdjustmentRequest(Req.Body);
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
              FStockMovementAppService.RegisterManualAdjustment(
                RequestDto));
        except
          on E: EStockMovementValidationException do
            Res
              .Status(400)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
          on E: EStockMovementNotFoundException do
            Res
              .Status(404)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
          on E: EStockMovementStateException do
            Res
              .Status(409)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
        end;
      finally
        RequestDto.Free;
      end;
    end);
end;

end.
