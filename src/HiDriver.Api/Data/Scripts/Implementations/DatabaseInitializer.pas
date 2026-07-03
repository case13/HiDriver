unit DatabaseInitializer;

interface

uses
  ApiConfigIntf,
  DatabaseConnectionIntf,
  DatabaseInitializerIntf;

type
  TDatabaseInitializer = class(TInterfacedObject, IDatabaseInitializer)
  private
    FDatabaseConnection: IDatabaseConnection;
    FConfig: IApiConfig;
    function GetScriptPath(const AFileName: string): string;
    procedure ExecuteScript(const AScriptPath: string);
  public
    constructor Create(
      const ADatabaseConnection: IDatabaseConnection;
      const AConfig: IApiConfig);
    procedure Initialize;
  end;

implementation

uses
  System.SysUtils,
  FireDAC.Comp.Script,
  FireDAC.Comp.ScriptCommands,
  FireDAC.Stan.Intf;

constructor TDatabaseInitializer.Create(
  const ADatabaseConnection: IDatabaseConnection;
  const AConfig: IApiConfig);
begin
  inherited Create;
  FDatabaseConnection := ADatabaseConnection;
  FConfig := AConfig;
end;

function TDatabaseInitializer.GetScriptPath(
  const AFileName: string): string;
var
  DatabaseDirectory: string;
  DatabaseRoot: string;
begin
  DatabaseDirectory := ExtractFileDir(FConfig.DatabasePath);
  DatabaseRoot := ExtractFileDir(DatabaseDirectory);
  Result := IncludeTrailingPathDelimiter(DatabaseRoot) +
    'scripts\' + AFileName;
end;

procedure TDatabaseInitializer.ExecuteScript(const AScriptPath: string);
var
  Script: TFDScript;
begin
  if not FileExists(AScriptPath) then
    raise Exception.CreateFmt(
      'Database initialization script not found: %s',
      [AScriptPath]);

  Script := TFDScript.Create(nil);
  try
    Script.Connection := FDatabaseConnection.Connection;
    Script.ScriptOptions.FileEncoding := ecUTF8;
    Script.SQLScriptFileName := AScriptPath;
    Script.ValidateAll;
    Script.ExecuteAll;
  finally
    Script.Free;
  end;
end;

procedure TDatabaseInitializer.Initialize;
var
  DatabaseDirectory: string;
begin
  DatabaseDirectory := ExtractFileDir(FConfig.DatabasePath);
  if not DirectoryExists(DatabaseDirectory) and
    not ForceDirectories(DatabaseDirectory) then
    raise Exception.CreateFmt(
      'Unable to create database directory: %s',
      [DatabaseDirectory]);

  FDatabaseConnection.Connect;
  ExecuteScript(GetScriptPath('001_create_schema_version.sql'));
  ExecuteScript(GetScriptPath('002_create_users.sql'));
  ExecuteScript(GetScriptPath('003_create_products.sql'));
  ExecuteScript(GetScriptPath('004_create_customers.sql'));
  ExecuteScript(GetScriptPath('005_create_cash_register.sql'));
end;

end.
