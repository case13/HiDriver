unit CashRegisterDomainServiceIntf;

interface

uses
  CashRegister;

type
  ICashRegisterDomainService = interface
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

end.
