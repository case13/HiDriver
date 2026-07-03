unit Product;

interface

type
  TProduct = class
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
    FCreatedAt: TDateTime;
    FUpdatedAt: TDateTime;
  public
    function IsBelowMinimumStock: Boolean;
    procedure Activate;
    procedure Deactivate;

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
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
  end;

implementation

function TProduct.IsBelowMinimumStock: Boolean;
begin
  Result := FCurrentStock < FMinimumStock;
end;

procedure TProduct.Activate;
begin
  FIsActive := True;
end;

procedure TProduct.Deactivate;
begin
  FIsActive := False;
end;

end.
