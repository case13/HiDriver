unit ReceiptAppServiceIntf;

interface

uses
  System.SysUtils,
  ReceiptDto;

type
  EReceiptValidationException = class(Exception);
  EReceiptNotFoundException = class(Exception);
  EReceiptStateException = class(Exception);

  IReceiptAppService = interface
    function GetAll: string;
    function GetById(AId: Integer): string;
    function GetByNumber(const AReceiptNumber: string): string;
    function IssueSaleReceipt(
      ARequest: TIssueSaleReceiptRequestDto): string;
    function IssueAccountReceivablePaymentReceipt(
      ARequest:
        TIssueAccountReceivablePaymentReceiptRequestDto): string;
    function Cancel(AId: Integer): string;
  end;

implementation

end.
