unit CustomerAppService;

interface

uses
  CustomerAppServiceIntf,
  CustomerDtos,
  CustomerRepositoryIntf,
  CustomerValidatorIntf;

type
  TCustomerAppService = class(TInterfacedObject, ICustomerAppService)
  private
    FCustomerRepository: ICustomerRepository;
    FCustomerValidator: ICustomerValidator;
  protected
    function ICustomerAppService.Create = CreateCustomer;
    function CreateCustomer(ACustomer: TCustomerCreateDto): string;
  public
    constructor Create(
      const ACustomerRepository: ICustomerRepository;
      const ACustomerValidator: ICustomerValidator);
    function GetAll: string;
    function GetById(AId: Integer): string;
    function Update(AId: Integer; ACustomer: TCustomerUpdateDto): string;
    function Delete(AId: Integer): string;
  end;

implementation

uses
  System.Generics.Collections,
  System.JSON,
  System.SysUtils,
  Customer;

function NormalizeDocument(const ADocument: string): string;
var
  CharacterItem: Char;
begin
  Result := '';
  for CharacterItem in Trim(ADocument) do
    if CharInSet(CharacterItem, ['0'..'9']) then
      Result := Result + CharacterItem;
end;

function CustomerToReadDto(ACustomer: TCustomer): TCustomerReadDto;
begin
  Result := TCustomerReadDto.Create;
  Result.Id := ACustomer.Id;
  Result.Name := ACustomer.Name;
  Result.Document := ACustomer.Document;
  Result.Phone := ACustomer.Phone;
  Result.Email := ACustomer.Email;
  Result.Address := ACustomer.Address;
  Result.City := ACustomer.City;
  Result.State := ACustomer.State;
  Result.ZipCode := ACustomer.ZipCode;
  Result.IsActive := ACustomer.IsActive;
end;

function CustomerDtoToJson(ACustomer: TCustomerReadDto): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(ACustomer.Id));
  Result.AddPair('name', ACustomer.Name);
  Result.AddPair('document', ACustomer.Document);
  Result.AddPair('phone', ACustomer.Phone);
  Result.AddPair('email', ACustomer.Email);
  Result.AddPair('address', ACustomer.Address);
  Result.AddPair('city', ACustomer.City);
  Result.AddPair('state', ACustomer.State);
  Result.AddPair('zipCode', ACustomer.ZipCode);
  Result.AddPair('isActive', TJSONBool.Create(ACustomer.IsActive));
end;

function CustomerToJson(ACustomer: TCustomer): TJSONObject;
var
  CustomerDto: TCustomerReadDto;
begin
  CustomerDto := CustomerToReadDto(ACustomer);
  try
    Result := CustomerDtoToJson(CustomerDto);
  finally
    CustomerDto.Free;
  end;
end;

function BuildSuccessResponse(
  const AMessage: string;
  AData: TJSONValue): string;
var
  Json: TJSONObject;
begin
  Json := TJSONObject.Create;
  try
    Json.AddPair('success', TJSONBool.Create(True));
    Json.AddPair('message', AMessage);
    if Assigned(AData) then
      Json.AddPair('data', AData)
    else
      Json.AddPair('data', TJSONNull.Create);
    Result := Json.ToJSON;
  finally
    Json.Free;
  end;
end;

procedure MapCreateDtoToCustomer(
  ASource: TCustomerCreateDto;
  ATarget: TCustomer);
begin
  ATarget.Name := Trim(ASource.Name);
  ATarget.Document := NormalizeDocument(ASource.Document);
  ATarget.Phone := Trim(ASource.Phone);
  ATarget.Email := Trim(ASource.Email);
  ATarget.Address := Trim(ASource.Address);
  ATarget.City := Trim(ASource.City);
  ATarget.State := Trim(ASource.State);
  ATarget.ZipCode := Trim(ASource.ZipCode);
  ATarget.IsActive := ASource.IsActive;
end;

procedure MapUpdateDtoToCustomer(
  ASource: TCustomerUpdateDto;
  ATarget: TCustomer);
