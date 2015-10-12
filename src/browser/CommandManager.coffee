ipc = require "ipc"

_ = require "lodash"

Emitter = require "../utils/Emitter"

###
* Browser side Command manager
###
module.exports =
class CommandManager extends Emitter
    _emitter : null

    constructor : ->
        super
        @_emitter = new Emitter()
        @_handleEvents()

    _handleEvents : ->
        ipc.on "command", @_didReceived.bind(@)
        return

    #
    # Dispatcher
    #

    dispatch : (command, args...) ->
        @emit command, args...
        return

    dispatchToWindow : (window, command, args...) ->
        return if typeof window?.browserWindow?.webContents?.send isnt "function"

        window.browserWindow.webContents.send "command", command, args...
        @_emitter.emit "did-send", {window, command, args}
        return

    #
    # Event handler
    #

    _didReceived : (e, command, args...) =>
        @emit command, args...
        @_emitter.emit "did-receive", {command, args}
        return

    #
    # Events
    #

    ###*
    # Register command handler
    # @param {String|Object<String, Function>}  command     command name or {"commandName": listener} Object
    # @param {Function} listener
    ###
    on : (command, listener) ->
        if _.isPlainObject(command)
            disposables = for commandName, listener of command
                @on commandName, listener
            return disposables

        super

    ###*
    # @param {Function} listener
    ###
    onDidSend : (fn) ->
        @_emitter.on "did-send", fn
        return

    ###*
    # @param {Function} listener
    ###
    onDidReceive : (fn) ->
        @_emitter.on "did-receive", fn
        return
