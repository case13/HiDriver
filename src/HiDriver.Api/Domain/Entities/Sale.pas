unit Sale;

interface

type
  TSale = class
  private
    FId: Integer;
    FCustomerId: Integer;
    FCashRegisterId: Integer;
    FSaleDate: TDateTime;
    FSubtotalAmount: Currency;
    FDiscountAmount: Currency;
    FTotalAmount: Currency;
    FStatus: string;
    FNotes: string;
    FCreatedAt: TDateTime;
    FUpdatedAt: TDateTime;
    FCanceledAt: TDateTime;
  public
    function IsCanceled: Boolean;
    procedure Cancel;
    procedure Complete;

    property Id: Integer read FId write FId;
    property CustomerId: Integer read FCustomerId write FCustomerId;
    property CashRegisterId: Integer
      read FCashRegisterId write FCashRegisterId;
    property SaleDate: TDateTime read FSaleDate write FSaleDate;
    property SubtotalAmount: Currency
      read FSubtotalAmount write FSubtotalAmount;
    property DiscountAmount: Currency
      read FDiscountAmount write FDiscountAmount;
    property TotalAmount: Currency
      read FTotalAmount write FTotalAmount;
    property Status: string read FStatus write FStatus;
    property Notes: string read FNotes write FNotes;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
    property CanceledAt: TDateTime read FCanceledAt write FCanceledAt;
  end;

implementation

uses
  System.SysUtils,
  SaleStatusEnum;

function TSale.IsCanceled: Boolean;
begin
  Result := SameText(FStatus, SaleStatusToString(ssCanceled));
end;

procedure TSale.Cancel;
begin
  FStatus := SaleStatusToString(ssCanceled);
  FCanceledAt := Now;
  FUpdatedAt := FCanceledAt;
end;

procedure TSale.Complete;
begin
  FStatus := SaleStatusToString(ssCompleted);
  FSaleDate := Now;
  FCreatedAt := FSaleDate;
end;

end.
