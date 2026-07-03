unit SaleRepositoryIntf;

interface

uses
  System.Generics.Collections,
  Sale;

type
  ISaleRepository = interface
    // The caller owns the returned list and its sales.
    function FindAll: TObjectList<TSale>;
    // The caller owns the sale returned by FindById.
    function FindById(AId: Integer): TSale;
    // Insert does not take ownership of ASale.
    function Insert(ASale: TSale): Integer;
    procedure Cancel(ASaleId: Integer);
    function ExistsById(AId: Integer): Boolean;
    function IsCanceled(ASaleId: Integer): Boolean;
  end;

implementation

end.
