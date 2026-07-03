unit AccountReceivable;

interface

type
  TAccountReceivable = class
  private
    FId: Integer;
    FSaleId: Integer;
    FCustomerId: Integer;
    FIssueDate: TDateTime;
    FDueDate: TDateTime;
    FTotalAmount: Currency;
    FReceivedAmount: Currency;
    FBalanceAmount: Currency;
    FStatus: string;
    FNotes: string;
    FIsActive: Boolean;
    FCreatedAt: TDateTime;
    FUpdatedAt: TDateTime;
  public
    function IsReceived: Boolean;
    function IsCanceled: Boolean;
    procedure Cancel;

    property Id: Integer read FId write FId;
    property SaleId: Integer read FSaleId write FSaleId;
    property CustomerId: Integer read FCustomerId write FCustomerId;
    property IssueDate: TDateTime read FIssueDate write FIssueDate;
    property DueDate: TDateTime read FDueDate write FDueDate;
    property TotalAmount: Currency
      read FTotalAmount write FTotalAmount;
    property ReceivedAmount: Currency
      read FReceivedAmount write FReceivedAmount;
    property BalanceAmount: Currency
      read FBalanceAmount write FBalanceAmount;
    property Status: string read FStatus write FStatus;
    property Notes: string read FNotes write FNotes;
    property IsActive: Boolean read FIsActive write FIsActive;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
  end;

implementation

uses
  System.SysUtils,
  AccountReceivableStatusEnum;

function TAccountReceivable.IsReceived: Boolean;
begin
  Result := SameText(
    FStatus,
    AccountReceivableStatusToString(arsReceived));
end;

function TAccountReceivable.IsCanceled: Boolean;
begin
  Result := SameText(
    FStatus,
    AccountReceivableStatusToString(arsCanceled));
end;

procedure TAccountReceivable.Cancel;
begin
  FStatus := AccountReceivableStatusToString(arsCanceled);
  FUpdatedAt := Now;
end;

end.
