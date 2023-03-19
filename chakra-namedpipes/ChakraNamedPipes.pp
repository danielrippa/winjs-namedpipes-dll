unit ChakraNamedPipes;

{$mode delphi}

interface

  uses ChakraTypes;

  function GetJsValue: TJsValue;

implementation

  uses Chakra, ChakraUtils, Win32NamedPipes;

  function ServerOpenPipeResult(aSuccess: Boolean; aPipe: TPipe): TJsValue;
  begin
    Result := CreateObject;

    SetProperty(Result, 'succeeded', BooleanAsJsBoolean(aSuccess));
    SetProperty(Result, 'pipeHandle', IntAsJsNumber(aPipe));
  end;

  function ChakraServerOpenPipe(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    aPipeName: WideString;
    aMessageLength: Integer;
    aAcceptsRemoteClients: Boolean;
    Pipe: TPipe;
    Success: Boolean;
  begin
    CheckParams('openPipe', Args, ArgCount, [jsString, jsNumber, jsBoolean], 3);

    aPipeName := JsStringAsString(Args^); Inc(Args);
    aMessageLength := JsNumberAsInt(Args^); Inc(Args);
    aAcceptsRemoteClients := JsBooleanAsBoolean(Args^);

    Success := ServerOpenPipe(aPipeName, aMessageLength, aAcceptsRemoteClients, Pipe);

    Result := ServerOpenPipeResult(Success, Pipe);
  end;

  function ChakraServerClosePipe(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    CheckParams('closePipe', Args, ArgCount, [jsNumber], 1);

    Result := BooleanAsJsBoolean(ServerClosePipe(JsNumberAsInt(Args^)));
  end;

  function ChakraServerConnectPipe(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    CheckParams('connectPipe', Args, ArgCount, [jsNumber], 1);

    Result := BooleanAsJsBoolean(ServerConnectPipe(JsNumberAsInt(Args^)));
  end;

  function ChakraServerDisconnectPipe(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    CheckParams('disconnectPipe', Args, ArgCount, [jsNumber], 1);

    Result := BooleanAsJsBoolean(ServerDisconnectPipe(JsNumberAsInt(Args^)));
  end;

  function GetPipeServer: TJsValue;
  begin
    Result := CreateObject;

    SetFunction(Result, 'openPipe', ChakraServerOpenPipe);
    SetFunction(Result, 'closePipe', ChakraServerClosePipe);
    SetFunction(Result, 'connectPipe', ChakraServerConnectPipe);
    SetFunction(Result, 'disconnectPipe', ChakraServerDisconnectPipe);
  end;

  function ClientConnectResult(aSuccess: Boolean; aPipe: TPipe): TJsValue;
  begin
    Result := CreateObject;

    SetProperty(Result, 'succeeded', BooleanAsJsBoolean(aSuccess));
    SetProperty(Result, 'pipeHandle', IntAsJsNumber(aPipe));
  end;

  function ChakraClientConnectPipe(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    aHostName, aPipeName, aMessage: WideString;
    Pipe: TPipe;
    Success: Boolean;
  begin
    CheckParams('connectPipe', Args, ArgCount, [jsString, jsString], 2);

    aHostName := JsStringAsString(Args^); Inc(Args);
    aPipeName := JsStringAsString(Args^);

    Success := ClientConnectPipe(aHostName, aPipeName, Pipe);

    Result := ClientConnectResult(Success, Pipe);
  end;

  function ChakraClientDisconnectPipe(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    CheckParams('disconnectPipe', Args, ArgCount, [jsNumber], 1);

    Result := BooleanAsJsBoolean(ClientDisconnectPipe(JsNumberAsInt(Args^)));
  end;

  function GetPipeClient: TJsValue;
  begin
    Result := CreateObject;

    SetFunction(Result, 'connectPipe', ChakraClientConnectPipe);
    SetFunction(Result, 'disconnectPipe', ChakraClientDisconnectPipe);
  end;

  function ReadMessageResult(aSuccess: Boolean; aMessage: WideString): TJsValue;
  begin
    Result := CreateObject;

    SetProperty(Result, 'succeeded', BooleanAsJsBoolean(aSuccess));
    SetProperty(Result, 'message', StringAsJsString(aMessage));
  end;

  function ChakraReadPipeMessage(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    aPipe: TPipe;
    aMessageLength: Integer;
    Message: String;
    Success: Boolean;
  begin
    CheckParams('readMessage', Args, ArgCount, [jsNumber, jsNumber], 2);

    aPipe := JsNumberAsInt(Args^); Inc(Args);
    aMessageLength := JsNumberAsInt(Args^);

    Success := ReadPipeMessage(aPipe, aMessageLength, Message);

    Result := ReadMessageResult(Success, Message);
  end;

  function ChakraWritePipeMessage(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    aPipe: TPipe;
    aMessage: WideString;
  begin
    CheckParams('writeMessage', Args, ArgCount, [jsNumber, jsString], 2);

    aPipe := JsNumberAsInt(Args^); Inc(Args);
    aMessage := JsStringAsString(Args^);

    Result := BooleanAsJsBoolean(WritePipeMessage(aPipe, aMessage));
  end;

  function GetPipeMessage: TJsValue;
  begin
    Result := CreateObject;

    SetFunction(Result, 'readMessage', ChakraReadPipeMessage);
    SetFunction(Result, 'writeMessage', ChakraWritePipeMessage);
  end;

  function GetJsValue;
  begin

    Result := CreateObject;

    SetProperty(Result, 'pipeServer', GetPipeServer);
    SetProperty(Result, 'pipeClient', GetPipeClient);
    SetProperty(Result, 'pipeMessage', GetPipeMessage);

  end;

end.