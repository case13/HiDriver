unit AuthDtos;

interface

type
  TLoginRequestDto = class
  private
    FUserName: string;
    FPassword: string;
  public
    property UserName: string read FUserName write FUserName;
    property Password: string read FPassword write FPassword;
  end;

  TLoginResponseDto = class
  private
    FToken: string;
    FUserId: Integer;
    FUserName: string;
    FDisplayName: string;
    FRole: string;
  public
    property Token: string read FToken write FToken;
    property UserId: Integer read FUserId write FUserId;
    property UserName: string read FUserName write FUserName;
    property DisplayName: string read FDisplayName write FDisplayName;
    property Role: string read FRole write FRole;
  end;

implementation

end.
