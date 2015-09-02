# Browser and Renderer must be lazy loading
# Can't use some Electron APIs on Renderer-process. (app, browser-window, and more)
# When electron-kit requiring on Renderer process,
# that modules failed to loading and caused an error.
Browser =
    Application         : null
    AppWindow           : null
    CommandManager      : null
    MenuManager         : null
    WindowManager       : null

Renderer =
    Application         : null
    CommandManager      : null
    ContextMenuManager  : null
    MenuManager         : null
    ConfigManager       : null


Object.defineProperties exports,
    Browser :
        get : ->
            Browser.Application     ?= require "./browser/Application"
            Browser.AppWindow       ?= require "./browser/AppWindow"
            Browser.CommandManager  ?= require "./browser/CommandManager"
            Browser.MenuManager     ?= require "./browser/MenuManager"
            Browser.WindowManager   ?= require "./browser/WindowManager"
            Browser


    Renderer :
        get : ->
            Renderer.Application        ?= require "./renderer/Application"
            Renderer.CommandManager     ?= require "./renderer/CommandManager"
            Renderer.ContextMenuManager ?= require "./renderer/ContextMenuManager"
            Renderer.MenuManager        ?= require "./renderer/MenuManagerProxy"
            Renderer.ConfigManager      ?= require "./renderer/ConfigManager"
            Renderer

    Emitter :
        value : require "./utils/Emitter"
