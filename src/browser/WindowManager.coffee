BrowserWindow = require "browser-window"

{CompositeDisposable} = require "event-kit"

Emitter = require "../utils/Emitter"
AppWindow = require "./AppWindow"

module.exports =
class WindowManager

    constructor : ->
        @emitter = new Emitter
        @subscriptions = new CompositeDisposable
        @windows = new Set

    #
    # Window management
    #

    ###*
    # Open a new BrowserWindow
    # @param {Object}      options     Options for BrowserWindow creation
    # @return {AppWindow}
    ###
    openWindow : (options = {}) ->
        window = new AppWindow(options)
        @addWindow window
        window

    ###*
    # Add created window into WindowManager
    # @param {AppWindow}    window
    ###
    addWindow : (window) ->
        beforeSize = @windows.size
        return if @windows.add(window).size is beforeSize

        @subscriptions.add window.on "focus", =>
            @setLastFocusedWindow(window)

        @emitter.emit "did-add-window", window
        return

    removeWindow : (window) ->
        return unless @windows.delete(window)
        @emitter.emit "did-remove-window", window
        return

    #
    # State management
    #

    setLastFocusedWindow : (window) ->
        @_lastFocusedWindow = window
        @emitter.emit "did-change-focused-window", window
        return

    lastFocusedWindow : ->
        @_lastFocusedWindow


    #
    # Events
    #

    onDidAddWindow : (fn) ->
        @emitter.on "did-add-window", fn

    onDidRemoveWindow : (fn) ->
        @emitter.on "did-remove-window", fn

    onDidChangeFocusedWindow : (fn) ->
        @emitter.on "did-change-focused-window", fn
