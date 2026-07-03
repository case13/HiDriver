unit UserRepositoryIntf;

interface

uses
  User;

type
  IUserRepository = interface
    // The caller owns the user returned by FindByUserName.
    function FindByUserName(const AUserName: string): TUser;
    function ExistsByUserName(const AUserName: string): Boolean;
    // Insert does not take ownership of AUser.
    procedure Insert(AUser: TUser);
  end;

implementation

end.
