unit ReceiptRepositoryIntf;

interface

uses
  System.Generics.Collections,
  Receipt,
  ReceiptItem;

type
  IReceiptRepository = interface
    // The caller owns the returned list and its receipts.
    function GetAll: TObjectList<TReceipt>;
    // The caller owns the returned receipt.
    function GetById(AId: Integer): TReceipt;
    // The caller owns the returned receipt.
    function GetByNumber(const AReceiptNumber: string): TReceipt;
    // Returns only an active receipt with Issued status. The caller owns it.
    function GetBySource(
      const ASourceType: string;
      ASourceId: Integer): TReceipt;
    function GetNextId: Integer;
    // Insert does not take ownership of AReceipt.
    procedure Insert(AReceipt: TReceipt);
    // InsertItems does not take ownership of AItems.
    procedure InsertItems(AItems: TObjectList<TReceiptItem>);
    procedure Cancel(AId: Integer);
  end;

implementation

end.
