unit CashRegisterAppServiceIntf;

interface

uses
  System.SysUtils,
  CashRegisterDtos;

type
  ECashRegisterValidationException = class(Exception);
  ECashRegisterNotFoundException = class(Exception);
  ECashRegisterStateException = class(Exception);

  ICashRegisterAppService = interface
    function Open(ARequest: TCashOpenRequestDto): string;
    function Close(ARequest: TCashCloseRequestDto): string;
    function GetCurrent: string;
    function GetMovements: string;
  end;

implementation

end.
