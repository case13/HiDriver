unit CustomerDesktopService;

interface

uses
  System.JSON,
  IApiClient,
  ICustomerDesktopService,
  CustomerDto,
  CustomerSaveRequestDto;

type
  TCustomerDesktopService = class(
    TInterfacedObject,
    ICustomerDesktopServiceContract)
  private
    FApiClient: IApiClientContract;
    FLastError: string;
    function BuildCustomerJson(
      const ACustomer: TCustomerSaveRequestDto): string;
    function CustomerFromJson(AJson: TJSONObject): TCustomerDto;
    function ExecuteWriteResponse(
      const AResponseBody,
      ADefaultError: string): Boolean;
    function GetLastError: string;
    function GetLastStatusCode: Integer;
    procedure SetRequestError(const ADefaultError: string);
  public
    constructor Create(const AApiClient: IApiClientContract);
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
  end;

implementation

uses
  System.Generics.Collections,
  System.Generics.Defaults,
  System.StrUtils,
  System.SysUtils;

function JsonTextValue(
  AJson: TJSONObject;
  const AName: string): string;
var
  Text: string;
  Value: TJSONValue;
begin
  Result := '';
  Value := AJson.GetValue(AName);
  if Value is TJSONString then
  begin
    Text := TJSONString(Value).Value;
    SetLength(Result, Length(Text));
    if Text <> '' then
      Move(Text[1], Result[1], Length(Text) * SizeOf(Char));
  end;
end;

function NormalizeCustomerFilterField(
  const AFilterField: string): string;
begin
  Result := LowerCase(Trim(AFilterField));
  Result := StringReplace(Result, '_', '', [rfReplaceAll]);
  Result := StringReplace(Result, '-', '', [rfReplaceAll]);
  if Result = '' then
    Result := 'name';
end;

function CustomerStatusText(ACustomer: TCustomerDto): string;
begin
  if ACustomer.IsActive then
    Result := 'Ativo'
  else
    Result := 'Inativo';
end;

function IsStatusFilterField(const AFilterField: string): Boolean;
var
  FieldName: string;
begin
  FieldName := NormalizeCustomerFilterField(AFilterField);
  Result := (FieldName = 'isactive') or
    (FieldName = 'status') or
    (FieldName = 'statustext');
end;

function StatusFieldMatches(
  ACustomer: TCustomerDto;
  const ASearchText: string): Boolean;
begin
  if SameText(ASearchText, 'ativo') then
    Exit(ACustomer.IsActive);

  if SameText(ASearchText, 'inativo') then
    Exit(not ACustomer.IsActive);

  Result := ContainsText(CustomerStatusText(ACustomer), ASearchText) or
    ContainsText(BoolToStr(ACustomer.IsActive, True), ASearchText);
end;

function CustomerFilterText(
  ACustomer: TCustomerDto;
  const AFilterField: string): string;
var
  FieldName: string;
begin
  Result := '';
  if not Assigned(ACustomer) then
    Exit;

  FieldName := NormalizeCustomerFilterField(AFilterField);
  if FieldName = 'document' then
    Result := ACustomer.Document
  else if FieldName = 'phone' then
    Result := ACustomer.Phone
  else if FieldName = 'email' then
    Result := ACustomer.Email
  else if FieldName = 'address' then
    Result := ACustomer.Address
  else if FieldName = 'city' then
    Result := ACustomer.City
  else if FieldName = 'state' then
    Result := ACustomer.State
  else if FieldName = 'zipcode' then
    Result := ACustomer.ZipCode
  else if IsStatusFilterField(AFilterField) then
    Result := CustomerStatusText(ACustomer)
  else
    Result := ACustomer.Name;
end;

function CompareIntegerValues(
  ALeft,
  ARight: Integer): Integer;
begin
  if ALeft < ARight then
    Result := -1
  else if ALeft > ARight then
    Result := 1
  else
    Result := 0;
end;

function CompareCustomerByField(
  ALeft,
  ARight: TCustomerDto;
  const ASortField: string): Integer;
var
  FieldName: string;
