unit ProductAppServiceIntf;

interface

uses
  System.SysUtils,
  ProductDtos;

type
  EProductValidationException = class(Exception);
  EProductNotFoundException = class(Exception);
  EProductDuplicateException = class(Exception);

  IProductAppService = interface
    function GetAll: string;
    function GetById(AId: Integer): string;
    function Create(AProduct: TProductCreateDto): string;
    function Update(AId: Integer; AProduct: TProductUpdateDto): string;
    function Delete(AId: Integer): string;
  end;

implementation

end.
