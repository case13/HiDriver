unit CashRegisterRepository;

interface

uses
  CashRegister,
  CashRegisterRepositoryIntf,
  DatabaseConnectionIntf;

type
  TCashRegisterRepository = class(
    TInterfacedObject,
    ICashRegisterRepository)
  private
    FDatabaseConnection: IDatabaseConnection;
  public
    constructor Create(const ADatabaseConnection: IDatabaseConnection);
    function FindOpen: TCashRegister;
    function FindById(AId: Integer): TCashRegister;
    function HasOpenCashRegister: Boolean;
    function Insert(ACashRegister: TCashRegister): Integer;
    procedure Close(ACashRegister: TCashRegister);
  end;

implementation

uses
  System.DateUtils,
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param;

function DatabaseTextToDateTime(const AValue: string): TDateTime;
begin
  Result := ISO8601ToDate(
    StringReplace(AValue, ' ', 'T', [rfReplaceAll]),
    False);
end;

function QueryToCashRegister(AQuery: TFDQuery): TCashRegister;
begin
  Result := TCashRegister.Create;
  try
    Result.Id := AQuery.FieldByName('id').AsInteger;
    Result.UserId := AQuery.FieldByName('user_id').AsInteger;
    Result.Status := AQuery.FieldByName('status').AsString;
    Result.OpeningAmount :=
      AQuery.FieldByName('opening_amount').AsCurrency;
    if not AQuery.FieldByName('closing_amount').IsNull then
      Result.ClosingAmount :=
        AQuery.FieldByName('closing_amount').AsCurrency;
    if not AQuery.FieldByName('expected_amount').IsNull then
      Result.ExpectedAmount :=
        AQuery.FieldByName('expected_amount').AsCurrency;
    if not AQuery.FieldByName('difference_amount').IsNull then
      Result.DifferenceAmount :=
        AQuery.FieldByName('difference_amount').AsCurrency;
    Result.OpenedAt := DatabaseTextToDateTime(
      AQuery.FieldByName('opened_at').AsString);
    if not AQuery.FieldByName('closed_at').IsNull then
      Result.ClosedAt := DatabaseTextToDateTime(
        AQuery.FieldByName('closed_at').AsString);
    Result.CreatedAt := DatabaseTextToDateTime(
      AQuery.FieldByName('created_at').AsString);
    if not AQuery.FieldByName('updated_at').IsNull then
      Result.UpdatedAt := DatabaseTextToDateTime(
        AQuery.FieldByName('updated_at').AsString);
  except
    Result.Free;
    raise;
  end;
end;

constructor TCashRegisterRepository.Create(
  const ADatabaseConnection: IDatabaseConnection);
begin
  inherited Create;
  FDatabaseConnection := ADatabaseConnection;
end;

function TCashRegisterRepository.FindOpen: TCashRegister;
var
  Query: TFDQuery;
begin
  Result := nil;
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT id, user_id, status, opening_amount, closing_amount, ' +
      'expected_amount, difference_amount, opened_at, closed_at, ' +
      'created_at, updated_at FROM cash_registers ' +
      'WHERE status = :status ORDER BY opened_at DESC, id DESC LIMIT 1';
    Query.ParamByName('status').AsString := 'Open';
    Query.Open;

    if not Query.IsEmpty then
      Result := QueryToCashRegister(Query);
  finally
    Query.Free;
  end;
end;

function TCashRegisterRepository.FindById(AId: Integer): TCashRegister;
var
  Query: TFDQuery;
begin
  Result := nil;
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT id, user_id, status, opening_amount, closing_amount, ' +
      'expected_amount, difference_amount, opened_at, closed_at, ' +
      'created_at, updated_at FROM cash_registers ' +
      'WHERE id = :id LIMIT 1';
    Query.ParamByName('id').AsInteger := AId;
    Query.Open;

    if not Query.IsEmpty then
      Result := QueryToCashRegister(Query);
  finally
    Query.Free;
  end;
end;

function TCashRegisterRepository.HasOpenCashRegister: Boolean;
var
  Query: TFDQuery;
begin
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT 1 FROM cash_registers WHERE status = :status LIMIT 1';
    Query.ParamByName('status').AsString := 'Open';
    Query.Open;
    Result := not Query.IsEmpty;
  finally
    Query.Free;
  end;
end;

function TCashRegisterRepository.Insert(
  ACashRegister: TCashRegister): Integer;
var
  Query: TFDQuery;
begin
  if not Assigned(ACashRegister) then
    raise EArgumentNilException.Create('Cash register is required.');

  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'INSERT INTO cash_registers (' +
      'user_id, status, opening_amount, expected_amount, opened_at, ' +
      'created_at) VALUES (' +
      ':user_id, :status, :opening_amount, :expected_amount, ' +
      'datetime(''now''), datetime(''now''))';
    Query.ParamByName('user_id').AsInteger := ACashRegister.UserId;
    Query.ParamByName('status').AsString := ACashRegister.Status;
    Query.ParamByName('opening_amount').AsCurrency :=
      ACashRegister.OpeningAmount;
    Query.ParamByName('expected_amount').AsCurrency :=
      ACashRegister.ExpectedAmount;
    Query.ExecSQL;

    Result := Query.Connection.GetLastAutoGenValue('cash_registers');
    ACashRegister.Id := Result;
  finally
    Query.Free;
  end;
end;

procedure TCashRegisterRepository.Close(
  ACashRegister: TCashRegister);
var
  Query: TFDQuery;
begin
  if not Assigned(ACashRegister) then
    raise EArgumentNilException.Create('Cash register is required.');

  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'UPDATE cash_registers SET status = :status, ' +
      'closing_amount = :closing_amount, ' +
      'expected_amount = :expected_amount, ' +
      'difference_amount = :difference_amount, ' +
      'closed_at = datetime(''now''), updated_at = datetime(''now'') ' +
      'WHERE id = :id';
    Query.ParamByName('status').AsString := ACashRegister.Status;
    Query.ParamByName('closing_amount').AsCurrency :=
      ACashRegister.ClosingAmount;
    Query.ParamByName('expected_amount').AsCurrency :=
      ACashRegister.ExpectedAmount;
    Query.ParamByName('difference_amount').AsCurrency :=
      ACashRegister.DifferenceAmount;
    Query.ParamByName('id').AsInteger := ACashRegister.Id;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

end.
