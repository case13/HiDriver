unit ReceiptDto;

interface

uses
  System.Generics.Collections;

type
  TReceiptItemDto = class
  private
    FId: Integer;
    FProductId: Integer;
    FDescription: string;
    FQuantity: Double;
    FUnitPrice: Currency;
    FDiscountAmount: Currency;
    FTotalAmount: Currency;
  public
    property Id: Integer read FId write FId;
    property ProductId: Integer read FProductId write FProductId;
    property Description: string read FDescription write FDescription;
    property Quantity: Double read FQuantity write FQuantity;
    property UnitPrice: Currency read FUnitPrice write FUnitPrice;
    property DiscountAmount: Currency
      read FDiscountAmount write FDiscountAmount;
    property TotalAmount: Currency
      read FTotalAmount write FTotalAmount;
  end;

  TReceiptDto = class
  private
    FId: Integer;
    FReceiptNumber: string;
    FSourceType: string;
    FSourceId: Integer;
    FCustomerId: Integer;
    FCustomerName: string;
    FCustomerDocument: string;
    FIssueDate: string;
    FSubtotalAmount: Currency;
    FDiscountAmount: Currency;
    FTotalAmount: Currency;
    FPaymentSummary: string;
    FNotes: string;
    FStatus: string;
    FItems: TObjectList<TReceiptItemDto>;
  public
    constructor Create;
    destructor Destroy; override;

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
    property IssueDate: string read FIssueDate write FIssueDate;
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
    property Items: TObjectList<TReceiptItemDto> read FItems;
  end;

  TIssueSaleReceiptRequestDto = class
  private
    FSaleId: Integer;
    FUserId: Integer;
    FNotes: string;
  public
    property SaleId: Integer read FSaleId write FSaleId;
    property UserId: Integer read FUserId write FUserId;
    property Notes: string read FNotes write FNotes;
  end;

  TIssueAccountReceivablePaymentReceiptRequestDto = class
  private
    FAccountReceivablePaymentId: Integer;
    FUserId: Integer;
    FNotes: string;
  public
    property AccountReceivablePaymentId: Integer
      read FAccountReceivablePaymentId
      write FAccountReceivablePaymentId;
    property UserId: Integer read FUserId write FUserId;
    property Notes: string read FNotes write FNotes;
  end;

implementation

constructor TReceiptDto.Create;
begin
  inherited Create;
  FItems := TObjectList<TReceiptItemDto>.Create(True);
end;

destructor TReceiptDto.Destroy;
begin
  FItems.Free;
  inherited;
end;

end.
