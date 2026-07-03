unit AccountReceivableRepositoryIntf;

interface

uses
  System.Generics.Collections,
  AccountReceivable,
  AccountReceivablePayment;

type
  IAccountReceivableRepository = interface
    // The caller owns the returned list and its accounts.
    function GetAll: TObjectList<TAccountReceivable>;
    // The caller owns the account returned by GetById.
    function GetById(AId: Integer): TAccountReceivable;
    // The caller owns the account returned by GetBySaleId.
    function GetBySaleId(ASaleId: Integer): TAccountReceivable;
    // Insert does not take ownership of AAccountReceivable.
    function Insert(AAccountReceivable: TAccountReceivable): Integer;
    // Update does not take ownership of AAccountReceivable.
    procedure Update(AAccountReceivable: TAccountReceivable);
    // InsertPayment does not take ownership of APayment.
    procedure InsertPayment(APayment: TAccountReceivablePayment);
    // The caller owns the returned list and its payments.
    function GetPaymentsByAccountReceivableId(
      AAccountReceivableId: Integer):
      TObjectList<TAccountReceivablePayment>;
  end;

implementation

end.
