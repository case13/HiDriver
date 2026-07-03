unit Receipt;

interface

uses
  System.Generics.Collections,
  ReceiptItem;

type
  TReceipt = class
  private
    FId: Integer;
    FReceiptNumber: string;
    FSourceType: string;
    FSourceId: Integer;
    FCustomerId: Integer;
    FCustomerName: string;
    FCustomerDocument: string;
    FIssueDate: TDateTime;
    FSubtotalAmount: Currency;
    FDiscountAmount: Currency;
    FTotalAmount: Currency;
    FPaymentSummary: string;
    FNotes: string;
    FStatus: string;
    FCreatedByUserId: Integer;
    FIsActive: Boolean;
    FCreatedAt: TDateTime;
    FUpdatedAt: TDateTime;
    FItems: TObjectList<TReceiptItem>;
  public
    constructor Create;
    destructor Destroy; override;
    function IsCanceled: Boolean;
    procedure Cancel;

    property Id: Integer read FId write FId;
    property ReceiptNumber: string
      read FReceiptNumber write FReceiptNumber;
    property SourceType: string read FSourceType write FSourceType;
    property SourceId: Integer read FSourceId write FSourceId;
    property CustomerId: Integer read FCustomerId write FCustomerId;
    property CustomerName: string
      read FCustomerName write FCustomerName;
    property CustomerDocument: string
      read FCustomerDocument write FCustomerDocument;
    property IssueDate: TDateTime read FIssueDate write FIssueDate;
    property SubtotalAmount: Currency
      read FSubtotalAmount write FSubtotalAmount;
    property DiscountAmount: Currency
      read FDiscountAmount write FDiscountAmount;
    property TotalAmount: Currency
      read FTotalAmount write FTotalAmount;
    property PaymentSummary: string
      read FPaymentSummary write FPaymentSummary;
    property Notes: string read FNotes write FNotes;
    property Status: string read FStatus write FStatus;
    property CreatedByUserId: Integer
      read FCreatedByUserId write FCreatedByUserId;
    property IsActive: Boolean read FIsActive write FIsActive;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
    property Items: TObjectList<TReceiptItem> read FItems;
  end;

implementation

uses
  System.SysUtils,
  ReceiptStatusEnum;

constructor TReceipt.Create;
begin
  inherited Create;
  FItems := TObjectList<TReceiptItem>.Create(True);
end;

destructor TReceipt.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TReceipt.IsCanceled: Boolean;
begin
  Result := SameText(FStatus, ReceiptStatusToString(rsCanceled));
end;

procedure TReceipt.Cancel;
begin
  FStatus := ReceiptStatusToString(rsCanceled);
  FUpdatedAt := Now;
end;

end.
