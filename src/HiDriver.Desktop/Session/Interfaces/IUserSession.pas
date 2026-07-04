unit IUserSession;

interface

type
  IUserSessionContract = interface
    ['{652D482E-8346-4825-9990-D9390DB5385A}']
    procedure SetAuthenticatedUser(
      const AToken: string;
      const AUserId: Integer;
      const AUserName, ADisplayName, ARole: string);
    procedure Clear;
    function IsAuthenticated: Boolean;
    function GetToken: string;
    function GetUserId: Integer;
    function GetUserName: string;
    function GetDisplayName: string;
    function GetRole: string;
    property Token: string read GetToken;
    property UserId: Integer read GetUserId;
    property UserName: string read GetUserName;
    property DisplayName: string read GetDisplayName;
    property Role: string read GetRole;
  end;

implementation

end.
