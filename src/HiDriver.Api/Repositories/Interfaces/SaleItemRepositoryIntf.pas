unit SaleItemRepositoryIntf;

interface

uses
  System.Generics.Collections,
  SaleItem;

type
  ISaleItemRepository = interface
    // The caller owns the returned list and its items.
    function FindBySaleId(
      ASaleId: Integer): TObjectList<TSaleItem>;
    // Insert does not take ownership of ASaleItem.
    procedure Insert(ASaleItem: TSaleItem);
  end;

implementation

end.
