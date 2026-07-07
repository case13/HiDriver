unit vwCustomerConsult;

interface

uses
  System.Classes,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Grids,
  Vcl.StdCtrls,
  GridFilterHelper,
  ICustomerDesktopService,
  CustomerDto, Vcl.Buttons, Vcl.ComCtrls, Vcl.ToolWin, Vcl.ExtCtrls;

type
  TfvwCustomerConsult = class(TForm)
    Panel1: TPanel;
    lblTitle: TLabel;
    Panel4: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    Panel3: TPanel;
    gridCustomers: TStringGrid;
    Panel5: TPanel;
    lblTotal: TLabel;
    SpeedButton4: TSpeedButton;
    Shape2: TShape;
    Shape1: TShape;
    Label1: TLabel;
    btnRefresh: TSpeedButton;
    edtSearch: TEdit;
    procedure btnRefreshClick(Sender: TObject);
    procedure edtSearchChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure gridCustomersClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
  private
    FCustomers: TCustomerDtoList;
    FCustomerService: ICustomerDesktopServiceContract;
    FGridFilter: TGridFilterHelper;
    FLoaded: Boolean;
    FSearchResult: TCustomerDtoReferenceList;
    FSelectedCustomerId: Integer;
    FSessionExpired: Boolean;
    procedure ApplyFilter;
    procedure ConfigureGrid;
    procedure ConfigureGridFilter;
    procedure FillGrid;
    function GetSessionExpired: Boolean;
    procedure GridFilterChanged(Sender: TObject);
    procedure HandleLoadError;
    procedure HandleServiceError(const ADefaultMessage: string);
    procedure LoadCustomers;
    function SelectedCustomer: TCustomerDto;
    procedure SyncSelectedCustomerFromGrid;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(
      const ACustomerService: ICustomerDesktopServiceContract);
    property SessionExpired: Boolean read GetSessionExpired;
  end;

var
  fvwCustomerConsult: TfvwCustomerConsult;

implementation

{$R *.dfm}

uses
  System.SysUtils,
  System.UITypes,
  Vcl.Dialogs,
  vwCustomerSave;

procedure TfvwCustomerConsult.ApplyFilter;
var
  FilterField: string;
  FilteredCustomers: TCustomerDtoReferenceList;
  SortDirection: string;
  SortField: string;
begin
  FilterField := 'name';
  SortField := 'name';
  SortDirection := 'asc';
  if Assigned(FGridFilter) then
  begin
    FilterField := FGridFilter.SelectedFilterField;
    SortField := FGridFilter.SelectedSortField;
    SortDirection := FGridFilter.SelectedSortDirection;
  end;

  FilteredCustomers := FCustomerService.SearchCustomersLocal(
    FCustomers,
    edtSearch.Text,
    FilterField,
    SortField,
    SortDirection);
  FSearchResult.Free;
  FSearchResult := FilteredCustomers;
  FillGrid;
end;

procedure TfvwCustomerConsult.btnRefreshClick(Sender: TObject);
begin
  LoadCustomers;
end;

procedure TfvwCustomerConsult.ConfigureGrid;
begin
  gridCustomers.ColCount := 7;
  gridCustomers.FixedCols := 0;
  gridCustomers.FixedRows := 1;
  gridCustomers.Cells[0, 0] := 'Nome';
  gridCustomers.Cells[1, 0] := 'Documento';
  gridCustomers.Cells[2, 0] := 'Telefone';
  gridCustomers.Cells[3, 0] := 'Email';
  gridCustomers.Cells[4, 0] := 'Cidade';
  gridCustomers.Cells[5, 0] := 'Estado';
  gridCustomers.Cells[6, 0] := 'Status';
  gridCustomers.ColWidths[0] := 260;
  gridCustomers.ColWidths[1] := 135;
  gridCustomers.ColWidths[2] := 130;
  gridCustomers.ColWidths[3] := 300;
  gridCustomers.ColWidths[4] := 200;
  gridCustomers.ColWidths[5] := 70;
  gridCustomers.ColWidths[6] := 80;
end;

