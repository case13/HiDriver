unit DatabaseConnectionIntf;

interface

uses
  FireDAC.Comp.Client;

type
  IDatabaseConnection = interface
    procedure Connect;
    procedure Disconnect;
    function IsConnected: Boolean;
    function GetConnection: TFDConnection;

    property Connection: TFDConnection read GetConnection;
  end;

implementation

end.
