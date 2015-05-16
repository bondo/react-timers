define [
    'react/addons'
    'jsx!react-contenteditable'
    './Duration'
], (React, ContentEditable, Duration) ->
    'use strict'

    React.createClass
        displayName: 'Timer'
        mixins: [React.addons.PureRenderMixin]

        updateName: (e) ->
            @props.setName @props.id, e.target.value

        getDuration: () -> ((@props.hours * 60 + @props.minutes) * 60 + @props.seconds) * 1000
        getTimeSinceStart: () -> @props.time - @props.started
        fromTime: (time) ->
            hours: Math.floor time / (60 * 60 * 1000)
            minutes: (Math.floor time / (60 * 1000)) % 60
            seconds: (Math.round time / 1000) % 60
        formatTime: (time) ->
            parsed = @fromTime time
            "#{parsed.hours}h #{parsed.minutes}m #{parsed.seconds}s"

        render: () ->
            time = null
            stop = null
            progress = null
            startText = 'Start'

            if @props.started?
                duration = @getDuration()
                passed = @getTimeSinceStart()
                completed = if duration > 0 then Math.min 100, Math.round 100 * passed / duration else 100

                startText = 'Restart'
                progress = <progress value={completed} max={100}>{completed}%</progress>
                stop = <button onClick={=> @props.onStop @props.id}>Stop</button>

                if completed >= 100
                    setTimeout (=> @props.onFinished @props.id), 0 unless @props.notified

                timeTextElapsed = if completed < 100 then @formatTime passed
                timeTextRemaining = if completed < 100 then @formatTime duration - passed
                time = <span>
                    <span className="time-info">{timeTextElapsed}</span> +
                    <span className="time-info">{timeTextRemaining}</span> =
                </span>

            <div className='timer'>
                <ContentEditable html={@props.name} onChange={@updateName} />
                <button onClick={=> @props.onStart @props.id}>{startText}</button>
                {stop}
                <button onClick={=> @props.onDelete @props.id}>Delete</button>
                {time}
                <Duration hours={@props.hours} minutes={@props.minutes} seconds={@props.seconds}
                    setHours={(v) => @props.setTime @props.id, 'hours', v}
                    setMinutes={(v) => @props.setTime @props.id, 'minutes', v}
                    setSeconds={(v) => @props.setTime @props.id, 'seconds', v}
                />
                {progress}
            </div>
