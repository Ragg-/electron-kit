BrowserWindow = require "browser-window"

_ = require "lodash"
{CompositeDisposable, Disposable} = require "event-kit"

Emitter = require "../utils/Emitter"

###*
# BrowserWindow compatible Window class
###
module.exports =
class AppWindow extends Emitter
    browserWindow : null

    # Implement BrowserWindow methods
    _.each Object.keys(BrowserWindow::), (methodName) =>
        return if methodName in ["constructor", "on", "off", "once", "addListener", "removeListener", "destroy"]

        @::[methodName] = (args...) ->
            if @disposed
                throw new Error("Window has been disposed")

            BrowserWindow::[methodName].apply @browserWindow, args
        return

    constructor : (options) ->
        super

        @subscriptions = new CompositeDisposable
        @browserWindow = new BrowserWindow(options)
        @_handleEvents()

    ###*
    # @protected
    ###
    _handleEvents : ->
        # delegate browserWindow events
        # https://github.com/atom/electron/blob/02bdace366f38271b5c186412f42810ecb06e99e/docs/api/browser-window.md
        [
            "page-title-updated"
            "close"
            "closed"
            "unresponsive"
            "responsive"
            "blur"
            "focus"
            "maximize"
            "unmaximize"
            "minimize"
            "restore"
            "resize"
            "move"
            "moved"
            "enter-full-screen"
            "leave-full-screen"
            "enter-html-full-screen"
            "leave-html-full-screen"
            "devtools-opened"
            "devtools-closed"
            "devtools-focused"
        ].forEach (name) =>
            @browserWindow.on name, => @emit name, arguments...
            @subscriptions.add new Disposable =>
                @off name,


    destroy : ->
        @dispose()

    dispose : ->
        @subscriptions.dispose()
        BrowserWindow::destroy.call(@browserWindow)
        @browserWindow = null
        super
