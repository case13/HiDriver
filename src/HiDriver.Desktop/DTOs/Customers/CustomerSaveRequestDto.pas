unit CustomerSaveRequestDto;

interface

type
  TCustomerSaveRequestDto = class
  private
    FName: string;
    FDocument: string;
    FPhone: string;
    FEmail: string;
    FAddress: string;
    FCity: string;
    FState: string;
    FZipCode: string;
    FIsActive: Boolean;
  public
    property Name: string read FName write FName;
    property Document: string read FDocument write FDocument;
    property Phone: string read FPhone write FPhone;
    property Email: string read FEmail write FEmail;
    property Address: string read FAddress write FAddress;
    property City: string read FCity write FCity;
    property State: string read FState write FState;
    property ZipCode: string read FZipCode write FZipCode;
    property IsActive: Boolean read FIsActive write FIsActive;
  end;

implementation

end.
