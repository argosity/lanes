class Lanes.Components.RecordFinder.Dialog extends Lanes.React.Component

    dataObjects:
        clauses: ->
            @props.query.clauses

    propTypes:
        onRecordSelect: React.PropTypes.func.isRequired

    contextTypes:
        viewport: Lanes.PropTypes.State.isRequired

    login: ->
        @model.save().then =>
            Lanes.current_user.setLoginData(@model.user, @model.access) if @model.user

    warning: ->
        <BS.Alert bsStyle='warning'>
             <strong>{@model.lastServerMessage}</strong>
        </BS.Alert>

    onRecordSelect: (model) ->
        return unless model
        @props.query.loadModelWithAssociations(model).then @props.onRecordSelect
        _.delay( =>
            @onCancel()
        , 300)

    onCancel: ->
        @refs.modal.onHide()

    addClause: ->
        @props.query.addNewClause()

    render: ->
        <LC.Modal title='Find Record'
            backdrop={false}
            ref="modal"
            animation={false}>
            <div className='modal-body record-finder-dialog'>
              <div className="form-horizontal query-clauses">
                { for c in @clauses.models
                    <LC.RecordFinder.Clause key={c.cid} onAddClause={@addClause} model=c /> }
              </div>
              <LC.Grid query={@props.query} height=200
                  onSelectionChange=@onRecordSelect
              />
            </div>

            <div className='modal-footer'>
                <BS.Button onClick={@onCancel}>Cancel</BS.Button>
            </div>

        </LC.Modal>
