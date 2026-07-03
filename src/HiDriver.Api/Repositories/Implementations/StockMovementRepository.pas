unit StockMovementRepository;

interface

uses
  System.Generics.Collections,
  DatabaseConnectionIntf,
  StockMovement,
  StockMovementRepositoryIntf;

type
  TStockMovementRepository = class(
    TInterfacedObject,
    IStockMovementRepository)
  private
    FDatabaseConnection: IDatabaseConnection;
  public
    constructor Create(const ADatabaseConnection: IDatabaseConnection);
    function GetAll: TObjectList<TStockMovement>;
    function GetById(AId: Integer): TStockMovement;
    function GetByProductId(
      AProductId: Integer): TObjectList<TStockMovement>;
    procedure Insert(AStockMovement: TStockMovement);
  end;

implementation

uses
  System.DateUtils,
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param;

const
  SelectFields =
    'SELECT id, product_id, movement_date, movement_type, source_type, ' +
    'source_id, quantity, previous_stock, new_stock, unit_cost, notes, ' +
    'user_id, is_active, created_at FROM stock_movements ';

function DatabaseTextToDateTime(const AValue: string): TDateTime;
begin
  Result := ISO8601ToDate(
    StringReplace(AValue, ' ', 'T', [rfReplaceAll]),
    False);
end;

function QueryToStockMovement(AQuery: TFDQuery): TStockMovement;
begin
  Result := TStockMovement.Create;
  try
    Result.Id := AQuery.FieldByName('id').AsInteger;
    Result.ProductId := AQuery.FieldByName('product_id').AsInteger;
    Result.MovementDate := DatabaseTextToDateTime(
      AQuery.FieldByName('movement_date').AsString);
    Result.MovementType :=
      AQuery.FieldByName('movement_type').AsString;
    Result.SourceType := AQuery.FieldByName('source_type').AsString;
    if not AQuery.FieldByName('source_id').IsNull then
      Result.SourceId := AQuery.FieldByName('source_id').AsInteger;
    Result.Quantity := AQuery.FieldByName('quantity').AsFloat;
    Result.PreviousStock :=
      AQuery.FieldByName('previous_stock').AsFloat;
    Result.NewStock := AQuery.FieldByName('new_stock').AsFloat;
    if not AQuery.FieldByName('unit_cost').IsNull then
      Result.UnitCost := AQuery.FieldByName('unit_cost').AsCurrency;
    Result.Notes := AQuery.FieldByName('notes').AsString;
    if not AQuery.FieldByName('user_id').IsNull then
      Result.UserId := AQuery.FieldByName('user_id').AsInteger;
    Result.IsActive := AQuery.FieldByName('is_active').AsInteger = 1;
    Result.CreatedAt := DatabaseTextToDateTime(
      AQuery.FieldByName('created_at').AsString);
  except
    Result.Free;
    raise;
  end;
end;

constructor TStockMovementRepository.Create(
  const ADatabaseConnection: IDatabaseConnection);
begin
  inherited Create;
  FDatabaseConnection := ADatabaseConnection;
end;

function TStockMovementRepository.GetAll:
  TObjectList<TStockMovement>;
var
  Query: TFDQuery;
begin
  Result := TObjectList<TStockMovement>.Create(True);
  try
    FDatabaseConnection.Connect;

    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FDatabaseConnection.Connection;
      Query.SQL.Text :=
        SelectFields +
        'WHERE is_active = 1 ' +
        'ORDER BY movement_date DESC, id DESC';
      Query.Open;

      while not Query.Eof do
      begin
        Result.Add(QueryToStockMovement(Query));
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

function TStockMovementRepository.GetById(
  AId: Integer): TStockMovement;
var
  Query: TFDQuery;
begin
  Result := nil;
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      SelectFields +
      'WHERE id = :id AND is_active = 1 LIMIT 1';
    Query.ParamByName('id').AsInteger := AId;
    Query.Open;

    if not Query.IsEmpty then
      Result := QueryToStockMovement(Query);
  finally
    Query.Free;
  end;
end;

function TStockMovementRepository.GetByProductId(
  AProductId: Integer): TObjectList<TStockMovement>;
var
  Query: TFDQuery;
begin
  Result := TObjectList<TStockMovement>.Create(True);
  try
    FDatabaseConnection.Connect;

    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FDatabaseConnection.Connection;
      Query.SQL.Text :=
        SelectFields +
        'WHERE product_id = :product_id AND is_active = 1 ' +
        'ORDER BY movement_date DESC, id DESC';
      Query.ParamByName('product_id').AsInteger := AProductId;
      Query.Open;

      while not Query.Eof do
      begin
        Result.Add(QueryToStockMovement(Query));
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

procedure TStockMovementRepository.Insert(
  AStockMovement: TStockMovement);
var
  Query: TFDQuery;
begin
  if not Assigned(AStockMovement) then
    raise EArgumentNilException.Create('Stock movement is required.');

  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'INSERT INTO stock_movements (' +
      'product_id, movement_date, movement_type, source_type, source_id, ' +
      'quantity, previous_stock, new_stock, unit_cost, notes, user_id, ' +
      'is_active, created_at) VALUES (' +
      ':product_id, :movement_date, :movement_type, :source_type, ' +
      'NULLIF(:source_id, 0), :quantity, :previous_stock, :new_stock, ' +
      ':unit_cost, :notes, NULLIF(:user_id, 0), :is_active, :created_at)';
    Query.ParamByName('product_id').AsInteger :=
      AStockMovement.ProductId;
    Query.ParamByName('movement_date').AsString :=
      DateToISO8601(AStockMovement.MovementDate, False);
    Query.ParamByName('movement_type').AsString :=
      AStockMovement.MovementType;
    Query.ParamByName('source_type').AsString :=
      AStockMovement.SourceType;
    Query.ParamByName('source_id').AsInteger :=
      AStockMovement.SourceId;
    Query.ParamByName('quantity').AsFloat := AStockMovement.Quantity;
    Query.ParamByName('previous_stock').AsFloat :=
      AStockMovement.PreviousStock;
    Query.ParamByName('new_stock').AsFloat := AStockMovement.NewStock;
    Query.ParamByName('unit_cost').AsCurrency :=
      AStockMovement.UnitCost;
    Query.ParamByName('notes').AsString := AStockMovement.Notes;
    Query.ParamByName('user_id').AsInteger := AStockMovement.UserId;
    Query.ParamByName('is_active').AsInteger :=
      Ord(AStockMovement.IsActive);
    Query.ParamByName('created_at').AsString :=
      DateToISO8601(AStockMovement.CreatedAt, False);
    Query.ExecSQL;
    AStockMovement.Id :=
      Query.Connection.GetLastAutoGenValue('stock_movements');
  finally
    Query.Free;
  end;
end;

end.
