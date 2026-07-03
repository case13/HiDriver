unit CashMovementRepositoryIntf;

interface

uses
  System.Generics.Collections,
  CashMovement;

type
  ICashMovementRepository = interface
    // The caller owns the returned list and its movements.
    function FindByCashRegisterId(
      ACashRegisterId: Integer): TObjectList<TCashMovement>;
    function SumByCashRegisterId(
      ACashRegisterId: Integer): Currency;
    // Insert does not take ownership of ACashMovement.
    procedure Insert(ACashMovement: TCashMovement);
  end;

implementation

end.
