_ = require "lodash"
__ = require "lodash-deep"
path = require "path"
fs = require "fs-plus"

Emitter = require "../utils/Emitter"
deepDelete = require "../utils/deepDelete"

module.exports =
class ConfigManager
    constructor : (options = {}) ->
        {
            configDirPath,
            configFileName,
            jsonIndent,
            saveThrottleMs
        } = options

        @_configDirPath = configDirPath
        @_configFileName = configFileName
        @_jsonIndent = jsonIndent
        @_saveThrottleMs = saveThrottleMs

        @_configFileName ?= "config.json"
        @_saveThrottleMs ?= 200
        @_jsonIndent ?= "  "

        @_emitter = new Emitter
        @_config = {}

        @_configFilePath = path.join @_configDirPath, @_configFileName
        @save = _.throttle @save.bind(@), @_saveThrottleMs

    ###*
    # Initialize configure save directory
    # @protected
    ###
    _initializeConfigDir : (force = false)->
        if fs.existsSync(@_configDirPath) is no or force
            fs.makeTreeSync(@_configDirPath)

        if fs.existsSync(@_configFilePath) is no or force
            fs.writeFileSync(@_configFilePath, "{}")

        @_emitter.emit "did-init-config-directory"
        @_initializeConfigDir = ->
        return

    ###*
    # Load config file
    ###
    load : ->
        @_initializeConfigDir()
        rawJSON = fs.readFileSync @_configFilePath, encoding: "utf8"
        @_config = JSON.parse rawJSON

        @_emitter.emit "did-load-config-file"
        return

    ###*
    # Save current config to config file
    ###
    save : ->
        @_initializeConfigDir()
        stringedJSON = JSON.stringify(@_config, null, @_jsonIndent)
        fs.writeFileSync @_configFilePath, stringedJSON, encoding : "utf8"

        @_emitter.emit "did-save-config-file"
        return

    ###*
    # Set config value
    # @param {String}       keyPath     Config key name (accept dot delimited key)
    ###
    set : (keyPath, value) ->
        oldValue = @get keyPath
        return if _.isEqual(oldValue, value)

        __.deepSet(@_config, keyPath, value)
        @_emitter.emit "did-change", {key: keyPath, newValue: value, oldValue}
        @save()
        return

    ###*
    # Get configured value
    # @param {String}       keyPath     Config key name (accept dot delimited key)
    ###
    get : (keyPath, defaultValue) ->
        value = __.deepGet(@_config, keyPath)
        return if value is undefined then defaultValue else value

    ###*
    # Unset config value
    # @param {String}       keyPath     Config key name (accept dot delimited key)
    ###
    delete : (keyPath) ->
        oldValue = @get(keyPath)
        deepDelete(@_config, keyPath)
        @_emitter.emit "did-change", {key: keyPath, newValue: undefined, oldValue, deleted: true}
        @save()
        return

    ###*
    # Observe specified configure changed
    # @param {String}       keyPath     Observing config key name (accept dot delimited key)
    # @param {Function}     observer    callback function
    ###
    observe : (keyPath = null, observer) ->
        oldValue = @get keyPath

        @onDidChange =>
            newValue = @get keyPath
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
        @_emitter.on "did-load-config-file"

    ###*
    # @param {Function}     fn          callback
    ###
    onDidSaveConfigFile : (fn) ->
        @_emitter.on "did-save-config-file"

    ###*
    # @param {Function}     fn          callback
    ###
    onDidChange : (fn) ->
        @_emitter.on "did-change", fn

    ###*
    # @param {Function}     fn          callback
    ###
    onDidInitializeConfigDirectory : (fn) ->
        @_emitter.on "did-init-config-directory"
