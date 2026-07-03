unit SaleAppServiceIntf;

interface

uses
  System.SysUtils,
  SaleDtos;

type
  ESaleValidationException = class(Exception);
  ESaleNotFoundException = class(Exception);
  ESaleStateException = class(Exception);

  ISaleAppService = interface
    function Create(ASale: TSaleCreateDto): string;
    function GetAll: string;
    function GetById(AId: Integer): string;
    function Cancel(AId: Integer): string;
  end;

implementation

end.
