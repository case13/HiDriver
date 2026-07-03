unit ReceiptValidatorIntf;

interface

uses
  AccountReceivablePayment,
  Receipt,
  ReceiptDto,
  Sale;

type
  IReceiptValidator = interface
    function ValidateIssueSale(
      ARequest: TIssueSaleReceiptRequestDto;
      ASale: TSale;
      AExistingReceipt: TReceipt;
      out AErrorMessage: string): Boolean;
    function ValidateIssueAccountReceivablePayment(
      ARequest: TIssueAccountReceivablePaymentReceiptRequestDto;
      APayment: TAccountReceivablePayment;
      AExistingReceipt: TReceipt;
      out AErrorMessage: string): Boolean;
    function ValidateCancel(
      AReceiptId: Integer;
      AReceipt: TReceipt;
      out AErrorMessage: string): Boolean;
  end;

implementation

end.
