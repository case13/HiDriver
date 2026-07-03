unit CashRegisterRepositoryIntf;

interface

uses
  CashRegister;

type
  ICashRegisterRepository = interface
    // The caller owns the cash register returned by FindOpen.
    function FindOpen: TCashRegister;
    // The caller owns the cash register returned by FindById.
    function FindById(AId: Integer): TCashRegister;
    function HasOpenCashRegister: Boolean;
    // Insert does not take ownership of ACashRegister.
    function Insert(ACashRegister: TCashRegister): Integer;
    // Close does not take ownership of ACashRegister.
    procedure Close(ACashRegister: TCashRegister);
  end;

implementation

end.
