Remote = require "remote"
Menu = Remote.require("menu")

_ = require "lodash"
{Disposable} = require "event-kit"

Emitter = require "../utils/Emitter"

module.exports =
class ContextMenuManager extends Emitter
    menus : null

    constructor : ->
        super
        @menus = {}

    #
    # Context menu management methods
    #

    ###*
    # @param {String}           selector
    # @param {Array<Object>}    menu
    ###
    add : (selector, menu) ->
        unless Array.isArray(menu)
            throw new TypeError("Menu list must be array.")

        (@menus[selector] ?= new Set).add menu
        return

    ###*
    # @param {String}   selector
    # @param {Array<Object>}    menu
    ###
    remove : (selector, menu) ->
        return unless @menus[selector]?
        @menus[selector].delete(menu)

    ###*
    # Clear all registered context menus
    ###
    clear : ->
        @menus = {}
        return

    #
    # Context menu builder methods
    #

    wrapClick : (item, el) ->
        clickListener = item.click

        =>
            Menu.sendActionToFirstResponder?(item.selector) if item.selector?

            clickListener.call(el, item, activeMenu) if typeof clickListener is "function"
            @emit("did-click-item", item, activeMenu, el)
            @emit("did-click-command-item", item.command, el, item) if item.command?
            return

    translateTemplate : (template, el) ->
        items = _.cloneDeep(template)

        for item in items
            item.metadata ?= {}

            item.click = @wrapClick(item, el)
            item.submenu = @translateTemplate(item.submenu, el) if item.submenu

        items

    templateForElement : (el) ->
        unshift = Array::unshift
        smm = @menus
        presentMenus = []

        for selector, menuList of smm
            continue unless el.matches(selector)
            menuList.forEach (item) ->
                unshift.apply(presentMenus, item)

        # Remove first, last, consecutive separator
        last = presentMenus.length - 1
        presentMenus.splice(0, 1) if presentMenus[0]?.type is "separator"
        presentMenus.splice(last, 1) if presentMenus[last]?.type is "separator"

        for item, i in presentMenus
            prevItem = presentMenus[i - 1]
            presentMenus.splice(i, 1) if prevItem? and prevItem.type is "separator" and item.type is "separator"

        @translateTemplate(presentMenus, el)

    #
    # Context menu display methods
    #

    ###*
    # Show context menu with related to the current focused element
    # @param {HTMLElement} el
    ###
    showForElement : (el) ->
        menu = Menu.buildFromTemplate(@templateForElement(el))
        menu.popup(Remote.getCurrentWindow())
        return

    ###*
    # Show context menu with related to the current focused element and thats parent elements
    # @param {Array<HTMLElement>} path      MouseEvent.path array
    ###
    showForElementPath : (path) ->
        push = Array::push

        menuItems = path.reduce (menus, el) =>
            return menus unless el instanceof HTMLElement
            push.apply(menus, @templateForElement(el))
            menus
        , []

        menu = Menu.buildFromTemplate(menuItems)
        menu.popup(Remote.getCurrentWindow())
        return


    #
    # Events
    #

    ###*
    # @param {Function} fn      listener
    ###
    onDidClickCommandItem : (fn) ->
        @on "did-click-command-item", fn

    ###*
    # @param {Function} fn      listener
    ###
    onDidClickItem : (fn) ->
        @on "did-click-command-item", fn
