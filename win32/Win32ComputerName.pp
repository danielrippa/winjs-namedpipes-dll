unit Win32ComputerName;

{$mode delphi}

interface

  function GetNetBiosComputerName: String;
  function GetDnHostNameComputerName: String;
  function GetDnsDomainComputerName: String;
  function GetDnsFullyQualifiedComputerName: String;

  function GetPhysicalNetBiosComputerName: String;
  function GetPhysicalDnsHostNameComputerName: String;
  function GetPhysicalDnsDomainComputerName: String;
  function GetPhysicalDnsFullyQualifiedComputerName: String;

implementation

  uses
    Windows;

  function GetLocalComputerName(aFormat: COMPUTER_NAME_FORMAT): String;
  var
    Size: DWord;
  begin
    Size := MAX_COMPUTERNAME_LENGTH;
    SetLength(Result, Size);

    if GetComputerNameEx(aFormat, Pointer(Result), @Size) then begin
      SetLength(Result, Size);
    end else begin
      Result := '';
    end;
  end;

  function GetDnsDomainComputerName: String;
  begin
    Result := GetLocalComputerName(ComputerNameDnsDomain);
  end;

  function GetDnsFullyQualifiedComputerName: String;
  begin
    Result := GetLocalComputerName(ComputerNameDnsFullyQualified);
  end;

  function GetDnHostNameComputerName: String;
  begin
    Result := GetLocalComputerName(ComputerNameDnsHostName);
  end;

  function GetNetBiosComputerName: String;
  begin
    Result := GetLocalComputerName(ComputerNameNetBios);
  end;

  function GetPhysicalDnsDomainComputerName: String;
  begin
    Result := GetLocalComputerName(ComputerNamePhysicalDnsDomain);
  end;

  function GetPhysicalDnsFullyQualifiedComputerName: String;
  begin
    Result := GetLocalComputerName(ComputerNameDnsFullyQualified);
  end;

  function GetPhysicalNetBiosComputerName;
  begin
    Result := GetLocalComputerName(ComputerNamePhysicalNetBios);
  end;

  function GetPhysicalDnsHostNameComputerName;
  begin
    Result := GetLocalComputerName(ComputerNameDnsHostName);
  end;

end.