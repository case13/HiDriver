program HiDriverDesktop;

uses
  Vcl.Forms,
  LoginForm in 'Forms\LoginForm.pas' {LoginForm},
  MainForm in 'Forms\MainForm.pas' {MainForm},
  vwCustomerConsult in 'Forms\Customers\vwCustomerConsult.pas' {fvwCustomerConsult},
  vwCustomerSave in 'Forms\Customers\vwCustomerSave.pas' {fvwCustomerSave},
  vwProductConsult in 'Forms\Products\vwProductConsult.pas' {fvwProductConsult},
  vwProductSave in 'Forms\Products\vwProductSave.pas' {fvwProductSave},
  IDesktopConfig in 'Config\Interfaces\IDesktopConfig.pas',
  DesktopConfig in 'Config\Implementations\DesktopConfig.pas',
  IUserSession in 'Session\Interfaces\IUserSession.pas',
  UserSession in 'Session\Implementations\UserSession.pas',
  IApiClient in 'ApiClient\Interfaces\IApiClient.pas',
  ApiClient in 'ApiClient\Implementations\ApiClient.pas',
  IAuthDesktopService in 'Services\Interfaces\IAuthDesktopService.pas',
  AuthDesktopService in 'Services\Implementations\AuthDesktopService.pas',
  CustomerDto in 'DTOs\Customers\CustomerDto.pas',
  CustomerSaveRequestDto in 'DTOs\Customers\CustomerSaveRequestDto.pas',
  ICustomerDesktopService in 'Services\Interfaces\ICustomerDesktopService.pas',
  CustomerDesktopService in 'Services\Implementations\CustomerDesktopService.pas',
  ProductDto in 'DTOs\Products\ProductDto.pas',
  ProductSaveRequestDto in 'DTOs\Products\ProductSaveRequestDto.pas',
  IProductDesktopService in 'Services\Interfaces\IProductDesktopService.pas',
  ProductDesktopService in 'Services\Implementations\ProductDesktopService.pas';

var
  ApiClientInstance: IApiClientContract;
  AuthService: IAuthDesktopServiceContract;
  Config: IDesktopConfigContract;
  CustomerService: ICustomerDesktopServiceContract;
  ProductService: IProductDesktopServiceContract;
  UserSessionInstance: IUserSessionContract;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'HiDriver Desktop';

  Config := TDesktopConfig.Create;
  UserSessionInstance := TUserSession.Create;
  ApiClientInstance := TApiClient.Create(Config);
  AuthService := TAuthDesktopService.Create(
    ApiClientInstance,
    UserSessionInstance);
  CustomerService := TCustomerDesktopService.Create(ApiClientInstance);
  ProductService := TProductDesktopService.Create(ApiClientInstance);

  Application.CreateForm(TLoginForm, LoginWindow);
  LoginWindow.Initialize(
    ApiClientInstance,
    AuthService,
    CustomerService,
    ProductService,
    UserSessionInstance);
  Application.Run;
end.
