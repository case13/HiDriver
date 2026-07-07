unit vwCustomerSave;

interface

uses
  Winapi.Windows,
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  ICustomerDesktopService,
  CustomerDto,
  CustomerSaveRequestDto;

type
  TfvwCustomerSave = class(TForm)
    lblTitle: TLabel;
    lblName: TLabel;
    edtName: TEdit;
    lblDocument: TLabel;
    edtDocument: TEdit;
    lblPhone: TLabel;
    edtPhone: TEdit;
    lblEmail: TLabel;
    edtEmail: TEdit;
    lblAddress: TLabel;
    edtAddress: TEdit;
    lblCity: TLabel;
    edtCity: TEdit;
    lblState: TLabel;
    edtState: TEdit;
    lblZipCode: TLabel;
    edtZipCode: TEdit;
    chkIsActive: TCheckBox;
    btnSave: TButton;
    btnCancel: TButton;
    tmrInitialize: TTimer;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure tmrInitializeTimer(Sender: TObject);
  private
    FCustomerId: Integer;
    FCustomerService: ICustomerDesktopServiceContract;
    FCustomerToEdit: TCustomerDto;
    FEditMode: Boolean;
    FLoaded: Boolean;
    FSessionExpired: Boolean;
    function BuildRequest: TCustomerSaveRequestDto;
    procedure ConfigureForCreate;
    procedure CopyCustomer(
      ASource: TCustomerDto;
      ATarget: TCustomerDto);
    procedure EnsureInputHandles;
    procedure FillFields(ACustomer: TCustomerDto);
    procedure HandleServiceError(const ADefaultMessage: string);
    function LoadCustomer: Boolean;
    procedure SetInputText(AEdit: TEdit; const AText: string);
    function ValidateFields: Boolean;
  protected
    procedure DoShow; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure InitializeForCreate(
      const ACustomerService: ICustomerDesktopServiceContract);
    function InitializeForEdit(
      const ACustomerService: ICustomerDesktopServiceContract;
      ACustomerId: Integer): Boolean;
    property SessionExpired: Boolean read FSessionExpired;
  end;

var
  fvwCustomerSave: TfvwCustomerSave;

implementation

{$R *.dfm}

uses
  System.SysUtils,
  Vcl.Dialogs;

function TfvwCustomerSave.BuildRequest: TCustomerSaveRequestDto;
begin
  Result := TCustomerSaveRequestDto.Create;
  try
    Result.Name := Trim(edtName.Text);
    Result.Document := Trim(edtDocument.Text);
    Result.Phone := Trim(edtPhone.Text);
    Result.Email := Trim(edtEmail.Text);
    Result.Address := Trim(edtAddress.Text);
    Result.City := Trim(edtCity.Text);
    Result.State := UpperCase(Trim(edtState.Text));
    Result.ZipCode := Trim(edtZipCode.Text);
    Result.IsActive := chkIsActive.Checked;
  except
    Result.Free;
    raise;
  end;
end;

procedure TfvwCustomerSave.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfvwCustomerSave.btnSaveClick(Sender: TObject);
var
  Request: TCustomerSaveRequestDto;
  Saved: Boolean;
begin
  if not ValidateFields then
    Exit;

  Request := BuildRequest;
  btnSave.Enabled := False;
  Screen.Cursor := crHourGlass;
  try
    try
      if FEditMode then
        Saved := FCustomerService.UpdateCustomer(FCustomerId, Request)
      else
        Saved := FCustomerService.CreateCustomer(Request);

      if not Saved then
      begin
        HandleServiceError('Nao foi possivel salvar o cliente.');
        Exit;
      end;

      if FEditMode then
        ShowMessage('Cliente atualizado com sucesso.')
      else
        ShowMessage('Cliente criado com sucesso.');
      ModalResult := mrOk;
    except
      on E: Exception do
        ShowMessage('Ocorreu um erro inesperado ao salvar o cliente.');
    end;
  finally
    Screen.Cursor := crDefault;
    btnSave.Enabled := True;
    Request.Free;
  end;
end;

procedure TfvwCustomerSave.ConfigureForCreate;
begin
  FEditMode := False;
  FCustomerId := 0;
  Caption := 'HiDriver - Novo Cliente';
  lblTitle.Caption := 'Novo Cliente';
  edtName.Clear;
  edtDocument.Clear;
  edtPhone.Clear;
  edtEmail.Clear;
  edtAddress.Clear;
  edtCity.Clear;
  edtState.Clear;
  edtZipCode.Clear;
  chkIsActive.Checked := True;
end;

procedure TfvwCustomerSave.CopyCustomer(
  ASource: TCustomerDto;
  ATarget: TCustomerDto);
begin
  ATarget.Id := ASource.Id;
  ATarget.Name := ASource.Name;
  ATarget.Document := ASource.Document;
  ATarget.Phone := ASource.Phone;
  ATarget.Email := ASource.Email;
  ATarget.Address := ASource.Address;
  ATarget.City := ASource.City;
  ATarget.State := ASource.State;
  ATarget.ZipCode := ASource.ZipCode;
  ATarget.IsActive := ASource.IsActive;
end;

