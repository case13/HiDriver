unit SalePaymentRepositoryIntf;

interface

uses
  System.Generics.Collections,
  SalePayment;

type
  ISalePaymentRepository = interface
    // The caller owns the returned list and its payments.
    function FindBySaleId(
      ASaleId: Integer): TObjectList<TSalePayment>;
    // Insert does not take ownership of ASalePayment.
    procedure Insert(ASalePayment: TSalePayment);
  end;

implementation

end.
