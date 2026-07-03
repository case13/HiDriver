unit ReceiptSourceTypeEnum;

interface

type
  TReceiptSourceTypeEnum = (
    rstSale,
    rstAccountReceivablePayment
  );

function ReceiptSourceTypeToString(
  ASourceType: TReceiptSourceTypeEnum): string;
function TryStringToReceiptSourceType(
  const AValue: string;
  out ASourceType: TReceiptSourceTypeEnum): Boolean;

implementation

uses
  System.SysUtils;

function ReceiptSourceTypeToString(
  ASourceType: TReceiptSourceTypeEnum): string;
begin
  case ASourceType of
    rstSale:
      Result := 'Sale';
    rstAccountReceivablePayment:
      Result := 'AccountReceivablePayment';
  else
    Result := '';
  end;
end;

function TryStringToReceiptSourceType(
  const AValue: string;
  out ASourceType: TReceiptSourceTypeEnum): Boolean;
var
  SourceType: TReceiptSourceTypeEnum;
begin
  for SourceType := Low(TReceiptSourceTypeEnum) to
    High(TReceiptSourceTypeEnum) do
    if SameText(AValue, ReceiptSourceTypeToString(SourceType)) then
    begin
      ASourceType := SourceType;
      Exit(True);
    end;

  ASourceType := rstSale;
  Result := False;
end;

end.
