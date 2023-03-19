
  if process.args.length > 2

    pipe-name = process.args.3
    message-length = 10
    accepts-remote-clients = no

    { pipe-server, pipe-message } = winjs.load-library 'WinjsNamedPipes.dll'
    { open-pipe, close-pipe, connect-pipe, disconnect-pipe } = pipe-server
    { read-message, write-message } = pipe-message

    finished = no

    execute-server-protocol = (handle) ->

      { succeeded, message } = read-message handle, message-length

      if succeeded

        switch message
          | 'exit' => finished := yes

      write-message handle, 'ok'

    { succeeded, pipe-handle } = open-pipe pipe-name, message-length, accepts-remote-clients
    if succeeded

      loop

        break if finished

        if connect-pipe pipe-handle
          execute-server-protocol pipe-handle
          disconnect-pipe pipe-handle

      close-pipe pipe-handle