procedure TfvwCustomerConsult.ConfigureGridFilter;
begin
  if not Assigned(FGridFilter) then
  begin
    FGridFilter := TGridFilterHelper.Create(
      gridCustomers,
      'name',
      0,
      gsdAscending);
    gridCustomers.OnDrawCell := FGridFilter.HandleGridDrawCell;
    gridCustomers.OnMouseDown := FGridFilter.HandleGridMouseDown;
  end
  else
    FGridFilter.ClearMappings;

  FGridFilter.OnFilterChanged := nil;
  FGridFilter.MapColumn(0, 'name');
  FGridFilter.MapColumn(1, 'document');
  FGridFilter.MapColumn(2, 'phone');
  FGridFilter.MapColumn(3, 'email');
  FGridFilter.MapColumn(4, 'city');
  FGridFilter.MapColumn(5, 'state');
  FGridFilter.MapColumn(6, 'status');
  FGridFilter.SelectDefaultColumn;
  FGridFilter.OnFilterChanged := GridFilterChanged;
end;

constructor TfvwCustomerConsult.Create(AOwner: TComponent);
begin
  inherited;
  FCustomers := TCustomerDtoList.Create(True);
  FSearchResult := TCustomerDtoReferenceList.Create;
  ConfigureGrid;
  ConfigureGridFilter;
  FillGrid;
end;

destructor TfvwCustomerConsult.Destroy;
begin
  gridCustomers.OnDrawCell := nil;
  gridCustomers.OnMouseDown := nil;
  FGridFilter.Free;
  FSearchResult.Free;
  FCustomers.Free;
  inherited;
end;

procedure TfvwCustomerConsult.edtSearchChange(Sender: TObject);
begin
  if Assigned(FCustomerService) then
    ApplyFilter;
end;

procedure TfvwCustomerConsult.FillGrid;
var
  ColumnIndex: Integer;
  CustomerItem: TCustomerDto;
  RowIndex: Integer;
begin
  FSelectedCustomerId := 0;
  if FSearchResult.Count = 0 then
    gridCustomers.RowCount := 2
  else
    gridCustomers.RowCount := FSearchResult.Count + 1;

  for RowIndex := 1 to gridCustomers.RowCount - 1 do
    for ColumnIndex := 0 to gridCustomers.ColCount - 1 do
      gridCustomers.Cells[ColumnIndex, RowIndex] := '';

  RowIndex := 1;
  for CustomerItem in FSearchResult do
  begin
    gridCustomers.Cells[0, RowIndex] := CustomerItem.Name;
    gridCustomers.Cells[1, RowIndex] := CustomerItem.Document;
    gridCustomers.Cells[2, RowIndex] := CustomerItem.Phone;
    gridCustomers.Cells[3, RowIndex] := CustomerItem.Email;
    gridCustomers.Cells[4, RowIndex] := CustomerItem.City;
    gridCustomers.Cells[5, RowIndex] := CustomerItem.State;
    if CustomerItem.IsActive then
      gridCustomers.Cells[6, RowIndex] := 'Ativo'
    else
      gridCustomers.Cells[6, RowIndex] := 'Inativo';
    Inc(RowIndex);
  end;

  lblTotal.Caption := Format(
    'Total: %d cliente(s)',
    [FSearchResult.Count]);

  if Assigned(FGridFilter) then
    FGridFilter.ApplySelectedHeaderStyle;

  if FSearchResult.Count > 0 then
  begin
    if gridCustomers.Row < 1 then
      gridCustomers.Row := 1;
    if gridCustomers.Row > FSearchResult.Count then
      gridCustomers.Row := FSearchResult.Count;
  end;
  SyncSelectedCustomerFromGrid;
end;

procedure TfvwCustomerConsult.FormShow(Sender: TObject);
begin
  if not FLoaded then
  begin
    FLoaded := True;
    LoadCustomers;
  end;
end;

function TfvwCustomerConsult.GetSessionExpired: Boolean;
begin
  Result := FSessionExpired;
end;

procedure TfvwCustomerConsult.GridFilterChanged(Sender: TObject);
begin
  if Assigned(FCustomerService) then
    ApplyFilter
  else if Assigned(FGridFilter) then
    FGridFilter.ApplySelectedHeaderStyle;
end;

procedure TfvwCustomerConsult.gridCustomersClick(Sender: TObject);
begin
  SyncSelectedCustomerFromGrid;
end;

procedure TfvwCustomerConsult.HandleLoadError;
begin
  HandleServiceError('Nao foi possivel carregar os clientes.');
end;

