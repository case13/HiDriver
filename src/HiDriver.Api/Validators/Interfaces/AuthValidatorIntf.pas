unit AuthValidatorIntf;

interface

type
  IAuthValidator = interface
    function ValidateLogin(
      const AUserName,
      APassword: string;
      out AErrorMessage: string): Boolean;
  end;

implementation

end.
