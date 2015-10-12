Emitter = require "../utils/Emitter"
CommandManager      = require "./CommandManager"
ContextMenuManager  = require "./ContextMenuManager"
ConfigManager       = require "./ConfigManager"
MenuManagerProxy    = require "./MenuManagerProxy"

module.exports =
class Application extends Emitter
    command         : null

    constructor : (@options = {}) ->
        super

        @_initializeModules()
        @_handleEvents()


    ###*
    # @protected
    ###
    _initializeModules : ->
        @command = new CommandManager(@options)
        @contextMenu = new ContextMenuManager(@options)
        @config = new ConfigManager(@options)
        @menu = new MenuManagerProxy(@options)
        return

    ###*
    # @protected
    ###
    _handleEvents : ->
        @contextMenu.onDidClickCommandItem (command, el) =>
            @command.dispatch command, el

        window.addEventListener "contextmenu", (e) =>
            setTimeout =>
                # Why use setTimeout???
                # event.path is buggy, execute `event.path` immediately,
                # e.path is broken... (array is only `window`)
                # WebKit has an bug?
                @contextMenu.showForElementPath e.path
            , 0

        return
