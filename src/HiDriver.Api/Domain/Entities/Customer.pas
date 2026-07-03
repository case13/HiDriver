unit Customer;

interface

type
  TCustomer = class
  private
    FId: Integer;
    FName: string;
    FDocument: string;
    FPhone: string;
    FEmail: string;
    FAddress: string;
    FCity: string;
    FState: string;
    FZipCode: string;
    FIsActive: Boolean;
    FCreatedAt: TDateTime;
    FUpdatedAt: TDateTime;
  public
    procedure Activate;
    procedure Deactivate;
    function HasDocument: Boolean;

    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property Document: string read FDocument write FDocument;
    property Phone: string read FPhone write FPhone;
    property Email: string read FEmail write FEmail;
    property Address: string read FAddress write FAddress;
    property City: string read FCity write FCity;
    property State: string read FState write FState;
    property ZipCode: string read FZipCode write FZipCode;
    property IsActive: Boolean read FIsActive write FIsActive;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
  end;

implementation

uses
  System.SysUtils;

procedure TCustomer.Activate;
begin
  FIsActive := True;
end;

procedure TCustomer.Deactivate;
begin
  FIsActive := False;
end;

function TCustomer.HasDocument: Boolean;
begin
  Result := Trim(FDocument) <> '';
end;

end.
