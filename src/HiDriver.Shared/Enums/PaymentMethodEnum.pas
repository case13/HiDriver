unit PaymentMethodEnum;

interface

type
  TPaymentMethodEnum = (
    pmCash,
    pmPix,
    pmDebit,
    pmCredit,
    pmCreditSale
  );

function PaymentMethodToString(
  APaymentMethod: TPaymentMethodEnum): string;
function TryStringToPaymentMethod(
  const AValue: string;
  out APaymentMethod: TPaymentMethodEnum): Boolean;

implementation

uses
  System.SysUtils;

function PaymentMethodToString(
  APaymentMethod: TPaymentMethodEnum): string;
begin
  case APaymentMethod of
    pmCash:
      Result := 'Cash';
    pmPix:
      Result := 'Pix';
    pmDebit:
      Result := 'Debit';
    pmCredit:
      Result := 'Credit';
    pmCreditSale:
      Result := 'CreditSale';
  else
    Result := '';
  end;
end;

function TryStringToPaymentMethod(
  const AValue: string;
  out APaymentMethod: TPaymentMethodEnum): Boolean;
var
  PaymentMethod: TPaymentMethodEnum;
begin
  for PaymentMethod := Low(TPaymentMethodEnum) to
    High(TPaymentMethodEnum) do
    if SameText(AValue, PaymentMethodToString(PaymentMethod)) then
    begin
      APaymentMethod := PaymentMethod;
      Exit(True);
    end;

  APaymentMethod := pmCash;
  Result := False;
end;

end.
