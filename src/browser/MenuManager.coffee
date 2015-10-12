Menu = require "menu"
path = require "path"

_ = require "lodash"

Emitter = require "../utils/Emitter"

module.exports = class MenuManager extends Emitter
    constructor     : ({@defaultTemplate}) ->
        super

        @_windowMenuMap = new WeakMap
        @_handleEvents()

    _handleEvents    : ->
        return

    #
    # Menu building helpers
    #

    _translateTemplate   : (template) ->
        wrapClick = (item) =>
            clickListener = item.click

            =>
                Menu.sendActionToFirstResponder?(item.selector) if item.selector?

                activeMenu = @getActiveMenu()
                clickListener(item, activeMenu) if typeof clickListener is "function"
                @emit("did-click-item", item, activeMenu)
                @emit("did-click-command-item", item.command, item, activeMenu) if item.command?
                return

        items = _.cloneDeep(template)

        for item in items
            item.metadata ?= {}

            item.click = wrapClick(item)
            item.submenu = @_translateTemplate(item.submenu) if item.submenu

        items

    _buildFromTemplate   : (template) ->
        Menu.buildFromTemplate @_translateTemplate(template)

    _getDefaultTemplate  : ->
        @defaultTemplate

    #
    # Menu controling
    #

    getActiveMenu       : ()->
        Menu.getApplicationMenu()

    attachMenu          : (window) ->
        menu = @_windowMenuMap.get window

        unless menu?
            # console.log @defaultTemplate
            menu = @_buildFromTemplate @_getDefaultTemplate()
            @_windowMenuMap.set window, menu

        menu

    changeActiveMenu    : (window) ->
        menu = @_windowMenuMap.get window
        menu = @attachMenu(window) unless menu?

        Menu.setApplicationMenu(menu)
        @emit "did-change-active-menu"
        return

    #
    # Event handlers
    #

    onDidClickCommandItem   : (fn) ->
        @on "did-click-command-item", fn
        return

    onDidChangeActiveMenu   : (fn) ->
        @on "did-change-active-menu", fn
        return

    onDidClickItem          : (fn) ->
        @on "did-click-item", fn
        return
