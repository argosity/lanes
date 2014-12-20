
# a simple reimplentation
# to use traffic cop
methodMap = {
    'create': 'POST',
    'update': 'PUT',
    'patch':  'PATCH',
    'delete': 'DELETE',
    'read':   'GET'
}

getValue = (object, prop)->
    if !(object && object[prop])
        return null;
    return if _.isFunction(object[prop]) then object[prop]() else object[prop];




paramsMap = {
    fields  : 'f'
    with    : 'w'
    query   : 'q'
    include : 'i'
    order   : 'o'
    limit   : 'l'
    start   : 's'
    format  : 'df'
}

Lanes.Data.Sync = {
    urlError: ->
        throw new Error('A "url" property or function must be specified')

    copyServerResp: (record,resp)->
        record.errors = resp?.errors
        record.lastServerMessage = resp?.message
        { record: record, response: resp }

    # Wraps a sync request's error and success functions
    # Copies any errors onto the model and sets it's data on success
    wrapRequest: (record, options)->
        error   = options.error
        success = options.success
        options.promise = new _.Promise( (resolve,reject)->
            options.resolvePromise = resolve
            options.rejectPromise  = reject
        )
        options.error = (reply, resp, req)->
            options.rejectPromise( this.copyServerResp(record,resp.responseJSON || {error: resp.responseText}) )
            error?.apply(options.scope, arguments)

        options.success = (reply,resp,req)->
            record.setFromResponse( resp.data, options ) if resp?.data?
            options.resolvePromise( Lanes.Data.Sync.copyServerResp(record,resp) )
            success?.apply(options.scope, arguments)
        options

    perform: (method, model, options={})->
        query = {}
        for key, value of options
            query[ paramsMap[key] ] = value if paramsMap[key]

        # Default JSON-request options.
        params = {
            type: methodMap[method]
            dataType: "json"
            data: query
        }

        # Ensure that we have a URL.
        params.url = _.result(model, "url") or Lanes.Data.Sync.urlError() unless options.url
        params.url += '.json'
        params.headers = {
            X_CSRF_TOKEN: Lanes.Data.Config.csrf_token
        }
        params.contentType = "application/json"
        if options.data || _.contains(['create','update','patch'], method)
            params.data = JSON.stringify( options.data || model.dataForSave(options) )
            delete options.data

        # Make the request, allowing the user to override any Ajax options.
        xhr = options.xhr = Lanes.$.ajax(_.extend(params, options))
        model.trigger "request", model, xhr, options
        xhr
}
