unit CashRegisterStatusEnum;

interface

type
  TCashRegisterStatusEnum = (
    crOpen,
    crClosed
  );

function CashRegisterStatusToString(
  AStatus: TCashRegisterStatusEnum): string;

implementation

function CashRegisterStatusToString(
  AStatus: TCashRegisterStatusEnum): string;
begin
  case AStatus of
    crOpen:
      Result := 'Open';
    crClosed:
      Result := 'Closed';
  else
    Result := '';
  end;
end;

end.