begin
  Result := 0;
  if (not Assigned(ALeft)) and (not Assigned(ARight)) then
    Exit;
  if not Assigned(ALeft) then
    Exit(-1);
  if not Assigned(ARight) then
    Exit(1);

  FieldName := NormalizeCustomerFilterField(ASortField);
  if FieldName = 'document' then
    Result := CompareText(ALeft.Document, ARight.Document)
  else if FieldName = 'phone' then
    Result := CompareText(ALeft.Phone, ARight.Phone)
  else if FieldName = 'email' then
    Result := CompareText(ALeft.Email, ARight.Email)
  else if FieldName = 'address' then
    Result := CompareText(ALeft.Address, ARight.Address)
  else if FieldName = 'city' then
    Result := CompareText(ALeft.City, ARight.City)
  else if FieldName = 'state' then
    Result := CompareText(ALeft.State, ARight.State)
  else if FieldName = 'zipcode' then
    Result := CompareText(ALeft.ZipCode, ARight.ZipCode)
  else if IsStatusFilterField(ASortField) then
    Result := CompareText(
      CustomerStatusText(ALeft),
      CustomerStatusText(ARight))
  else
    Result := CompareText(ALeft.Name, ARight.Name);
end;

function IsDescendingSortDirection(
  const ASortDirection: string): Boolean;
begin
  Result := SameText(Trim(ASortDirection), 'desc') or
    SameText(Trim(ASortDirection), 'descending') or
    SameText(Trim(ASortDirection), 'd');
end;

procedure SortCustomerReferences(
  ACustomers: TCustomerDtoReferenceList;
  const ASortField,
  ASortDirection: string);
var
  SortDescending: Boolean;
  SortField: string;
begin
  if not Assigned(ACustomers) then
    Exit;

  SortField := ASortField;
  if Trim(SortField) = '' then
    SortField := 'name';
  SortDescending := IsDescendingSortDirection(ASortDirection);

  ACustomers.Sort(
    TComparer<TCustomerDto>.Construct(
      function(
        const ALeft,
        ARight: TCustomerDto): Integer
      begin
        Result := CompareCustomerByField(ALeft, ARight, SortField);
        if Result = 0 then
          Result := CompareCustomerByField(ALeft, ARight, 'name');
        if Result = 0 then
          Result := CompareCustomerByField(ALeft, ARight, 'document');
        if Result = 0 then
        begin
          if Assigned(ALeft) and Assigned(ARight) then
            Result := CompareIntegerValues(ALeft.Id, ARight.Id);
        end;

        if SortDescending then
          Result := -Result;
      end));
end;

function TCustomerDesktopService.BuildCustomerJson(
  const ACustomer: TCustomerSaveRequestDto): string;
var
  Json: TJSONObject;
begin
  Json := TJSONObject.Create;
  try
    Json.AddPair('name', ACustomer.Name);
    Json.AddPair('document', ACustomer.Document);
    Json.AddPair('phone', ACustomer.Phone);
    Json.AddPair('email', ACustomer.Email);
    Json.AddPair('address', ACustomer.Address);
    Json.AddPair('city', ACustomer.City);
    Json.AddPair('state', ACustomer.State);
    Json.AddPair('zipCode', ACustomer.ZipCode);
    Json.AddPair('isActive', TJSONBool.Create(ACustomer.IsActive));
    Result := Json.ToJSON;
  finally
    Json.Free;
  end;
end;

constructor TCustomerDesktopService.Create(
  const AApiClient: IApiClientContract);
begin
  inherited Create;
  if not Assigned(AApiClient) then
    raise EArgumentNilException.Create('API client is required.');

  FApiClient := AApiClient;
end;

function TCustomerDesktopService.CreateCustomer(
  const ACustomer: TCustomerSaveRequestDto): Boolean;
var
  ResponseBody: string;
begin
  Result := False;
  FLastError := '';
  if not Assigned(ACustomer) then
  begin
    FLastError := 'Customer data is required.';
    Exit;
  end;

  ResponseBody := FApiClient.Post(
    '/api/customers',
    BuildCustomerJson(ACustomer));
  Result := ExecuteWriteResponse(
    ResponseBody,
    'Unable to create the customer.');
end;

function TCustomerDesktopService.CustomerFromJson(
  AJson: TJSONObject): TCustomerDto;
