unit TransactionManager;

interface

uses
  DatabaseConnectionIntf,
  TransactionManagerIntf;

type
  TTransactionManager = class(TInterfacedObject, ITransactionManager)
  private
    FDatabaseConnection: IDatabaseConnection;
  public
    constructor Create(const ADatabaseConnection: IDatabaseConnection);
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
    function InTransaction: Boolean;
  end;

implementation

constructor TTransactionManager.Create(
  const ADatabaseConnection: IDatabaseConnection);
begin
  inherited Create;
  FDatabaseConnection := ADatabaseConnection;
end;

procedure TTransactionManager.StartTransaction;
begin
  FDatabaseConnection.Connect;
  if not FDatabaseConnection.Connection.InTransaction then
    FDatabaseConnection.Connection.StartTransaction;
end;

procedure TTransactionManager.Commit;
begin
  if InTransaction then
    FDatabaseConnection.Connection.Commit;
end;

procedure TTransactionManager.Rollback;
begin
  if InTransaction then
    FDatabaseConnection.Connection.Rollback;
end;

function TTransactionManager.InTransaction: Boolean;
begin
  Result := FDatabaseConnection.IsConnected and
    FDatabaseConnection.Connection.InTransaction;
end;

end.
