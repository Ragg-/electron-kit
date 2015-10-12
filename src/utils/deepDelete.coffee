module.exports = (obj, keyPath) ->
    # from http://stackoverflow.com/questions/5059951/deleting-js-object-properties-a-few-levels-deep
    paths = keyPath.split(".")

    if paths.length > 1
        deepDelete(obj[paths[0]], paths[1..].join("."))
    else
        delete obj[keyPath]

    return
