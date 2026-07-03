unit ReceiptDomainService;

interface

uses
  System.Generics.Collections,
  AccountReceivable,
  AccountReceivablePayment,
  Customer,
  Receipt,
  ReceiptDomainServiceIntf,
  ReceiptItem,
  Sale,
  SaleItem,
  SalePayment;

type
  TReceiptDomainService = class(
    TInterfacedObject,
    IReceiptDomainService)
  public
    function GenerateReceiptNumber(ASequence: Integer): string;
    function CalculateSubtotal(
      AItems: TObjectList<TReceiptItem>): Currency;
    function CalculateDiscountTotal(
      AItems: TObjectList<TReceiptItem>;
      ASaleDiscount: Currency): Currency;
    function CalculateTotal(
      ASubtotal,
      ADiscountAmount: Currency): Currency;
    function BuildSalePaymentSummary(
      APayments: TObjectList<TSalePayment>): string;
    function BuildAccountPaymentSummary(
      APayment: TAccountReceivablePayment): string;
    function BuildSaleReceipt(
      ASequence: Integer;
      ASale: TSale;
      ASaleItems: TObjectList<TSaleItem>;
      APayments: TObjectList<TSalePayment>;
      ACustomer: TCustomer;
      AUserId: Integer;
      const ANotes: string): TReceipt;
    function BuildAccountReceivablePaymentReceipt(
      ASequence: Integer;
      APayment: TAccountReceivablePayment;
      AAccountReceivable: TAccountReceivable;
      ACustomer: TCustomer;
      AUserId: Integer;
      const ANotes: string): TReceipt;
  end;

implementation

uses
  System.SysUtils,
  ReceiptSourceTypeEnum,
  ReceiptStatusEnum;

function FormatMoney(AValue: Currency): string;
var
  FormatSettings: TFormatSettings;
begin
  FormatSettings := TFormatSettings.Create('en-US');
  Result := FormatFloat('0.00', AValue, FormatSettings);
end;

function TReceiptDomainService.GenerateReceiptNumber(
  ASequence: Integer): string;
begin
  if ASequence <= 0 then
    raise EArgumentOutOfRangeException.Create(
      'Receipt sequence must be greater than zero.');
  Result := Format('RCP-%.6d', [ASequence]);
end;

function TReceiptDomainService.CalculateSubtotal(
  AItems: TObjectList<TReceiptItem>): Currency;
var
  Item: TReceiptItem;
begin
  Result := 0;
  for Item in AItems do
    Result := Result + (Item.Quantity * Item.UnitPrice);
end;

function TReceiptDomainService.CalculateDiscountTotal(
  AItems: TObjectList<TReceiptItem>;
  ASaleDiscount: Currency): Currency;
var
  Item: TReceiptItem;
begin
  Result := ASaleDiscount;
  for Item in AItems do
    Result := Result + Item.DiscountAmount;
end;

function TReceiptDomainService.CalculateTotal(
  ASubtotal,
  ADiscountAmount: Currency): Currency;
begin
  Result := ASubtotal - ADiscountAmount;
end;

function TReceiptDomainService.BuildSalePaymentSummary(
  APayments: TObjectList<TSalePayment>): string;
var
  Amount: Currency;
  Amounts: TDictionary<string, Currency>;
  Index: Integer;
  Method: string;
  Methods: TList<string>;
  Payment: TSalePayment;
begin
  Result := '';
  Amounts := TDictionary<string, Currency>.Create;
  Methods := TList<string>.Create;
  try
    for Payment in APayments do
    begin
      Method := Payment.PaymentMethod;
      if not Amounts.TryGetValue(Method, Amount) then
      begin
        Amount := 0;
        Methods.Add(Method);
      end;
      Amounts.AddOrSetValue(Method, Amount + Payment.Amount);
    end;

    for Index := 0 to Methods.Count - 1 do
    begin
      Method := Methods[Index];
      if Result <> '' then
        Result := Result + '; ';
      Result := Result + Method + ': ' +
        FormatMoney(Amounts[Method]);
    end;
  finally
    Methods.Free;
    Amounts.Free;
  end;
end;

function TReceiptDomainService.BuildAccountPaymentSummary(
  APayment: TAccountReceivablePayment): string;
begin
  if not Assigned(APayment) then
    Exit('');
  Result := APayment.PaymentMethod + ': ' +
    FormatMoney(APayment.TotalReceived);
end;

