Lanes.Components.Grid ||= {}
Lanes.Components.Grid.Editing = {

    propTypes:
        topOffset: React.PropTypes.number.isRequired
        rowIndex:  React.PropTypes.number.isRequired
        rowHeight: React.PropTypes.number.isRequired
        columns:   React.PropTypes.arrayOf(React.PropTypes.object).isRequired
        onSave:    React.PropTypes.func.isRequired
        model:     Lanes.PropTypes.State.isRequired
        editors:   React.PropTypes.object
        hideEditor:  React.PropTypes.func.isRequired

    topOffset: ->
        @props.topOffset + (@props.rowIndex * @props.rowHeight)

#    getRowHeight: -> @props.rowHeight + 3

    renderControls: ->
        <div className="controls">
            <div className="buttons">
                <button type="button" className="btn cancel" onClick={@props.hideEditor}>
                    <i className="icon icon-refresh" /> Cancel
                </button>
                <button type="button" className="btn save" onClick={@saveRecord}>
                    <i className="icon icon-save" />Save
                </button>
            </div>
        </div>

    getFieldValue: (column) ->
        @props.model[column.id]

    onFieldChange: (column, ev) ->
        @props.model[column.id] = ev.target.value

    renderFields: ->
        _.map @props.columns, @renderField

    renderBody: ->
        <div className="body">
            <div className="fields">
                {@renderFields()}
            </div>
            {@renderControls()}
        </div>

    renderField: (column) ->
        return null unless column.visible
        control = if @props.editors[column.id]
            @props.editors[column.id](model: @props.model)
        else
            <input type="text"
                value={@getFieldValue(column)}
                onChange={_.partial(@onFieldChange, column)} />
        <div key={column.id} className="field">
            <label>{column.title}</label>
            {control}
        </div>

    saveRecord: ->
        @props.model.save().then (model) =>
            @props.onSave(model)
}
