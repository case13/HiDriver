unit ProductValidatorIntf;

interface

uses
  ProductDtos;

type
  IProductValidator = interface
    function ValidateCreate(
      AProduct: TProductCreateDto;
      out AErrorMessage: string): Boolean;
    function ValidateUpdate(
      AProduct: TProductUpdateDto;
      out AErrorMessage: string): Boolean;
  end;

implementation

end.
