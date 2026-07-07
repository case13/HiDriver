unit LoginForm;

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  IApiClient,
  IAuthDesktopService,
  ICustomerDesktopService,
  IProductDesktopService,
  IUserSession;

type
  TLoginForm = class(TForm)
    lblTitle: TLabel;
    lblSubtitle: TLabel;
    lblUserName: TLabel;
    edtUserName: TEdit;
    lblPassword: TLabel;
    edtPassword: TEdit;
    btnLogin: TButton;
    btnTestApi: TButton;
    btnExit: TButton;
    lblHint: TLabel;
    procedure btnExitClick(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure btnTestApiClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    FApiClient: IApiClientContract;
    FAuthService: IAuthDesktopServiceContract;
    FCustomerService: ICustomerDesktopServiceContract;
    FProductService: IProductDesktopServiceContract;
    FUserSession: IUserSessionContract;
    procedure ShowMainForm;
  public
    procedure Initialize(
      const AApiClient: IApiClientContract;
      const AAuthService: IAuthDesktopServiceContract;
      const ACustomerService: ICustomerDesktopServiceContract;
      const AProductService: IProductDesktopServiceContract;
      const AUserSession: IUserSessionContract);
  end;

var
  LoginWindow: TLoginForm;

implementation

{$R *.dfm}

uses
  System.SysUtils,
  Vcl.Dialogs,
  MainForm;

procedure TLoginForm.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TLoginForm.btnLoginClick(Sender: TObject);
begin
  if Trim(edtUserName.Text) = '' then
  begin
    ShowMessage('Enter your username.');
    edtUserName.SetFocus;
    Exit;
  end;

  if edtPassword.Text = '' then
  begin
    ShowMessage('Enter your password.');
    edtPassword.SetFocus;
    Exit;
  end;

  btnLogin.Enabled := False;
  try
    if not FAuthService.Login(edtUserName.Text, edtPassword.Text) then
    begin
      ShowMessage(FAuthService.LastError);
      edtPassword.Clear;
      edtPassword.SetFocus;
      Exit;
    end;

    edtPassword.Clear;
    ShowMainForm;
  finally
    btnLogin.Enabled := True;
  end;
end;

procedure TLoginForm.btnTestApiClick(Sender: TObject);
begin
  btnTestApi.Enabled := False;
  try
    FApiClient.Get('/api/health');
    if (FApiClient.LastStatusCode >= 200) and
      (FApiClient.LastStatusCode < 300) then
      ShowMessage('The HiDriver API is online and healthy.')
    else
      ShowMessage(FApiClient.LastError);
  finally
    btnTestApi.Enabled := True;
  end;
end;

procedure TLoginForm.FormClose(
  Sender: TObject;
  var Action: TCloseAction);
begin
  if Assigned(FAuthService) then
    FAuthService.Logout;
end;

procedure TLoginForm.FormShow(Sender: TObject);
begin
  if edtUserName.Text = '' then
    edtUserName.SetFocus
  else
    edtPassword.SetFocus;
end;

procedure TLoginForm.Initialize(
  const AApiClient: IApiClientContract;
  const AAuthService: IAuthDesktopServiceContract;
  const ACustomerService: ICustomerDesktopServiceContract;
  const AProductService: IProductDesktopServiceContract;
  const AUserSession: IUserSessionContract);
begin
  FApiClient := AApiClient;
  FAuthService := AAuthService;
  FCustomerService := ACustomerService;
  FProductService := AProductService;
  FUserSession := AUserSession;
end;

procedure TLoginForm.ShowMainForm;
var
  DesktopMainForm: TMainForm;
begin
  Hide;
  DesktopMainForm := TMainForm.Create(Application);
  try
    DesktopMainForm.Initialize(
      FApiClient,
      FAuthService,
      FCustomerService,
      FProductService,
      FUserSession);
    DesktopMainForm.ShowModal;
  finally
    DesktopMainForm.Free;
    Show;
  end;
end;

end.
