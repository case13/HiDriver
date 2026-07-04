unit ApiClient;

interface

uses
  System.Net.HttpClient,
  System.Net.URLClient,
  IApiClient,
  IDesktopConfig;

type
  TApiClient = class(TInterfacedObject, IApiClientContract)
  private
    FBaseApiUrl: string;
    FBearerToken: string;
    FHttpClient: THTTPClient;
    FLastStatusCode: Integer;
    FLastError: string;
    function BuildHeaders: TNetHeaders;
    function BuildUrl(const APath: string): string;
    function ExtractErrorMessage(const AResponseBody: string): string;
    function HandleResponse(const AResponse: IHTTPResponse): string;
    function HandleRequestException: string;
    function GetLastStatusCode: Integer;
    function GetLastError: string;
  public
    constructor Create(const AConfig: IDesktopConfigContract);
    destructor Destroy; override;
    function Get(const APath: string): string;
    function Post(const APath, AJsonBody: string): string;
    function Put(const APath, AJsonBody: string): string;
    function Delete(const APath: string): string;
    procedure SetBearerToken(const AToken: string);
    procedure ClearBearerToken;
  end;

implementation

uses
  System.Classes,
  System.JSON,
  System.SysUtils;

constructor TApiClient.Create(const AConfig: IDesktopConfigContract);
begin
  inherited Create;
  if not Assigned(AConfig) then
    raise EArgumentNilException.Create('Desktop configuration is required.');

  FBaseApiUrl := AConfig.BaseApiUrl;
  FHttpClient := THTTPClient.Create;
  FHttpClient.ConnectionTimeout := 5000;
  FHttpClient.ResponseTimeout := 15000;
end;

destructor TApiClient.Destroy;
begin
  FHttpClient.Free;
  inherited;
end;

function TApiClient.BuildHeaders: TNetHeaders;
var
  HeaderCount: Integer;
begin
  HeaderCount := 2;
  if FBearerToken <> '' then
    Inc(HeaderCount);

  SetLength(Result, HeaderCount);
  Result[0] := TNetHeader.Create('Accept', 'application/json');
  Result[1] := TNetHeader.Create('Content-Type', 'application/json; charset=utf-8');
  if FBearerToken <> '' then
    Result[2] := TNetHeader.Create(
      'Authorization',
      'Bearer ' + FBearerToken);
end;

function TApiClient.BuildUrl(const APath: string): string;
var
  NormalizedPath: string;
begin
  NormalizedPath := Trim(APath);
  if not NormalizedPath.StartsWith('/') then
    NormalizedPath := '/' + NormalizedPath;
  Result := FBaseApiUrl + NormalizedPath;
end;

procedure TApiClient.ClearBearerToken;
begin
  FBearerToken := '';
end;

function TApiClient.Delete(const APath: string): string;
begin
  try
    Result := HandleResponse(
      FHttpClient.Delete(BuildUrl(APath), nil, BuildHeaders));
  except
    Result := HandleRequestException;
  end;
end;

function TApiClient.ExtractErrorMessage(
  const AResponseBody: string): string;
var
  ErrorValue: TJSONValue;
  JsonObject: TJSONObject;
  RootValue: TJSONValue;
begin
  Result := '';
  RootValue := TJSONObject.ParseJSONValue(AResponseBody);
  try
    if RootValue is TJSONObject then
    begin
      JsonObject := TJSONObject(RootValue);
      ErrorValue := JsonObject.GetValue('message');
      if Assigned(ErrorValue) then
        Result := Trim(ErrorValue.Value);
    end;
  finally
    RootValue.Free;
  end;
end;

function TApiClient.Get(const APath: string): string;
begin
  try
    Result := HandleResponse(
      FHttpClient.Get(BuildUrl(APath), nil, BuildHeaders));
  except
    Result := HandleRequestException;
  end;
end;

function TApiClient.GetLastError: string;
begin
  Result := FLastError;
end;

function TApiClient.GetLastStatusCode: Integer;
begin
  Result := FLastStatusCode;
end;

function TApiClient.HandleRequestException: string;
begin
  FLastStatusCode := 0;
  FLastError :=
    'Unable to connect to the API. Check whether the server is running.';
  Result := '';
end;

function TApiClient.HandleResponse(
  const AResponse: IHTTPResponse): string;
begin
  FLastStatusCode := AResponse.StatusCode;
  Result := AResponse.ContentAsString(TEncoding.UTF8);

  if (FLastStatusCode >= 200) and (FLastStatusCode < 300) then
  begin
    FLastError := '';
    Exit;
  end;

  if FLastStatusCode = 401 then
  begin
    FLastError := ExtractErrorMessage(Result);
    if FLastError = '' then
      FLastError := 'Unauthorized. Please sign in again.';
    Exit;
  end;

  FLastError := ExtractErrorMessage(Result);
  if FLastError = '' then
    FLastError := Format('The API returned HTTP status %d.',
      [FLastStatusCode]);
end;

function TApiClient.Post(
  const APath, AJsonBody: string): string;
var
  Body: TStringStream;
begin
  Body := TStringStream.Create(AJsonBody, TEncoding.UTF8);
  try
    try
      Result := HandleResponse(
        FHttpClient.Post(BuildUrl(APath), Body, nil, BuildHeaders));
    except
      Result := HandleRequestException;
    end;
  finally
    Body.Free;
  end;
end;

function TApiClient.Put(
  const APath, AJsonBody: string): string;
var
  Body: TStringStream;
begin
  Body := TStringStream.Create(AJsonBody, TEncoding.UTF8);
  try
    try
      Result := HandleResponse(
        FHttpClient.Put(BuildUrl(APath), Body, nil, BuildHeaders));
    except
      Result := HandleRequestException;
    end;
  finally
    Body.Free;
  end;
end;

procedure TApiClient.SetBearerToken(const AToken: string);
begin
  FBearerToken := Trim(AToken);
end;

end.
