unit CustomerController;

interface

uses
  CustomerAppServiceIntf,
  CustomerControllerIntf;

type
  TCustomerController = class(TInterfacedObject, ICustomerController)
  private
    FCustomerAppService: ICustomerAppService;
    class function BuildErrorResponse(const AMessage: string): string; static;
  public
    constructor Create(const ACustomerAppService: ICustomerAppService);
    procedure RegisterRoutes;
  end;

implementation

uses
  System.JSON,
  System.SysUtils,
  CustomerDtos,
  Horse;

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

function ParseCreateDto(const ABody: string): TCustomerCreateDto;
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
    Result := TCustomerCreateDto.Create;
    try
      Result.Name := JsonStringValue(Json, 'name');
      Result.Document := JsonStringValue(Json, 'document');
      Result.Phone := JsonStringValue(Json, 'phone');
      Result.Email := JsonStringValue(Json, 'email');
      Result.Address := JsonStringValue(Json, 'address');
      Result.City := JsonStringValue(Json, 'city');
      Result.State := JsonStringValue(Json, 'state');
      Result.ZipCode := JsonStringValue(Json, 'zipCode');
      Result.IsActive := JsonBooleanValue(Json, 'isActive', True);
    except
      Result.Free;
      raise;
    end;
  finally
    JsonValue.Free;
  end;
end;

function ParseUpdateDto(const ABody: string): TCustomerUpdateDto;
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
    Result := TCustomerUpdateDto.Create;
    try
      Result.Name := JsonStringValue(Json, 'name');
      Result.Document := JsonStringValue(Json, 'document');
      Result.Phone := JsonStringValue(Json, 'phone');
      Result.Email := JsonStringValue(Json, 'email');
      Result.Address := JsonStringValue(Json, 'address');
      Result.City := JsonStringValue(Json, 'city');
      Result.State := JsonStringValue(Json, 'state');
      Result.ZipCode := JsonStringValue(Json, 'zipCode');
      Result.IsActive := JsonBooleanValue(Json, 'isActive', True);
    except
      Result.Free;
      raise;
    end;
  finally
    JsonValue.Free;
  end;
end;

constructor TCustomerController.Create(
  const ACustomerAppService: ICustomerAppService);
begin
  inherited Create;
  FCustomerAppService := ACustomerAppService;
end;

class function TCustomerController.BuildErrorResponse(
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

procedure TCustomerController.RegisterRoutes;
begin
  THorse.Get('/api/customers',
    procedure(Res: THorseResponse)
    begin
      Res
        .Status(200)
        .ContentType('application/json')
        .Send(FCustomerAppService.GetAll);
    end);

  THorse.Get('/api/customers/:id',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      CustomerId: Integer;
    begin
      if not TryStrToInt(Req.Params['id'], CustomerId) or
        (CustomerId <= 0) then
      begin
        Res
          .Status(400)
          .ContentType('application/json')
          .Send(BuildErrorResponse('Invalid customer id.'));
        Exit;
      end;

      try
        Res
          .Status(200)
          .ContentType('application/json')
          .Send(FCustomerAppService.GetById(CustomerId));
      except
        on E: ECustomerNotFoundException do
          Res
            .Status(404)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
      end;
    end);

  THorse.Post('/api/customers',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      CustomerDto: TCustomerCreateDto;
    begin
      CustomerDto := ParseCreateDto(Req.Body);
      try
        if not Assigned(CustomerDto) then
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
            .Send(FCustomerAppService.Create(CustomerDto));
        except
          on E: ECustomerValidationException do
            Res
              .Status(400)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
          on E: ECustomerDuplicateException do
            Res
              .Status(409)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
        end;
      finally
        CustomerDto.Free;
      end;
    end);

  THorse.Put('/api/customers/:id',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      CustomerDto: TCustomerUpdateDto;
      CustomerId: Integer;
    begin
      if not TryStrToInt(Req.Params['id'], CustomerId) or
        (CustomerId <= 0) then
      begin
        Res
          .Status(400)
          .ContentType('application/json')
          .Send(BuildErrorResponse('Invalid customer id.'));
        Exit;
      end;

      CustomerDto := ParseUpdateDto(Req.Body);
      try
        if not Assigned(CustomerDto) then
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
            .Send(FCustomerAppService.Update(CustomerId, CustomerDto));
        except
          on E: ECustomerValidationException do
            Res
              .Status(400)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
          on E: ECustomerDuplicateException do
            Res
              .Status(409)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
          on E: ECustomerNotFoundException do
            Res
              .Status(404)
              .ContentType('application/json')
              .Send(BuildErrorResponse(E.Message));
        end;
      finally
        CustomerDto.Free;
      end;
    end);

  THorse.Delete('/api/customers/:id',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      CustomerId: Integer;
    begin
      if not TryStrToInt(Req.Params['id'], CustomerId) or
        (CustomerId <= 0) then
      begin
        Res
          .Status(400)
          .ContentType('application/json')
          .Send(BuildErrorResponse('Invalid customer id.'));
        Exit;
      end;

      try
        Res
          .Status(200)
          .ContentType('application/json')
          .Send(FCustomerAppService.Delete(CustomerId));
      except
        on E: ECustomerNotFoundException do
          Res
            .Status(404)
            .ContentType('application/json')
            .Send(BuildErrorResponse(E.Message));
      end;
    end);
end;

end.
