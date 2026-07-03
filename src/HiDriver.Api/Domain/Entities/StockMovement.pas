unit StockMovement;

interface

type
  TStockMovement = class
  private
    FId: Integer;
    FProductId: Integer;
    FMovementDate: TDateTime;
    FMovementType: string;
    FSourceType: string;
    FSourceId: Integer;
    FQuantity: Double;
    FPreviousStock: Double;
    FNewStock: Double;
    FUnitCost: Currency;
    FNotes: string;
    FUserId: Integer;
    FIsActive: Boolean;
    FCreatedAt: TDateTime;
  public
    property Id: Integer read FId write FId;
    property ProductId: Integer read FProductId write FProductId;
    property MovementDate: TDateTime
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
    property IsActive: Boolean read FIsActive write FIsActive;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
  end;

implementation

end.
