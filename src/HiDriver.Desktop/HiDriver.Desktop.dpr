program HiDriverDesktop;

uses
  Vcl.Forms,
  LoginForm in 'Forms\LoginForm.pas' {LoginForm},
  MainForm in 'Forms\MainForm.pas' {MainForm},
  IDesktopConfig in 'Config\Interfaces\IDesktopConfig.pas',
  DesktopConfig in 'Config\Implementations\DesktopConfig.pas',
  IUserSession in 'Session\Interfaces\IUserSession.pas',
  UserSession in 'Session\Implementations\UserSession.pas',
  IApiClient in 'ApiClient\Interfaces\IApiClient.pas',
  ApiClient in 'ApiClient\Implementations\ApiClient.pas',
  IAuthDesktopService in 'Services\Interfaces\IAuthDesktopService.pas',
  AuthDesktopService in 'Services\Implementations\AuthDesktopService.pas';

var
  ApiClientInstance: IApiClientContract;
  AuthService: IAuthDesktopServiceContract;
  Config: IDesktopConfigContract;
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

  Application.CreateForm(TLoginForm, LoginWindow);
  LoginWindow.Initialize(
    ApiClientInstance,
    AuthService,
    UserSessionInstance);
  Application.Run;
end.
