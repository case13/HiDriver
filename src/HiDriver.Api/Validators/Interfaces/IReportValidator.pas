unit IReportValidator;

interface

type
  IReportValidatorContract = interface
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

end.
