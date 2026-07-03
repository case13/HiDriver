unit ProductRepositoryIntf;

interface

uses
  System.Generics.Collections,
  Product;

type
  IProductRepository = interface
    // The caller owns the returned list and its products.
    function FindAllActive: TObjectList<TProduct>;
    // The caller owns the product returned by FindById.
    function FindById(AId: Integer): TProduct;
    function ExistsByInternalCode(
      const AInternalCode: string;
      AIgnoreId: Integer = 0): Boolean;
    // Insert does not take ownership of AProduct.
    function Insert(AProduct: TProduct): Integer;
    // Update does not take ownership of AProduct.
    procedure Update(AProduct: TProduct);
    procedure Deactivate(AId: Integer);
    function ExistsById(AId: Integer): Boolean;
  end;

implementation

end.
