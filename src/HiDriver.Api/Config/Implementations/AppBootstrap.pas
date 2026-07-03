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
  UserRepository,
  ProductControllerIntf,
  ProductController,
  ProductAppServiceIntf,
  ProductAppService,
  ProductValidatorIntf,
  ProductValidator,
  ProductRepositoryIntf,
  ProductRepository,
  CustomerControllerIntf,
  CustomerController,
  CustomerAppServiceIntf,
  CustomerAppService,
  CustomerValidatorIntf,
  CustomerValidator,
  CustomerRepositoryIntf,
  CustomerRepository,
  CashRegisterControllerIntf,
  CashRegisterController,
  CashRegisterAppServiceIntf,
  CashRegisterAppService,
  CashRegisterValidatorIntf,
  CashRegisterValidator,
  CashRegisterDomainServiceIntf,
  CashRegisterDomainService,
  CashRegisterRepositoryIntf,
  CashRegisterRepository,
  CashMovementRepositoryIntf,
  CashMovementRepository,
  TransactionManagerIntf,
  TransactionManager,
  SaleControllerIntf,
  SaleController,
  SaleAppServiceIntf,
  SaleAppService,
  SaleValidatorIntf,
  SaleValidator,
  SaleDomainServiceIntf,
  SaleDomainService,
  SaleRepositoryIntf,
  SaleRepository,
  SaleItemRepositoryIntf,
  SaleItemRepository,
  SalePaymentRepositoryIntf,
  SalePaymentRepository,
  AccountReceivableControllerIntf,
  AccountReceivableController,
  AccountReceivableAppServiceIntf,
  AccountReceivableAppService,
  AccountReceivableValidatorIntf,
  AccountReceivableValidator,
  AccountReceivableDomainServiceIntf,
  AccountReceivableDomainService,
  AccountReceivableRepositoryIntf,
  AccountReceivableRepository,
  StockMovementControllerIntf,
  StockMovementController,
  StockMovementAppServiceIntf,
  StockMovementAppService,
  StockMovementValidatorIntf,
  StockMovementValidator,
  StockMovementDomainServiceIntf,
  StockMovementDomainService,
  StockMovementRepositoryIntf,
  StockMovementRepository;

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
  ProductRepository: IProductRepository;
  ProductValidator: IProductValidator;
  ProductAppService: IProductAppService;
  ProductController: IProductController;
  CustomerRepository: ICustomerRepository;
  CustomerValidator: ICustomerValidator;
  CustomerAppService: ICustomerAppService;
  CustomerController: ICustomerController;
  CashRegisterRepository: ICashRegisterRepository;
  CashMovementRepository: ICashMovementRepository;
  CashRegisterValidator: ICashRegisterValidator;
  CashRegisterDomainService: ICashRegisterDomainService;
  CashRegisterAppService: ICashRegisterAppService;
  CashRegisterController: ICashRegisterController;
  TransactionManager: ITransactionManager;
  SaleRepository: ISaleRepository;
  SaleItemRepository: ISaleItemRepository;
  SalePaymentRepository: ISalePaymentRepository;
  SaleValidator: ISaleValidator;
  SaleDomainService: ISaleDomainService;
  SaleAppService: ISaleAppService;
  SaleController: ISaleController;
  AccountReceivableRepository: IAccountReceivableRepository;
  AccountReceivableValidator: IAccountReceivableValidator;
  AccountReceivableDomainService: IAccountReceivableDomainService;
  AccountReceivableAppService: IAccountReceivableAppService;
  AccountReceivableController: IAccountReceivableController;
  StockMovementRepository: IStockMovementRepository;
  StockMovementValidator: IStockMovementValidator;
  StockMovementDomainService: IStockMovementDomainService;
  StockMovementAppService: IStockMovementAppService;
  StockMovementController: IStockMovementController;
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

  ProductRepository := TProductRepository.Create(DatabaseConnection);
  ProductValidator := TProductValidator.Create;
  ProductAppService := TProductAppService.Create(
    ProductRepository,
    ProductValidator);
  ProductController := TProductController.Create(ProductAppService);
  ProductController.RegisterRoutes;

  CustomerRepository := TCustomerRepository.Create(DatabaseConnection);
  CustomerValidator := TCustomerValidator.Create;
  CustomerAppService := TCustomerAppService.Create(
    CustomerRepository,
    CustomerValidator);
  CustomerController := TCustomerController.Create(CustomerAppService);
  CustomerController.RegisterRoutes;

  CashRegisterRepository :=
    TCashRegisterRepository.Create(DatabaseConnection);
  CashMovementRepository :=
    TCashMovementRepository.Create(DatabaseConnection);
  CashRegisterValidator := TCashRegisterValidator.Create;
  CashRegisterDomainService := TCashRegisterDomainService.Create;
  TransactionManager := TTransactionManager.Create(DatabaseConnection);
  CashRegisterAppService := TCashRegisterAppService.Create(
    CashRegisterRepository,
    CashMovementRepository,
    CashRegisterValidator,
    CashRegisterDomainService,
    TransactionManager);
  CashRegisterController :=
    TCashRegisterController.Create(CashRegisterAppService);
  CashRegisterController.RegisterRoutes;

  AccountReceivableRepository :=
    TAccountReceivableRepository.Create(DatabaseConnection);
  AccountReceivableValidator :=
    TAccountReceivableValidator.Create;
  AccountReceivableDomainService :=
    TAccountReceivableDomainService.Create;
  AccountReceivableAppService :=
    TAccountReceivableAppService.Create(
      AccountReceivableRepository,
      AccountReceivableValidator,
      AccountReceivableDomainService,
      CashRegisterRepository,
      CashMovementRepository,
      CustomerRepository,
      TransactionManager);
  AccountReceivableController :=
    TAccountReceivableController.Create(
      AccountReceivableAppService);
  AccountReceivableController.RegisterRoutes;

  StockMovementRepository :=
    TStockMovementRepository.Create(DatabaseConnection);
  StockMovementValidator := TStockMovementValidator.Create;
  StockMovementDomainService :=
    TStockMovementDomainService.Create;
  StockMovementAppService := TStockMovementAppService.Create(
    StockMovementRepository,
    StockMovementValidator,
    StockMovementDomainService,
    ProductRepository,
    TransactionManager);
  StockMovementController :=
    TStockMovementController.Create(StockMovementAppService);
  StockMovementController.RegisterRoutes;

  SaleRepository := TSaleRepository.Create(DatabaseConnection);
  SaleItemRepository := TSaleItemRepository.Create(DatabaseConnection);
  SalePaymentRepository := TSalePaymentRepository.Create(DatabaseConnection);
  SaleValidator := TSaleValidator.Create;
  SaleDomainService := TSaleDomainService.Create;
  SaleAppService := TSaleAppService.Create(
    SaleRepository,
    SaleItemRepository,
    SalePaymentRepository,
    ProductRepository,
    CustomerRepository,
    CashRegisterRepository,
    CashMovementRepository,
    SaleValidator,
    SaleDomainService,
    TransactionManager,
    AccountReceivableAppService,
    StockMovementAppService);
  SaleController := TSaleController.Create(SaleAppService);
  SaleController.RegisterRoutes;

  THorse.Listen(FConfig.DefaultPort,
    procedure
    begin
      Writeln('Server running at: http://localhost:', FConfig.DefaultPort);
      Writeln('Health check: http://localhost:', FConfig.DefaultPort, '/api/health');
      Writeln('Auth endpoint: http://localhost:', FConfig.DefaultPort,
        '/api/auth/login');
      Writeln('Products endpoint: http://localhost:', FConfig.DefaultPort,
        '/api/products');
      Writeln('Customers endpoint: http://localhost:', FConfig.DefaultPort,
        '/api/customers');
      Writeln('Cash endpoint: http://localhost:', FConfig.DefaultPort,
        '/api/cash/current');
      Writeln('Sales endpoint: http://localhost:', FConfig.DefaultPort,
        '/api/sales');
      Writeln('Accounts receivable endpoint: http://localhost:',
        FConfig.DefaultPort, '/api/accounts-receivable');
      Writeln('Stock movements endpoint: http://localhost:',
        FConfig.DefaultPort, '/api/stock-movements');
    end);
end;

end.
