app = require "app"
ipc = require "ipc"

Emitter = require "../utils/Emitter"
WindowManager = require "./WindowManager"
CommandManager = require "./CommandManager"
MenuManager = require "./MenuManager"

module.exports =
class Application extends Emitter
    windows         : null
    command         : null
    menu            : null
    options         : null

    constructor : (@options = {}) ->
        super

        @_initializeModules()
        @_handleEvents()
        @_handleCommands()

    ###*
    # @protected
    ###
    _initializeModules : ->
        @windows = new WindowManager(@options)
        @command = new CommandManager(@options)
        @menu = new MenuManager(@options)
        return

    ###*
    # @protected
    ###
    _handleEvents : ->

        # MenuManager events
        @windows.onDidAddWindow (window) =>
            @menu.attachMenu window

        @windows.onDidChangeFocusedWindow (window) =>
            @menu.changeActiveMenu window

        @menu.onDidClickCommandItem (command) =>
            @command.dispatch command

        return

    ###*
    # @protected
    ###
    _handleCommands : ->
        @command.on
            # Application commands
            "app:new-window" : =>
                @windows.openWindow()

            "app:quit" : =>
                app.quit()
                return

            # Window commands
            "window:toggle-dev-tools" : => @windows.lastFocusedWindow()?.toggleDevTools()
            "window:reload" : => @windows.lastFocusedWindow()?.reload()
            "window:close" : =>
                return unless (bw = @windows.lastFocusedWindow()?.browserWindow)?

                if bw.devToolsWebContents?
                    bw.closeDevTools()
                else if bw.isFocused()
                    bw.close()
                return

        return
