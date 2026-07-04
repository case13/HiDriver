unit IDesktopConfig;

interface

type
  IDesktopConfigContract = interface
    ['{8627DD09-00DE-4556-A5BE-E68230D61096}']
    function GetBaseApiUrl: string;
    property BaseApiUrl: string read GetBaseApiUrl;
  end;

implementation

end.
