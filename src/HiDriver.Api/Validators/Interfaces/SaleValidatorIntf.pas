unit SaleValidatorIntf;

interface

uses
  SaleDtos;

type
  ISaleValidator = interface
    function ValidateCreate(
      ASale: TSaleCreateDto;
      out AErrorMessage: string): Boolean;
  end;

implementation

end.
