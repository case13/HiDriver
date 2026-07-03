unit StockMovementRepositoryIntf;

interface

uses
  System.Generics.Collections,
  StockMovement;

type
  IStockMovementRepository = interface
    // The caller owns the returned list and its stock movements.
    function GetAll: TObjectList<TStockMovement>;
    // The caller owns the returned stock movement.
    function GetById(AId: Integer): TStockMovement;
    // The caller owns the returned list and its stock movements.
    function GetByProductId(
      AProductId: Integer): TObjectList<TStockMovement>;
    // Insert does not take ownership of AStockMovement.
    procedure Insert(AStockMovement: TStockMovement);
  end;

implementation

end.
