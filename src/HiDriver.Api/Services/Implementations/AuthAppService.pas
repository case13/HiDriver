unit AuthAppService;

interface

uses
  AuthDtos,
  AuthAppServiceIntf,
  AuthValidatorIntf,
  JwtServiceIntf,
  UserRepositoryIntf;

type
  TAuthAppService = class(TInterfacedObject, IAuthAppService)
  private
    FUserRepository: IUserRepository;
    FAuthValidator: IAuthValidator;
    FJwtService: IJwtService;
  public
    constructor Create(
      const AUserRepository: IUserRepository;
      const AAuthValidator: IAuthValidator;
      const AJwtService: IJwtService);
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
  const AAuthValidator: IAuthValidator;
  const AJwtService: IJwtService);
begin
  inherited Create;
  FUserRepository := AUserRepository;
  FAuthValidator := AAuthValidator;
  FJwtService := AJwtService;
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
    Result.Token := FJwtService.GenerateToken(
      User.Id,
      User.UserName,
      User.DisplayName,
      User.Role);
    Result.UserId := User.Id;
    Result.UserName := User.UserName;
    Result.DisplayName := User.DisplayName;
    Result.Role := User.Role;
  finally
    User.Free;
  end;
end;

end.
