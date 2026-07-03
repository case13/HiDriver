unit CustomerRepositoryIntf;

interface

uses
  System.Generics.Collections,
  Customer;

type
  ICustomerRepository = interface
    // The caller owns the returned list and its customers.
    function FindAllActive: TObjectList<TCustomer>;
    // The caller owns the customer returned by FindById.
    function FindById(AId: Integer): TCustomer;
    function ExistsByDocument(
      const ADocument: string;
      AIgnoreId: Integer = 0): Boolean;
    // Insert does not take ownership of ACustomer.
    function Insert(ACustomer: TCustomer): Integer;
    // Update does not take ownership of ACustomer.
    procedure Update(ACustomer: TCustomer);
    procedure Deactivate(AId: Integer);
    function ExistsById(AId: Integer): Boolean;
  end;

implementation

end.
