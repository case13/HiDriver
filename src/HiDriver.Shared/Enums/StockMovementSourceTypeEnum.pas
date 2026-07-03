unit StockMovementSourceTypeEnum;

interface

type
  TStockMovementSourceTypeEnum = (
    smstSale,
    smstSaleCancellation,
    smstManualAdjustment,
    smstInitialBalance
  );

function StockMovementSourceTypeToString(
  ASourceType: TStockMovementSourceTypeEnum): string;
function TryStringToStockMovementSourceType(
  const AValue: string;
  out ASourceType: TStockMovementSourceTypeEnum): Boolean;

implementation

uses
  System.SysUtils;

function StockMovementSourceTypeToString(
  ASourceType: TStockMovementSourceTypeEnum): string;
begin
  case ASourceType of
    smstSale:
      Result := 'Sale';
    smstSaleCancellation:
      Result := 'SaleCancellation';
    smstManualAdjustment:
      Result := 'ManualAdjustment';
    smstInitialBalance:
      Result := 'InitialBalance';
  else
    Result := '';
  end;
end;

function TryStringToStockMovementSourceType(
  const AValue: string;
  out ASourceType: TStockMovementSourceTypeEnum): Boolean;
var
  SourceType: TStockMovementSourceTypeEnum;
begin
  for SourceType := Low(TStockMovementSourceTypeEnum) to
    High(TStockMovementSourceTypeEnum) do
    if SameText(
      AValue,
      StockMovementSourceTypeToString(SourceType)) then
    begin
      ASourceType := SourceType;
      Exit(True);
    end;

  ASourceType := smstSale;
  Result := False;
end;

end.
