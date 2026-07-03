unit HealthController;

interface

uses
  ApiConfigIntf,
  HealthControllerIntf;

type
  THealthController = class(TInterfacedObject, IHealthController)
  private
    FConfig: IApiConfig;
  public
    constructor Create(const AConfig: IApiConfig);
    procedure RegisterRoutes;
  end;

implementation

uses
  System.SysUtils,
  Horse;

constructor THealthController.Create(const AConfig: IApiConfig);
begin
  inherited Create;
  FConfig := AConfig;
end;

procedure THealthController.RegisterRoutes;
begin
  THorse.Get('/api/health',
    procedure(Res: THorseResponse)
    begin
      Res
        .ContentType('application/json')
        .Send(Format(
          '{"success":true,"application":"%s","version":"%s",' +
          '"environment":"%s","status":"Healthy"}',
          [
            FConfig.ApplicationName,
            FConfig.Version,
            FConfig.Environment
          ]));
    end);
end;

end.
