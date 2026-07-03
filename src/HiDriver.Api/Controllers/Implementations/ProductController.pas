unit ProductController;

interface

uses
  ProductAppServiceIntf,
  ProductControllerIntf;

type
  TProductController = class(TInterfacedObject, IProductController)
  private
    FProductAppService: IProductAppService;
    class function BuildErrorResponse(const AMessage: string): string; static;
  public
    constructor Create(const AProductAppService: IProductAppService);
    procedure RegisterRoutes;
  end;

implementation

uses
  System.JSON,
  System.SysUtils,
  Horse,
  ProductDtos;

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

function JsonNumberValue(
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

function JsonBooleanValue(
  AJson: TJSONObject;
  const AName: string;
  ADefault: Boolean): Boolean;
var
  Value: TJSONValue;
begin
  Result := ADefault;
  Value := AJson.GetValue(AName);
  if Value is TJSONBool then
    Result := TJSONBool(Value).AsBoolean;
end;

function ParseCreateDto(const ABody: string): TProductCreateDto;
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
    Result := TProductCreateDto.Create;
    try
      Result.InternalCode := JsonStringValue(Json, 'internalCode');
      Result.BarCode := JsonStringValue(Json, 'barCode');
      Result.OriginalCode := JsonStringValue(Json, 'originalCode');
      Result.Description := JsonStringValue(Json, 'description');
      Result.BrandName := JsonStringValue(Json, 'brandName');
      Result.CategoryName := JsonStringValue(Json, 'categoryName');
      Result.VehicleApplication :=
        JsonStringValue(Json, 'vehicleApplication');
      Result.CurrentStock := JsonNumberValue(Json, 'currentStock');
      Result.MinimumStock := JsonNumberValue(Json, 'minimumStock');
      Result.CostPrice := JsonNumberValue(Json, 'costPrice');
      Result.SalePrice := JsonNumberValue(Json, 'salePrice');
      Result.IsActive := JsonBooleanValue(Json, 'isActive', True);
    except
      Result.Free;
      raise;
    end;
  finally
    JsonValue.Free;
  end;
end;

function ParseUpdateDto(const ABody: string): TProductUpdateDto;
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
    Result := TProductUpdateDto.Create;
    try
      Result.InternalCode := JsonStringValue(Json, 'internalCode');
      Result.BarCode := JsonStringValue(Json, 'barCode');
      Result.OriginalCode := JsonStringValue(Json, 'originalCode');
      Result.Description := JsonStringValue(Json, 'description');
      Result.BrandName := JsonStringValue(Json, 'brandName');
      Result.CategoryName := JsonStringValue(Json, 'categoryName');
      Result.VehicleApplication :=
        JsonStringValue(Json, 'vehicleApplication');
      Result.CurrentStock := JsonNumberValue(Json, 'currentStock');
      Result.MinimumStock := JsonNumberValue(Json, 'minimumStock');
      Result.CostPrice := JsonNumberValue(Json, 'costPrice');
      Result.SalePrice := JsonNumberValue(Json, 'salePrice');
      Result.IsActive := JsonBooleanValue(Json, 'isActive', True);
    except
      Result.Free;
      raise;
    end;
  finally
    JsonValue.Free;
  end;
end;

constructor TProductController.Create(
  const AProductAppService: IProductAppService);
begin
  inherited Create;
  FProductAppService := AProductAppService;
end;

class function TProductController.BuildErrorResponse(
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

procedure TProductController.RegisterRoutes;
begin
  THorse.Get('/api/products',
    procedure(Res: THorseResponse)
    begin
      Res
        .Status(200)
        .ContentType('application/json')
        .Send(FProductAppService.GetAll);
    end);

  THorse.Get('/api/products/:id',
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

      try
        Res
          .Status(200)
          .ContentType('application/json')
          .Send(FProductAppService.GetById(ProductId));
      except
        on E: EProductNotFoundException do
          Res
            .Status(404)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
      end;
    end);

  THorse.Post('/api/products',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      ProductDto: TProductCreateDto;
    begin
      ProductDto := ParseCreateDto(Req.Body);
      try
        if not Assigned(ProductDto) then
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
            .Send(FProductAppService.Create(ProductDto));
        except
          on E: EProductValidationException do
            Res
              .Status(400)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
          on E: EProductDuplicateException do
            Res
              .Status(409)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
        end;
      finally
        ProductDto.Free;
      end;
    end);

  THorse.Put('/api/products/:id',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      ProductDto: TProductUpdateDto;
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

      ProductDto := ParseUpdateDto(Req.Body);
      try
        if not Assigned(ProductDto) then
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
            .Send(FProductAppService.Update(ProductId, ProductDto));
        except
          on E: EProductValidationException do
            Res
              .Status(400)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
          on E: EProductDuplicateException do
            Res
              .Status(409)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
          on E: EProductNotFoundException do
            Res
              .Status(404)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
        end;
      finally
        ProductDto.Free;
      end;
    end);

  THorse.Delete('/api/products/:id',
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

      try
        Res
          .Status(200)
          .ContentType('application/json')
          .Send(FProductAppService.Delete(ProductId));
      except
        on E: EProductNotFoundException do
          Res
            .Status(404)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
      end;
    end);
end;

end.
