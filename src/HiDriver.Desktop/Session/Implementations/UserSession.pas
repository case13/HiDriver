unit UserSession;

interface

uses
  IUserSession;

type
  TUserSession = class(TInterfacedObject, IUserSessionContract)
  private
    FToken: string;
    FUserId: Integer;
    FUserName: string;
    FDisplayName: string;
    FRole: string;
    function GetToken: string;
    function GetUserId: Integer;
    function GetUserName: string;
    function GetDisplayName: string;
    function GetRole: string;
  public
    constructor Create;
    procedure SetAuthenticatedUser(
      const AToken: string;
      const AUserId: Integer;
      const AUserName, ADisplayName, ARole: string);
    procedure Clear;
    function IsAuthenticated: Boolean;
  end;

implementation

uses
  System.SysUtils;

constructor TUserSession.Create;
begin
  inherited Create;
  Clear;
end;

procedure TUserSession.Clear;
begin
  FToken := '';
  FUserId := 0;
  FUserName := '';
  FDisplayName := '';
  FRole := '';
end;

function TUserSession.GetDisplayName: string;
begin
  Result := FDisplayName;
end;

function TUserSession.GetRole: string;
begin
  Result := FRole;
end;

function TUserSession.GetToken: string;
begin
  Result := FToken;
end;

function TUserSession.GetUserId: Integer;
begin
  Result := FUserId;
end;

function TUserSession.GetUserName: string;
begin
  Result := FUserName;
end;

function TUserSession.IsAuthenticated: Boolean;
begin
  Result := Trim(FToken) <> '';
end;

procedure TUserSession.SetAuthenticatedUser(
  const AToken: string;
  const AUserId: Integer;
  const AUserName, ADisplayName, ARole: string);
begin
  FToken := AToken;
  FUserId := AUserId;
  FUserName := AUserName;
  FDisplayName := ADisplayName;
  FRole := ARole;
end;

end.
