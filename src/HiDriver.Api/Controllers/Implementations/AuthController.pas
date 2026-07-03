unit AuthController;

interface

uses
  AuthAppServiceIntf,
  AuthControllerIntf;

type
  TAuthController = class(TInterfacedObject, IAuthController)
  private
    FAuthAppService: IAuthAppService;
    class function BuildErrorResponse(const AMessage: string): string; static;
    class function BuildSuccessResponse(
      const AToken: string;
      const AUserId: Integer;
      const AUserName,
      ADisplayName,
      ARole: string): string; static;
  public
    constructor Create(const AAuthAppService: IAuthAppService);
    procedure RegisterRoutes;
  end;

implementation

uses
  System.JSON,
  AuthDtos,
  Horse;

constructor TAuthController.Create(
  const AAuthAppService: IAuthAppService);
begin
  inherited Create;
  FAuthAppService := AAuthAppService;
end;

class function TAuthController.BuildErrorResponse(
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

class function TAuthController.BuildSuccessResponse(
  const AToken: string;
  const AUserId: Integer;
  const AUserName,
  ADisplayName,
  ARole: string): string;
var
  Data: TJSONObject;
  Json: TJSONObject;
begin
  Json := TJSONObject.Create;
  try
    Data := TJSONObject.Create;
    Data.AddPair('token', AToken);
    Data.AddPair('userId', TJSONNumber.Create(AUserId));
    Data.AddPair('userName', AUserName);
    Data.AddPair('displayName', ADisplayName);
    Data.AddPair('role', ARole);

    Json.AddPair('success', TJSONBool.Create(True));
    Json.AddPair('message', 'Login successful.');
    Json.AddPair('data', Data);
    Result := Json.ToJSON;
  finally
    Json.Free;
  end;
end;

procedure TAuthController.RegisterRoutes;
begin
  THorse.Post('/api/auth/login',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      JsonObject: TJSONObject;
      JsonValue: TJSONValue;
      LoginResponse: TLoginResponseDto;
      Password: string;
      UserName: string;
      Value: TJSONValue;
    begin
      JsonValue := TJSONObject.ParseJSONValue(Req.Body);
      try
        if not (JsonValue is TJSONObject) then
        begin
          Res
            .Status(400)
            .ContentType('application/json')
            .Send(BuildErrorResponse('Invalid JSON body.'));
          Exit;
        end;

        JsonObject := TJSONObject(JsonValue);

        Value := JsonObject.GetValue('username');
        if Assigned(Value) then
          UserName := Value.Value
        else
          UserName := '';

        Value := JsonObject.GetValue('password');
        if Assigned(Value) then
          Password := Value.Value
        else
          Password := '';

        LoginResponse := nil;
        try
          try
            LoginResponse := FAuthAppService.Login(UserName, Password);
            Res
              .Status(200)
              .ContentType('application/json')
              .Send(BuildSuccessResponse(
                LoginResponse.Token,
                LoginResponse.UserId,
                LoginResponse.UserName,
                LoginResponse.DisplayName,
                LoginResponse.Role));
          except
            on E: EAuthValidationException do
              Res
                .Status(400)
                .ContentType('application/json')
                .Send(BuildErrorResponse(E.Message));
            on E: EInvalidCredentialsException do
              Res
                .Status(401)
                .ContentType('application/json')
                .Send(BuildErrorResponse(E.Message));
          end;
        finally
          LoginResponse.Free;
        end;
      finally
        JsonValue.Free;
      end;
    end);
end;

end.
