describe "Hippo.Models.Query", ->

    beforeEach ->
        @query =
            new Hippo.Models.Query({
                syncOptions: @syncOptions
                src: Hippo.Models.User, fields: [
                    {id:'id',   visible: false}
                    {id:'email', fixedWidth: 130 },
                    {id:'login', },
                    {id:'name', flex: 1}
                ]
            })


    it "can be cloned unsaved attributes", ->
        newQuery = @query.clone()
        expect(newQuery).toBeDefined()
        expect(newQuery.fields.pluck('id')).toEqual(@query.fields.pluck('id'))
