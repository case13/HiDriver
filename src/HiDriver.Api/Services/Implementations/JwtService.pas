unit JwtService;

interface

uses
  System.SysUtils,
  ApiConfigIntf,
  JwtServiceIntf;

type
  TJwtService = class(TInterfacedObject, IJwtService)
  private
    FConfig: IApiConfig;
    class function Base64UrlEncode(
      const ABytes: TBytes): string; static;
    class function Base64UrlDecode(
      const AValue: string): string; static;
    class function SecureEquals(
      const ALeft,
      ARight: string): Boolean; static;
    function CreateSignature(const ASigningInput: string): string;
    function TryParseToken(
      const AToken: string;
      out AClaims: TJwtClaims;
      out AExpired: Boolean): Boolean;
  public
    constructor Create(const AConfig: IApiConfig);
    function GenerateToken(
      AUserId: Integer;
      const AUserName,
      ADisplayName,
      ARole: string): string;
    function ValidateToken(
      const AToken: string;
      out AExpired: Boolean): Boolean;
    function ExtractClaims(const AToken: string): TJwtClaims;
    function ExtractUserId(const AToken: string): Integer;
    function ExtractUserName(const AToken: string): string;
    function ExtractRole(const AToken: string): string;
  end;

implementation

uses
  System.DateUtils,
  System.Hash,
  System.JSON,
  System.NetEncoding;

function TryGetJsonString(
  AJson: TJSONObject;
  const AName: string;
  out AValue: string): Boolean;
var
  JsonValue: TJSONValue;
begin
  AValue := '';
  JsonValue := AJson.GetValue(AName);
  Result := Assigned(JsonValue) and
    (JsonValue.ClassType = TJSONString);
  if Result then
    AValue := JsonValue.Value;
end;

function TryGetJsonInteger(
  AJson: TJSONObject;
  const AName: string;
  out AValue: Int64): Boolean;
var
  JsonValue: TJSONValue;
begin
  AValue := 0;
  JsonValue := AJson.GetValue(AName);
  Result := JsonValue is TJSONNumber;
  if Result then
    AValue := TJSONNumber(JsonValue).AsInt64;
end;

constructor TJwtService.Create(const AConfig: IApiConfig);
begin
  inherited Create;
  FConfig := AConfig;
end;

class function TJwtService.Base64UrlEncode(
  const ABytes: TBytes): string;
