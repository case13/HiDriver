unit ReceiptItem;

interface

type
  TReceiptItem = class
  private
    FId: Integer;
    FReceiptId: Integer;
    FProductId: Integer;
    FDescription: string;
    FQuantity: Double;
    FUnitPrice: Currency;
    FDiscountAmount: Currency;
    FTotalAmount: Currency;
    FCreatedAt: TDateTime;
  public
    property Id: Integer read FId write FId;
    property ReceiptId: Integer read FReceiptId write FReceiptId;
    property ProductId: Integer read FProductId write FProductId;
    property Description: string read FDescription write FDescription;
    property Quantity: Double read FQuantity write FQuantity;
    property UnitPrice: Currency read FUnitPrice write FUnitPrice;
    property DiscountAmount: Currency
      read FDiscountAmount write FDiscountAmount;
    property TotalAmount: Currency
      read FTotalAmount write FTotalAmount;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
  end;

implementation

end.
