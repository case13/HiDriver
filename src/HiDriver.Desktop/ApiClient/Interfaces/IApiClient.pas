unit IApiClient;

interface

type
  IApiClientContract = interface
    ['{5E6BE7FB-9194-42DC-A8B7-6D9B71349DD1}']
    function Get(const APath: string): string;
    function Post(const APath, AJsonBody: string): string;
    function Put(const APath, AJsonBody: string): string;
    function Delete(const APath: string): string;
    procedure SetBearerToken(const AToken: string);
    procedure ClearBearerToken;
    function GetLastStatusCode: Integer;
    function GetLastError: string;
    property LastStatusCode: Integer read GetLastStatusCode;
    property LastError: string read GetLastError;
  end;

implementation

end.
