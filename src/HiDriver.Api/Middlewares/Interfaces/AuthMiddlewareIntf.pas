unit AuthMiddlewareIntf;

interface

uses
  Horse.Session;

type
  TAuthenticatedUserContext = class(TSession)
  private
    FUserId: Integer;
    FUserName: string;
    FDisplayName: string;
    FRole: string;
  public
    property UserId: Integer read FUserId write FUserId;
    property UserName: string read FUserName write FUserName;
    property DisplayName: string read FDisplayName write FDisplayName;
    property Role: string read FRole write FRole;
  end;

  IAuthMiddleware = interface
    procedure Register;
  end;

implementation

end.
