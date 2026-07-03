unit AccountReceivableStatusEnum;

interface

type
  TAccountReceivableStatusEnum = (
    arsOpen,
    arsPartial,
    arsReceived,
    arsOverdue,
    arsCanceled
  );

function AccountReceivableStatusToString(
  AStatus: TAccountReceivableStatusEnum): string;

implementation

function AccountReceivableStatusToString(
  AStatus: TAccountReceivableStatusEnum): string;
begin
  case AStatus of
    arsOpen:
      Result := 'Open';
    arsPartial:
      Result := 'Partial';
    arsReceived:
      Result := 'Received';
    arsOverdue:
      Result := 'Overdue';
    arsCanceled:
      Result := 'Canceled';
  else
    Result := '';
  end;
end;

end.