procedure TfvwCustomerConsult.HandleServiceError(
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

procedure TfvwCustomerConsult.Initialize(
  const ACustomerService: ICustomerDesktopServiceContract);
begin
  FCustomerService := ACustomerService;
end;

procedure TfvwCustomerConsult.LoadCustomers;
var
  LoadedCustomers: TCustomerDtoList;
begin
  btnRefresh.Enabled := False;
  Screen.Cursor := crHourGlass;
  try
    try
      LoadedCustomers := FCustomerService.GetCustomers;
      if not Assigned(LoadedCustomers) then
      begin
        HandleLoadError;
        Exit;
      end;

      FSearchResult.Free;
      FSearchResult := nil;
      FCustomers.Free;
      FCustomers := LoadedCustomers;
      FSearchResult := TCustomerDtoReferenceList.Create;
      if Assigned(FGridFilter) then
        FGridFilter.EnsureSelectedColumnExists;
      ApplyFilter;

      if FCustomers.Count = 0 then
        ShowMessage('Nenhum cliente foi encontrado.');
    except
      on E: Exception do
        ShowMessage('Ocorreu um erro inesperado ao carregar os clientes.');
    end;
  finally
    Screen.Cursor := crDefault;
    btnRefresh.Enabled := True;
  end;
end;

function TfvwCustomerConsult.SelectedCustomer: TCustomerDto;
var
  CustomerItem: TCustomerDto;
begin
  Result := nil;
  SyncSelectedCustomerFromGrid;
  if FSelectedCustomerId <= 0 then
    Exit;

  for CustomerItem in FSearchResult do
    if CustomerItem.Id = FSelectedCustomerId then
      Exit(CustomerItem);
end;

procedure TfvwCustomerConsult.SyncSelectedCustomerFromGrid;
var
  CustomerIndex: Integer;
begin
  FSelectedCustomerId := 0;
  if not Assigned(FSearchResult) then
    Exit;

  CustomerIndex := gridCustomers.Row - 1;
  if (CustomerIndex >= 0) and
    (CustomerIndex < FSearchResult.Count) then
    FSelectedCustomerId := FSearchResult[CustomerIndex].Id;
end;

procedure TfvwCustomerConsult.SpeedButton1Click(Sender: TObject);
var
  EditForm: TfvwCustomerSave;
begin
  EditForm := TfvwCustomerSave.Create(Application);
  try
    EditForm.InitializeForCreate(FCustomerService);
    if EditForm.ShowModal = mrOk then
      LoadCustomers;

    if EditForm.SessionExpired then
    begin
      FSessionExpired := True;
      ModalResult := mrCancel;
    end;
  finally
    EditForm.Free;
  end;
end;

procedure TfvwCustomerConsult.SpeedButton2Click(Sender: TObject);
var
  CustomerItem: TCustomerDto;
  EditForm: TfvwCustomerSave;
begin
  CustomerItem := SelectedCustomer;
  if not Assigned(CustomerItem) then
  begin
    ShowMessage('Selecione um cliente para editar.');
    Exit;
  end;

  EditForm := TfvwCustomerSave.Create(Application);
  try
    if EditForm.InitializeForEdit(FCustomerService, CustomerItem.Id) then
      if EditForm.ShowModal = mrOk then
        LoadCustomers;

    if EditForm.SessionExpired then
    begin
      FSessionExpired := True;
      ModalResult := mrCancel;
    end;
  finally
    EditForm.Free;
  end;
end;

procedure TfvwCustomerConsult.SpeedButton3Click(Sender: TObject);
var
  CustomerItem: TCustomerDto;
begin
  CustomerItem := SelectedCustomer;
  if not Assigned(CustomerItem) then
  begin
    ShowMessage('Selecione um cliente para excluir.');
    Exit;
  end;

  if MessageDlg(
    'Deseja realmente excluir este cliente?',
    mtConfirmation,
    [mbYes, mbNo],
    0) <> mrYes then
    Exit;

  try
    if not FCustomerService.DeleteCustomer(CustomerItem.Id) then
    begin
      HandleServiceError('Nao foi possivel excluir o cliente.');
      Exit;
    end;

    ShowMessage('Cliente excluido com sucesso.');
    LoadCustomers;
  except
    on E: Exception do
      ShowMessage('Ocorreu um erro inesperado ao excluir o cliente.');
  end;
end;

procedure TfvwCustomerConsult.SpeedButton4Click(Sender: TObject);
begin
  Close;
end;

end.
