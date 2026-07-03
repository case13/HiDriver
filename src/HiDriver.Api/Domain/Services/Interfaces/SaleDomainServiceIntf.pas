unit SaleDomainServiceIntf;

interface

uses
  System.Generics.Collections,
  CashRegister,
  Product,
  SaleDtos,
  SaleItem;

type
  ISaleDomainService = interface
    function ValidateCashRegisterIsOpen(
      ACashRegister: TCashRegister;
      out AErrorMessage: string): Boolean;
    function ValidateProductForSale(
      AProduct: TProduct;
      AQuantity: Double;
      out AErrorMessage: string): Boolean;
    function ValidateCreditSaleRequiresCustomer(
      ASale: TSaleCreateDto;
      out AErrorMessage: string): Boolean;
    function CalculateItemTotal(
      const AQuantity: Double;
      const AUnitPrice,
      ADiscountAmount: Currency): Currency;
    function CalculateSubtotal(
      AItems: TObjectList<TSaleItem>): Currency;
    function CalculateTotal(
      const ASubtotal,
      ADiscountAmount: Currency): Currency;
    function CalculatePaymentsTotal(
      APayments: TObjectList<TSalePaymentCreateDto>): Currency;
    function ValidatePayments(
      const ATotalAmount,
      APaymentsTotal: Currency;
      out AErrorMessage: string): Boolean;
  end;

implementation

end.
