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
  AuthControllerIntf in 'Controllers\Interfaces\AuthControllerIntf.pas',
  AuthController in 'Controllers\Implementations\AuthController.pas',
  ProductControllerIntf in 'Controllers\Interfaces\ProductControllerIntf.pas',
  ProductController in 'Controllers\Implementations\ProductController.pas',
  AuthAppServiceIntf in 'Services\Interfaces\AuthAppServiceIntf.pas',
  AuthAppService in 'Services\Implementations\AuthAppService.pas',
  ProductAppServiceIntf in 'Services\Interfaces\ProductAppServiceIntf.pas',
  ProductAppService in 'Services\Implementations\ProductAppService.pas',
  AuthValidatorIntf in 'Validators\Interfaces\AuthValidatorIntf.pas',
  AuthValidator in 'Validators\Implementations\AuthValidator.pas',
  ProductValidatorIntf in 'Validators\Interfaces\ProductValidatorIntf.pas',
  ProductValidator in 'Validators\Implementations\ProductValidator.pas',
  UserRepositoryIntf in 'Repositories\Interfaces\UserRepositoryIntf.pas',
  UserRepository in 'Repositories\Implementations\UserRepository.pas',
  ProductRepositoryIntf in 'Repositories\Interfaces\ProductRepositoryIntf.pas',
  ProductRepository in 'Repositories\Implementations\ProductRepository.pas',
  User in 'Domain\Entities\User.pas',
  Product in 'Domain\Entities\Product.pas',
  PasswordHasher in 'Utils\PasswordHasher.pas',
  AuthDtos in '..\HiDriver.Shared\DTOs\Auth\AuthDtos.pas',
  ProductDtos in '..\HiDriver.Shared\DTOs\Products\ProductDtos.pas',
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
