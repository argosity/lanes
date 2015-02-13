# ------------------------------------------------------------------ #
# Handles Association definitions.                                   #
# It creates a derived definition for each one                       #
# and contains utility functions to operate on them                  #
# ------------------------------------------------------------------ #
class Lanes.Models.AssocationMap
    constructor: (@klass)->
        @klass::derived ||= {}
        @definitions = @klass::associations
        @definitions['created_by'] ||= { model: 'Lanes.Models.User', readOnly: true }
        @definitions['updated_by'] ||= { model: 'Lanes.Models.User', readOnly: true }
        for name, options of @definitions
            @klass::derived[name] = this.derivedDefinition(name,options)

    getClassFor: (name)->
        definition = @definitions[name]
        object = definition.model || definition.collection
        Lanes.u.findObject( object, 'Models', @klass::FILE)

    getOptions: (name, definition, model)->
        options = { parent: model }
        if definition.options
            _.extend(options, Lanes.u.resultsFor(model,definition.options))
        options

    # will be called in the scope of the model
    createModel: (association, name, definition, fk, pk, target_klass)->
        target_klass ||= association.getClassFor(name)
        options = association.getOptions(name,definition,this)
        model_id = this.get(pk)
        if model_id && model_id == this._cache[name]?.id
            this._cache[name]
        else
            target_klass.findOrCreate(options)

    # will be called in the scope of the model
    createCollection: (association, name, definition, fk, pk, target_klass)->
        target_klass ||= association.getClassFor(name)
        options = association.getOptions(name,definition,this)
        options.filter ||= {}
        options.filter[fk]=this.get(pk)

        if target_klass::isCollection
            new target_klass(options.models||[],options)
        else
            options.model=target_klass
            new Lanes.Models.AssociationCollection(options.models||[],options)
    # returns the definition for the derived property
    derivedDefinition: (name,definition)->
#        me = this
#        target_klass = this.getClassFor(name)
#        fk = this.fk(name) ; pk = this.pk(name)

        # if definition.defaultValue
        #     _.defaults(args, _.evaluateFunction(definition.defaultValue))
        createFn = _.partial(
            if definition.model then this.createModel else this.createCollection,
            this, name, definition, this.fk(name), this.pk(name), this.getClassFor(name)
        )
        { deps: [this.pk(name)], fn: createFn }

        # createAssocation = if definition.model then ->
        #     target_klass ||= me.getClassFor(name)
        #     _.extend(args, parent: this)
        #     model_id = this.get(pk)
        #     if model_id && model_id == this._cache[name]?.id
        #         this._cache[name]
        #     else
        #         target_klass.findOrCreate(args)
        # else ->
        #     target_klass ||= me.getClassFor(name)
        #     filter = {}
        #     filter[ fk ] = this.get( pk)
        #     _.extend(args, filter: filter, parent: this)
        #     if target_klass::isCollection
        #         new target_klass([],args)
        #     else
        #         args.model=target_klass
        #         new Lanes.Models.AssociationCollection(args)
        # { deps: [pk], fn: createFn }

    # Sets the assocations for "model"
    set: (model, data)->
        for name, value of data
            if @definitions[name]
                attributes = if _.isFunction(value.serialize) then value.serialize() else value
                model[name].set( attributes )

    pk: (name)->
        def = @definitions[name]
        return null unless name
        def.pk || ( if def.model then "#{name}_id" else "id" )

    fk: (name)->
        def = @definitions[name]
        return null unless name
        def.fk || ( if def.model then "id" else "#{name}_id" )

    # returns the data from all assocations for saving
    dataForSave: (model,options)->
        ret = {}
        options.saveDepth = ( if options.saveDepth then options.saveDepth+1 else 1 )
        return ret if options.saveDepth > 5
        for name, assoc_options of @definitions
            unless assoc_options.readOnly
                data = model[name].dataForSave(options)
                unless _.isEmpty( data )
                    ret[name] = data

        ret

    # return a list of assocations from "name" that are not loaded
    nonLoaded: (model, names)->
        list = []
        for name in names
            if _.has(@definitions, name) && model[name].isNew()
                list.push(name)
        list
