unit PasswordHasher;

interface

type
  TPasswordHasher = class
  public
    class function GenerateSalt: string; static;
    class function HashPassword(
      const APassword,
      ASalt: string): string; static;
    class function VerifyPassword(
      const APassword,
      AHash,
      ASalt: string): Boolean; static;
  end;

implementation

uses
  System.Hash,
  System.SysUtils;

class function TPasswordHasher.GenerateSalt: string;
begin
  Result := GUIDToString(TGUID.NewGuid);
  Result := StringReplace(Result, '{', '', [rfReplaceAll]);
  Result := StringReplace(Result, '}', '', [rfReplaceAll]);
  Result := StringReplace(Result, '-', '', [rfReplaceAll]);
  Result := LowerCase(Result);
end;

class function TPasswordHasher.HashPassword(
  const APassword,
  ASalt: string): string;
begin
  Result := THashSHA2.GetHashString(ASalt + APassword);
end;

class function TPasswordHasher.VerifyPassword(
  const APassword,
  AHash,
  ASalt: string): Boolean;
begin
  Result := SameText(HashPassword(APassword, ASalt), AHash);
end;

end.
