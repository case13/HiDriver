unit SaleStatusEnum;

interface

type
  TSaleStatusEnum = (
    ssCompleted,
    ssCanceled
  );

function SaleStatusToString(AStatus: TSaleStatusEnum): string;

implementation

function SaleStatusToString(AStatus: TSaleStatusEnum): string;
begin
  case AStatus of
    ssCompleted:
      Result := 'Completed';
    ssCanceled:
      Result := 'Canceled';
  else
    Result := '';
  end;
end;

end.
