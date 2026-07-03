unit AppBootstrap;

interface

uses
  ApiConfigIntf,
  AppBootstrapIntf;

type
  TAppBootstrap = class(TInterfacedObject, IAppBootstrap)
  private
    FConfig: IApiConfig;
  public
    constructor Create(const AConfig: IApiConfig);
    procedure Execute;
  end;

implementation

uses
  Horse,
  DatabaseConnectionIntf,
  DatabaseConnection,
  DatabaseInitializerIntf,
  DatabaseInitializer,
  HealthControllerIntf,
  HealthController;

constructor TAppBootstrap.Create(const AConfig: IApiConfig);
begin
  inherited Create;
  FConfig := AConfig;
end;

procedure TAppBootstrap.Execute;
var
  DatabaseConnection: IDatabaseConnection;
  DatabaseInitializer: IDatabaseInitializer;
  HealthController: IHealthController;
begin
  HealthController := THealthController.Create(FConfig);
  HealthController.RegisterRoutes;

  Writeln(FConfig.ApplicationName);
  Writeln('Version: ' + FConfig.Version);
  Writeln('Environment: ' + FConfig.Environment);
  Writeln('Default Port: ', FConfig.DefaultPort);
  Writeln('Status: Starting...');

  DatabaseConnection := TDatabaseConnection.Create(FConfig);
  DatabaseInitializer := TDatabaseInitializer.Create(
    DatabaseConnection,
    FConfig);
  DatabaseInitializer.Initialize;

  Writeln('Database: SQLite');
  Writeln('Database Status: Ready');

  THorse.Listen(FConfig.DefaultPort,
    procedure
    begin
      Writeln('Server running at: http://localhost:', FConfig.DefaultPort);
      Writeln('Health check: http://localhost:', FConfig.DefaultPort, '/api/health');
    end);
end;

end.
