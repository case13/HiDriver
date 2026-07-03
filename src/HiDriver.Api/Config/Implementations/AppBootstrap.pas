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
  HealthController,
  AuthControllerIntf,
  AuthController,
  AuthAppServiceIntf,
  AuthAppService,
  AuthValidatorIntf,
  AuthValidator,
  UserRepositoryIntf,
  UserRepository;

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
  UserRepository: IUserRepository;
  AuthValidator: IAuthValidator;
  AuthAppService: IAuthAppService;
  AuthController: IAuthController;
begin
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

  HealthController := THealthController.Create(FConfig);
  HealthController.RegisterRoutes;

  UserRepository := TUserRepository.Create(DatabaseConnection);
  AuthValidator := TAuthValidator.Create;
  AuthAppService := TAuthAppService.Create(UserRepository, AuthValidator);
  AuthController := TAuthController.Create(AuthAppService);
  AuthController.RegisterRoutes;

  THorse.Listen(FConfig.DefaultPort,
    procedure
    begin
      Writeln('Server running at: http://localhost:', FConfig.DefaultPort);
      Writeln('Health check: http://localhost:', FConfig.DefaultPort, '/api/health');
      Writeln('Auth endpoint: http://localhost:', FConfig.DefaultPort,
        '/api/auth/login');
    end);
end;

end.
