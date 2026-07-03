unit ApiConfigIntf;

interface

type
  IApiConfig = interface
    function GetApplicationName: string;
    function GetVersion: string;
    function GetEnvironment: string;
    function GetDefaultPort: Integer;
    function GetDatabasePath: string;
    function GetJwtSecret: string;
    function GetJwtIssuer: string;
    function GetJwtAudience: string;
    function GetJwtExpirationMinutes: Integer;

    property ApplicationName: string read GetApplicationName;
    property Version: string read GetVersion;
    property Environment: string read GetEnvironment;
    property DefaultPort: Integer read GetDefaultPort;
    property DatabasePath: string read GetDatabasePath;
    property JwtSecret: string read GetJwtSecret;
    property JwtIssuer: string read GetJwtIssuer;
    property JwtAudience: string read GetJwtAudience;
    property JwtExpirationMinutes: Integer
      read GetJwtExpirationMinutes;
  end;

implementation

end.
