unit MainForm;

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  IApiClient,
  IAuthDesktopService,
  IProductDesktopService,
  IUserSession;

type
  TMainForm = class(TForm)
    lblTitle: TLabel;
    lblWelcome: TLabel;
    lblRole: TLabel;
    btnProtectedRequest: TButton;
    btnProducts: TButton;
    btnLogout: TButton;
    lblResult: TLabel;
    mmResult: TMemo;
    procedure btnLogoutClick(Sender: TObject);
    procedure btnProductsClick(Sender: TObject);
    procedure btnProtectedRequestClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FApiClient: IApiClientContract;
    FAuthService: IAuthDesktopServiceContract;
    FProductService: IProductDesktopServiceContract;
    FUserSession: IUserSessionContract;
    procedure UpdateUserInformation;
  public
    procedure Initialize(
      const AApiClient: IApiClientContract;
      const AAuthService: IAuthDesktopServiceContract;
      const AProductService: IProductDesktopServiceContract;
      const AUserSession: IUserSessionContract);
  end;

implementation

{$R *.dfm}

uses
  System.SysUtils,
  Vcl.Dialogs,
  vwProductConsult;

procedure TMainForm.btnLogoutClick(Sender: TObject);
begin
  FAuthService.Logout;
  ModalResult := mrCancel;
end;

procedure TMainForm.btnProductsClick(Sender: TObject);
var
  ProductsForm: TfvwProductConsult;
begin
  ProductsForm := TfvwProductConsult.Create(Application);
  try
    ProductsForm.Initialize(FProductService);
    ProductsForm.ShowModal;
    if ProductsForm.SessionExpired then
    begin
      FAuthService.Logout;
      ModalResult := mrCancel;
    end;
  finally
    ProductsForm.Free;
  end;
end;

procedure TMainForm.btnProtectedRequestClick(Sender: TObject);
var
  ResponseBody: string;
begin
  btnProtectedRequest.Enabled := False;
  try
    ResponseBody := FApiClient.Get('/api/products');
    if (FApiClient.LastStatusCode >= 200) and
      (FApiClient.LastStatusCode < 300) then
    begin
      mmResult.Lines.Text := ResponseBody;
      ShowMessage('Protected endpoint accessed successfully.');
      Exit;
    end;

    mmResult.Clear;
    if FApiClient.LastStatusCode = 401 then
    begin
      ShowMessage('Your session is no longer valid. Please sign in again.');
      FAuthService.Logout;
      ModalResult := mrCancel;
      Exit;
    end;

    ShowMessage(FApiClient.LastError);
  finally
    btnProtectedRequest.Enabled := True;
  end;
end;

procedure TMainForm.FormClose(
  Sender: TObject;
  var Action: TCloseAction);
begin
  if Assigned(FUserSession) and FUserSession.IsAuthenticated then
    FAuthService.Logout;
end;

procedure TMainForm.Initialize(
  const AApiClient: IApiClientContract;
  const AAuthService: IAuthDesktopServiceContract;
  const AProductService: IProductDesktopServiceContract;
  const AUserSession: IUserSessionContract);
begin
  FApiClient := AApiClient;
  FAuthService := AAuthService;
  FProductService := AProductService;
  FUserSession := AUserSession;
  UpdateUserInformation;
end;

procedure TMainForm.UpdateUserInformation;
var
  NameToDisplay: string;
  RoleToDisplay: string;
begin
  NameToDisplay := Trim(FUserSession.DisplayName);
  if NameToDisplay = '' then
    NameToDisplay := FUserSession.UserName;

  RoleToDisplay := Trim(FUserSession.Role);
  if RoleToDisplay = '' then
    RoleToDisplay := 'Not informed';

  lblWelcome.Caption := Format(
    'Signed in as %s (@%s, ID %d)',
    [NameToDisplay, FUserSession.UserName, FUserSession.UserId]);
  lblRole.Caption := 'Role: ' + RoleToDisplay;
end;

end.
