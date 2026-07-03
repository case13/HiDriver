unit SaleDtos;

interface

uses
  System.Generics.Collections;

type
  TSaleItemCreateDto = class
  private
    FProductId: Integer;
    FQuantity: Double;
    FUnitPrice: Currency;
    FDiscountAmount: Currency;
  public
    property ProductId: Integer read FProductId write FProductId;
    property Quantity: Double read FQuantity write FQuantity;
    property UnitPrice: Currency read FUnitPrice write FUnitPrice;
    property DiscountAmount: Currency
      read FDiscountAmount write FDiscountAmount;
  end;

  TSalePaymentCreateDto = class
  private
    FPaymentMethod: string;
    FAmount: Currency;
  public
    property PaymentMethod: string
      read FPaymentMethod write FPaymentMethod;
    property Amount: Currency read FAmount write FAmount;
  end;

  TSaleCreateDto = class
  private
    FCustomerId: Integer;
    FDiscountAmount: Currency;
    FNotes: string;
    FItems: TObjectList<TSaleItemCreateDto>;
    FPayments: TObjectList<TSalePaymentCreateDto>;
  public
    constructor Create;
    destructor Destroy; override;

    property CustomerId: Integer read FCustomerId write FCustomerId;
    property DiscountAmount: Currency
      read FDiscountAmount write FDiscountAmount;
    property Notes: string read FNotes write FNotes;
    property Items: TObjectList<TSaleItemCreateDto> read FItems;
    property Payments: TObjectList<TSalePaymentCreateDto> read FPayments;
  end;

  TSaleItemReadDto = class
  private
    FId: Integer;
    FProductId: Integer;
    FProductDescription: string;
    FQuantity: Double;
    FUnitPrice: Currency;
    FDiscountAmount: Currency;
    FTotalAmount: Currency;
  public
    property Id: Integer read FId write FId;
    property ProductId: Integer read FProductId write FProductId;
    property ProductDescription: string
      read FProductDescription write FProductDescription;
    property Quantity: Double read FQuantity write FQuantity;
    property UnitPrice: Currency read FUnitPrice write FUnitPrice;
    property DiscountAmount: Currency
      read FDiscountAmount write FDiscountAmount;
    property TotalAmount: Currency read FTotalAmount write FTotalAmount;
  end;

  TSalePaymentReadDto = class
  private
    FId: Integer;
    FPaymentMethod: string;
    FAmount: Currency;
  public
    property Id: Integer read FId write FId;
    property PaymentMethod: string
      read FPaymentMethod write FPaymentMethod;
    property Amount: Currency read FAmount write FAmount;
  end;

  TSaleReadDto = class
  private
    FId: Integer;
    FCustomerId: Integer;
    FCashRegisterId: Integer;
    FSaleDate: string;
    FSubtotalAmount: Currency;
    FDiscountAmount: Currency;
    FTotalAmount: Currency;
    FStatus: string;
    FNotes: string;
    FItems: TObjectList<TSaleItemReadDto>;
    FPayments: TObjectList<TSalePaymentReadDto>;
  public
    constructor Create;
    destructor Destroy; override;

    property Id: Integer read FId write FId;
    property CustomerId: Integer read FCustomerId write FCustomerId;
    property CashRegisterId: Integer
      read FCashRegisterId write FCashRegisterId;
    property SaleDate: string read FSaleDate write FSaleDate;
    property SubtotalAmount: Currency
      read FSubtotalAmount write FSubtotalAmount;
    property DiscountAmount: Currency
      read FDiscountAmount write FDiscountAmount;
    property TotalAmount: Currency read FTotalAmount write FTotalAmount;
    property Status: string read FStatus write FStatus;
    property Notes: string read FNotes write FNotes;
    property Items: TObjectList<TSaleItemReadDto> read FItems;
    property Payments: TObjectList<TSalePaymentReadDto> read FPayments;
  end;

implementation

constructor TSaleCreateDto.Create;
begin
  inherited Create;
  FItems := TObjectList<TSaleItemCreateDto>.Create(True);
  FPayments := TObjectList<TSalePaymentCreateDto>.Create(True);
end;

destructor TSaleCreateDto.Destroy;
begin
  FPayments.Free;
  FItems.Free;
  inherited;
end;

constructor TSaleReadDto.Create;
begin
  inherited Create;
  FItems := TObjectList<TSaleItemReadDto>.Create(True);
  FPayments := TObjectList<TSalePaymentReadDto>.Create(True);
end;

destructor TSaleReadDto.Destroy;
begin
  FPayments.Free;
  FItems.Free;
  inherited;
end;

end.
