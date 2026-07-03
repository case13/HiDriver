unit AuthValidator;

interface

uses
  AuthValidatorIntf;

type
  TAuthValidator = class(TInterfacedObject, IAuthValidator)
  public
    function ValidateLogin(
      const AUserName,
      APassword: string;
      out AErrorMessage: string): Boolean;
  end;

implementation

uses
  System.SysUtils;

function TAuthValidator.ValidateLogin(
  const AUserName,
  APassword: string;
  out AErrorMessage: string): Boolean;
begin
  AErrorMessage := '';

  if Trim(AUserName) = '' then
    AErrorMessage := 'Username is required.'
  else if APassword = '' then
    AErrorMessage := 'Password is required.';

  Result := AErrorMessage = '';
end;

end.
