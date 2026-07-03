unit ProductDtos;

interface

type
  TProductCreateDto = class
  private
    FInternalCode: string;
    FBarCode: string;
    FOriginalCode: string;
    FDescription: string;
    FBrandName: string;
    FCategoryName: string;
    FVehicleApplication: string;
    FCurrentStock: Double;
    FMinimumStock: Double;
    FCostPrice: Currency;
    FSalePrice: Currency;
    FIsActive: Boolean;
  public
    property InternalCode: string read FInternalCode write FInternalCode;
    property BarCode: string read FBarCode write FBarCode;
    property OriginalCode: string read FOriginalCode write FOriginalCode;
    property Description: string read FDescription write FDescription;
    property BrandName: string read FBrandName write FBrandName;
    property CategoryName: string read FCategoryName write FCategoryName;
    property VehicleApplication: string
      read FVehicleApplication write FVehicleApplication;
    property CurrentStock: Double read FCurrentStock write FCurrentStock;
    property MinimumStock: Double read FMinimumStock write FMinimumStock;
    property CostPrice: Currency read FCostPrice write FCostPrice;
    property SalePrice: Currency read FSalePrice write FSalePrice;
    property IsActive: Boolean read FIsActive write FIsActive;
  end;

  TProductUpdateDto = class
  private
    FId: Integer;
    FInternalCode: string;
    FBarCode: string;
    FOriginalCode: string;
    FDescription: string;
    FBrandName: string;
    FCategoryName: string;
    FVehicleApplication: string;
    FCurrentStock: Double;
    FMinimumStock: Double;
    FCostPrice: Currency;
    FSalePrice: Currency;
    FIsActive: Boolean;
  public
    property Id: Integer read FId write FId;
    property InternalCode: string read FInternalCode write FInternalCode;
    property BarCode: string read FBarCode write FBarCode;
    property OriginalCode: string read FOriginalCode write FOriginalCode;
    property Description: string read FDescription write FDescription;
    property BrandName: string read FBrandName write FBrandName;
    property CategoryName: string read FCategoryName write FCategoryName;
    property VehicleApplication: string
      read FVehicleApplication write FVehicleApplication;
    property CurrentStock: Double read FCurrentStock write FCurrentStock;
    property MinimumStock: Double read FMinimumStock write FMinimumStock;
    property CostPrice: Currency read FCostPrice write FCostPrice;
    property SalePrice: Currency read FSalePrice write FSalePrice;
    property IsActive: Boolean read FIsActive write FIsActive;
  end;

  TProductReadDto = class
  private
    FId: Integer;
    FInternalCode: string;
    FBarCode: string;
    FOriginalCode: string;
    FDescription: string;
    FBrandName: string;
    FCategoryName: string;
    FVehicleApplication: string;
    FCurrentStock: Double;
    FMinimumStock: Double;
    FCostPrice: Currency;
    FSalePrice: Currency;
    FIsActive: Boolean;
  public
    property Id: Integer read FId write FId;
    property InternalCode: string read FInternalCode write FInternalCode;
    property BarCode: string read FBarCode write FBarCode;
    property OriginalCode: string read FOriginalCode write FOriginalCode;
    property Description: string read FDescription write FDescription;
    property BrandName: string read FBrandName write FBrandName;
    property CategoryName: string read FCategoryName write FCategoryName;
    property VehicleApplication: string
      read FVehicleApplication write FVehicleApplication;
    property CurrentStock: Double read FCurrentStock write FCurrentStock;
    property MinimumStock: Double read FMinimumStock write FMinimumStock;
    property CostPrice: Currency read FCostPrice write FCostPrice;
    property SalePrice: Currency read FSalePrice write FSalePrice;
    property IsActive: Boolean read FIsActive write FIsActive;
  end;

implementation

end.