begin
  Result := TCustomerDto.Create;
  try
    Result.Id := AJson.GetValue<Integer>('id', 0);
    Result.Name := JsonTextValue(AJson, 'name');
    Result.Document := JsonTextValue(AJson, 'document');
    Result.Phone := JsonTextValue(AJson, 'phone');
    Result.Email := JsonTextValue(AJson, 'email');
    Result.Address := JsonTextValue(AJson, 'address');
    Result.City := JsonTextValue(AJson, 'city');
    Result.State := JsonTextValue(AJson, 'state');
    Result.ZipCode := JsonTextValue(AJson, 'zipCode');
    Result.IsActive := AJson.GetValue<Boolean>('isActive', False);
  except
    Result.Free;
    raise;
  end;
end;

function TCustomerDesktopService.DeleteCustomer(
  ACustomerId: Integer): Boolean;
var
  ResponseBody: string;
begin
  FLastError := '';
  ResponseBody := FApiClient.Delete(
    Format('/api/customers/%d', [ACustomerId]));
  Result := ExecuteWriteResponse(
    ResponseBody,
    'Unable to delete the customer.');
end;

function TCustomerDesktopService.ExecuteWriteResponse(
  const AResponseBody,
  ADefaultError: string): Boolean;
var
  JsonObject: TJSONObject;
  RootValue: TJSONValue;
begin
  Result := False;
  if (FApiClient.LastStatusCode < 200) or
    (FApiClient.LastStatusCode >= 300) then
  begin
    SetRequestError(ADefaultError);
    Exit;
  end;

  RootValue := nil;
  try
    try
      RootValue := TJSONObject.ParseJSONValue(AResponseBody);
      if not (RootValue is TJSONObject) then
      begin
        FLastError := 'The API returned an invalid response.';
        Exit;
      end;

      JsonObject := TJSONObject(RootValue);
      if not JsonObject.GetValue<Boolean>('success', False) then
      begin
        FLastError := JsonObject.GetValue<string>(
          'message',
          ADefaultError);
        Exit;
      end;

      Result := True;
    except
      on E: Exception do
        FLastError := 'The API returned unexpected customer data.';
    end;
  finally
    RootValue.Free;
  end;
end;

function TCustomerDesktopService.GetCustomerById(
  ACustomerId: Integer): TCustomerDto;
var
  DataValue: TJSONValue;
  JsonObject: TJSONObject;
  ResponseBody: string;
  RootValue: TJSONValue;
begin
  Result := nil;
  FLastError := '';
  ResponseBody := FApiClient.Get(
    Format('/api/customers/%d', [ACustomerId]));
  if (FApiClient.LastStatusCode < 200) or
    (FApiClient.LastStatusCode >= 300) then
  begin
    SetRequestError('Unable to load the customer.');
    Exit;
  end;

  RootValue := nil;
  try
    try
      RootValue := TJSONObject.ParseJSONValue(ResponseBody);
      if not (RootValue is TJSONObject) then
      begin
        FLastError := 'The API returned an invalid customer response.';
        Exit;
      end;

      JsonObject := TJSONObject(RootValue);
      if not JsonObject.GetValue<Boolean>('success', False) then
      begin
        FLastError := JsonObject.GetValue<string>(
          'message',
          'Unable to load the customer.');
        Exit;
      end;

      DataValue := JsonObject.GetValue('data');
      if not (DataValue is TJSONObject) then
      begin
        FLastError := 'The API returned invalid customer data.';
        Exit;
      end;

      Result := CustomerFromJson(TJSONObject(DataValue));
    except
      on E: Exception do
      begin
        Result.Free;
        Result := nil;
        FLastError := 'The API returned unexpected customer data.';
      end;
    end;
  finally
    RootValue.Free;
  end;
end;

function TCustomerDesktopService.GetCustomers: TCustomerDtoList;
var
  Customers: TCustomerDtoList;
  DataArray: TJSONArray;
  DataValue: TJSONValue;
  Index: Integer;
  JsonObject: TJSONObject;
  ResponseBody: string;
  RootValue: TJSONValue;
