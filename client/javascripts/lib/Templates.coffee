Lanes.namespace "Templates"


ns2path = (ns)->
    ns.replace(".","/").toLowerCase()

Lanes.Templates.find = (name, namespace) ->
    return Lanes.Templates[name] if Lanes.Templates[name]
    if namespace?
        Lanes.Templates[ ns2path(namespace) + "/" + name]
    else
        null

# scribbed from eco's compiler.coffee
# we include the functions here rather than on every single template
Lanes.TemplateWrapper = {

    sanitize: (value) ->
        if value and value.HTMLSafe
            value
        else if typeof value isnt "undefined" and value?
            Lanes.TemplateWrapper.escape value
        else
            ""

    capture: (__out) ->
        (callback) ->
            out = __out
            result = undefined
            __out = []
            callback.call this
            result = __out.join("")
            __out = out
            __safe result

    escape: _.escape

    safe: (value) ->
        if value and value.HTMLSafe
            value
        else
            value = ""  unless typeof value isnt "undefined" and value?
            result = new String(value)
            result.HTMLSafe = true
            result

}