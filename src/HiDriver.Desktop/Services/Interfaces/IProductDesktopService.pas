unit IProductDesktopService;

interface

uses
  ProductDto,
  ProductSaveRequestDto;

type
  IProductDesktopServiceContract = interface
    ['{11D8A7A2-710C-4487-B8CC-7E16B1B2AB55}']
    function GetProducts: TProductDtoList;
    function GetProductById(AProductId: Integer): TProductDto;
    function CreateProduct(
      const AProduct: TProductSaveRequestDto): Boolean;
    function UpdateProduct(
      AProductId: Integer;
      const AProduct: TProductSaveRequestDto): Boolean;
    function DeleteProduct(AProductId: Integer): Boolean;
    function SearchProductsLocal(
      const AProducts: TProductDtoList;
      const ASearchText: string): TProductDtoReferenceList; overload;
    function SearchProductsLocal(
      const AProducts: TProductDtoList;
      const ASearchText,
      AFilterField: string): TProductDtoReferenceList; overload;
    function SearchProductsLocal(
      const AProducts: TProductDtoList;
      const ASearchText,
      AFilterField,
      ASortField,
      ASortDirection: string): TProductDtoReferenceList; overload;
    function GetLastError: string;
    function GetLastStatusCode: Integer;
    property LastError: string read GetLastError;
    property LastStatusCode: Integer read GetLastStatusCode;
  end;

implementation

end.
