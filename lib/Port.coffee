events = require "events"

class Port extends events.EventEmitter
    constructor: (name) ->
        @name = name
        @socket = null

    attach: (socket) ->
        throw new Error "#{@name}: Socket already attached #{@socket.getId()} - #{socket.getId()}" if @socket
        @socket = socket
        @from = socket.from
        @socket.on "connect", =>
            @emit "connect", socket
        @socket.on "data", (data) =>
            @emit "data", data
        @socket.on "disconnect", =>
            @emit "disconnect", socket

    detach: ->
        @socket = null

    send: (data) ->
        return @socket.send data if @isConnected()
        @socket.on "connect", =>
            @socket.send data
        @socket.connect()

    connect: ->
        throw new Error "No connection available" unless @socket
        @socket.connect()

    disconnect: ->
        return unless @socket
        @socket.disconnect()

    isConnected: ->
        unless @socket
            return false
        @socket.isConnected()

exports.Port = Port
