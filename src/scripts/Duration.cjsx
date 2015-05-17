define [
    'react/addons'
], (React) ->
    'use strict'

    React.createClass
        displayName: 'DurationEditor'
        mixins: [React.addons.PureRenderMixin]

        render: () ->
            <div className="duration">
                <input type="number" min={0} max={99}
                    onChange={(e) => @props.setHours parseInt(e.target.value,10)}
                    value={@props.hours}
                />h
                <input type="number" min={0} max={59}
                    onChange={(e) => @props.setMinutes parseInt(e.target.value,10)}
                    value={@props.minutes}
                />m
                <input type="number" min={0} max={59}
                    onChange={(e) => @props.setSeconds parseInt(e.target.value,10)}
                    value={@props.seconds}
                />s
            </div>
