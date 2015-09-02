Remote = require "remote"
Menu = Remote.require "menu"

module.exports =
class MenuManagerProxy

    #
    # Menu controling
    #

    getActiveMenu       : ->
        Menu.getApplicationMenu()
