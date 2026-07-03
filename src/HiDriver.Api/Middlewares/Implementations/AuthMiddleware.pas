unit AuthMiddleware;

interface

uses
  AuthMiddlewareIntf,
  Horse,
  JwtServiceIntf;

type
  TAuthMiddleware = class(TInterfacedObject, IAuthMiddleware)
  private
    FJwtService: IJwtService;
    class function BuildErrorResponse(
      const AMessage: string): string; static;
    class function GetAuthorizationHeader(
      ARequest: THorseRequest): string; static;
    class function IsPublicRoute(
      ARequest: THorseRequest): Boolean; static;
    class procedure SendUnauthorized(
      AResponse: THorseResponse;
      const AMessage: string); static;
    procedure Handle(
      ARequest: THorseRequest;
      AResponse: THorseResponse;
      ANext: TNextProc);
  public
    constructor Create(const AJwtService: IJwtService);
    procedure Register;
  end;

implementation

uses
  System.Generics.Collections,
  System.JSON,
  System.SysUtils,
  Web.HTTPApp;

constructor TAuthMiddleware.Create(const AJwtService: IJwtService);
begin
  inherited Create;
  FJwtService := AJwtService;
end;

class function TAuthMiddleware.BuildErrorResponse(
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

class function TAuthMiddleware.GetAuthorizationHeader(
  ARequest: THorseRequest): string;
var
  Header: TPair<string, string>;
begin
  Result := ARequest.Headers['Authorization'];
  if Result <> '' then
    Exit;

  for Header in ARequest.Headers.ToArray do
    if SameText(Header.Key, 'Authorization') then
      Exit(Header.Value);
end;

class function TAuthMiddleware.IsPublicRoute(
  ARequest: THorseRequest): Boolean;
var
  Path: string;
begin
  Path := Trim(ARequest.PathInfo);
  while (Length(Path) > 1) and Path.EndsWith('/') do
    Delete(Path, Length(Path), 1);

  Result :=
    ((ARequest.MethodType = mtGet) and
      SameText(Path, '/api/health')) or
    ((ARequest.MethodType = mtPost) and
      SameText(Path, '/api/auth/login'));
end;

class procedure TAuthMiddleware.SendUnauthorized(
  AResponse: THorseResponse;
  const AMessage: string);
begin
  AResponse
    .Status(401)
    .ContentType('application/json')
    .Send(BuildErrorResponse(AMessage));
  raise EHorseCallbackInterrupted.Create;
end;

procedure TAuthMiddleware.Handle(
  ARequest: THorseRequest;
  AResponse: THorseResponse;
  ANext: TNextProc);
const
  BearerPrefix = 'Bearer ';
var
  Authorization: string;
  Claims: TJwtClaims;
  Expired: Boolean;
  Token: string;
  UserContext: TAuthenticatedUserContext;
begin
  if IsPublicRoute(ARequest) then
  begin
    ANext();
    Exit;
  end;

  Authorization := Trim(GetAuthorizationHeader(ARequest));
  if (Authorization = '') or
    not Authorization.StartsWith(BearerPrefix, True) then
    SendUnauthorized(AResponse, 'Unauthorized.');

  Token := Trim(Copy(
    Authorization,
    Length(BearerPrefix) + 1,
    MaxInt));
  if Token = '' then
    SendUnauthorized(AResponse, 'Unauthorized.');

  if not FJwtService.ValidateToken(Token, Expired) then
  begin
    if Expired then
      SendUnauthorized(AResponse, 'Token expired.')
    else
      SendUnauthorized(AResponse, 'Unauthorized.');
  end;

  Claims := nil;
  try
    try
      Claims := FJwtService.ExtractClaims(Token);
    except
      on E: EJwtExpiredException do
        SendUnauthorized(AResponse, 'Token expired.');
      on E: EJwtValidationException do
        SendUnauthorized(AResponse, 'Unauthorized.');
    end;

    UserContext := TAuthenticatedUserContext.Create;
    try
      UserContext.UserId := Claims.UserId;
      UserContext.UserName := Claims.UserName;
      UserContext.DisplayName := Claims.DisplayName;
      UserContext.Role := Claims.Role;
      ARequest.Sessions.SetSession(
        TAuthenticatedUserContext,
        UserContext);
      UserContext := nil;
    finally
      UserContext.Free;
    end;
  finally
    Claims.Free;
  end;

  ANext();
end;

procedure TAuthMiddleware.Register;
begin
  THorse.Use(
    procedure(
      Request: THorseRequest;
      Response: THorseResponse;
      Next: TNextProc)
    begin
      Handle(Request, Response, Next);
    end);
end;

end.
