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
    function GetInitialScriptPath: string;
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
  FireDAC.Comp.ScriptCommands;

constructor TDatabaseInitializer.Create(
  const ADatabaseConnection: IDatabaseConnection;
  const AConfig: IApiConfig);
begin
  inherited Create;
  FDatabaseConnection := ADatabaseConnection;
  FConfig := AConfig;
end;

function TDatabaseInitializer.GetInitialScriptPath: string;
var
  DatabaseDirectory: string;
  DatabaseRoot: string;
begin
  DatabaseDirectory := ExtractFileDir(FConfig.DatabasePath);
  DatabaseRoot := ExtractFileDir(DatabaseDirectory);
  Result := IncludeTrailingPathDelimiter(DatabaseRoot) +
    'scripts\001_create_schema_version.sql';
end;

procedure TDatabaseInitializer.Initialize;
var
  DatabaseDirectory: string;
  Script: TFDScript;
  ScriptPath: string;
begin
  DatabaseDirectory := ExtractFileDir(FConfig.DatabasePath);
  if not DirectoryExists(DatabaseDirectory) and
    not ForceDirectories(DatabaseDirectory) then
    raise Exception.CreateFmt(
      'Unable to create database directory: %s',
      [DatabaseDirectory]);

  ScriptPath := GetInitialScriptPath;
  if not FileExists(ScriptPath) then
    raise Exception.CreateFmt(
      'Database initialization script not found: %s',
      [ScriptPath]);

  FDatabaseConnection.Connect;

  Script := TFDScript.Create(nil);
  try
    Script.Connection := FDatabaseConnection.Connection;
    Script.SQLScriptFileName := ScriptPath;
    Script.ValidateAll;
    Script.ExecuteAll;
  finally
    Script.Free;
  end;
end;

end.
