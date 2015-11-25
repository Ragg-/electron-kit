{remote} = require "remote"
Menu = remote.Menu

module.exports =
class MenuManagerProxy

    #
    # Menu controling
    #

    getActiveMenu       : ->
        Menu.getApplicationMenu()
