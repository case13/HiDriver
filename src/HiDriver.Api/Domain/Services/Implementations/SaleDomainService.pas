unit SaleDomainService;

interface

uses
  System.Generics.Collections,
  CashRegister,
  Product,
  SaleDomainServiceIntf,
  SaleDtos,
  SaleItem;

type
  TSaleDomainService = class(TInterfacedObject, ISaleDomainService)
  public
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

uses
  System.SysUtils,
  PaymentMethodEnum;

function TSaleDomainService.ValidateCashRegisterIsOpen(
  ACashRegister: TCashRegister;
  out AErrorMessage: string): Boolean;
begin
  AErrorMessage := '';

  if not Assigned(ACashRegister) then
    AErrorMessage := 'There is no open cash register.'
  else if not ACashRegister.IsOpen then
    AErrorMessage := 'Cash register is not open.';

  Result := AErrorMessage = '';
end;

function TSaleDomainService.ValidateProductForSale(
  AProduct: TProduct;
  AQuantity: Double;
  out AErrorMessage: string): Boolean;
begin
  AErrorMessage := '';

  if not Assigned(AProduct) then
    AErrorMessage := 'Product not found or inactive.'
  else if not AProduct.IsActive then
    AErrorMessage := 'Product is inactive.'
  else if AQuantity > AProduct.CurrentStock then
    AErrorMessage := 'Insufficient stock for product ' +
      AProduct.InternalCode + '.';

  Result := AErrorMessage = '';
end;

function TSaleDomainService.ValidateCreditSaleRequiresCustomer(
  ASale: TSaleCreateDto;
  out AErrorMessage: string): Boolean;
var
  Payment: TSalePaymentCreateDto;
begin
  AErrorMessage := '';

  if Assigned(ASale) then
    for Payment in ASale.Payments do
      if SameText(
        Payment.PaymentMethod,
        PaymentMethodToString(pmCreditSale)) and
        (ASale.CustomerId <= 0) then
      begin
        AErrorMessage := 'Credit sale requires a customer.';
        Break;
      end;

  Result := AErrorMessage = '';
end;

function TSaleDomainService.CalculateItemTotal(
  const AQuantity: Double;
  const AUnitPrice,
  ADiscountAmount: Currency): Currency;
begin
  Result := (AQuantity * AUnitPrice) - ADiscountAmount;
end;

function TSaleDomainService.CalculateSubtotal(
  AItems: TObjectList<TSaleItem>): Currency;
var
  Item: TSaleItem;
begin
  Result := 0;
  for Item in AItems do
    Result := Result + Item.CalculateTotal;
end;

function TSaleDomainService.CalculateTotal(
  const ASubtotal,
  ADiscountAmount: Currency): Currency;
begin
  Result := ASubtotal - ADiscountAmount;
end;

function TSaleDomainService.CalculatePaymentsTotal(
  APayments: TObjectList<TSalePaymentCreateDto>): Currency;
var
  Payment: TSalePaymentCreateDto;
begin
  Result := 0;
  for Payment in APayments do
    Result := Result + Payment.Amount;
end;

function TSaleDomainService.ValidatePayments(
  const ATotalAmount,
  APaymentsTotal: Currency;
  out AErrorMessage: string): Boolean;
begin
  AErrorMessage := '';
  if APaymentsTotal < ATotalAmount then
    AErrorMessage := 'Payment total is less than sale total.';
  Result := AErrorMessage = '';
end;

end.
