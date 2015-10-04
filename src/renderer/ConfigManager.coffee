_ = require "lodash"
__ = require "lodash-deep"
path = require "path"
fs = require "fs-plus"

Emitter = require "../utils/Emitter"

module.exports =
class ConfigManager
    constructor : (options = {}) ->
        {
            @configDirPath,
            @configFileName,
            @jsonIndent,
            @saveThrottleMs
        } = options

        @configFileName ?= "config.json"
        @saveThrottleMs ?= 200
        @jsonIndent ?= "  "

        @emitter = new Emitter
        @config = {}
        @observers = {}

        @configFilePath = path.join @configDirPath, @configFileName
        @save = _.throttle @save.bind(@), @saveThrottleMs

    ###*
    # Initialize configure save directory
    # @protected
    ###
    initializeConfigDir : ->
        return if fs.existsSync(@configDirPath)

        fs.makeTreeSync(@configDirPath)
        @emitter.emit "did-init-config-directory"

        return

    ###*
    # Load config file
    ###
    load : ->
        @initializeConfigDir()
        rawJSON = fs.readFileSync @configFilePath, encoding: "utf8"
        @config = JSON.parse rawJSON

        @emitter.emit "did-load-config-file"
        return

    ###*
    # Save current config to config file
    ###
    save : ->
        @initializeConfigDir()
        stringedJSON = JSON.stringify(@config, null, @jsonIndent)
        fs.writeFileSync @configFilePath, stringedJSON, encoding : "utf8"

        @emitter.emit "did-save-config-file"
        return

    ###*
    # Set config value
    # @param {String}       keyPath     Config key name (accept dot delimited key)
    ###
    set : (keyPath, value) ->
        oldValue = @get keyPath
        return if _.isEqual(oldValue, value)

        __.deepSet(@config, keyPath, value)
        @emitter.emit "did-change", {key: keyPath, newValue: value, oldValue}
        @save()
        return

    ###*
    # Get configured value
    # @param {String}       keyPath     Config key name (accept dot delimited key)
    ###
    get : (keyPath, defaultValue) ->
        __.deepGet(@config, keyPath)

    ###*
    # Observe specified configure changed
    # @param {String}       keyPath     Observing config key name (accept dot delimited key)
    # @param {Function}     observer    callback function
    ###
    observe : (keyPath = null, observer) ->
        oldValue = @get keyPath

        @onDidChange =>
            newValue = @get(keyPath)
            observer(newValue, oldValue) unless _.isEqual(newValue, oldValue)
            oldValue = newValue

    ###*
    # Unobserve specified configured change observer
    # @param {String}       keyPath     Observing config key name (accept dot delimited key)
    # @param {Function}     observer    callback function
    ###
    unobserve : (keyPath = null, observer) ->
        @off "did-change", observer

    #
    # Events
    #

    ###*
    # @param {Function}     fn          callback
    ###
    onDidLoadConfigFile : (fn) ->
        @emitter.on "did-load-config-file"

    ###*
    # @param {Function}     fn          callback
    ###
    onDidSaveConfigFile : (fn) ->
        @emitter.on "did-save-config-file"

    ###*
    # @param {Function}     fn          callback
    ###
    onDidChange : (fn) ->
        @emitter.on "did-change", fn

    ###*
    # @param {Function}     fn          callback
    ###
    onDidInitializeConfigDirectory : (fn) ->
        @emitter.on "did-init-config-directory"