begin
  Result := nil;
  FLastError := '';

  ResponseBody := FApiClient.Get('/api/customers');
  if (FApiClient.LastStatusCode < 200) or
    (FApiClient.LastStatusCode >= 300) then
  begin
    SetRequestError('Unable to load customers.');
    Exit;
  end;

  RootValue := nil;
  Customers := nil;
  try
    try
      RootValue := TJSONObject.ParseJSONValue(ResponseBody);
      if not (RootValue is TJSONObject) then
      begin
        FLastError := 'The API returned an invalid customers response.';
        Exit;
      end;

      JsonObject := TJSONObject(RootValue);
      if not JsonObject.GetValue<Boolean>('success', False) then
      begin
        FLastError := JsonObject.GetValue<string>(
          'message',
          'Unable to load customers.');
        Exit;
      end;

      DataValue := JsonObject.GetValue('data');
      if not (DataValue is TJSONArray) then
      begin
        FLastError := 'The API returned invalid customer data.';
        Exit;
      end;

      DataArray := TJSONArray(DataValue);
      Customers := TCustomerDtoList.Create(True);
      for Index := 0 to DataArray.Count - 1 do
      begin
        if not (DataArray.Items[Index] is TJSONObject) then
        begin
          FLastError := 'The API returned an invalid customer item.';
          Exit;
        end;

        Customers.Add(CustomerFromJson(
          TJSONObject(DataArray.Items[Index])));
      end;

      Result := Customers;
      Customers := nil;
    except
      on E: Exception do
        FLastError := 'The API returned unexpected customer data.';
    end;
  finally
    Customers.Free;
    RootValue.Free;
  end;
end;

function TCustomerDesktopService.GetLastError: string;
begin
  Result := FLastError;
end;

function TCustomerDesktopService.GetLastStatusCode: Integer;
begin
  Result := FApiClient.LastStatusCode;
end;

function TCustomerDesktopService.SearchCustomersLocal(
  const ACustomers: TCustomerDtoList;
  const ASearchText: string): TCustomerDtoReferenceList;
begin
  Result := SearchCustomersLocal(
    ACustomers,
    ASearchText,
    'name',
    'name',
    'asc');
end;

function TCustomerDesktopService.SearchCustomersLocal(
  const ACustomers: TCustomerDtoList;
  const ASearchText,
  AFilterField: string): TCustomerDtoReferenceList;
begin
  Result := SearchCustomersLocal(
    ACustomers,
    ASearchText,
    AFilterField,
    AFilterField,
    'asc');
end;

function TCustomerDesktopService.SearchCustomersLocal(
  const ACustomers: TCustomerDtoList;
  const ASearchText,
  AFilterField,
  ASortField,
  ASortDirection: string): TCustomerDtoReferenceList;
var
  CustomerItem: TCustomerDto;
  SearchText: string;
begin
  Result := TCustomerDtoReferenceList.Create;
  if not Assigned(ACustomers) then
    Exit;

  SearchText := Trim(ASearchText);
  for CustomerItem in ACustomers do
    if (SearchText = '') or
      (IsStatusFilterField(AFilterField) and
        StatusFieldMatches(CustomerItem, SearchText)) or
      (not IsStatusFilterField(AFilterField) and
        ContainsText(
          CustomerFilterText(CustomerItem, AFilterField),
          SearchText)) then
      Result.Add(CustomerItem);

  SortCustomerReferences(Result, ASortField, ASortDirection);
end;

procedure TCustomerDesktopService.SetRequestError(
  const ADefaultError: string);
begin
  FLastError := FApiClient.LastError;
  if FLastError = '' then
    FLastError := ADefaultError;
end;

function TCustomerDesktopService.UpdateCustomer(
  ACustomerId: Integer;
  const ACustomer: TCustomerSaveRequestDto): Boolean;
var
  ResponseBody: string;
begin
  Result := False;
  FLastError := '';
  if not Assigned(ACustomer) then
  begin
    FLastError := 'Customer data is required.';
    Exit;
  end;

  ResponseBody := FApiClient.Put(
    Format('/api/customers/%d', [ACustomerId]),
    BuildCustomerJson(ACustomer));
  Result := ExecuteWriteResponse(
    ResponseBody,
    'Unable to update the customer.');
end;

end.
