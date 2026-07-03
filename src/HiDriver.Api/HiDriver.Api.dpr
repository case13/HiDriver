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
  CustomerControllerIntf in 'Controllers\Interfaces\CustomerControllerIntf.pas',
  CustomerController in 'Controllers\Implementations\CustomerController.pas',
  CashRegisterControllerIntf in 'Controllers\Interfaces\CashRegisterControllerIntf.pas',
  CashRegisterController in 'Controllers\Implementations\CashRegisterController.pas',
  AuthAppServiceIntf in 'Services\Interfaces\AuthAppServiceIntf.pas',
  AuthAppService in 'Services\Implementations\AuthAppService.pas',
  ProductAppServiceIntf in 'Services\Interfaces\ProductAppServiceIntf.pas',
  ProductAppService in 'Services\Implementations\ProductAppService.pas',
  CustomerAppServiceIntf in 'Services\Interfaces\CustomerAppServiceIntf.pas',
  CustomerAppService in 'Services\Implementations\CustomerAppService.pas',
  CashRegisterAppServiceIntf in 'Services\Interfaces\CashRegisterAppServiceIntf.pas',
  CashRegisterAppService in 'Services\Implementations\CashRegisterAppService.pas',
  AuthValidatorIntf in 'Validators\Interfaces\AuthValidatorIntf.pas',
  AuthValidator in 'Validators\Implementations\AuthValidator.pas',
  ProductValidatorIntf in 'Validators\Interfaces\ProductValidatorIntf.pas',
  ProductValidator in 'Validators\Implementations\ProductValidator.pas',
  CustomerValidatorIntf in 'Validators\Interfaces\CustomerValidatorIntf.pas',
  CustomerValidator in 'Validators\Implementations\CustomerValidator.pas',
  CashRegisterValidatorIntf in 'Validators\Interfaces\CashRegisterValidatorIntf.pas',
  CashRegisterValidator in 'Validators\Implementations\CashRegisterValidator.pas',
  UserRepositoryIntf in 'Repositories\Interfaces\UserRepositoryIntf.pas',
  UserRepository in 'Repositories\Implementations\UserRepository.pas',
  ProductRepositoryIntf in 'Repositories\Interfaces\ProductRepositoryIntf.pas',
  ProductRepository in 'Repositories\Implementations\ProductRepository.pas',
  CustomerRepositoryIntf in 'Repositories\Interfaces\CustomerRepositoryIntf.pas',
  CustomerRepository in 'Repositories\Implementations\CustomerRepository.pas',
  CashRegisterRepositoryIntf in 'Repositories\Interfaces\CashRegisterRepositoryIntf.pas',
  CashRegisterRepository in 'Repositories\Implementations\CashRegisterRepository.pas',
  CashMovementRepositoryIntf in 'Repositories\Interfaces\CashMovementRepositoryIntf.pas',
  CashMovementRepository in 'Repositories\Implementations\CashMovementRepository.pas',
  User in 'Domain\Entities\User.pas',
  Product in 'Domain\Entities\Product.pas',
  Customer in 'Domain\Entities\Customer.pas',
  CashRegister in 'Domain\Entities\CashRegister.pas',
  CashMovement in 'Domain\Entities\CashMovement.pas',
  CashRegisterDomainServiceIntf in 'Domain\Services\Interfaces\CashRegisterDomainServiceIntf.pas',
  CashRegisterDomainService in 'Domain\Services\Implementations\CashRegisterDomainService.pas',
  PasswordHasher in 'Utils\PasswordHasher.pas',
  AuthDtos in '..\HiDriver.Shared\DTOs\Auth\AuthDtos.pas',
  ProductDtos in '..\HiDriver.Shared\DTOs\Products\ProductDtos.pas',
  CustomerDtos in '..\HiDriver.Shared\DTOs\Customers\CustomerDtos.pas',
  CashRegisterDtos in '..\HiDriver.Shared\DTOs\CashRegister\CashRegisterDtos.pas',
  CashRegisterStatusEnum in '..\HiDriver.Shared\Enums\CashRegisterStatusEnum.pas',
  CashMovementTypeEnum in '..\HiDriver.Shared\Enums\CashMovementTypeEnum.pas',
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
