unit AuthDesktopService;

interface

uses
  IApiClient,
  IAuthDesktopService,
  IUserSession;

type
  TAuthDesktopService = class(
    TInterfacedObject,
    IAuthDesktopServiceContract)
  private
    FApiClient: IApiClientContract;
    FUserSession: IUserSessionContract;
    FLastError: string;
    function GetLastError: string;
    function ParseLoginResponse(const AResponseBody: string): Boolean;
  public
    constructor Create(
      const AApiClient: IApiClientContract;
      const AUserSession: IUserSessionContract);
    function Login(const AUserName, APassword: string): Boolean;
    procedure Logout;
  end;

implementation

uses
  System.JSON,
  System.SysUtils;

constructor TAuthDesktopService.Create(
  const AApiClient: IApiClientContract;
  const AUserSession: IUserSessionContract);
begin
  inherited Create;
  if not Assigned(AApiClient) then
    raise EArgumentNilException.Create('API client is required.');
  if not Assigned(AUserSession) then
    raise EArgumentNilException.Create('User session is required.');

  FApiClient := AApiClient;
  FUserSession := AUserSession;
end;

function TAuthDesktopService.GetLastError: string;
begin
  Result := FLastError;
end;

function TAuthDesktopService.Login(
  const AUserName, APassword: string): Boolean;
var
  JsonBody: TJSONObject;
  ResponseBody: string;
begin
  Result := False;
  FLastError := '';

  if (Trim(AUserName) = '') or (APassword = '') then
  begin
    FLastError := 'Enter your username and password.';
    Exit;
  end;

  JsonBody := TJSONObject.Create;
  try
    JsonBody.AddPair('username', Trim(AUserName));
    JsonBody.AddPair('password', APassword);
    ResponseBody := FApiClient.Post(
      '/api/auth/login',
      JsonBody.ToJSON);
  finally
    JsonBody.Free;
  end;

  if (FApiClient.LastStatusCode < 200) or
    (FApiClient.LastStatusCode >= 300) then
  begin
    FLastError := FApiClient.LastError;
    if FLastError = '' then
      FLastError := 'Sign-in failed. Check your credentials.';
    Exit;
  end;

  Result := ParseLoginResponse(ResponseBody);
end;

procedure TAuthDesktopService.Logout;
begin
  FApiClient.ClearBearerToken;
  FUserSession.Clear;
  FLastError := '';
end;

function TAuthDesktopService.ParseLoginResponse(
  const AResponseBody: string): Boolean;
var
  DataObject: TJSONObject;
  DataValue: TJSONValue;
  JsonObject: TJSONObject;
  RootValue: TJSONValue;
  Role: string;
  Token: string;
  UserId: Integer;
  UserName: string;
  DisplayName: string;
begin
  Result := False;
  RootValue := TJSONObject.ParseJSONValue(AResponseBody);
  try
    if not (RootValue is TJSONObject) then
    begin
      FLastError := 'The API returned an invalid sign-in response.';
      Exit;
    end;

    JsonObject := TJSONObject(RootValue);
    if not JsonObject.GetValue<Boolean>('success', False) then
    begin
      FLastError := JsonObject.GetValue<string>(
        'message',
        'Sign-in failed.');
      Exit;
    end;

    DataValue := JsonObject.GetValue('data');
    if not (DataValue is TJSONObject) then
    begin
      FLastError := 'The API returned incomplete sign-in data.';
      Exit;
    end;

    DataObject := TJSONObject(DataValue);
    Token := DataObject.GetValue<string>('token', '');
    UserId := DataObject.GetValue<Integer>('userId', 0);
    UserName := DataObject.GetValue<string>('userName', '');
    DisplayName := DataObject.GetValue<string>('displayName', '');
    Role := DataObject.GetValue<string>('role', '');

    if (Trim(Token) = '') or (UserId <= 0) or
      (Trim(UserName) = '') then
    begin
      FLastError := 'The API returned incomplete sign-in data.';
      Exit;
    end;

    FUserSession.SetAuthenticatedUser(
      Token,
      UserId,
      UserName,
      DisplayName,
      Role);
    FApiClient.SetBearerToken(Token);
    Result := True;
  finally
    RootValue.Free;
  end;
end;

end.
