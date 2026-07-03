unit SaleValidator;

interface

uses
  SaleDtos,
  SaleValidatorIntf;

type
  TSaleValidator = class(TInterfacedObject, ISaleValidator)
  public
    function ValidateCreate(
      ASale: TSaleCreateDto;
      out AErrorMessage: string): Boolean;
  end;

implementation

uses
  PaymentMethodEnum;

function TSaleValidator.ValidateCreate(
  ASale: TSaleCreateDto;
  out AErrorMessage: string): Boolean;
var
  Item: TSaleItemCreateDto;
  Payment: TSalePaymentCreateDto;
  PaymentMethod: TPaymentMethodEnum;
begin
  AErrorMessage := '';

  if not Assigned(ASale) then
    AErrorMessage := 'Sale data is required.'
  else if ASale.Items.Count = 0 then
    AErrorMessage := 'Sale must have at least one item.'
  else if ASale.Payments.Count = 0 then
    AErrorMessage := 'Sale must have at least one payment.'
  else if ASale.DiscountAmount < 0 then
    AErrorMessage := 'Sale discount cannot be negative.';

  if AErrorMessage <> '' then
    Exit(False);

  for Item in ASale.Items do
  begin
    if not Assigned(Item) or (Item.ProductId <= 0) then
      AErrorMessage := 'Product id must be greater than zero.'
    else if Item.Quantity <= 0 then
      AErrorMessage := 'Item quantity must be greater than zero.'
    else if Item.UnitPrice <= 0 then
      AErrorMessage := 'Item unit price must be greater than zero.'
    else if Item.DiscountAmount < 0 then
      AErrorMessage := 'Item discount cannot be negative.';

    if AErrorMessage <> '' then
      Exit(False);
  end;

  for Payment in ASale.Payments do
  begin
    if not Assigned(Payment) then
      AErrorMessage := 'Payment data is required.'
    else if not TryStringToPaymentMethod(
      Payment.PaymentMethod,
      PaymentMethod) then
      AErrorMessage := 'Payment method is invalid.'
    else if Payment.Amount <= 0 then
      AErrorMessage := 'Payment amount must be greater than zero.';

    if AErrorMessage <> '' then
      Exit(False);
  end;

  Result := True;
end;

end.
