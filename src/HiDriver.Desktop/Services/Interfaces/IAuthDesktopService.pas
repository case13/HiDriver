unit IAuthDesktopService;

interface

type
  IAuthDesktopServiceContract = interface
    ['{7EF2F066-E888-4F07-98B7-258D5EE3B54E}']
    function Login(const AUserName, APassword: string): Boolean;
    procedure Logout;
    function GetLastError: string;
    property LastError: string read GetLastError;
  end;

implementation

end.
