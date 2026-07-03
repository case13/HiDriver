unit AccountReceivableDto;

interface

type
  TAccountReceivableDto = class
  private
    FId: Integer;
    FSaleId: Integer;
    FCustomerId: Integer;
    FCustomerName: string;
    FIssueDate: string;
    FDueDate: string;
    FTotalAmount: Currency;
    FReceivedAmount: Currency;
    FBalanceAmount: Currency;
    FStatus: string;
    FNotes: string;
  public
    property Id: Integer read FId write FId;
    property SaleId: Integer read FSaleId write FSaleId;
    property CustomerId: Integer read FCustomerId write FCustomerId;
    property CustomerName: string
      read FCustomerName write FCustomerName;
    property IssueDate: string read FIssueDate write FIssueDate;
    property DueDate: string read FDueDate write FDueDate;
    property TotalAmount: Currency
      read FTotalAmount write FTotalAmount;
    property ReceivedAmount: Currency
      read FReceivedAmount write FReceivedAmount;
    property BalanceAmount: Currency
      read FBalanceAmount write FBalanceAmount;
    property Status: string read FStatus write FStatus;
    property Notes: string read FNotes write FNotes;
  end;

  TReceiveAccountReceivableRequestDto = class
  private
    FAccountReceivableId: Integer;
    FUserId: Integer;
    FPaymentMethod: string;
    FAmount: Currency;
    FDiscountAmount: Currency;
    FInterestAmount: Currency;
    FNotes: string;
  public
    property AccountReceivableId: Integer
      read FAccountReceivableId write FAccountReceivableId;
    property UserId: Integer read FUserId write FUserId;
    property PaymentMethod: string
      read FPaymentMethod write FPaymentMethod;
    property Amount: Currency read FAmount write FAmount;
    property DiscountAmount: Currency
      read FDiscountAmount write FDiscountAmount;
    property InterestAmount: Currency
      read FInterestAmount write FInterestAmount;
    property Notes: string read FNotes write FNotes;
  end;

  TReceiveAccountReceivableResponseDto = class
  private
    FAccountReceivableId: Integer;
    FStatus: string;
    FTotalAmount: Currency;
    FReceivedAmount: Currency;
    FBalanceAmount: Currency;
    FMessage: string;
  public
    property AccountReceivableId: Integer
      read FAccountReceivableId write FAccountReceivableId;
    property Status: string read FStatus write FStatus;
    property TotalAmount: Currency
      read FTotalAmount write FTotalAmount;
    property ReceivedAmount: Currency
      read FReceivedAmount write FReceivedAmount;
    property BalanceAmount: Currency
      read FBalanceAmount write FBalanceAmount;
    property Message: string read FMessage write FMessage;
  end;

  TAccountReceivablePaymentDto = class
  private
    FId: Integer;
    FAccountReceivableId: Integer;
    FCashRegisterId: Integer;
    FCashMovementId: Integer;
    FPaymentDate: string;
    FPaymentMethod: string;
    FAmount: Currency;
    FDiscountAmount: Currency;
    FInterestAmount: Currency;
    FTotalReceived: Currency;
    FNotes: string;
  public
    property Id: Integer read FId write FId;
    property AccountReceivableId: Integer
      read FAccountReceivableId write FAccountReceivableId;
    property CashRegisterId: Integer
      read FCashRegisterId write FCashRegisterId;
    property CashMovementId: Integer
      read FCashMovementId write FCashMovementId;
    property PaymentDate: string read FPaymentDate write FPaymentDate;
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
  end;

implementation

end.
