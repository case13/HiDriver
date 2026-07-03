unit StockMovementTypeEnum;

interface

type
  TStockMovementTypeEnum = (
    smtIn,
    smtOut,
    smtAdjustment,
    smtReversal
  );

function StockMovementTypeToString(
  AMovementType: TStockMovementTypeEnum): string;
function TryStringToStockMovementType(
  const AValue: string;
  out AMovementType: TStockMovementTypeEnum): Boolean;

implementation

uses
  System.SysUtils;

function StockMovementTypeToString(
  AMovementType: TStockMovementTypeEnum): string;
begin
  case AMovementType of
    smtIn:
      Result := 'In';
    smtOut:
      Result := 'Out';
    smtAdjustment:
      Result := 'Adjustment';
    smtReversal:
      Result := 'Reversal';
  else
    Result := '';
  end;
end;

function TryStringToStockMovementType(
  const AValue: string;
  out AMovementType: TStockMovementTypeEnum): Boolean;
var
  MovementType: TStockMovementTypeEnum;
begin
  for MovementType := Low(TStockMovementTypeEnum) to
    High(TStockMovementTypeEnum) do
    if SameText(AValue, StockMovementTypeToString(MovementType)) then
    begin
      AMovementType := MovementType;
      Exit(True);
    end;

  AMovementType := smtIn;
  Result := False;
end;

end.
