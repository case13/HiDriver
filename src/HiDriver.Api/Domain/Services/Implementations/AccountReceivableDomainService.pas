unit AccountReceivableDomainService;

interface

uses
  AccountReceivable,
  AccountReceivableDomainServiceIntf;

type
  TAccountReceivableDomainService = class(
    TInterfacedObject,
    IAccountReceivableDomainService)
  public
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

uses
  System.SysUtils,
  AccountReceivableStatusEnum;

function TAccountReceivableDomainService.CalculateBalance(
  const ABalanceAmount,
  AAmount,
  ADiscountAmount,
  AInterestAmount: Currency): Currency;
begin
  Result :=
    ABalanceAmount -
    AAmount -
    ADiscountAmount +
    AInterestAmount;
  if Result < 0 then
    Result := 0;
end;

function TAccountReceivableDomainService.DetermineStatus(
  const ABalanceAmount: Currency): string;
begin
  if ABalanceAmount <= 0 then
    Result := AccountReceivableStatusToString(arsReceived)
  else
    Result := AccountReceivableStatusToString(arsPartial);
end;

procedure TAccountReceivableDomainService.ApplyReceipt(
  AAccountReceivable: TAccountReceivable;
  const AAmount,
  ADiscountAmount,
  AInterestAmount: Currency);
begin
  AAccountReceivable.BalanceAmount := CalculateBalance(
    AAccountReceivable.BalanceAmount,
    AAmount,
    ADiscountAmount,
    AInterestAmount);
  AAccountReceivable.ReceivedAmount :=
    AAccountReceivable.ReceivedAmount + AAmount;
  AAccountReceivable.Status := DetermineStatus(
    AAccountReceivable.BalanceAmount);
  AAccountReceivable.UpdatedAt := Now;
end;

function TAccountReceivableDomainService.CanCancelFromSale(
  AAccountReceivable: TAccountReceivable;
  out AErrorMessage: string): Boolean;
begin
  AErrorMessage := '';

  if not Assigned(AAccountReceivable) then
    Exit(True);

  if AAccountReceivable.IsCanceled then
    Exit(True);

  if (AAccountReceivable.ReceivedAmount > 0) or
    SameText(
      AAccountReceivable.Status,
      AccountReceivableStatusToString(arsPartial)) or
    AAccountReceivable.IsReceived then
    AErrorMessage :=
      'Sale has an account receivable with registered payments and ' +
      'cannot be canceled in this stage.'
  else if not SameText(
    AAccountReceivable.Status,
    AccountReceivableStatusToString(arsOpen)) then
    AErrorMessage :=
      'Account receivable status does not allow sale cancellation.';

  Result := AErrorMessage = '';
end;

end.
