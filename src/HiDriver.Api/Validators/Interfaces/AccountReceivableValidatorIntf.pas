unit AccountReceivableValidatorIntf;

interface

uses
  AccountReceivable,
  AccountReceivableDto;

type
  IAccountReceivableValidator = interface
    function ValidateReceive(
      ARequest: TReceiveAccountReceivableRequestDto;
      AAccountReceivable: TAccountReceivable;
      out AErrorMessage: string): Boolean;
  end;

implementation

end.
