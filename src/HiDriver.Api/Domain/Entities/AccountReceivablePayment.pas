unit AccountReceivablePayment;

interface

type
  TAccountReceivablePayment = class
  private
    FId: Integer;
    FAccountReceivableId: Integer;
    FCashRegisterId: Integer;
    FCashMovementId: Integer;
    FPaymentDate: TDateTime;
    FPaymentMethod: string;
    FAmount: Currency;
    FDiscountAmount: Currency;
    FInterestAmount: Currency;
    FTotalReceived: Currency;
    FNotes: string;
    FCreatedAt: TDateTime;
  public
    property Id: Integer read FId write FId;
    property AccountReceivableId: Integer
      read FAccountReceivableId write FAccountReceivableId;
    property CashRegisterId: Integer
      read FCashRegisterId write FCashRegisterId;
    property CashMovementId: Integer
      read FCashMovementId write FCashMovementId;
    property PaymentDate: TDateTime
      read FPaymentDate write FPaymentDate;
    property PaymentMethod: string
      read FPaymentMethod write FPaymentMethod;
    property Amount: Currency read FAmount write FAmount;
    property DiscountAmount: Currency
      read FDiscountAmount write FDiscountAmount;
    property InterestAmount: Currency
      read FInterestAmount write FInterestAmount;
    property TotalReceived: Currency
      read FTotalReceived write FTotalReceived;
    property Notes: string read FNotes write FNotes;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
  end;

implementation

end.
