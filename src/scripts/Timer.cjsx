define [
    'react/addons'
    'jsx!react-contenteditable'
    '../../vendor/react-progress-bar'
    './Duration'
], (React, ContentEditable, ProgressBar, Duration) ->
    'use strict'

    React.createClass
        displayName: 'Timer'
        mixins: [React.addons.PureRenderMixin]

        getInitialState: () ->
            time: new Date().getTime()

        getDefaultProps: () ->
            updateInterval: 200
            # Take that much longer than the updateInterval to make the transition.
            # This seems a bit weird, but it makes for a much smoother transition.
            transitionDurationScale: 1.8

        updateTime: () ->
            @setState time: new Date().getTime()

        trackTime: () ->
            @forgatTime false if @intervalId?
            @updateTime()
            @intervalId = setInterval (=> @updateTime()), @props.updateInterval

        forgetTime: (clearTime = true) ->
            return unless @intervalId?
            clearInterval @intervalId
            @intervalId = null
            @setState time: null if clearTime

        componentDidMount: () -> @trackTime() if @props.started?
        componentWillUnmount: () -> @forgetTime false
        componentWillReceiveProps: (nextProps) ->
            return if nextProps.started is @props.started
            @forgetTime(not nextProps.started?) if @props.started?
            @trackTime() if nextProps.started?

        onStart: () -> @props.onStart @props.id
        onStop: () -> @props.onStop @props.id
        onDelete: () -> @props.onDelete @props.id

        updateName: (e) ->
            @props.setName @props.id, e.target.value

        getDuration: () -> ((@props.hours * 60 + @props.minutes) * 60 + @props.seconds) * 1000
        getTimeSinceStart: () -> @state.time - @props.started
        fromTime: (time) ->
            hours: Math.floor time / (60 * 60 * 1000)
            minutes: (Math.floor time / (60 * 1000)) % 60
            seconds: (Math.round time / 1000) % 60
        formatTime: (time) ->
            parsed = @fromTime time
            "#{parsed.hours}h #{parsed.minutes}m #{parsed.seconds}s"

        renderProgressBarText: (v) ->
            Math.floor(v)+'%'

        render: () ->
            time = null
            stop = null
            progressBgColor = 'white'
            progressValueColor = 'gray'
            progressTextOnBgColor = 'black'
            progressTextOnValueColor = 'rgb(240,240,240)'
            startText = 'Start'
            completed = 0

            if @props.started?
                duration = @getDuration()
                passed = @getTimeSinceStart()

                completed = 100
                if duration > 0 and passed < duration
                    completed = Math.min 100, 100 * (passed + @props.updateInterval) / duration

                    progressBgColor = 'lightgreen'
                    progressTextOnBgColor = 'rgb(50,50,50)'

                    progressValueColor = 'darkgreen'
                    progressTextOnValueColor = 'rgb(200,200,200)'

                startText = 'Restart'
                stop = <button onClick={@onStop}>Stop</button>

                if passed >= duration
                    setTimeout (=> @props.onFinished @props.id), 0 unless @props.notified

                timeTextElapsed = if completed < 100 then @formatTime passed else @formatTime duration
                timeTextRemaining = if completed < 100 then @formatTime duration - passed else @formatTime 0
                time = <span>
                    <span className="time-info">{timeTextElapsed}</span> +
                    <span className="time-info">{timeTextRemaining}</span> =
                </span>

            <div className='timer'>
                <ContentEditable html={@props.name} onChange={@updateName} />
                <button onClick={@onStart}>{startText}</button>
                {stop}
                <button onClick={@onDelete}>Delete</button>
                {time}
                <Duration hours={@props.hours} minutes={@props.minutes} seconds={@props.seconds}
                    setHours={(v) => @props.setTime @props.id, 'hours', v}
                    setMinutes={(v) => @props.setTime @props.id, 'minutes', v}
                    setSeconds={(v) => @props.setTime @props.id, 'seconds', v}
                />
                <ProgressBar
                    value={completed}
                    transitionDuration={((@props.updateInterval*@props.transitionDurationScale)/1000)+'s'}
                    textColor={[progressTextOnValueColor,progressTextOnBgColor]}
                    valueBarStyle={background: progressValueColor, transitionTimingFunction: 'linear'}
                    style={background: progressBgColor, width: '100%', marginTop: 5}
                    renderText={@renderProgressBarText}
                />
            </div>
