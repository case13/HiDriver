unit ApiConfigIntf;

interface

type
  IApiConfig = interface
    function GetApplicationName: string;
    function GetVersion: string;
    function GetEnvironment: string;
    function GetDefaultPort: Integer;
    function GetDatabasePath: string;

    property ApplicationName: string read GetApplicationName;
    property Version: string read GetVersion;
    property Environment: string read GetEnvironment;
    property DefaultPort: Integer read GetDefaultPort;
    property DatabasePath: string read GetDatabasePath;
  end;

implementation

end.
