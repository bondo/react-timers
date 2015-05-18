define [
    'react/addons'
    './utils'
], (React, utils) ->
    'use strict'

    React.createClass
        displayName: 'DurationEditor'
        mixins: [React.addons.PureRenderMixin]

        set: (name, value) ->
            res =
                hours: @props.hours
                minutes: @props.minutes
                seconds: @props.seconds
            res[name] = value
            @props.setTime res

        setHours:   (e) -> @set 'hours',   parseInt(e.target.value, 10)
        setMinutes: (e) -> @set 'minutes', parseInt(e.target.value, 10)
        setSeconds: (e) -> @set 'seconds', parseInt(e.target.value, 10)

        setFullSeconds: (e) ->
            @props.setTime utils.fromTime 1000 * parseInt(e.target.value, 10)

        digits: (v) -> Math.ceil( Math.log(v) / Math.log(10) )

        render: () ->
            fullSeconds = (@props.hours * 60 + @props.minutes) * 60 + @props.seconds
            <div className="duration">
                <input type="number" min={0} max={99}
                    onChange={@setHours}
                    value={@props.hours}
                />h
                <input type="number" min={0} max={59}
                    onChange={@setMinutes}
                    value={@props.minutes}
                />m
                <input type="number" min={0} max={59}
                    onChange={@setSeconds}
                    value={@props.seconds}
                />s
                &nbsp;&nbsp; or &nbsp;&nbsp;
                <input type="number" min={0} style={width: Math.max(4, @digits(fullSeconds))*7 + 20}
                    onChange={@setFullSeconds}
                    value={fullSeconds}
                />s
            </div>
