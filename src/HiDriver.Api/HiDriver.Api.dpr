program HiDriver.Api;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ApiConfigIntf in 'Config\Interfaces\ApiConfigIntf.pas',
  ApiConfig in 'Config\Implementations\ApiConfig.pas',
  AppBootstrapIntf in 'Config\Interfaces\AppBootstrapIntf.pas',
  AppBootstrap in 'Config\Implementations\AppBootstrap.pas',
  HealthControllerIntf in 'Controllers\Interfaces\HealthControllerIntf.pas',
  HealthController in 'Controllers\Implementations\HealthController.pas',
  DatabaseConnectionIntf in 'Data\Connection\Interfaces\DatabaseConnectionIntf.pas',
  DatabaseConnection in 'Data\Connection\Implementations\DatabaseConnection.pas',
  TransactionManagerIntf in 'Data\Transactions\Interfaces\TransactionManagerIntf.pas',
  TransactionManager in 'Data\Transactions\Implementations\TransactionManager.pas',
  DatabaseInitializerIntf in 'Data\Scripts\Interfaces\DatabaseInitializerIntf.pas',
  DatabaseInitializer in 'Data\Scripts\Implementations\DatabaseInitializer.pas';

var
  Config: IApiConfig;
  Bootstrap: IAppBootstrap;

begin
  try
    Config := TApiConfig.Create;
    Bootstrap := TAppBootstrap.Create(Config);
    Bootstrap.Execute;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
