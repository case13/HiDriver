unit CashRegister;

interface

type
  TCashRegister = class
  private
    FId: Integer;
    FUserId: Integer;
    FStatus: string;
    FOpeningAmount: Currency;
    FClosingAmount: Currency;
    FExpectedAmount: Currency;
    FDifferenceAmount: Currency;
    FOpenedAt: TDateTime;
    FClosedAt: TDateTime;
    FCreatedAt: TDateTime;
    FUpdatedAt: TDateTime;
  public
    function IsOpen: Boolean;
    function IsClosed: Boolean;
    procedure Open;
    procedure Close(
      const AClosingAmount,
      AExpectedAmount: Currency);

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
    property OpenedAt: TDateTime read FOpenedAt write FOpenedAt;
    property ClosedAt: TDateTime read FClosedAt write FClosedAt;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
  end;

implementation

uses
  System.SysUtils,
  CashRegisterStatusEnum;

function TCashRegister.IsOpen: Boolean;
begin
  Result := SameText(FStatus, CashRegisterStatusToString(crOpen));
end;

function TCashRegister.IsClosed: Boolean;
begin
  Result := SameText(FStatus, CashRegisterStatusToString(crClosed));
end;

procedure TCashRegister.Open;
begin
  FStatus := CashRegisterStatusToString(crOpen);
  FOpenedAt := Now;
  FCreatedAt := FOpenedAt;
  FExpectedAmount := FOpeningAmount;
end;

procedure TCashRegister.Close(
  const AClosingAmount,
  AExpectedAmount: Currency);
begin
  FClosingAmount := AClosingAmount;
  FExpectedAmount := AExpectedAmount;
  FDifferenceAmount := AClosingAmount - AExpectedAmount;
  FStatus := CashRegisterStatusToString(crClosed);
  FClosedAt := Now;
  FUpdatedAt := FClosedAt;
end;

end.
