unit ReportValidator;

interface

uses
  IReportValidator;

type
  TReportValidator = class(
    TInterfacedObject,
    IReportValidatorContract)
  public
    function ValidateRequiredPeriod(
      const AStartDate,
      AEndDate: string;
      out AParsedStartDate,
      AParsedEndDate: TDateTime;
      out AErrorMessage: string): Boolean;
    function ValidateStockMovementFilter(
      AProductId: Integer;
      const AStartDate,
      AEndDate: string;
      out AParsedStartDate,
      AParsedEndDate: TDateTime;
      out AErrorMessage: string): Boolean;
  end;

implementation

uses
  System.DateUtils,
  System.SysUtils;

function TryParseReportDate(
  const AValue: string;
  out ADate: TDateTime): Boolean;
var
  Day: Integer;
  Month: Integer;
  Value: string;
  Year: Integer;
begin
  ADate := 0;
  Value := Trim(AValue);
  Result :=
    (Length(Value) = 10) and
    (Value[5] = '-') and
    (Value[8] = '-') and
    TryStrToInt(Copy(Value, 1, 4), Year) and
    TryStrToInt(Copy(Value, 6, 2), Month) and
    TryStrToInt(Copy(Value, 9, 2), Day) and
    TryEncodeDate(Year, Month, Day, ADate);
end;

function TReportValidator.ValidateRequiredPeriod(
  const AStartDate,
  AEndDate: string;
  out AParsedStartDate,
  AParsedEndDate: TDateTime;
  out AErrorMessage: string): Boolean;
begin
  AParsedStartDate := 0;
  AParsedEndDate := 0;
  AErrorMessage := '';

  if Trim(AStartDate) = '' then
    AErrorMessage := 'Start date is required.'
  else if Trim(AEndDate) = '' then
    AErrorMessage := 'End date is required.'
  else if not TryParseReportDate(AStartDate, AParsedStartDate) then
    AErrorMessage := 'Start date must use the YYYY-MM-DD format.'
  else if not TryParseReportDate(AEndDate, AParsedEndDate) then
    AErrorMessage := 'End date must use the YYYY-MM-DD format.'
  else if AParsedStartDate > AParsedEndDate then
    AErrorMessage := 'Start date cannot be greater than end date.';

  Result := AErrorMessage = '';
end;

function TReportValidator.ValidateStockMovementFilter(
  AProductId: Integer;
  const AStartDate,
  AEndDate: string;
  out AParsedStartDate,
  AParsedEndDate: TDateTime;
  out AErrorMessage: string): Boolean;
begin
  AParsedStartDate := 0;
  AParsedEndDate := 0;
  AErrorMessage := '';

  if AProductId <= 0 then
    AErrorMessage := 'Product id must be greater than zero.'
  else if (Trim(AStartDate) <> '') and
    not TryParseReportDate(AStartDate, AParsedStartDate) then
    AErrorMessage := 'Start date must use the YYYY-MM-DD format.'
  else if (Trim(AEndDate) <> '') and
    not TryParseReportDate(AEndDate, AParsedEndDate) then
    AErrorMessage := 'End date must use the YYYY-MM-DD format.'
  else if (AParsedStartDate > 0) and
    (AParsedEndDate > 0) and
    (AParsedStartDate > AParsedEndDate) then
    AErrorMessage := 'Start date cannot be greater than end date.';

  Result := AErrorMessage = '';
end;

end.
