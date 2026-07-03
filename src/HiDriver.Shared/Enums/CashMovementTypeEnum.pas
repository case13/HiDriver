unit CashMovementTypeEnum;

interface

type
  TCashMovementTypeEnum = (
    cmtOpening,
    cmtSale,
    cmtSaleCancel,
    cmtSupply,
    cmtWithdrawal,
    cmtAccountReceivable,
    cmtCashCloseAdjustment
  );

function CashMovementTypeToString(
  AMovementType: TCashMovementTypeEnum): string;
function TryStringToCashMovementType(
  const AValue: string;
  out AMovementType: TCashMovementTypeEnum): Boolean;

implementation

uses
  System.SysUtils;

function CashMovementTypeToString(
  AMovementType: TCashMovementTypeEnum): string;
begin
  case AMovementType of
    cmtOpening:
      Result := 'Opening';
    cmtSale:
      Result := 'Sale';
    cmtSaleCancel:
      Result := 'SaleCancel';
    cmtSupply:
      Result := 'Supply';
    cmtWithdrawal:
      Result := 'Withdrawal';
    cmtAccountReceivable:
      Result := 'AccountReceivable';
    cmtCashCloseAdjustment:
      Result := 'CashCloseAdjustment';
  else
    Result := '';
  end;
end;

function TryStringToCashMovementType(
  const AValue: string;
  out AMovementType: TCashMovementTypeEnum): Boolean;
var
  MovementType: TCashMovementTypeEnum;
begin
  for MovementType := Low(TCashMovementTypeEnum) to
    High(TCashMovementTypeEnum) do
    if SameText(AValue, CashMovementTypeToString(MovementType)) then
    begin
      AMovementType := MovementType;
      Exit(True);
    end;

  AMovementType := cmtOpening;
  Result := False;
end;

end.
