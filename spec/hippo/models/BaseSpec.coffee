describe "Hippo.Models.Base", ->
    class Color
        constructor: -> super
        props: { id: 'integer', rgb: 'string' }
    Hippo.Models.Base.extend(Color)

    it "tracks unsaved attributes", ->
        model = Hippo.Test.makeModel({
            session:
                foo: 'string'
                bar: 'integer'
            props:
                saved: 'string'
        }, {bar: 'baz'}, {xhr: {}}) # it comes from xhr
        expect(model.isDirty).toBe(false)
        model.foo = 'baz' # session prop
        expect(model.isDirty).toBe(false)
        expect(model.unsavedAttributes()).toBeEmptyObject()
        model.saved = 'bar'
        expect(model.isDirty).toBe(true)
        model.setFromServer( foo: 'bar' )
        expect(model.isDirty).toBe(false)


    it "can tell if it has attributes", ->
        model = Hippo.Test.makeModel({
            session:
                foo: 'string'
            props:
                bar: 'string'
        })
        expect(model.hasAttribute('missing')).toBe(false)
        expect(model.hasAttribute('foo')).toBe(true)
        expect(model.hasAttribute('bar')).toBe(true)

    it "provides data for saving", ->
        # model with other types of data, but should only save "props"
        model = Hippo.Test.makeModel({
            associations:
                color:{ model: Color }
            session:
                unsaved: 'string'
            props:
                id: 'integer'
                foo: 'string'
                bar: 'string'
                color_id: 'integer'
            derived:
                atest:
                    fn: -> 'blarg'
        })
        model.set( id: 10, foo:'bar', unsaved: 'falsify', color: { rgb: '99FFFF' } )
        expect(model.color.rgb).toEqual('99FFFF')
        expect(id: 10, foo:'bar', color: { rgb: '99FFFF' }).toEqual( model.dataForSave()  )
        model.foo = 'a value'
        a = model.changeMonitor.changedAttributes()
        expect( model.dataForSave() ).toEqual( id: 10, foo: 'a value', color: { rgb: '99FFFF' } )

    it "can be saved", (done) ->
        model = Hippo.Test.makeModel({
            props:
                id: 'integer'
                foo: 'string'
                bar: 'string'

        }, { foo: 'one, two, three'} )
        expect(model.isDirty).toBe(true)
        expect(model.unsavedAttributes()).toEqual( foo: 'one, two, three' )
        model.save()
        expect(Hippo.Models.Sync.perform).toHaveBeenCalledWith('create', jasmine.any(Object))
        model.id = 11
        expect(model.isNew()).toBe(false)
        Hippo.Models.Sync.perform.calls.reset()
        LT.syncSucceedWith({
            foo: 'a new foo value'
        })
        model.save().then ->
            expect(Hippo.Models.Sync.perform).toHaveBeenCalledWith('patch', jasmine.any(Object))
            expect(model.foo).toEqual('a new foo value')
            done()

    it "can be fetched", (done) ->
        model = Hippo.Test.makeModel({
            props:
                { id: 'integer', foo: 'string' }
        })
        LT.syncSucceedWith({
            foo: 'foo value'
        })
        model.fetch().then ->
            expect(Hippo.Models.Sync.perform).toHaveBeenCalledWith('read', jasmine.any(Object))
            expect(model.foo).toEqual('foo value')
            options = Hippo.Models.Sync.perform.lastOptions()
            expect(options).toHaveTrue('ignoreUnsaved')
            expect(options).toHaveNumberWithinRange('limit', 1, 1)
            done()

    it "creates a Collection property even when the base is abstract", ->
        class Base
            constructor: -> super
            abstractClass: true
        Hippo.Models.Base.extend(Base)
        class Model
            constructor: -> super
        Model = Base.extend(Model)
        expect(Model.Collection::model).toEqual(Model)


    it "loads using where", (done) ->
        LT.syncSucceedWith([
            { id: 1, title: 'first value'  }
            { id: 2, title: 'second value' }
        ])

        Model = LT.defineModel
            props: { id: 'integer', title: 'string' }

        Model.where(title: 'first value').whenLoaded (collection) ->
            options = Hippo.Models.Sync.perform.lastOptions()
            expect(options.query).toEqual({title:'first value'})
            expect(collection.length).toEqual(2)
            done()

    it "can be destroyed", (done) ->
        model = Hippo.Test.makeModel({
            props: { id: 'integer' }
        }, { id: 1 })
        collection = model.constructor.Collection
        model.destroy().then ->
            expect(Hippo.Models.Sync.perform)
                .toHaveBeenCalledWith('delete', jasmine.any(Object))
            done()

    it "sets associations", ->
        model = Hippo.Test.makeModel({
            associations:
                color:{ model: Color }
            props: { id: 'integer', foo: 'string' }
        }, { id: 1 })
        expect(model.color).toBeObject()
        model.set(color: { rgb: '99FFFF' })
        expect(model.color.rgb).toEqual('99FFFF')
        model.setFromServer(color:{ rgb: 'FFA500' })
        expect(model.color.rgb).toEqual('FFA500')

    it "can fetch associations", ->
        model = Hippo.Test.makeModel({
            associations:
                color:{ model: Color }
            props: { id: 'integer', foo: 'string' }
        }, { id: 1 })
        model.withAssociations(['color'])
        expect(Hippo.Models.Sync.perform).toHaveBeenCalledWith('read', jasmine.any(Object))
        options = Hippo.Models.Sync.perform.lastOptions()
        expect(options.include).toEqual(['color'])
