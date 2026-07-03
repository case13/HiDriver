unit AuthAppServiceIntf;

interface

uses
  System.SysUtils,
  AuthDtos;

type
  EAuthValidationException = class(Exception);
  EInvalidCredentialsException = class(Exception);

  IAuthAppService = interface
    function Login(
      const AUserName,
      APassword: string): TLoginResponseDto;
  end;

implementation

end.
