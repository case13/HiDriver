unit SalePayment;

interface

type
  TSalePayment = class
  private
    FId: Integer;
    FSaleId: Integer;
    FPaymentMethod: string;
    FAmount: Currency;
    FCreatedAt: TDateTime;
  public
    function AffectsCashRegister: Boolean;

    property Id: Integer read FId write FId;
    property SaleId: Integer read FSaleId write FSaleId;
    property PaymentMethod: string
      read FPaymentMethod write FPaymentMethod;
    property Amount: Currency read FAmount write FAmount;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
  end;

implementation

uses
  PaymentMethodEnum;

function TSalePayment.AffectsCashRegister: Boolean;
var
  PaymentMethod: TPaymentMethodEnum;
begin
  Result :=
    TryStringToPaymentMethod(FPaymentMethod, PaymentMethod) and
    (PaymentMethod <> pmCreditSale);
end;

end.
