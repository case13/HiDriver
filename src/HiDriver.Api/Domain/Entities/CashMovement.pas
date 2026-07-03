unit CashMovement;

interface

type
  TCashMovement = class
  private
    FId: Integer;
    FCashRegisterId: Integer;
    FMovementType: string;
    FDescription: string;
    FAmount: Currency;
    FPaymentMethod: string;
    FReferenceType: string;
    FReferenceId: Integer;
    FCreatedAt: TDateTime;
  public
    function AffectsBalance: Boolean;

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
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
  end;

implementation

uses
  CashMovementTypeEnum;

function TCashMovement.AffectsBalance: Boolean;
var
  MovementType: TCashMovementTypeEnum;
begin
  Result := TryStringToCashMovementType(FMovementType, MovementType);
end;

end.
