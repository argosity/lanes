class Lanes.Screens.CommonComponents extends Lanes.React.Component

    propTypes:
        commands:        React.PropTypes.instanceOf(Lanes.Screens.Commands).isRequired
        toolbar:         React.PropTypes.bool
        errors:          React.PropTypes.bool
        networkActivity: React.PropTypes.bool
        toolbarProps:    React.PropTypes.object

    render: ->
        model = @props.commands.getModel()
        <div>
            {unless @networkActivity is false
                <LC.NetworkActivityOverlay model={model} {...@props} /> }
            {<LC.Toolbar {...@props} {...@props.toolbarProps} />      unless @toolbar is false}
            {<LC.ErrorDisplay model={model} {...@props} /> unless @errors  is false}
        </div>
