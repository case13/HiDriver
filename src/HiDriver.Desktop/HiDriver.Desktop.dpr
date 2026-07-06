program HiDriverDesktop;

uses
  Vcl.Forms,
  LoginForm in 'Forms\LoginForm.pas' {LoginForm},
  MainForm in 'Forms\MainForm.pas' {MainForm},
  ProductsListForm in 'Forms\ProductsListForm.pas' {ProductsListForm},
  IDesktopConfig in 'Config\Interfaces\IDesktopConfig.pas',
  DesktopConfig in 'Config\Implementations\DesktopConfig.pas',
  IUserSession in 'Session\Interfaces\IUserSession.pas',
  UserSession in 'Session\Implementations\UserSession.pas',
  IApiClient in 'ApiClient\Interfaces\IApiClient.pas',
  ApiClient in 'ApiClient\Implementations\ApiClient.pas',
  IAuthDesktopService in 'Services\Interfaces\IAuthDesktopService.pas',
  AuthDesktopService in 'Services\Implementations\AuthDesktopService.pas',
  ProductDto in 'DTOs\Products\ProductDto.pas',
  IProductDesktopService in 'Services\Interfaces\IProductDesktopService.pas',
  ProductDesktopService in 'Services\Implementations\ProductDesktopService.pas';

var
  ApiClientInstance: IApiClientContract;
  AuthService: IAuthDesktopServiceContract;
  Config: IDesktopConfigContract;
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
  ProductService := TProductDesktopService.Create(ApiClientInstance);

  Application.CreateForm(TLoginForm, LoginWindow);
  LoginWindow.Initialize(
    ApiClientInstance,
    AuthService,
    ProductService,
    UserSessionInstance);
  Application.Run;
end.
