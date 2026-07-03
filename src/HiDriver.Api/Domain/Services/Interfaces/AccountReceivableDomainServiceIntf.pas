unit AccountReceivableDomainServiceIntf;

interface

uses
  AccountReceivable;

type
  IAccountReceivableDomainService = interface
    function CalculateBalance(
      const ABalanceAmount,
      AAmount,
      ADiscountAmount,
      AInterestAmount: Currency): Currency;
    function DetermineStatus(
      const ABalanceAmount: Currency): string;
    procedure ApplyReceipt(
      AAccountReceivable: TAccountReceivable;
      const AAmount,
      ADiscountAmount,
      AInterestAmount: Currency);
    function CanCancelFromSale(
      AAccountReceivable: TAccountReceivable;
      out AErrorMessage: string): Boolean;
  end;

implementation

end.