begin
  Result := TNetEncoding.Base64.EncodeBytesToString(ABytes);
  Result := Result.Replace(#13, '').Replace(#10, '');
  Result := Result.Replace('+', '-');
  Result := Result.Replace('/', '_');
  Result := Result.TrimRight(['=']);
end;

class function TJwtService.Base64UrlDecode(
  const AValue: string): string;
var
  Base64Value: string;
  Bytes: TBytes;
begin
  Base64Value := AValue.Replace('-', '+').Replace('_', '/');
  while (Length(Base64Value) mod 4) <> 0 do
    Base64Value := Base64Value + '=';
  Bytes := TNetEncoding.Base64.DecodeStringToBytes(Base64Value);
  Result := TEncoding.UTF8.GetString(Bytes);
end;

class function TJwtService.SecureEquals(
  const ALeft,
  ARight: string): Boolean;
var
  Difference: Integer;
  Index: Integer;
begin
  if Length(ALeft) <> Length(ARight) then
    Exit(False);

  Difference := 0;
  for Index := 1 to Length(ALeft) do
    Difference := Difference or
      (Ord(ALeft[Index]) xor Ord(ARight[Index]));
  Result := Difference = 0;
end;

function TJwtService.CreateSignature(
  const ASigningInput: string): string;
begin
  Result := Base64UrlEncode(
    THashSHA2.GetHMACAsBytes(
      ASigningInput,
      FConfig.JwtSecret,
      THashSHA2.TSHA2Version.SHA256));
end;

function TJwtService.GenerateToken(
  AUserId: Integer;
  const AUserName,
  ADisplayName,
  ARole: string): string;
var
  Expiration: Int64;
  Header: TJSONObject;
  HeaderSegment: string;
  IssuedAt: Int64;
  Payload: TJSONObject;
  PayloadSegment: string;
  SigningInput: string;
begin
  if AUserId <= 0 then
    raise EArgumentOutOfRangeException.Create(
      'User id must be greater than zero.');
  if Trim(AUserName) = '' then
    raise EArgumentException.Create('User name is required.');
  if Trim(ADisplayName) = '' then
    raise EArgumentException.Create('Display name is required.');
  if Trim(ARole) = '' then
    raise EArgumentException.Create('Role is required.');

  IssuedAt := DateTimeToUnix(Now, False);
  Expiration := IssuedAt +
    (Int64(FConfig.JwtExpirationMinutes) * 60);

  Header := TJSONObject.Create;
  try
    Header.AddPair('alg', 'HS256');
    Header.AddPair('typ', 'JWT');
    HeaderSegment := Base64UrlEncode(
      TEncoding.UTF8.GetBytes(Header.ToJSON));
  finally
    Header.Free;
  end;

  Payload := TJSONObject.Create;
  try
    Payload.AddPair('userId', TJSONNumber.Create(AUserId));
    Payload.AddPair('userName', Trim(AUserName));
    Payload.AddPair('displayName', Trim(ADisplayName));
    Payload.AddPair('role', Trim(ARole));
    Payload.AddPair('iss', FConfig.JwtIssuer);
    Payload.AddPair('aud', FConfig.JwtAudience);
    Payload.AddPair('iat', TJSONNumber.Create(IssuedAt));
    Payload.AddPair('exp', TJSONNumber.Create(Expiration));
    PayloadSegment := Base64UrlEncode(
      TEncoding.UTF8.GetBytes(Payload.ToJSON));
  finally
    Payload.Free;
  end;

  SigningInput := HeaderSegment + '.' + PayloadSegment;
  Result := SigningInput + '.' + CreateSignature(SigningInput);
end;

function TJwtService.TryParseToken(
  const AToken: string;
  out AClaims: TJwtClaims;
  out AExpired: Boolean): Boolean;
var
  Audience: string;
  DisplayName: string;
  Expiration: Int64;
  Header: TJSONObject;
  HeaderJson: TJSONValue;
  Issuer: string;
  JwtType: string;
  Algorithm: string;
  Payload: TJSONObject;
  PayloadJson: TJSONValue;
  Role: string;
  Segments: TArray<string>;
  SigningInput: string;
  UserId: Int64;
  UserName: string;
begin
  Result := False;
  AClaims := nil;
  AExpired := False;
  HeaderJson := nil;
  PayloadJson := nil;
  try
    try
      Segments := AToken.Split(['.']);
      if (Length(Segments) <> 3) or
        (Segments[0] = '') or
        (Segments[1] = '') or
        (Segments[2] = '') then
        Exit;

      SigningInput := Segments[0] + '.' + Segments[1];
      if not SecureEquals(
        Segments[2],
        CreateSignature(SigningInput)) then
        Exit;

      HeaderJson := TJSONObject.ParseJSONValue(
        Base64UrlDecode(Segments[0]));
      if not (HeaderJson is TJSONObject) then
        Exit;
      Header := TJSONObject(HeaderJson);
      if not TryGetJsonString(Header, 'alg', Algorithm) or
        not SameText(Algorithm, 'HS256') or
        not TryGetJsonString(Header, 'typ', JwtType) or
        not SameText(JwtType, 'JWT') then
        Exit;

      PayloadJson := TJSONObject.ParseJSONValue(
        Base64UrlDecode(Segments[1]));
      if not (PayloadJson is TJSONObject) then
        Exit;
      Payload := TJSONObject(PayloadJson);

      if not TryGetJsonInteger(Payload, 'userId', UserId) or
        (UserId <= 0) or
        (UserId > High(Integer)) or
        not TryGetJsonString(Payload, 'userName', UserName) or
        (Trim(UserName) = '') or
        not TryGetJsonString(Payload, 'displayName', DisplayName) or
        (Trim(DisplayName) = '') or
        not TryGetJsonString(Payload, 'role', Role) or
        (Trim(Role) = '') or
        not TryGetJsonString(Payload, 'iss', Issuer) or
        not SameText(Issuer, FConfig.JwtIssuer) or
        not TryGetJsonString(Payload, 'aud', Audience) or
        not SameText(Audience, FConfig.JwtAudience) or
        not TryGetJsonInteger(Payload, 'exp', Expiration) or
        (Expiration <= 0) then
        Exit;

      if Expiration <= DateTimeToUnix(Now, False) then
      begin
        AExpired := True;
        Exit;
      end;

      AClaims := TJwtClaims.Create;
      AClaims.UserId := Integer(UserId);
      AClaims.UserName := UserName;
      AClaims.DisplayName := DisplayName;
      AClaims.Role := Role;
      AClaims.Issuer := Issuer;
      AClaims.Audience := Audience;
      AClaims.Expiration := Expiration;
      Result := True;
    except
      Result := False;
      FreeAndNil(AClaims);
    end;
  finally
    PayloadJson.Free;
    HeaderJson.Free;
  end;
end;

function TJwtService.ValidateToken(
  const AToken: string;
  out AExpired: Boolean): Boolean;
var
  Claims: TJwtClaims;
begin
  Claims := nil;
  try
    Result := TryParseToken(Trim(AToken), Claims, AExpired);
  finally
    Claims.Free;
  end;
end;

function TJwtService.ExtractClaims(
  const AToken: string): TJwtClaims;
var
  Expired: Boolean;
begin
  Result := nil;
  if not TryParseToken(Trim(AToken), Result, Expired) then
  begin
    if Expired then
      raise EJwtExpiredException.Create('Token expired.');
    raise EJwtValidationException.Create('Invalid token.');
  end;
end;

function TJwtService.ExtractUserId(const AToken: string): Integer;
var
  Claims: TJwtClaims;
begin
  Claims := ExtractClaims(AToken);
  try
    Result := Claims.UserId;
  finally
    Claims.Free;
  end;
end;

function TJwtService.ExtractUserName(const AToken: string): string;
var
  Claims: TJwtClaims;
begin
  Claims := ExtractClaims(AToken);
  try
    Result := Claims.UserName;
  finally
    Claims.Free;
  end;
end;

function TJwtService.ExtractRole(const AToken: string): string;
var
  Claims: TJwtClaims;
begin
  Claims := ExtractClaims(AToken);
  try
    Result := Claims.Role;
  finally
    Claims.Free;
  end;
end;

end.
