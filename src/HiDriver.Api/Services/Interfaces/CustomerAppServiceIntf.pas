unit CustomerAppServiceIntf;

interface

uses
  System.SysUtils,
  CustomerDtos;

type
  ECustomerValidationException = class(Exception);
  ECustomerNotFoundException = class(Exception);
  ECustomerDuplicateException = class(Exception);

  ICustomerAppService = interface
    function GetAll: string;
    function GetById(AId: Integer): string;
    function Create(ACustomer: TCustomerCreateDto): string;
    function Update(AId: Integer; ACustomer: TCustomerUpdateDto): string;
    function Delete(AId: Integer): string;
  end;

implementation

end.