begin
  ATarget.Name := Trim(ASource.Name);
  ATarget.Document := NormalizeDocument(ASource.Document);
  ATarget.Phone := Trim(ASource.Phone);
  ATarget.Email := Trim(ASource.Email);
  ATarget.Address := Trim(ASource.Address);
  ATarget.City := Trim(ASource.City);
  ATarget.State := Trim(ASource.State);
  ATarget.ZipCode := Trim(ASource.ZipCode);
  ATarget.IsActive := ASource.IsActive;
end;

constructor TCustomerAppService.Create(
  const ACustomerRepository: ICustomerRepository;
  const ACustomerValidator: ICustomerValidator);
begin
  inherited Create;
  FCustomerRepository := ACustomerRepository;
  FCustomerValidator := ACustomerValidator;
end;

function TCustomerAppService.GetAll: string;
var
  CustomerItem: TCustomer;
  Customers: TObjectList<TCustomer>;
  JsonArray: TJSONArray;
begin
  Customers := FCustomerRepository.FindAllActive;
  try
    JsonArray := TJSONArray.Create;
    try
      for CustomerItem in Customers do
        JsonArray.AddElement(CustomerToJson(CustomerItem));
      Result := BuildSuccessResponse('', JsonArray);
      JsonArray := nil;
    finally
      JsonArray.Free;
    end;
  finally
    Customers.Free;
  end;
end;

function TCustomerAppService.GetById(AId: Integer): string;
var
  CustomerItem: TCustomer;
begin
  CustomerItem := FCustomerRepository.FindById(AId);
  try
    if not Assigned(CustomerItem) then
      raise ECustomerNotFoundException.Create('Customer not found.');

    Result := BuildSuccessResponse('', CustomerToJson(CustomerItem));
  finally
    CustomerItem.Free;
  end;
end;

function TCustomerAppService.CreateCustomer(
  ACustomer: TCustomerCreateDto): string;
var
  CustomerItem: TCustomer;
  DocumentValue: string;
  ErrorMessage: string;
begin
  if not FCustomerValidator.ValidateCreate(ACustomer, ErrorMessage) then
    raise ECustomerValidationException.Create(ErrorMessage);

  DocumentValue := NormalizeDocument(ACustomer.Document);
  if (DocumentValue <> '') and
    FCustomerRepository.ExistsByDocument(DocumentValue) then
    raise ECustomerDuplicateException.Create(
      'A customer with this document already exists.');

  CustomerItem := TCustomer.Create;
  try
    MapCreateDtoToCustomer(ACustomer, CustomerItem);
    CustomerItem.CreatedAt := Now;
    CustomerItem.Id := FCustomerRepository.Insert(CustomerItem);
    Result := BuildSuccessResponse(
      'Customer created successfully.',
      CustomerToJson(CustomerItem));
  finally
    CustomerItem.Free;
  end;
end;

function TCustomerAppService.Update(
  AId: Integer;
  ACustomer: TCustomerUpdateDto): string;
var
  CustomerItem: TCustomer;
  DocumentValue: string;
  ErrorMessage: string;
begin
  if not FCustomerValidator.ValidateUpdate(ACustomer, ErrorMessage) then
    raise ECustomerValidationException.Create(ErrorMessage);

  CustomerItem := FCustomerRepository.FindById(AId);
  try
    if not Assigned(CustomerItem) then
      raise ECustomerNotFoundException.Create('Customer not found.');

    ACustomer.Id := AId;
    DocumentValue := NormalizeDocument(ACustomer.Document);
    if (DocumentValue <> '') and
      FCustomerRepository.ExistsByDocument(DocumentValue, AId) then
      raise ECustomerDuplicateException.Create(
        'A customer with this document already exists.');

    MapUpdateDtoToCustomer(ACustomer, CustomerItem);
    CustomerItem.UpdatedAt := Now;
    FCustomerRepository.Update(CustomerItem);
    Result := BuildSuccessResponse(
      'Customer updated successfully.',
      CustomerToJson(CustomerItem));
  finally
    CustomerItem.Free;
  end;
end;

function TCustomerAppService.Delete(AId: Integer): string;
begin
  if not FCustomerRepository.ExistsById(AId) then
    raise ECustomerNotFoundException.Create('Customer not found.');

  FCustomerRepository.Deactivate(AId);
  Result := BuildSuccessResponse(
    'Customer deleted successfully.',
    nil);
end;

end.
