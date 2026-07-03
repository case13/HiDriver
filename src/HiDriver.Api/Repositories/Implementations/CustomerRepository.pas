unit CustomerRepository;

interface

uses
  System.Generics.Collections,
  Customer,
  CustomerRepositoryIntf,
  DatabaseConnectionIntf;

type
  TCustomerRepository = class(TInterfacedObject, ICustomerRepository)
  private
    FDatabaseConnection: IDatabaseConnection;
  public
    constructor Create(const ADatabaseConnection: IDatabaseConnection);
    function FindAllActive: TObjectList<TCustomer>;
    function FindById(AId: Integer): TCustomer;
    function ExistsByDocument(
      const ADocument: string;
      AIgnoreId: Integer = 0): Boolean;
    function Insert(ACustomer: TCustomer): Integer;
    procedure Update(ACustomer: TCustomer);
    procedure Deactivate(AId: Integer);
    function ExistsById(AId: Integer): Boolean;
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

function QueryToCustomer(AQuery: TFDQuery): TCustomer;
begin
  Result := TCustomer.Create;
  try
    Result.Id := AQuery.FieldByName('id').AsInteger;
    Result.Name := AQuery.FieldByName('name').AsString;
    Result.Document := AQuery.FieldByName('document').AsString;
    Result.Phone := AQuery.FieldByName('phone').AsString;
    Result.Email := AQuery.FieldByName('email').AsString;
    Result.Address := AQuery.FieldByName('address').AsString;
    Result.City := AQuery.FieldByName('city').AsString;
    Result.State := AQuery.FieldByName('state').AsString;
    Result.ZipCode := AQuery.FieldByName('zip_code').AsString;
    Result.IsActive := AQuery.FieldByName('is_active').AsInteger = 1;
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

constructor TCustomerRepository.Create(
  const ADatabaseConnection: IDatabaseConnection);
begin
  inherited Create;
  FDatabaseConnection := ADatabaseConnection;
end;

function TCustomerRepository.FindAllActive: TObjectList<TCustomer>;
var
  Query: TFDQuery;
begin
  Result := TObjectList<TCustomer>.Create(True);
  try
    FDatabaseConnection.Connect;

    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FDatabaseConnection.Connection;
      Query.SQL.Text :=
        'SELECT id, name, document, phone, email, address, city, state, ' +
        'zip_code, is_active, created_at, updated_at FROM customers ' +
        'WHERE is_active = 1 ORDER BY name';
      Query.Open;

      while not Query.Eof do
      begin
        Result.Add(QueryToCustomer(Query));
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

function TCustomerRepository.FindById(AId: Integer): TCustomer;
var
  Query: TFDQuery;
begin
  Result := nil;
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT id, name, document, phone, email, address, city, state, ' +
      'zip_code, is_active, created_at, updated_at FROM customers ' +
      'WHERE id = :id AND is_active = 1 LIMIT 1';
    Query.ParamByName('id').AsInteger := AId;
    Query.Open;

    if not Query.IsEmpty then
      Result := QueryToCustomer(Query);
  finally
    Query.Free;
  end;
end;

function TCustomerRepository.ExistsByDocument(
  const ADocument: string;
  AIgnoreId: Integer): Boolean;
var
  Query: TFDQuery;
begin
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT 1 FROM customers WHERE document = :document ' +
      'AND (:ignore_id = 0 OR id <> :ignore_id) LIMIT 1';
    Query.ParamByName('document').AsString := ADocument;
    Query.ParamByName('ignore_id').AsInteger := AIgnoreId;
    Query.Open;
    Result := not Query.IsEmpty;
  finally
    Query.Free;
  end;
end;

function TCustomerRepository.Insert(ACustomer: TCustomer): Integer;
var
  Query: TFDQuery;
begin
  if not Assigned(ACustomer) then
    raise EArgumentNilException.Create('Customer is required.');

  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'INSERT INTO customers (' +
      'name, document, phone, email, address, city, state, zip_code, ' +
      'is_active, created_at) VALUES (' +
      ':name, :document, :phone, :email, :address, :city, :state, ' +
      ':zip_code, :is_active, datetime(''now''))';
    Query.ParamByName('name').AsString := ACustomer.Name;
    Query.ParamByName('document').AsString := ACustomer.Document;
    Query.ParamByName('phone').AsString := ACustomer.Phone;
    Query.ParamByName('email').AsString := ACustomer.Email;
    Query.ParamByName('address').AsString := ACustomer.Address;
    Query.ParamByName('city').AsString := ACustomer.City;
    Query.ParamByName('state').AsString := ACustomer.State;
    Query.ParamByName('zip_code').AsString := ACustomer.ZipCode;
    Query.ParamByName('is_active').AsInteger := Ord(ACustomer.IsActive);
    Query.ExecSQL;

    Result := Query.Connection.GetLastAutoGenValue('customers');
    ACustomer.Id := Result;
  finally
    Query.Free;
  end;
end;

procedure TCustomerRepository.Update(ACustomer: TCustomer);
var
  Query: TFDQuery;
begin
  if not Assigned(ACustomer) then
    raise EArgumentNilException.Create('Customer is required.');

  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'UPDATE customers SET name = :name, document = :document, ' +
      'phone = :phone, email = :email, address = :address, city = :city, ' +
      'state = :state, zip_code = :zip_code, is_active = :is_active, ' +
      'updated_at = datetime(''now'') WHERE id = :id';
    Query.ParamByName('name').AsString := ACustomer.Name;
    Query.ParamByName('document').AsString := ACustomer.Document;
    Query.ParamByName('phone').AsString := ACustomer.Phone;
    Query.ParamByName('email').AsString := ACustomer.Email;
    Query.ParamByName('address').AsString := ACustomer.Address;
    Query.ParamByName('city').AsString := ACustomer.City;
    Query.ParamByName('state').AsString := ACustomer.State;
    Query.ParamByName('zip_code').AsString := ACustomer.ZipCode;
    Query.ParamByName('is_active').AsInteger := Ord(ACustomer.IsActive);
    Query.ParamByName('id').AsInteger := ACustomer.Id;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TCustomerRepository.Deactivate(AId: Integer);
var
  Query: TFDQuery;
begin
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'UPDATE customers SET is_active = 0, updated_at = datetime(''now'') ' +
      'WHERE id = :id';
    Query.ParamByName('id').AsInteger := AId;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

function TCustomerRepository.ExistsById(AId: Integer): Boolean;
var
  Query: TFDQuery;
begin
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT 1 FROM customers WHERE id = :id AND is_active = 1 LIMIT 1';
    Query.ParamByName('id').AsInteger := AId;
    Query.Open;
    Result := not Query.IsEmpty;
  finally
    Query.Free;
  end;
end;

end.
