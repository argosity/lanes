#=require hippo/access/User
#=require hippo/access/Roles

describe "Hippo.Models.AssociationMap", ->

    class Color
        constructor: -> super
        api_path: -> 'test'
        props: { id: 'integer', model_fk_id: 'integer', rgb: 'string' }
    Hippo.Models.Base.extend(Color)

    DATA = {total:1, success:true, message:"Retrieve succeeded", data:[
        [1, "TEST", "Nathan Stitt", null, "0.0"]
    ]}
    RESPONSE = {
        status:200,
        contentType: "application/json"
        responseText: JSON.stringify(DATA)
    }
    beforeEach ->
        jasmine.Ajax.install()
    afterEach ->
        jasmine.Ajax.uninstall()

    it "sets up has_many associations", ->
        model = LT.makeModel({
            associations:
                color:{ model: Color }
                colors: { collection: Color, fk: 'model_fk_id' }
            props: { id: 'integer', foo: 'string' }
        }, { id: 123 })

        expect(model.associations.isCreated(model, 'colors')).toBe(false)

        color = model.colors.add({ rgb:'#ffffff' })

        expect(model.associations.isCreated(model, 'colors')).toBe(true)
        expect(color).toEqual(jasmine.any(Color))
        expect(color.model_fk_id).toEqual(123)

        spy = jasmine.createSpy('sync')
        model.colors.sync = spy

        model.colors.fetch(force:true)

        expect(spy).toHaveBeenCalledWith('read', model.colors, jasmine.any(Object))
        call_options = spy.calls.mostRecent().args[2]
        expect(call_options.query).toEqual( model_fk_id: 123 )


    it "sets up belongs_to associations", ->
        model = LT.makeModel({
            associations:
                color:{ model: Color }
            props: { id: 'integer', foo: 'string', color_id: 'integer' }
        }, { id: 123, color: {} })

        expect(model.associations.isCreated(model, 'color')).toBe(false)
        color = model.color
        expect(model.associations.isCreated(model, 'color')).toBe(true)


        model.set(color: {rgb: 'red'})
        expect(model.color.rgb).toEqual('red')


    it "serializes associations", ->
        modelData = {
            id: 123, title: 'Colors', color: { rgb: 'red' },
            colors: [
                { id: 1, rgb: '123' }
                { id: 2, rgb: '1234' }
                { id: 3, rgb: '12345' }
            ]
        }
        model = LT.makeModel({
            props: { id: 'integer', title: 'string' }
            associations:
                color:{ model: Color }
                colors: { collection: Color, fk: 'model_fk_id' }
        }, modelData)

        expect(model.serialize()).toEqual(
            modelData
        )
