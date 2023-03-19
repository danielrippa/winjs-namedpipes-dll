
  process.args

    args-ok = ..length > 3

    if args-ok

      pipe-name = ..3
      command = ..4

  if args-ok

    message-length = 10

    { pipe-client, pipe-message } = winjs.load-library 'WinjsNamedPipes.dll'
    { connect-pipe, disconnect-pipe } = pipe-client
    { read-message, write-message } = pipe-message

    execute-client-protocol = (handle) ->

      write-message handle, command
      { succeded, message: response } = read-message handle, message-length
      if succeeded
        process.io.stdout response

    { succeeded, pipe-handle } = connect-pipe '.', pipe-name
    if succeeded

      execute-client-protocol pipe-handle
      disconnect-pipe pipe-handle

