unit TransactionManagerIntf;

interface

type
  ITransactionManager = interface
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
    function InTransaction: Boolean;
  end;

implementation

end.
