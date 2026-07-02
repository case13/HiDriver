unit ApiConfig;

interface

uses
  ApiConfigIntf;

type
  TApiConfig = class(TInterfacedObject, IApiConfig)
  public
    function GetApplicationName: string;
    function GetVersion: string;
    function GetEnvironment: string;
    function GetDefaultPort: Integer;
  end;

implementation

function TApiConfig.GetApplicationName: string;
begin
  Result := 'HiDriver API';
end;

function TApiConfig.GetVersion: string;
begin
  Result := '0.1.0';
end;

function TApiConfig.GetEnvironment: string;
begin
  Result := 'Development';
end;

function TApiConfig.GetDefaultPort: Integer;
begin
  Result := 9000;
end;

end.
