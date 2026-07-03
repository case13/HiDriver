unit CustomerValidatorIntf;

interface

uses
  CustomerDtos;

type
  ICustomerValidator = interface
    function ValidateCreate(
      ACustomer: TCustomerCreateDto;
      out AErrorMessage: string): Boolean;
    function ValidateUpdate(
      ACustomer: TCustomerUpdateDto;
      out AErrorMessage: string): Boolean;
  end;

implementation

end.
