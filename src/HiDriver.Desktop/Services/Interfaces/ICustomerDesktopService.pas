unit ICustomerDesktopService;

interface

uses
  CustomerDto,
  CustomerSaveRequestDto;

type
  ICustomerDesktopServiceContract = interface
    ['{55F2347E-48B1-4E1C-903C-F46A9C5FD7DD}']
    function GetCustomers: TCustomerDtoList;
    function GetCustomerById(ACustomerId: Integer): TCustomerDto;
    function CreateCustomer(
      const ACustomer: TCustomerSaveRequestDto): Boolean;
    function UpdateCustomer(
      ACustomerId: Integer;
      const ACustomer: TCustomerSaveRequestDto): Boolean;
    function DeleteCustomer(ACustomerId: Integer): Boolean;
    function SearchCustomersLocal(
      const ACustomers: TCustomerDtoList;
      const ASearchText: string): TCustomerDtoReferenceList; overload;
    function SearchCustomersLocal(
      const ACustomers: TCustomerDtoList;
      const ASearchText,
      AFilterField: string): TCustomerDtoReferenceList; overload;
    function SearchCustomersLocal(
      const ACustomers: TCustomerDtoList;
      const ASearchText,
      AFilterField,
      ASortField,
      ASortDirection: string): TCustomerDtoReferenceList; overload;
    function GetLastError: string;
    function GetLastStatusCode: Integer;
    property LastError: string read GetLastError;
    property LastStatusCode: Integer read GetLastStatusCode;
  end;

implementation

end.
