# Patterned loosely after Backbone React
# https://github.com/magalhas/backbone-react-component/blob/master/lib/component.js

# Mixing `Backbone.Events` into `Wrapper.prototype`
# Binds models and collections to a `React.Component`. It mixes `Backbone.Events`.

class DataWrapper

    constructor: (@component, initialState = {}) ->
        # Object to store data state (not the component state)
        @states = {}
        @rebind(_.clone(initialState), silent: true)

    rebind: (objects, options = {}) ->
        customEvents = _.result(@component, 'bindDataEvents', {})
        @_rebindAttr(name, state, customEvents[name], options) for name, state of objects when state isnt false

    _rebindAttr: (name, state, ev, options) ->
        unless state
            Lanes.warn "#{name} is not set on #{@componentName()}"
            return

        prevState = @states[name]

        # onto next if the object is the same
        return if prevState == state

        @states[name] = state

        this.bindEvents(name, state, ev)

        if Lanes.u.isModel(state)
            @listenToNetworkEvents(state) if @component.listenNetworkEvents
            if @isStateUsingPubsub(name, state)
                if !prevState? or prevState.getId() != state.getId()
                    Lanes.Models.PubSub.remove(prevState) if prevState
                    unless false == state.pubsub
                        if state.isNew()
                            state.once "change:#{state.idAttribute}", -> Lanes.Models.PubSub.add(state)
                        else
                            Lanes.Models.PubSub.add(state)
                @listenTo(state, 'remote-update', @onPubSubChangeSet)
        this.setComponentState({}) unless options.silent

    listenToNetworkEvents: (state) ->
        @listenTo(state,     'error',     @onError)
            .listenTo(state, 'request',   @onRequest)
            .listenTo(state, 'load sync', @onSync)

    onPubSubChangeSet: (model, cs) ->
        screen = @component.context?.screen || @component.getChildContext?()?.screen
        screen?.onPubSubChangeSet?(model, cs)

    componentName: ->
        @component.constructor.displayName

    onProxyReplace: (name, model) ->
        @states[name] = model
        @setComponentState(name, model)

    bindEvents: (name, state, events) ->
        if state.isProxy
            @listenTo(state, 'proxyreplace', _.partial(@onProxyReplace, name))
        if !events
            if state.isState or state.isProxy
                events ||= 'change'
            else if Lanes.u.isCollection(state)
                events ||= 'add remove change sort reset'
            else
                Lanes.warn "Unable to listen to unknown type #{name}"

        @listenTo(state, events, _.partial(@setComponentState, name, state))

    onError: (modelOrCollection, options) ->
        # Set state only if there's no silent option
        unless options.silent
            @setComponentState
                isRequesting: false
                hasError: modelOrCollection?.errorMessage or true
                error: modelOrCollection.errors

    onInvalid: (model, res, options) ->
        @setComponentState(isInvalid: true) unless options.silent

    onRequest: (modelOrCollection, type, options) ->
        # Set `state` only if there's no silent option
        unless options.silent
            @setComponentState
                isRequesting: type
                hasError: false
                isInvalid: false

    onSync: (modelOrCollection, res, options = {}) ->
        # Calls `setReactState` only if there's no silent option
        this.setComponentState(isRequesting: false) unless options.silent

    setComponentState: (key, value, args...) ->
        return unless @component.isMounted()
        state = if _.isObject(key) then key else {"#{key}": value}
        if _.isFunction(@component.setDataState)
            @component.setDataState(state, args...)
        else
            @component.setState(state)
        true

    isStateUsingPubsub: (name, state) ->
        _.result(state, 'registerforPubSub') isnt false and
            not (false == @component.pubsub or false == @component.pubsub?[name])

    destroy: (state, events, fn) ->
        for name, state of @states when @isStateUsingPubsub(name, state)
            Lanes.Models.PubSub.remove(state) if Lanes.u.isModel(state)
        this.stopListening()
        delete @component.data


Lanes.Vendor.Events.createEmitter(DataWrapper.prototype)
#_.extend(DataWrapper.prototype, Lanes.Vendor.BBEvents)

readDataObjects = (comp, newProps) ->
    bound = _.clone _.result(comp, 'dataObjects') || {}
    bound.model ||= 'props' if comp.props.model
    bound.collection ||= 'props' if comp.props.collection
    _.mapValues(bound, (value, name) ->
        if _.isFunction(value)
            if _.isEmpty(comp.data?.states[name]) then value.call(comp) else false
        else if 'props' == value then newProps?[name] or comp.props[name]
        else value
    )

Lanes.React.Mixins.Data = {
    # When the component gets the initial state, instance a `DataWrapper` to take
    # care of models and collections binding
    getInitialState: ->
        defaults = readDataObjects(this)
        @data = new DataWrapper(this, defaults) unless _.isEmpty(defaults)
        {}

    # When the component unmounts, dispose listeners and delete @data reference.
    componentWillUnmount: ->
        @data.destroy() if @data

    componentWillReceiveProps: (newProps) ->
        newState = readDataObjects(this, newProps)
        return if _.isEmpty(newState)
        if @data
            @data.rebind(newState)
        else
            @data = new DataWrapper(this, newState)

    listenTo: (state, events, fn) ->
        @data.listenTo(state, events, fn)

    stopListening: (state, events, fn) ->
        @data.stopListening(state, events, fn)

}
