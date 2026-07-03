unit AccountReceivableAppServiceIntf;

interface

uses
  System.SysUtils,
  AccountReceivableDto;

type
  EAccountReceivableValidationException = class(Exception);
  EAccountReceivableNotFoundException = class(Exception);
  EAccountReceivableStateException = class(Exception);

  IAccountReceivableAppService = interface
    function GetAll: string;
    function GetById(AId: Integer): string;
    function GetPayments(AId: Integer): string;
    procedure CreateFromCreditSale(
      ASaleId,
      ACustomerId: Integer;
      AAmount: Currency);
    function Receive(
      ARequest: TReceiveAccountReceivableRequestDto): string;
    procedure ValidateSaleCancellation(ASaleId: Integer);
    procedure CancelBySaleId(ASaleId: Integer);
  end;

implementation

end.
