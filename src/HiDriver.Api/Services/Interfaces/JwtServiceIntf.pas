unit JwtServiceIntf;

interface

uses
  System.SysUtils;

type
  TJwtClaims = class
  private
    FUserId: Integer;
    FUserName: string;
    FDisplayName: string;
    FRole: string;
    FIssuer: string;
    FAudience: string;
    FExpiration: Int64;
  public
    property UserId: Integer read FUserId write FUserId;
    property UserName: string read FUserName write FUserName;
    property DisplayName: string read FDisplayName write FDisplayName;
    property Role: string read FRole write FRole;
    property Issuer: string read FIssuer write FIssuer;
    property Audience: string read FAudience write FAudience;
    property Expiration: Int64 read FExpiration write FExpiration;
  end;

  EJwtValidationException = class(Exception);
  EJwtExpiredException = class(EJwtValidationException);

  IJwtService = interface
    function GenerateToken(
      AUserId: Integer;
      const AUserName,
      ADisplayName,
      ARole: string): string;
    function ValidateToken(
      const AToken: string;
      out AExpired: Boolean): Boolean;
    // The caller owns the returned claims.
    function ExtractClaims(const AToken: string): TJwtClaims;
    function ExtractUserId(const AToken: string): Integer;
    function ExtractUserName(const AToken: string): string;
    function ExtractRole(const AToken: string): string;
  end;

implementation

end.
