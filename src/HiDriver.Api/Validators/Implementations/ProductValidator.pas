unit ProductValidator;

interface

uses
  ProductDtos,
  ProductValidatorIntf;

type
  TProductValidator = class(TInterfacedObject, IProductValidator)
  private
    function ValidateValues(
      const AInternalCode,
      ADescription: string;
      const ACurrentStock,
      AMinimumStock: Double;
      const ACostPrice,
      ASalePrice: Currency;
      out AErrorMessage: string): Boolean;
  public
    function ValidateCreate(
      AProduct: TProductCreateDto;
      out AErrorMessage: string): Boolean;
    function ValidateUpdate(
      AProduct: TProductUpdateDto;
      out AErrorMessage: string): Boolean;
  end;

implementation

uses
  System.SysUtils;

function TProductValidator.ValidateValues(
  const AInternalCode,
  ADescription: string;
  const ACurrentStock,
  AMinimumStock: Double;
  const ACostPrice,
  ASalePrice: Currency;
  out AErrorMessage: string): Boolean;
begin
  AErrorMessage := '';

  if Trim(AInternalCode) = '' then
    AErrorMessage := 'Internal code is required.'
  else if Trim(ADescription) = '' then
    AErrorMessage := 'Description is required.'
  else if ASalePrice <= 0 then
    AErrorMessage := 'Sale price must be greater than zero.'
  else if ACostPrice < 0 then
    AErrorMessage := 'Cost price cannot be negative.'
  else if ACurrentStock < 0 then
    AErrorMessage := 'Current stock cannot be negative.'
  else if AMinimumStock < 0 then
    AErrorMessage := 'Minimum stock cannot be negative.';

  Result := AErrorMessage = '';
end;

function TProductValidator.ValidateCreate(
  AProduct: TProductCreateDto;
  out AErrorMessage: string): Boolean;
begin
  if not Assigned(AProduct) then
  begin
    AErrorMessage := 'Product data is required.';
    Exit(False);
  end;

  Result := ValidateValues(
    AProduct.InternalCode,
    AProduct.Description,
    AProduct.CurrentStock,
    AProduct.MinimumStock,
    AProduct.CostPrice,
    AProduct.SalePrice,
    AErrorMessage);
end;

function TProductValidator.ValidateUpdate(
  AProduct: TProductUpdateDto;
  out AErrorMessage: string): Boolean;
begin
  if not Assigned(AProduct) then
  begin
    AErrorMessage := 'Product data is required.';
    Exit(False);
  end;

  Result := ValidateValues(
    AProduct.InternalCode,
    AProduct.Description,
    AProduct.CurrentStock,
    AProduct.MinimumStock,
    AProduct.CostPrice,
    AProduct.SalePrice,
    AErrorMessage);
end;

end.
