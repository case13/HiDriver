unit DesktopConfig;

interface

uses
  IDesktopConfig;

type
  TDesktopConfig = class(TInterfacedObject, IDesktopConfigContract)
  private
    FBaseApiUrl: string;
    function GetBaseApiUrl: string;
  public
    constructor Create;
  end;

implementation

uses
  System.SysUtils;

const
  DEFAULT_API_URL = 'http://localhost:9000';

constructor TDesktopConfig.Create;
begin
  inherited Create;
  FBaseApiUrl := Trim(GetEnvironmentVariable('HIDRIVER_API_URL'));
  if FBaseApiUrl = '' then
    FBaseApiUrl := DEFAULT_API_URL;

  while FBaseApiUrl.EndsWith('/') do
    Delete(FBaseApiUrl, Length(FBaseApiUrl), 1);
end;

function TDesktopConfig.GetBaseApiUrl: string;
begin
  Result := FBaseApiUrl;
end;

end.
