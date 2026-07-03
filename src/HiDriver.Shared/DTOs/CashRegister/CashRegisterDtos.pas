unit CashRegisterDtos;

interface

type
  TCashOpenRequestDto = class
  private
    FUserId: Integer;
    FOpeningAmount: Currency;
  public
    property UserId: Integer read FUserId write FUserId;
    property OpeningAmount: Currency
      read FOpeningAmount write FOpeningAmount;
  end;

  TCashCloseRequestDto = class
  private
    FClosingAmount: Currency;
  public
    property ClosingAmount: Currency
      read FClosingAmount write FClosingAmount;
  end;

  TCashRegisterReadDto = class
  private
    FId: Integer;
    FUserId: Integer;
    FStatus: string;
    FOpeningAmount: Currency;
    FClosingAmount: Currency;
    FExpectedAmount: Currency;
    FDifferenceAmount: Currency;
    FOpenedAt: string;
    FClosedAt: string;
  public
    property Id: Integer read FId write FId;
    property UserId: Integer read FUserId write FUserId;
    property Status: string read FStatus write FStatus;
    property OpeningAmount: Currency
      read FOpeningAmount write FOpeningAmount;
    property ClosingAmount: Currency
      read FClosingAmount write FClosingAmount;
    property ExpectedAmount: Currency
      read FExpectedAmount write FExpectedAmount;
    property DifferenceAmount: Currency
      read FDifferenceAmount write FDifferenceAmount;
    property OpenedAt: string read FOpenedAt write FOpenedAt;
    property ClosedAt: string read FClosedAt write FClosedAt;
  end;

  TCashMovementReadDto = class
  private
    FId: Integer;
    FCashRegisterId: Integer;
    FMovementType: string;
    FDescription: string;
    FAmount: Currency;
    FPaymentMethod: string;
    FReferenceType: string;
    FReferenceId: Integer;
    FCreatedAt: string;
  public
    property Id: Integer read FId write FId;
    property CashRegisterId: Integer
      read FCashRegisterId write FCashRegisterId;
    property MovementType: string
      read FMovementType write FMovementType;
    property Description: string read FDescription write FDescription;
    property Amount: Currency read FAmount write FAmount;
    property PaymentMethod: string
      read FPaymentMethod write FPaymentMethod;
    property ReferenceType: string
      read FReferenceType write FReferenceType;
    property ReferenceId: Integer read FReferenceId write FReferenceId;
    property CreatedAt: string read FCreatedAt write FCreatedAt;
  end;

implementation

end.
