unit CashRegisterDomainService;

interface

uses
  CashRegister,
  CashRegisterDomainServiceIntf;

type
  TCashRegisterDomainService = class(
    TInterfacedObject,
    ICashRegisterDomainService)
  public
    function CanOpenCashRegister(
      AHasOpenCashRegister: Boolean;
      out AErrorMessage: string): Boolean;
    function CanCloseCashRegister(
      ACashRegister: TCashRegister;
      out AErrorMessage: string): Boolean;
    function CalculateExpectedAmount(
      const AOpeningAmount,
      AMovementsTotal: Currency): Currency;
    function CalculateDifference(
      const AClosingAmount,
      AExpectedAmount: Currency): Currency;
  end;

implementation

function TCashRegisterDomainService.CanOpenCashRegister(
  AHasOpenCashRegister: Boolean;
  out AErrorMessage: string): Boolean;
begin
  AErrorMessage := '';
  if AHasOpenCashRegister then
    AErrorMessage := 'There is already an open cash register.';
  Result := AErrorMessage = '';
end;

function TCashRegisterDomainService.CanCloseCashRegister(
  ACashRegister: TCashRegister;
  out AErrorMessage: string): Boolean;
begin
  AErrorMessage := '';

  if not Assigned(ACashRegister) then
    AErrorMessage := 'There is no open cash register.'
  else if ACashRegister.IsClosed then
    AErrorMessage := 'Cash register is already closed.'
  else if not ACashRegister.IsOpen then
    AErrorMessage := 'Cash register status is invalid.';

  Result := AErrorMessage = '';
end;

function TCashRegisterDomainService.CalculateExpectedAmount(
  const AOpeningAmount,
  AMovementsTotal: Currency): Currency;
begin
  Result := AOpeningAmount + AMovementsTotal;
end;

function TCashRegisterDomainService.CalculateDifference(
  const AClosingAmount,
  AExpectedAmount: Currency): Currency;
begin
  Result := AClosingAmount - AExpectedAmount;
end;

end.
