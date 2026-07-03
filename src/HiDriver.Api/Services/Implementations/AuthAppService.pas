unit AuthAppService;

interface

uses
  AuthDtos,
  AuthAppServiceIntf,
  AuthValidatorIntf,
  UserRepositoryIntf;

type
  TAuthAppService = class(TInterfacedObject, IAuthAppService)
  private
    FUserRepository: IUserRepository;
    FAuthValidator: IAuthValidator;
  public
    constructor Create(
      const AUserRepository: IUserRepository;
      const AAuthValidator: IAuthValidator);
    function Login(
      const AUserName,
      APassword: string): TLoginResponseDto;
  end;

implementation

uses
  System.SysUtils,
  PasswordHasher,
  User;

constructor TAuthAppService.Create(
  const AUserRepository: IUserRepository;
  const AAuthValidator: IAuthValidator);
begin
  inherited Create;
  FUserRepository := AUserRepository;
  FAuthValidator := AAuthValidator;
end;

function TAuthAppService.Login(
  const AUserName,
  APassword: string): TLoginResponseDto;
var
  ErrorMessage: string;
  User: TUser;
begin
  if not FAuthValidator.ValidateLogin(
    AUserName,
    APassword,
    ErrorMessage) then
    raise EAuthValidationException.Create(ErrorMessage);

  User := FUserRepository.FindByUserName(Trim(AUserName));
  try
    if not Assigned(User) or
      not User.CanLogin or
      not TPasswordHasher.VerifyPassword(
        APassword,
        User.PasswordHash,
        User.PasswordSalt) then
      raise EInvalidCredentialsException.Create(
        'Invalid username or password.');

    Result := TLoginResponseDto.Create;
    Result.Token := TGUID.NewGuid.ToString;
    Result.UserId := User.Id;
    Result.UserName := User.UserName;
    Result.DisplayName := User.DisplayName;
    Result.Role := User.Role;
  finally
    User.Free;
  end;
end;

end.
