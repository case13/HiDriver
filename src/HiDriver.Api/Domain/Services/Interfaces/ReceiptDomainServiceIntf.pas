unit ReceiptDomainServiceIntf;

interface

uses
  System.Generics.Collections,
  AccountReceivable,
  AccountReceivablePayment,
  Customer,
  Receipt,
  ReceiptItem,
  Sale,
  SaleItem,
  SalePayment;

type
  IReceiptDomainService = interface
    function GenerateReceiptNumber(ASequence: Integer): string;
    function CalculateSubtotal(
      AItems: TObjectList<TReceiptItem>): Currency;
    function CalculateDiscountTotal(
      AItems: TObjectList<TReceiptItem>;
      ASaleDiscount: Currency): Currency;
    function CalculateTotal(
      ASubtotal,
      ADiscountAmount: Currency): Currency;
    function BuildSalePaymentSummary(
      APayments: TObjectList<TSalePayment>): string;
    function BuildAccountPaymentSummary(
      APayment: TAccountReceivablePayment): string;
    // The caller owns the returned receipt.
    function BuildSaleReceipt(
      ASequence: Integer;
      ASale: TSale;
      ASaleItems: TObjectList<TSaleItem>;
      APayments: TObjectList<TSalePayment>;
      ACustomer: TCustomer;
      AUserId: Integer;
      const ANotes: string): TReceipt;
    // The caller owns the returned receipt.
    function BuildAccountReceivablePaymentReceipt(
      ASequence: Integer;
      APayment: TAccountReceivablePayment;
      AAccountReceivable: TAccountReceivable;
      ACustomer: TCustomer;
      AUserId: Integer;
      const ANotes: string): TReceipt;
  end;

implementation

end.
