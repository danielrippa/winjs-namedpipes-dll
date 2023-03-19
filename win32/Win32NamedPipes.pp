unit Win32NamedPipes;

{$mode delphi}

interface

  type TPipe = THandle;

  function ServerOpenPipe(aPipeName: String; aMessageLength: DWord; aAcceptRemoteClients: Boolean; var Pipe: TPipe): Boolean;
  function ServerClosePipe(aPipe: TPipe): Boolean;
  function ServerConnectPipe(aPipe: TPipe): Boolean;
  function ServerDisconnectPipe(aPipe: TPIpe): Boolean;

  function ClientConnectPipe(aHostName, aPipeName: String; var Pipe: TPipe): Boolean;
  function ClientDisconnectPipe(aPipe: TPipe): Boolean;

  function ReadPipeMessage(aPipe: TPipe; aMessageLength: DWord; var Message: String): Boolean;
  function WritePipeMessage(aPipe: TPipe; aMessage: String): Boolean;

implementation

  uses
    Windows, SysUtils, Win32ComputerName;

  const

    FILE_FLAG_FIRST_PIPE_INSTANCE = $00080000;

    PIPE_ACCEPT_REMOTE_CLIENTS = $00000000;
    PIPE_REJECT_REMOTE_CLIENTS = $00000008;

  function GetPipeName(aHostName, aPipeName: String): String;
  begin
    Result := Format('\\%s\pipe\%s', [aHostName, aPipeName]);
  end;

  function ServerOpenPipe;
  var
    lpName: PChar;
    dwOpenMode, dwPipeMode: DWord;
  begin

    lpName := PChar(GetPipeName('.', aPipeName));

    dwOpenMode := PIPE_ACCESS_DUPLEX or FILE_FLAG_FIRST_PIPE_INSTANCE;
    dwPipeMode := PIPE_TYPE_MESSAGE or PIPE_READMODE_MESSAGE or PIPE_WAIT;

    if aAcceptRemoteClients then
      dwPipeMode := dwPipeMode or PIPE_ACCEPT_REMOTE_CLIENTS
    else
      dwPipeMode := dwPipeMode or PIPE_REJECT_REMOTE_CLIENTS;

    Pipe := CreateNamedPipe(lpName, dwOpenMode, dwPipeMode, 1, aMessageLength, aMessageLength, 0, Nil);
    Result := Pipe <> INVALID_HANDLE_VALUE;

  end;

  function ServerClosePipe;
  begin
    Result := CloseHandle(aPipe);
  end;

  function ServerConnectPipe;
  begin
    Result := ConnectNamedPipe(aPipe, Nil);
  end;

  function ServerDisconnectPipe;
  begin
    FlushFileBuffers(aPipe);
    Result := DisconnectNamedPipe(aPipe);
  end;

  function ClientConnectPipe;
  var
    lpName: Array[0..1023] of WideChar;
    dwPipeMode: DWord;
    Success: Boolean;
  begin

    Result := False;

    if aHostName = '' then begin
      aHostName := '.';
    end else begin
      if CompareText(aHostName, GetNetBiosComputerName) = 0 then begin
        aHostName := '.';
      end;
    end;

    StrCopy(@lpName, PWideChar(GetPipeName(aHostName, aPipeName)));

    if WaitNamedPipe(@lpName, NMPWAIT_USE_DEFAULT_WAIT) then begin

      Pipe := CreateFile(@lpName, GENERIC_READ or GENERIC_WRITE, 0, Nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
      Success := Pipe <> INVALID_HANDLE_VALUE;

      if Success then begin

        dwPipeMode := PIPE_READMODE_MESSAGE or PIPE_WAIT;
        Result := SetNamedPipeHandleState(Pipe, dwPipeMode, Nil, Nil);

      end;

    end;

  end;

  function ClientDisconnectPipe;
  begin
    Result := CloseHandle(aPipe);
  end;

  function ReadPipeMessage;
  var
    lpBuffer: Pointer;
    BytesRead: DWord;
    PAnsiBuffer: PAnsiChar;
  begin

    Result := False;

    GetMem(lpBuffer, aMessageLength + 1);

    try

      if ReadFile(aPipe, lpBuffer^, aMessageLength, BytesRead, Nil) then begin
        if BytesRead > 0 then begin

          PAnsiBuffer := lpBuffer;
          PAnsiBuffer[BytesRead] := #0;

          Message := String(PAnsiBuffer);

          Result := True;

        end;
      end;

    finally
      FreeMem(lpBuffer);
    end;

  end;

  function WritePipeMessage;
  var
    lpBuffer: PChar;
    BytesWritten: DWord;
  begin
    lpBuffer := PChar(aMessage);

    Result := WriteFile(aPipe, lpBuffer^, Length(aMessage), BytesWritten, Nil);
  end;

end.