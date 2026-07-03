unit ReceiptValidator;

interface

uses
  AccountReceivablePayment,
  Receipt,
  ReceiptDto,
  ReceiptValidatorIntf,
  Sale;

type
  TReceiptValidator = class(TInterfacedObject, IReceiptValidator)
  public
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

function TReceiptValidator.ValidateIssueSale(
  ARequest: TIssueSaleReceiptRequestDto;
  ASale: TSale;
  AExistingReceipt: TReceipt;
  out AErrorMessage: string): Boolean;
begin
  AErrorMessage := '';
  if not Assigned(ARequest) then
    AErrorMessage := 'Sale receipt data is required.'
  else if ARequest.SaleId <= 0 then
    AErrorMessage := 'Sale id must be greater than zero.'
  else if ARequest.UserId <= 0 then
    AErrorMessage := 'User id must be greater than zero.'
  else if not Assigned(ASale) then
    AErrorMessage := 'Sale not found.'
  else if ASale.IsCanceled then
    AErrorMessage := 'A receipt cannot be issued for a canceled sale.'
  else if Assigned(AExistingReceipt) then
    AErrorMessage := 'An active receipt already exists for this sale.';
  Result := AErrorMessage = '';
end;

function TReceiptValidator.ValidateIssueAccountReceivablePayment(
  ARequest: TIssueAccountReceivablePaymentReceiptRequestDto;
  APayment: TAccountReceivablePayment;
  AExistingReceipt: TReceipt;
  out AErrorMessage: string): Boolean;
begin
  AErrorMessage := '';
  if not Assigned(ARequest) then
    AErrorMessage := 'Account receivable payment receipt data is required.'
  else if ARequest.AccountReceivablePaymentId <= 0 then
    AErrorMessage :=
      'Account receivable payment id must be greater than zero.'
  else if ARequest.UserId <= 0 then
    AErrorMessage := 'User id must be greater than zero.'
  else if not Assigned(APayment) then
    AErrorMessage := 'Account receivable payment not found.'
  else if Assigned(AExistingReceipt) then
    AErrorMessage :=
      'An active receipt already exists for this account receivable payment.';
  Result := AErrorMessage = '';
end;

function TReceiptValidator.ValidateCancel(
  AReceiptId: Integer;
  AReceipt: TReceipt;
  out AErrorMessage: string): Boolean;
begin
  AErrorMessage := '';
  if AReceiptId <= 0 then
    AErrorMessage := 'Receipt id must be greater than zero.'
  else if not Assigned(AReceipt) then
    AErrorMessage := 'Receipt not found.'
  else if AReceipt.IsCanceled then
    AErrorMessage := 'Receipt is already canceled.';
  Result := AErrorMessage = '';
end;

end.
