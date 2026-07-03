unit UserRepository;

interface

uses
  DatabaseConnectionIntf,
  UserRepositoryIntf,
  User;

type
  TUserRepository = class(TInterfacedObject, IUserRepository)
  private
    FDatabaseConnection: IDatabaseConnection;
  public
    constructor Create(const ADatabaseConnection: IDatabaseConnection);
    function FindByUserName(const AUserName: string): TUser;
    function ExistsByUserName(const AUserName: string): Boolean;
    procedure Insert(AUser: TUser);
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

constructor TUserRepository.Create(
  const ADatabaseConnection: IDatabaseConnection);
begin
  inherited Create;
  FDatabaseConnection := ADatabaseConnection;
end;

function TUserRepository.FindByUserName(const AUserName: string): TUser;
var
  Query: TFDQuery;
begin
  Result := nil;
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT id, username, display_name, password_hash, password_salt, ' +
      'role, is_active, created_at, updated_at ' +
      'FROM users WHERE username = :username LIMIT 1';
    Query.ParamByName('username').AsString := AUserName;
    Query.Open;

    if Query.IsEmpty then
      Exit;

    Result := TUser.Create;
    try
      Result.Id := Query.FieldByName('id').AsInteger;
      Result.UserName := Query.FieldByName('username').AsString;
      Result.DisplayName := Query.FieldByName('display_name').AsString;
      Result.PasswordHash := Query.FieldByName('password_hash').AsString;
      Result.PasswordSalt := Query.FieldByName('password_salt').AsString;
      Result.Role := Query.FieldByName('role').AsString;
      Result.IsActive := Query.FieldByName('is_active').AsInteger = 1;
      Result.CreatedAt := DatabaseTextToDateTime(
        Query.FieldByName('created_at').AsString);
      if not Query.FieldByName('updated_at').IsNull then
        Result.UpdatedAt := DatabaseTextToDateTime(
          Query.FieldByName('updated_at').AsString);
    except
      Result.Free;
      raise;
    end;
  finally
    Query.Free;
  end;
end;

function TUserRepository.ExistsByUserName(const AUserName: string): Boolean;
var
  Query: TFDQuery;
begin
  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'SELECT 1 FROM users WHERE username = :username LIMIT 1';
    Query.ParamByName('username').AsString := AUserName;
    Query.Open;
    Result := not Query.IsEmpty;
  finally
    Query.Free;
  end;
end;

procedure TUserRepository.Insert(AUser: TUser);
var
  Query: TFDQuery;
begin
  if not Assigned(AUser) then
    raise EArgumentNilException.Create('User is required.');

  FDatabaseConnection.Connect;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDatabaseConnection.Connection;
    Query.SQL.Text :=
      'INSERT INTO users (' +
      'username, display_name, password_hash, password_salt, role, ' +
      'is_active, created_at, updated_at) ' +
      'VALUES (' +
      ':username, :display_name, :password_hash, :password_salt, :role, ' +
      ':is_active, :created_at, :updated_at)';
    Query.ParamByName('username').AsString := AUser.UserName;
    Query.ParamByName('display_name').AsString := AUser.DisplayName;
    Query.ParamByName('password_hash').AsString := AUser.PasswordHash;
    Query.ParamByName('password_salt').AsString := AUser.PasswordSalt;
    Query.ParamByName('role').AsString := AUser.Role;
    Query.ParamByName('is_active').AsInteger := Ord(AUser.IsActive);
    Query.ParamByName('created_at').AsDateTime := AUser.CreatedAt;
    if AUser.UpdatedAt > 0 then
      Query.ParamByName('updated_at').AsDateTime := AUser.UpdatedAt
    else
      Query.ParamByName('updated_at').Clear;
    Query.ExecSQL;
    AUser.Id := Query.Connection.GetLastAutoGenValue('users');
  finally
    Query.Free;
  end;
end;

end.
