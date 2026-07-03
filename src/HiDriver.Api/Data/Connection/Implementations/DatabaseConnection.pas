unit DatabaseConnection;

interface

uses
  FireDAC.Comp.Client,
  ApiConfigIntf,
  DatabaseConnectionIntf;

type
  TDatabaseConnection = class(TInterfacedObject, IDatabaseConnection)
  private
    FConnection: TFDConnection;
  public
    constructor Create(const AConfig: IApiConfig);
    destructor Destroy; override;
    procedure Connect;
    procedure Disconnect;
    function IsConnected: Boolean;
    function GetConnection: TFDConnection;
  end;

implementation

uses
  FireDAC.Stan.Def,
  FireDAC.Phys,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef;

constructor TDatabaseConnection.Create(const AConfig: IApiConfig);
begin
  inherited Create;
  FConnection := TFDConnection.Create(nil);
  FConnection.LoginPrompt := False;
  FConnection.Params.Clear;
  FConnection.Params.Values['DriverID'] := 'SQLite';
  FConnection.Params.Values['Database'] := AConfig.DatabasePath;
  FConnection.Params.Values['LockingMode'] := 'Normal';
  FConnection.Params.Values['Synchronous'] := 'Normal';
end;

destructor TDatabaseConnection.Destroy;
begin
  FConnection.Free;
  inherited;
end;

procedure TDatabaseConnection.Connect;
begin
  if not FConnection.Connected then
    FConnection.Open;
end;

procedure TDatabaseConnection.Disconnect;
begin
  if FConnection.Connected then
    FConnection.Close;
end;

function TDatabaseConnection.IsConnected: Boolean;
begin
  Result := FConnection.Connected;
end;

function TDatabaseConnection.GetConnection: TFDConnection;
begin
  Result := FConnection;
end;

end.
