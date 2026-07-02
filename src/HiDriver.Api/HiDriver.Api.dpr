program HiDriver.Api;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ApiConfigIntf in 'Config\Interfaces\ApiConfigIntf.pas',
  ApiConfig in 'Config\Implementations\ApiConfig.pas',
  AppBootstrapIntf in 'Config\Interfaces\AppBootstrapIntf.pas',
  Horse,
  AppBootstrap in 'Config\Implementations\AppBootstrap.pas';

var
  Config: IApiConfig;
  Bootstrap: IAppBootstrap;

begin
  try
    Config := TApiConfig.Create;
    Bootstrap := TAppBootstrap.Create(Config);
    Bootstrap.Execute;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
