Menu = require "menu"
path = require "path"

_ = require "lodash"

Emitter = require "../utils/Emitter"

module.exports = class MenuManager extends Emitter
    constructor     : ({@defaultTemplate}) ->
        super

        @windowMenuMap = new WeakMap
        @handleEvents()

    handleEvents    : ->
        return

    #
    # Menu building helpers
    #

    getDefaultTemplate  : ->
        @defaultTemplate

    #
    # Menu controling
    #

    getActiveMenu       : ->
        Menu.getApplicationMenu()

    attachMenu          : (window) ->
        menu = @windowMenuMap.get window

        unless menu?
            # console.log @defaultTemplate
            menu = @buildFromTemplate @getDefaultTemplate()
            @windowMenuMap.set window, menu

        menu

    changeActiveMenu    : (window) ->
        menu = @windowMenuMap.get window
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
