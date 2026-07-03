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
  end;

implementation

uses
  System.SysUtils;

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
