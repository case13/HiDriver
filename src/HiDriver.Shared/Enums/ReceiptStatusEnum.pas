unit ReceiptStatusEnum;

interface

type
  TReceiptStatusEnum = (
    rsIssued,
    rsCanceled
  );

function ReceiptStatusToString(AStatus: TReceiptStatusEnum): string;
function TryStringToReceiptStatus(
  const AValue: string;
  out AStatus: TReceiptStatusEnum): Boolean;

implementation

uses
  System.SysUtils;

function ReceiptStatusToString(AStatus: TReceiptStatusEnum): string;
begin
  case AStatus of
    rsIssued:
      Result := 'Issued';
    rsCanceled:
      Result := 'Canceled';
  else
    Result := '';
  end;
end;

function TryStringToReceiptStatus(
  const AValue: string;
  out AStatus: TReceiptStatusEnum): Boolean;
var
  Status: TReceiptStatusEnum;
begin
  for Status := Low(TReceiptStatusEnum) to High(TReceiptStatusEnum) do
    if SameText(AValue, ReceiptStatusToString(Status)) then
    begin
      AStatus := Status;
      Exit(True);
    end;

  AStatus := rsIssued;
  Result := False;
end;

end.
