unit ApiConfig;

interface

uses
  ApiConfigIntf;

type
  TApiConfig = class(TInterfacedObject, IApiConfig)
  public
    function GetApplicationName: string;
    function GetVersion: string;
    function GetEnvironment: string;
    function GetDefaultPort: Integer;
    function GetDatabasePath: string;
    function GetJwtSecret: string;
    function GetJwtIssuer: string;
    function GetJwtAudience: string;
    function GetJwtExpirationMinutes: Integer;
  end;

implementation

uses
  System.SysUtils;

const
  DefaultJwtSecret =
    'HiDriver-Development-JWT-Secret-2026-Change-In-Production';
  DefaultJwtIssuer = 'HiDriver.Api';
  DefaultJwtAudience = 'HiDriver.Clients';
  DefaultJwtExpirationMinutes = 60;

function EnvironmentValueOrDefault(
  const AName,
  ADefault: string): string;
begin
  Result := Trim(GetEnvironmentVariable(AName));
  if Result = '' then
    Result := ADefault;
end;

function TApiConfig.GetApplicationName: string;
begin
  Result := 'HiDriver API';
end;

function TApiConfig.GetVersion: string;
begin
  Result := '0.1.0';
end;

function TApiConfig.GetEnvironment: string;
begin
  Result := 'Development';
end;

function TApiConfig.GetDefaultPort: Integer;
begin
  Result := 9000;
end;

function TApiConfig.GetJwtSecret: string;
begin
  Result := EnvironmentValueOrDefault(
    'HIDRIVER_JWT_SECRET',
    DefaultJwtSecret);
end;

function TApiConfig.GetJwtIssuer: string;
begin
  Result := EnvironmentValueOrDefault(
    'HIDRIVER_JWT_ISSUER',
    DefaultJwtIssuer);
end;

function TApiConfig.GetJwtAudience: string;
begin
  Result := EnvironmentValueOrDefault(
    'HIDRIVER_JWT_AUDIENCE',
    DefaultJwtAudience);
end;

function TApiConfig.GetJwtExpirationMinutes: Integer;
var
  Value: string;
begin
  Value := Trim(GetEnvironmentVariable(
    'HIDRIVER_JWT_EXPIRATION_MINUTES'));
  if not TryStrToInt(Value, Result) or (Result <= 0) then
    Result := DefaultJwtExpirationMinutes;
end;

function TApiConfig.GetDatabasePath: string;
var
  BasePath: string;
  ParentPath: string;
begin
  BasePath := ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));

  while BasePath <> '' do
  begin
    if DirectoryExists(
      IncludeTrailingPathDelimiter(BasePath) + 'database\scripts') then
    begin
      Result := IncludeTrailingPathDelimiter(BasePath) +
        'database\sqlite\hidriver.db';
      Exit;
    end;

    ParentPath := ExtractFileDir(BasePath);
    if SameText(ParentPath, BasePath) then
      Break;

    BasePath := ParentPath;
  end;

  Result := ExpandFileName(
    IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    '..\..\database\sqlite\hidriver.db');
end;

end.
