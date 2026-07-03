unit CustomerValidator;

interface

uses
  CustomerDtos,
  CustomerValidatorIntf;

type
  TCustomerValidator = class(TInterfacedObject, ICustomerValidator)
  private
    function ValidateValues(
      const AName,
      ADocument,
      AEmail: string;
      out AErrorMessage: string): Boolean;
  public
    function ValidateCreate(
      ACustomer: TCustomerCreateDto;
      out AErrorMessage: string): Boolean;
    function ValidateUpdate(
      ACustomer: TCustomerUpdateDto;
      out AErrorMessage: string): Boolean;
  end;

implementation

uses
  System.SysUtils;

function UnmaskDocument(const ADocument: string): string;
var
  CharacterItem: Char;
begin
  Result := '';
  for CharacterItem in Trim(ADocument) do
    if not CharInSet(CharacterItem, ['.', '-', '/', ' ', '(', ')']) then
      Result := Result + CharacterItem;
end;

function IsDocumentFormatValid(const ADocument: string): Boolean;
var
  CharacterItem: Char;
  DocumentValue: string;
begin
  DocumentValue := UnmaskDocument(ADocument);
  Result := DocumentValue <> '';
  if not Result then
    Exit;

  for CharacterItem in DocumentValue do
    if not CharInSet(CharacterItem, ['0'..'9']) then
      Exit(False);
end;

function IsEmailFormatValid(const AEmail: string): Boolean;
var
  AtPosition: Integer;
  DotPosition: Integer;
  EmailValue: string;
begin
  EmailValue := Trim(AEmail);
  AtPosition := Pos('@', EmailValue);
  DotPosition := LastDelimiter('.', EmailValue);
  Result :=
    (AtPosition > 1) and
    (DotPosition > AtPosition + 1) and
    (DotPosition < Length(EmailValue));
end;

function TCustomerValidator.ValidateValues(
  const AName,
  ADocument,
  AEmail: string;
  out AErrorMessage: string): Boolean;
begin
  AErrorMessage := '';

  if Trim(AName) = '' then
    AErrorMessage := 'Name is required.'
  else if (Trim(AEmail) <> '') and
    not IsEmailFormatValid(AEmail) then
    AErrorMessage := 'Email format is invalid.'
  else if (Trim(ADocument) <> '') and
    not IsDocumentFormatValid(ADocument) then
    AErrorMessage := 'Document format is invalid.';

  Result := AErrorMessage = '';
end;

function TCustomerValidator.ValidateCreate(
  ACustomer: TCustomerCreateDto;
  out AErrorMessage: string): Boolean;
begin
  if not Assigned(ACustomer) then
  begin
    AErrorMessage := 'Customer data is required.';
    Exit(False);
  end;

  Result := ValidateValues(
    ACustomer.Name,
    ACustomer.Document,
    ACustomer.Email,
    AErrorMessage);
end;

function TCustomerValidator.ValidateUpdate(
  ACustomer: TCustomerUpdateDto;
  out AErrorMessage: string): Boolean;
begin
  if not Assigned(ACustomer) then
  begin
    AErrorMessage := 'Customer data is required.';
    Exit(False);
  end;

  Result := ValidateValues(
    ACustomer.Name,
    ACustomer.Document,
    ACustomer.Email,
    AErrorMessage);
end;

end.
