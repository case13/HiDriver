unit SaleItem;

interface

type
  TSaleItem = class
  private
    FId: Integer;
    FSaleId: Integer;
    FProductId: Integer;
    FProductDescription: string;
    FQuantity: Double;
    FUnitPrice: Currency;
    FDiscountAmount: Currency;
    FTotalAmount: Currency;
    FCreatedAt: TDateTime;
  public
    function CalculateTotal: Currency;

    property Id: Integer read FId write FId;
    property SaleId: Integer read FSaleId write FSaleId;
    property ProductId: Integer read FProductId write FProductId;
    property ProductDescription: string
      read FProductDescription write FProductDescription;
    property Quantity: Double read FQuantity write FQuantity;
    property UnitPrice: Currency read FUnitPrice write FUnitPrice;
    property DiscountAmount: Currency
      read FDiscountAmount write FDiscountAmount;
    property TotalAmount: Currency
      read FTotalAmount write FTotalAmount;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
  end;

implementation

function TSaleItem.CalculateTotal: Currency;
begin
  Result := (FQuantity * FUnitPrice) - FDiscountAmount;
end;

end.