constructor TfvwCustomerSave.Create(AOwner: TComponent);
begin
  inherited;
  edtState.MaxLength := 2;
  ConfigureForCreate;
end;

destructor TfvwCustomerSave.Destroy;
begin
  FCustomerToEdit.Free;
  inherited;
end;

procedure TfvwCustomerSave.DoShow;
begin
  inherited;
  tmrInitialize.Enabled := True;
end;

procedure TfvwCustomerSave.EnsureInputHandles;
begin
  if edtName.Handle = 0 then Exit;
  if edtDocument.Handle = 0 then Exit;
  if edtPhone.Handle = 0 then Exit;
  if edtEmail.Handle = 0 then Exit;
  if edtAddress.Handle = 0 then Exit;
  if edtCity.Handle = 0 then Exit;
  if edtState.Handle = 0 then Exit;
  if edtZipCode.Handle = 0 then Exit;
  if chkIsActive.Handle = 0 then Exit;
end;

procedure TfvwCustomerSave.FillFields(ACustomer: TCustomerDto);
begin
  SetInputText(edtName, ACustomer.Name);
  SetInputText(edtDocument, ACustomer.Document);
  SetInputText(edtPhone, ACustomer.Phone);
  SetInputText(edtEmail, ACustomer.Email);
  SetInputText(edtAddress, ACustomer.Address);
  SetInputText(edtCity, ACustomer.City);
  SetInputText(edtState, ACustomer.State);
  SetInputText(edtZipCode, ACustomer.ZipCode);
  chkIsActive.Checked := ACustomer.IsActive;
end;

procedure TfvwCustomerSave.HandleServiceError(
  const ADefaultMessage: string);
begin
  if FCustomerService.LastStatusCode = 401 then
  begin
    FSessionExpired := True;
    ShowMessage(
      'Sua sessao expirou ou o token e invalido. Faca login novamente.');
    ModalResult := mrCancel;
    Exit;
  end;

  if FCustomerService.LastStatusCode = 0 then
    ShowMessage(
      'Nao foi possivel conectar a API. Verifique se ela esta em execucao.')
  else if FCustomerService.LastError <> '' then
    ShowMessage(FCustomerService.LastError)
  else
    ShowMessage(ADefaultMessage);
end;

procedure TfvwCustomerSave.InitializeForCreate(
  const ACustomerService: ICustomerDesktopServiceContract);
begin
  FCustomerService := ACustomerService;
  ConfigureForCreate;
end;

function TfvwCustomerSave.InitializeForEdit(
  const ACustomerService: ICustomerDesktopServiceContract;
  ACustomerId: Integer): Boolean;
begin
  FCustomerService := ACustomerService;
  FEditMode := True;
  FCustomerId := ACustomerId;
  FLoaded := False;
  Caption := 'HiDriver - Editar Cliente';
  lblTitle.Caption := 'Editar Cliente';
  Result := LoadCustomer;
end;

function TfvwCustomerSave.LoadCustomer: Boolean;
var
  CustomerItem: TCustomerDto;
begin
  Result := False;
  btnSave.Enabled := False;
  Screen.Cursor := crHourGlass;
  try
    try
      CustomerItem := FCustomerService.GetCustomerById(FCustomerId);
      try
        if not Assigned(CustomerItem) then
        begin
          HandleServiceError('Cliente nao encontrado.');
          Exit;
        end;

        FCustomerToEdit.Free;
        FCustomerToEdit := TCustomerDto.Create;
        CopyCustomer(CustomerItem, FCustomerToEdit);
        Result := True;
      finally
        CustomerItem.Free;
      end;
    except
      on E: Exception do
        ShowMessage('Ocorreu um erro inesperado ao carregar o cliente.');
    end;
  finally
    Screen.Cursor := crDefault;
    btnSave.Enabled := True;
  end;
end;

procedure TfvwCustomerSave.SetInputText(
  AEdit: TEdit;
  const AText: string);
begin
  AEdit.Text := AText;
  SetWindowText(AEdit.Handle, PChar(AText));
end;

procedure TfvwCustomerSave.tmrInitializeTimer(Sender: TObject);
begin
  tmrInitialize.Enabled := False;
  EnsureInputHandles;
  if FEditMode and Assigned(FCustomerToEdit) then
  begin
    FillFields(FCustomerToEdit);
    FLoaded := True;
  end;

  if edtName.CanFocus then
    edtName.SetFocus;
end;

function TfvwCustomerSave.ValidateFields: Boolean;
var
  EmailText: string;
  StateText: string;
begin
  Result := False;
  if Trim(edtName.Text) = '' then
  begin
    ShowMessage('O nome e obrigatorio.');
    edtName.SetFocus;
    Exit;
  end;

  EmailText := Trim(edtEmail.Text);
  if (EmailText <> '') and (Pos('@', EmailText) = 0) then
  begin
    ShowMessage('Informe um email valido.');
    edtEmail.SetFocus;
    Exit;
  end;

  StateText := Trim(edtState.Text);
  if Length(StateText) > 2 then
  begin
    ShowMessage('O estado deve ter no maximo 2 caracteres.');
    edtState.SetFocus;
    Exit;
  end;

  Result := True;
end;

end.
