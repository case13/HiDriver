unit CashMovementRepository;

interface

uses
  System.Generics.Collections,
  CashMovement,
  CashMovementRepositoryIntf,
  DatabaseConnectionIntf;

type
  TCashMovementRepository = class(
    TInterfacedObject,
    ICashMovementRepository)
  private
    FDatabaseConnection: IDatabaseConnection;
  public
    constructor Create(const ADatabaseConnection: IDatabaseConnection);
    function FindByCashRegisterId(
      ACashRegisterId: Integer): TObjectList<TCashMovement>;
    function SumByCashRegisterId(
      ACashRegisterId: Integer): Currency;
    procedure Insert(ACashMovement: TCashMovement);
  end;

implementation

uses
  System.DateUtils,
  System.SysUtils,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param;

function DatabaseTextToDateTime(const AValue: string): TDateTime;
begin
  Result := ISO8601ToDate(
    StringReplace(AValue, ' ', 'T', [rfReplaceAll]),
    False);
end;

function QueryToCashMovement(AQuery: TFDQuery): TCashMovement;
begin
  Result := TCashMovement.Create;
  try
    Result.Id := AQuery.FieldByName('id').AsInteger;
    Result.CashRegisterId :=
      AQuery.FieldByName('cash_register_id').AsInteger;
    Result.MovementType :=
      AQuery.FieldByName('movement_type').AsString;
    Result.Description :=
      AQuery.FieldByName('description').AsString;
    Result.Amount := AQuery.FieldByName('amount').AsCurrency;
    Result.PaymentMethod :=
      AQuery.FieldByName('payment_method').AsString;
    Result.ReferenceType :=
      AQuery.FieldByName('reference_type').AsString;
    if not AQuery.FieldByName('reference_id').IsNull then
      Result.ReferenceId :=
        AQuery.FieldByName('reference_id').AsInteger;
    Result.CreatedAt := DatabaseTextToDateTime(
      AQuery.FieldByName('created_at').AsString);
  except
    Result.Free;
    raise;
  end;
end;

constructor TCashMovementRepository.Create(
  const ADatabaseConnection: IDatabaseConnection);
begin
  inherited Create;
  FDatabaseConnection := ADatabaseConnection;
end;

function TCashMovementRepository.FindByCashRegisterId(
  ACashRegisterId: Integer): TObjectList<TCashMovement>;
var
  Query: TFDQuery;
begin
  Result := TObjectList<TCashMovement>.Create(True);
  try
    FDatabaseConnection.Connect;

    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FDatabaseConnection.Connection;
      Query.SQL.Text :=
        'SELECT id, cash_register_id, movement_type, description, amount, ' +
        'payment_method, reference_type, reference_id, created_at ' +
        'FROM cash_movements WHERE cash_register_id = :cash_register_id ' +
        'ORDER BY created_at, id';
      Query.ParamByName('cash_register_id').AsInteger := ACashRegisterId;
      Query.Open;

      while not Query.Eof do
      begin
        Result.Add(QueryToCashMovement(Query));
        Query.Next;
      end;
    finally
      Query.Free;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TCashMovementRepository.SumByCashRegisterId(
  ACashRegisterId: Integer): Currency;
var
  Query: TFDQuery;
begin
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT COALESCE(SUM(amount), 0) AS total_amount ' +
      'FROM cash_movements WHERE cash_register_id = :cash_register_id';
    Query.ParamByName('cash_register_id').AsInteger := ACashRegisterId;
    Query.Open;
    Result := Query.FieldByName('total_amount').AsCurrency;
  finally
    Query.Free;
  end;
end;

procedure TCashMovementRepository.Insert(
  ACashMovement: TCashMovement);
var
  Query: TFDQuery;
begin
  if not Assigned(ACashMovement) then
    raise EArgumentNilException.Create('Cash movement is required.');

  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'INSERT INTO cash_movements (' +
      'cash_register_id, movement_type, description, amount, ' +
      'payment_method, reference_type, reference_id, created_at) VALUES (' +
      ':cash_register_id, :movement_type, :description, :amount, ' +
      ':payment_method, :reference_type, :reference_id, datetime(''now''))';
    Query.ParamByName('cash_register_id').AsInteger :=
      ACashMovement.CashRegisterId;
    Query.ParamByName('movement_type').AsString :=
      ACashMovement.MovementType;
    Query.ParamByName('description').AsString :=
      ACashMovement.Description;
    Query.ParamByName('amount').AsCurrency := ACashMovement.Amount;
    Query.ParamByName('payment_method').AsString :=
      ACashMovement.PaymentMethod;
    Query.ParamByName('reference_type').AsString :=
      ACashMovement.ReferenceType;
    Query.ParamByName('reference_id').AsInteger :=
      ACashMovement.ReferenceId;
    Query.ExecSQL;
    ACashMovement.Id :=
      Query.Connection.GetLastAutoGenValue('cash_movements');
  finally
    Query.Free;
  end;
end;

end.
