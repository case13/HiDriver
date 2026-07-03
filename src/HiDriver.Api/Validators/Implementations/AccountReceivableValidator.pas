unit AccountReceivableValidator;

interface

uses
  AccountReceivable,
  AccountReceivableDto,
  AccountReceivableValidatorIntf;

type
  TAccountReceivableValidator = class(
    TInterfacedObject,
    IAccountReceivableValidator)
  public
    function ValidateReceive(
      ARequest: TReceiveAccountReceivableRequestDto;
      AAccountReceivable: TAccountReceivable;
      out AErrorMessage: string): Boolean;
  end;

implementation

uses
  PaymentMethodEnum;

function TAccountReceivableValidator.ValidateReceive(
  ARequest: TReceiveAccountReceivableRequestDto;
  AAccountReceivable: TAccountReceivable;
  out AErrorMessage: string): Boolean;
var
  EffectiveReduction: Currency;
  PaymentMethod: TPaymentMethodEnum;
begin
  AErrorMessage := '';

  if not Assigned(ARequest) then
    AErrorMessage := 'Receipt data is required.'
  else if ARequest.AccountReceivableId <= 0 then
    AErrorMessage := 'Account receivable id must be greater than zero.'
  else if ARequest.UserId <= 0 then
    AErrorMessage := 'User id must be greater than zero.'
  else if ARequest.Amount <= 0 then
    AErrorMessage := 'Amount must be greater than zero.'
  else if ARequest.DiscountAmount < 0 then
    AErrorMessage := 'Discount amount cannot be negative.'
  else if ARequest.InterestAmount < 0 then
    AErrorMessage := 'Interest amount cannot be negative.'
  else if not TryStringToPaymentMethod(
    ARequest.PaymentMethod,
    PaymentMethod) then
    AErrorMessage := 'Payment method is invalid.'
  else if PaymentMethod = pmCreditSale then
    AErrorMessage := 'CreditSale cannot be used to receive an account.'
  else if not Assigned(AAccountReceivable) then
    AErrorMessage := 'Account receivable not found.'
  else if AAccountReceivable.IsReceived then
    AErrorMessage := 'Account receivable is already received.'
  else if AAccountReceivable.IsCanceled then
    AErrorMessage := 'Canceled account receivable cannot be received.'
  else
  begin
    EffectiveReduction :=
      ARequest.Amount +
      ARequest.DiscountAmount -
      ARequest.InterestAmount;

    if EffectiveReduction <= 0 then
      AErrorMessage :=
        'Receipt must reduce the account balance.'
    else if EffectiveReduction > AAccountReceivable.BalanceAmount then
      AErrorMessage :=
        'Receipt amount cannot exceed the account balance.';
  end;

  Result := AErrorMessage = '';
end;

end.
