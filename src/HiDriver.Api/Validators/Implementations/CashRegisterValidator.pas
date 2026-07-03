unit CashRegisterValidator;

interface

uses
  CashRegisterDtos,
  CashRegisterValidatorIntf;

type
  TCashRegisterValidator = class(
    TInterfacedObject,
    ICashRegisterValidator)
  public
    function ValidateOpen(
      ARequest: TCashOpenRequestDto;
      out AErrorMessage: string): Boolean;
    function ValidateClose(
      ARequest: TCashCloseRequestDto;
      out AErrorMessage: string): Boolean;
  end;

implementation

function TCashRegisterValidator.ValidateOpen(
  ARequest: TCashOpenRequestDto;
  out AErrorMessage: string): Boolean;
begin
  AErrorMessage := '';

  if not Assigned(ARequest) then
    AErrorMessage := 'Cash register data is required.'
  else if ARequest.UserId <= 0 then
    AErrorMessage := 'User id must be greater than zero.'
  else if ARequest.OpeningAmount < 0 then
    AErrorMessage := 'Opening amount cannot be negative.';

  Result := AErrorMessage = '';
end;

function TCashRegisterValidator.ValidateClose(
  ARequest: TCashCloseRequestDto;
  out AErrorMessage: string): Boolean;
begin
  AErrorMessage := '';

  if not Assigned(ARequest) then
    AErrorMessage := 'Cash register data is required.'
  else if ARequest.ClosingAmount < 0 then
    AErrorMessage := 'Closing amount cannot be negative.';

  Result := AErrorMessage = '';
end;

end.