function TReceiptDomainService.BuildSaleReceipt(
  ASequence: Integer;
  ASale: TSale;
  ASaleItems: TObjectList<TSaleItem>;
  APayments: TObjectList<TSalePayment>;
  ACustomer: TCustomer;
  AUserId: Integer;
  const ANotes: string): TReceipt;
var
  Item: TReceiptItem;
  SaleItem: TSaleItem;
begin
  if not Assigned(ASale) then
    raise EArgumentNilException.Create('Sale is required.');
  if not Assigned(ASaleItems) or (ASaleItems.Count = 0) then
    raise EArgumentException.Create('Sale items are required.');
  if not Assigned(APayments) or (APayments.Count = 0) then
    raise EArgumentException.Create('Sale payments are required.');

  Result := TReceipt.Create;
  try
    Result.ReceiptNumber := GenerateReceiptNumber(ASequence);
    Result.SourceType := ReceiptSourceTypeToString(rstSale);
    Result.SourceId := ASale.Id;
    if Assigned(ACustomer) then
    begin
      Result.CustomerId := ACustomer.Id;
      Result.CustomerName := ACustomer.Name;
      Result.CustomerDocument := ACustomer.Document;
    end;
    Result.IssueDate := Now;

    for SaleItem in ASaleItems do
    begin
      Item := TReceiptItem.Create;
      Item.ProductId := SaleItem.ProductId;
      Item.Description := SaleItem.ProductDescription;
      Item.Quantity := SaleItem.Quantity;
      Item.UnitPrice := SaleItem.UnitPrice;
      Item.DiscountAmount := SaleItem.DiscountAmount;
      Item.TotalAmount := SaleItem.TotalAmount;
      Item.CreatedAt := Result.IssueDate;
      Result.Items.Add(Item);
    end;

    Result.SubtotalAmount := CalculateSubtotal(Result.Items);
    Result.DiscountAmount := CalculateDiscountTotal(
      Result.Items,
      ASale.DiscountAmount);
    Result.TotalAmount := CalculateTotal(
      Result.SubtotalAmount,
      Result.DiscountAmount);
    Result.PaymentSummary := BuildSalePaymentSummary(APayments);
    Result.Notes := Trim(ANotes);
    Result.Status := ReceiptStatusToString(rsIssued);
    Result.CreatedByUserId := AUserId;
    Result.IsActive := True;
    Result.CreatedAt := Result.IssueDate;
  except
    Result.Free;
    raise;
  end;
end;

function TReceiptDomainService.BuildAccountReceivablePaymentReceipt(
  ASequence: Integer;
  APayment: TAccountReceivablePayment;
  AAccountReceivable: TAccountReceivable;
  ACustomer: TCustomer;
  AUserId: Integer;
  const ANotes: string): TReceipt;
var
  Item: TReceiptItem;
begin
  if not Assigned(APayment) then
    raise EArgumentNilException.Create(
      'Account receivable payment is required.');
  if not Assigned(AAccountReceivable) then
    raise EArgumentNilException.Create('Account receivable is required.');

  Result := TReceipt.Create;
  try
    Result.ReceiptNumber := GenerateReceiptNumber(ASequence);
    Result.SourceType :=
      ReceiptSourceTypeToString(rstAccountReceivablePayment);
    Result.SourceId := APayment.Id;
    if Assigned(ACustomer) then
    begin
      Result.CustomerId := ACustomer.Id;
      Result.CustomerName := ACustomer.Name;
      Result.CustomerDocument := ACustomer.Document;
    end;
    Result.IssueDate := Now;

    Item := TReceiptItem.Create;
    Item.Description := Format(
      'Accounts receivable payment - Sale #%d',
      [AAccountReceivable.SaleId]);
    Item.Quantity := 1;
    Item.UnitPrice := APayment.TotalReceived;
    Item.DiscountAmount := 0;
    Item.TotalAmount := APayment.TotalReceived;
    Item.CreatedAt := Result.IssueDate;
    Result.Items.Add(Item);

    Result.SubtotalAmount := CalculateSubtotal(Result.Items);
    Result.DiscountAmount := 0;
    Result.TotalAmount := CalculateTotal(
      Result.SubtotalAmount,
      Result.DiscountAmount);
    Result.PaymentSummary := BuildAccountPaymentSummary(APayment);
    Result.Notes := Trim(ANotes);
    Result.Status := ReceiptStatusToString(rsIssued);
    Result.CreatedByUserId := AUserId;
    Result.IsActive := True;
    Result.CreatedAt := Result.IssueDate;
  except
    Result.Free;
    raise;
  end;
end;

end.
