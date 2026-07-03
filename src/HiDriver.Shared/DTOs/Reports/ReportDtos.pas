unit ReportDtos;

interface

type
  TReportFilterDto = class
  private
    FStartDate: string;
    FEndDate: string;
  public
    property StartDate: string read FStartDate write FStartDate;
    property EndDate: string read FEndDate write FEndDate;
  end;

  TSalesSummaryReportDto = class
  private
    FStartDate: string;
    FEndDate: string;
    FTotalSales: Integer;
    FCanceledSales: Integer;
    FNetSales: Integer;
    FGrossAmount: Currency;
    FDiscountAmount: Currency;
    FNetAmount: Currency;
  public
    property StartDate: string read FStartDate write FStartDate;
    property EndDate: string read FEndDate write FEndDate;
    property TotalSales: Integer read FTotalSales write FTotalSales;
    property CanceledSales: Integer
      read FCanceledSales write FCanceledSales;
    property NetSales: Integer read FNetSales write FNetSales;
    property GrossAmount: Currency
      read FGrossAmount write FGrossAmount;
    property DiscountAmount: Currency
      read FDiscountAmount write FDiscountAmount;
    property NetAmount: Currency read FNetAmount write FNetAmount;
  end;

  TSalesByPaymentMethodReportDto = class
  private
    FPaymentMethod: string;
    FTotalTransactions: Integer;
    FTotalAmount: Currency;
  public
    property PaymentMethod: string
      read FPaymentMethod write FPaymentMethod;
    property TotalTransactions: Integer
      read FTotalTransactions write FTotalTransactions;
    property TotalAmount: Currency
      read FTotalAmount write FTotalAmount;
  end;

  TLowStockProductReportDto = class
  private
    FProductId: Integer;
    FInternalCode: string;
    FBarCode: string;
    FDescription: string;
    FBrandName: string;
    FCategoryName: string;
    FCurrentStock: Double;
    FMinimumStock: Double;
    FMissingQuantity: Double;
  public
    property ProductId: Integer read FProductId write FProductId;
    property InternalCode: string
      read FInternalCode write FInternalCode;
    property BarCode: string read FBarCode write FBarCode;
    property Description: string read FDescription write FDescription;
    property BrandName: string read FBrandName write FBrandName;
    property CategoryName: string
      read FCategoryName write FCategoryName;
    property CurrentStock: Double
      read FCurrentStock write FCurrentStock;
    property MinimumStock: Double
      read FMinimumStock write FMinimumStock;
    property MissingQuantity: Double
      read FMissingQuantity write FMissingQuantity;
  end;

  TOpenAccountReceivableReportDto = class
  private
    FAccountReceivableId: Integer;
    FSaleId: Integer;
    FCustomerId: Integer;
    FCustomerName: string;
    FIssueDate: string;
    FDueDate: string;
    FTotalAmount: Currency;
    FReceivedAmount: Currency;
    FBalanceAmount: Currency;
    FStatus: string;
  public
    property AccountReceivableId: Integer
      read FAccountReceivableId write FAccountReceivableId;
    property SaleId: Integer read FSaleId write FSaleId;
    property CustomerId: Integer read FCustomerId write FCustomerId;
    property CustomerName: string
      read FCustomerName write FCustomerName;
    property IssueDate: string read FIssueDate write FIssueDate;
    property DueDate: string read FDueDate write FDueDate;
    property TotalAmount: Currency
      read FTotalAmount write FTotalAmount;
    property ReceivedAmount: Currency
      read FReceivedAmount write FReceivedAmount;
    property BalanceAmount: Currency
      read FBalanceAmount write FBalanceAmount;
    property Status: string read FStatus write FStatus;
  end;

  TCashSummaryReportDto = class
  private
    FCashRegisterId: Integer;
    FOpenedAt: string;
    FClosedAt: string;
    FOpeningAmount: Currency;
    FTotalIn: Currency;
    FTotalOut: Currency;
    FExpectedAmount: Currency;
    FClosingAmount: Currency;
    FDifferenceAmount: Currency;
    FStatus: string;
  public
    property CashRegisterId: Integer
      read FCashRegisterId write FCashRegisterId;
    property OpenedAt: string read FOpenedAt write FOpenedAt;
    property ClosedAt: string read FClosedAt write FClosedAt;
    property OpeningAmount: Currency
      read FOpeningAmount write FOpeningAmount;
    property TotalIn: Currency read FTotalIn write FTotalIn;
    property TotalOut: Currency read FTotalOut write FTotalOut;
    property ExpectedAmount: Currency
      read FExpectedAmount write FExpectedAmount;
    property ClosingAmount: Currency
      read FClosingAmount write FClosingAmount;
    property DifferenceAmount: Currency
      read FDifferenceAmount write FDifferenceAmount;
    property Status: string read FStatus write FStatus;
  end;

  TStockMovementReportDto = class
  private
    FId: Integer;
    FProductId: Integer;
    FProductDescription: string;
    FMovementDate: string;
    FMovementType: string;
    FSourceType: string;
    FSourceId: Integer;
    FQuantity: Double;
    FPreviousStock: Double;
    FNewStock: Double;
    FNotes: string;
  public
    property Id: Integer read FId write FId;
    property ProductId: Integer read FProductId write FProductId;
    property ProductDescription: string
      read FProductDescription write FProductDescription;
    property MovementDate: string
      read FMovementDate write FMovementDate;
    property MovementType: string
      read FMovementType write FMovementType;
    property SourceType: string read FSourceType write FSourceType;
    property SourceId: Integer read FSourceId write FSourceId;
    property Quantity: Double read FQuantity write FQuantity;
    property PreviousStock: Double
      read FPreviousStock write FPreviousStock;
    property NewStock: Double read FNewStock write FNewStock;
    property Notes: string read FNotes write FNotes;
  end;

implementation

end.
