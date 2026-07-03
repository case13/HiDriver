unit CashRegisterValidatorIntf;

interface

uses
  CashRegisterDtos;

type
  ICashRegisterValidator = interface
    function ValidateOpen(
      ARequest: TCashOpenRequestDto;
      out AErrorMessage: string): Boolean;
    function ValidateClose(
      ARequest: TCashCloseRequestDto;
      out AErrorMessage: string): Boolean;
  end;

implementation

end.
