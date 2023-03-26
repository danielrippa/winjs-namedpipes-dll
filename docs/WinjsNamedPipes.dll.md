# WinjsNamedPipes.dll

```
  get-js-value: ->

    pipe-server:

      open-pipe: (pipename: string, message-length: number, accepts-remote-clients: boolean) ->

        succeeded: boolean
        pipe-handle: number

      close-pipe: (pipe-handle: number) -> boolean
      connect-pipe: -> boolean

      disconnect-pipe: (pipe-handle: number) -> boolean

    pipe-client:

      connect-pipe: (hostname: string, pipename: string ) ->

        succeeded: boolean
        pipe-handle: number

      disconnect-pipe: ->

    pipe-message:

      read-message: (pipe-handle: number) -> string
      write-message: (pipe-handle: number, message: string) -> boolean


```
