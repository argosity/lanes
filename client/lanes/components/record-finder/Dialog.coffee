class Lanes.Components.RecordFinder.Dialog extends Lanes.Components.ModalDialog

    domEvents:
        'click .add-clause': 'addClause'
        'click .run-query':  'runQuery'
        'select-row .grid': 'onSelect'
        'shown.bs.modal' : 'onShown'

    subviews:
        grid:
            hook: 'grid'
            component: 'Grid'
            options: ->
                _.extend(@gridOptions||{}, { recordQuery: @recordQuery, options: @gridOptions })
        query_clauses:
             container: '.query-clauses'
             view: Lanes.Components.RecordFinder.Clause, collection: 'clauses'

    bodyTemplateName: 'dialog'
    bodyClass: "record-finder"

    session:
        recordQuery: 'model'
        gridOptions: 'object'
        clauses: 'collection'

    initialize:(options)->
        @clauses = @recordQuery.clauses
        @debounceMethod( 'runQuery')
        this.listenTo(@recordQuery,'change',@runQuery)
        _.bindAll(this,'hide')

    onShown: ->
        this.grid.adjustColumnWidth()

    onSelect: (ev, model)->
        @record = model
        ev.preventDefault()
        _.delay(this.hide, 500)

    addClause: ->
        @recordQuery.addNewClause()

    runQuery: ->
        this.grid.reload() if @recordQuery.isValid()
