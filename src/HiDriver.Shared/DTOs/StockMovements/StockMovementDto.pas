unit StockMovementDto;

interface

type
  TStockMovementDto = class
  private
    FId: Integer;
    FProductId: Integer;
    FProductDescription: string;
    FMovementDate: string;
    FMovementType: string;
    FSourceType: string;
    FSourceId: Integer;
    FQuantity: Double;
    FPreviousStock: Double;
    FNewStock: Double;
    FUnitCost: Currency;
    FNotes: string;
    FUserId: Integer;
  public
    property Id: Integer read FId write FId;
    property ProductId: Integer read FProductId write FProductId;
    property ProductDescription: string
      read FProductDescription write FProductDescription;
    property MovementDate: string
      read FMovementDate write FMovementDate;
    property MovementType: string
      read FMovementType write FMovementType;
    property SourceType: string read FSourceType write FSourceType;
    property SourceId: Integer read FSourceId write FSourceId;
    property Quantity: Double read FQuantity write FQuantity;
    property PreviousStock: Double
      read FPreviousStock write FPreviousStock;
    property NewStock: Double read FNewStock write FNewStock;
    property UnitCost: Currency read FUnitCost write FUnitCost;
    property Notes: string read FNotes write FNotes;
    property UserId: Integer read FUserId write FUserId;
  end;

  TCreateStockAdjustmentRequestDto = class
  private
    FProductId: Integer;
    FUserId: Integer;
    FQuantity: Double;
    FMovementType: string;
    FNotes: string;
  public
    property ProductId: Integer read FProductId write FProductId;
    property UserId: Integer read FUserId write FUserId;
    property Quantity: Double read FQuantity write FQuantity;
    property MovementType: string
      read FMovementType write FMovementType;
    property Notes: string read FNotes write FNotes;
  end;

  TStockAdjustmentResponseDto = class
  private
    FProductId: Integer;
    FPreviousStock: Double;
    FNewStock: Double;
    FMovementType: string;
    FQuantity: Double;
    FMessage: string;
  public
    property ProductId: Integer read FProductId write FProductId;
    property PreviousStock: Double
      read FPreviousStock write FPreviousStock;
    property NewStock: Double read FNewStock write FNewStock;
    property MovementType: string
      read FMovementType write FMovementType;
    property Quantity: Double read FQuantity write FQuantity;
    property Message: string read FMessage write FMessage;
  end;

implementation

end.
