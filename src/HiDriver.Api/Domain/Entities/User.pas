unit User;

interface

uses
  System.SysUtils;

type
  TUser = class
  private
    FId: Integer;
    FUserName: string;
    FDisplayName: string;
    FPasswordHash: string;
    FPasswordSalt: string;
    FRole: string;
    FIsActive: Boolean;
    FCreatedAt: TDateTime;
    FUpdatedAt: TDateTime;
  public
    function IsAdmin: Boolean;
    function CanLogin: Boolean;

    property Id: Integer read FId write FId;
    property UserName: string read FUserName write FUserName;
    property DisplayName: string read FDisplayName write FDisplayName;
    property PasswordHash: string read FPasswordHash write FPasswordHash;
    property PasswordSalt: string read FPasswordSalt write FPasswordSalt;
    property Role: string read FRole write FRole;
    property IsActive: Boolean read FIsActive write FIsActive;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
  end;

implementation

function TUser.IsAdmin: Boolean;
begin
  Result := SameText(FRole, 'Admin');
end;

function TUser.CanLogin: Boolean;
begin
  Result := FIsActive;
end;

end.
