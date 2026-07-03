unit SaleController;

interface

uses
  SaleAppServiceIntf,
  SaleControllerIntf;

type
  TSaleController = class(TInterfacedObject, ISaleController)
  private
    FSaleAppService: ISaleAppService;
    class function BuildErrorResponse(const AMessage: string): string; static;
  public
    constructor Create(const ASaleAppService: ISaleAppService);
    procedure RegisterRoutes;
  end;

implementation

uses
  System.Generics.Collections,
  System.JSON,
  System.SysUtils,
  Horse,
  SaleDtos;

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

function ParseSaleCreateDto(const ABody: string): TSaleCreateDto;
var
  Index: Integer;
  ItemDto: TSaleItemCreateDto;
  Items: TJSONArray;
  Json: TJSONObject;
  JsonValue: TJSONValue;
  PaymentDto: TSalePaymentCreateDto;
  Payments: TJSONArray;
  Value: TJSONValue;
begin
  Result := nil;
  JsonValue := TJSONObject.ParseJSONValue(ABody);
  try
    if not (JsonValue is TJSONObject) then
      Exit;

    Json := TJSONObject(JsonValue);
    Result := TSaleCreateDto.Create;
    try
      Result.CustomerId := JsonIntegerValue(Json, 'customerId');
      Result.DiscountAmount := JsonDoubleValue(Json, 'discountAmount');
      Result.Notes := JsonStringValue(Json, 'notes');

      Value := Json.GetValue('items');
      if Value is TJSONArray then
      begin
        Items := TJSONArray(Value);
        for Index := 0 to Items.Count - 1 do
          if Items.Items[Index] is TJSONObject then
          begin
            ItemDto := TSaleItemCreateDto.Create;
            ItemDto.ProductId := JsonIntegerValue(
              TJSONObject(Items.Items[Index]),
              'productId');
            ItemDto.Quantity := JsonDoubleValue(
              TJSONObject(Items.Items[Index]),
              'quantity');
            ItemDto.UnitPrice := JsonDoubleValue(
              TJSONObject(Items.Items[Index]),
              'unitPrice');
            ItemDto.DiscountAmount := JsonDoubleValue(
              TJSONObject(Items.Items[Index]),
              'discountAmount');
            Result.Items.Add(ItemDto);
          end;
      end;

      Value := Json.GetValue('payments');
      if Value is TJSONArray then
      begin
        Payments := TJSONArray(Value);
        for Index := 0 to Payments.Count - 1 do
          if Payments.Items[Index] is TJSONObject then
          begin
            PaymentDto := TSalePaymentCreateDto.Create;
            PaymentDto.PaymentMethod := JsonStringValue(
              TJSONObject(Payments.Items[Index]),
              'paymentMethod');
            PaymentDto.Amount := JsonDoubleValue(
              TJSONObject(Payments.Items[Index]),
              'amount');
            Result.Payments.Add(PaymentDto);
          end;
      end;
    except
      Result.Free;
      raise;
    end;
  finally
    JsonValue.Free;
  end;
end;

constructor TSaleController.Create(
  const ASaleAppService: ISaleAppService);
begin
  inherited Create;
  FSaleAppService := ASaleAppService;
end;

class function TSaleController.BuildErrorResponse(
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

procedure TSaleController.RegisterRoutes;
begin
  THorse.Post('/api/sales',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      SaleDto: TSaleCreateDto;
    begin
      SaleDto := ParseSaleCreateDto(Req.Body);
      try
        if not Assigned(SaleDto) then
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
            .Send(FSaleAppService.Create(SaleDto));
        except
          on E: ESaleValidationException do
            Res
              .Status(400)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
          on E: ESaleStateException do
            Res
              .Status(409)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
        end;
      finally
        SaleDto.Free;
      end;
    end);

  THorse.Get('/api/sales',
    procedure(Res: THorseResponse)
    begin
      Res
        .Status(200)
        .ContentType('application/json')
        .Send(FSaleAppService.GetAll);
    end);

  THorse.Get('/api/sales/:id',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      SaleId: Integer;
    begin
      if not TryStrToInt(Req.Params['id'], SaleId) or
        (SaleId <= 0) then
      begin
        Res
          .Status(400)
          .ContentType('application/json')
          .Send(BuildErrorResponse('Invalid sale id.'));
        Exit;
      end;

      try
        Res
          .Status(200)
          .ContentType('application/json')
          .Send(FSaleAppService.GetById(SaleId));
      except
        on E: ESaleNotFoundException do
          Res
            .Status(404)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
      end;
    end);

  THorse.Post('/api/sales/:id/cancel',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      SaleId: Integer;
    begin
      if not TryStrToInt(Req.Params['id'], SaleId) or
        (SaleId <= 0) then
      begin
        Res
          .Status(400)
          .ContentType('application/json')
          .Send(BuildErrorResponse('Invalid sale id.'));
        Exit;
      end;

      try
        Res
          .Status(200)
          .ContentType('application/json')
          .Send(FSaleAppService.Cancel(SaleId));
      except
        on E: ESaleNotFoundException do
          Res
            .Status(404)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
        on E: ESaleStateException do
          Res
            .Status(409)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
      end;
    end);
end;

end.
