ipc = require "ipc"

_ = require "lodash"
{Disposable} = require "event-kit"

Emitter = require "../utils/Emitter"

###*
# Renderer side Command manager
###
module.exports =
class CommandManager extends Emitter
    constructor     : ->
        super

        @_emitter = new Emitter()
        @_domObservers = {}
        @_handleEvents()

    ###*
    # @protected
    ###
    _handleEvents    : ->
        ipc.on "command", @_didReceived.bind(@)
        return

    #
    # Dispatcher
    #

    ###*
    # Dispatch command to Renderer and Browser process
    # @param {String} command
    # @param {Any...} args
    ###
    dispatch : (command, args...) ->
        @emit command, args...
        @dispatchToBrowser command, args...
        return

    ###*
    # Dispatch command to Browser process
    # @param {String} command
    # @param {Any...} args
    ###
    dispatchToBrowser : (command, args...) ->
        ipc.send "command", command, args...
        @_emitter.emit "did-send", {command, args}
        return

    #
    # Command handler
    #

    on : (command, handler) ->
        if _.isPlainObject(command)
            disposables = for eventName, listener of command
                @on eventName, listener

            return new Disposable ->
                disposables.forEach (disposable) ->
                    disposable.dispose()

                disposables = null
                return

        super

    ###*
    # Add command observer on DOMElement
    # @param {String|HTMLElement} selector      handler element (or CSS selector)
    # @param {String|Object.<String,Function>} command       handle command
    # @param {Function} callback    command listener
    # @return {Disposable}
    ###
    observeOn : (selector, command, handler) ->
        if _.isPlainObject(command)
            disposables = for commandName, handler of event
                @observeOn selector, commandName, handler

            return new Disposable ->
                disposables.forEach (disposable) ->
                    disposable.dispose()

                disposables = null
                return

        listener = ->
            currentElement = document.activeElement

            if _.isElement(selector) and currentElement is selector
                callback.call(currentElement)
            else if currentElement.matches(selector)
                callback.call(currentElement)

        observerSet = {selector, listener}

        commandObserver = @_domObservers[command] ?= new Set
        commandObserver.add observerSet

        disposer = @on command, listener

        new Disposable =>
            commandObserver.delete(observerSet)
            disposer.dispose()


    #
    # Event handler
    #

    ###*
    # @private
    ###
    _didReceived : (command, args...) ->
        @emit command, args...
        @_emitter.emit "did-receive", {command, args}
        return

    #
    # Events
    #

    ###*
    # @param {Function} fn      listener
    ###
    onDidSend       : (fn) ->
        @_emitter.on "did-send", fn
        new Disposable => @off "did-send", fn

    ###*
    # @param {Function} fn      listener
    ###
    onDidReceive    : (fn) ->
        @_emitter.on "did-receive", fn
        new Disposable => @off "did-receive", fn
