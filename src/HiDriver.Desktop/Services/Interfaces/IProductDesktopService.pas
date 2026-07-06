unit IProductDesktopService;

interface

uses
  ProductDto;

type
  IProductDesktopServiceContract = interface
    ['{11D8A7A2-710C-4487-B8CC-7E16B1B2AB55}']
    function GetProducts: TProductDtoList;
    function SearchProductsLocal(
      const AProducts: TProductDtoList;
      const ASearchText: string): TProductDtoReferenceList;
    function GetLastError: string;
    function GetLastStatusCode: Integer;
    property LastError: string read GetLastError;
    property LastStatusCode: Integer read GetLastStatusCode;
  end;

implementation

end.
