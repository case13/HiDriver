unit AppBootstrap;

interface

uses
  ApiConfigIntf,
  AppBootstrapIntf;

type
  TAppBootstrap = class(TInterfacedObject, IAppBootstrap)
  private
    FConfig: IApiConfig;
  public
    constructor Create(const AConfig: IApiConfig);
    procedure Execute;
  end;

implementation

constructor TAppBootstrap.Create(const AConfig: IApiConfig);
begin
  inherited Create;
  FConfig := AConfig;
end;

procedure TAppBootstrap.Execute;
begin
  Writeln(FConfig.ApplicationName);
  Writeln('Version: ' + FConfig.Version);
  Writeln('Environment: ' + FConfig.Environment);
  Writeln('Default Port: ', FConfig.DefaultPort);
  Writeln('Status: Starting...');
end;

end.
