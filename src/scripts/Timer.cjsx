define [
    'react/addons'
    'jsx!react-contenteditable'
    '../../vendor/react-progress-bar'
    './Duration'
    './utils'
], (React, ContentEditable, ProgressBar, Duration, utils) ->
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
            @forgetTime false if @intervalId?
            @updateTime()
            @intervalId = setInterval @updateTime, @props.updateInterval

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

        componentDidUpdate: (prevProps, prevState) ->
            if @getTimeSinceStart() >= @getDuration() and not @props.notified
                @props.onFinished @props.id

        onStart: () -> @props.onStart @props.id
        onStop: () -> @props.onStop @props.id
        onDelete: () -> @props.onDelete @props.id
        setTime: (v) -> @props.setTime @props.id, v
        setName: (e) -> @props.setName @props.id, e.target.value

        getDuration: () -> ((@props.hours * 60 + @props.minutes) * 60 + @props.seconds) * 1000
        getTimeSinceStart: () -> @state.time - @props.started

        renderProgressBarText: (v) -> Math.floor(v)+'%'

        render: () ->
            startText = 'Start'
            completed = 0

            progressBgColor = 'white'
            progressTextOnBgColor = 'black'

            progressValueColor = 'gray'
            progressTextOnValueColor = 'rgb(240,240,240)'

            duration = @getDuration()
            timeTextElapsed = utils.formatTime 0
            timeTextRemaining = utils.formatTime duration

            if @props.started?
                startText = 'Restart'
                passed = @getTimeSinceStart()
                completed = 100

                if duration > 0 and passed < duration
                    completed = Math.min 100, 100 * (passed + @props.updateInterval) / duration

                    progressBgColor = 'lightgreen'
                    progressTextOnBgColor = 'rgb(50,50,50)'

                    progressValueColor = 'darkgreen'
                    progressTextOnValueColor = 'rgb(200,200,200)'

                passed = duration if passed >= duration
                timeTextElapsed = utils.formatTime passed
                timeTextRemaining = utils.formatTime duration - passed, Math.ceil

            transitionDuration = Math.round @props.updateInterval * @props.transitionDurationScale

            <div className='timer'>
                <ContentEditable html={@props.name} onChange={@setName} />
                <button onClick={@onStart} className="btn-start">{startText}</button>
                <button onClick={@onStop} disabled={not @props.started?}>Stop</button>
                <button onClick={@onDelete}>Delete</button>
                <span>
                    <span className="time-info">{timeTextElapsed}</span> +
                    <span className="time-info">{timeTextRemaining}</span> =
                </span>
                <Duration
                    hours={@props.hours} minutes={@props.minutes} seconds={@props.seconds}
                    setTime={@setTime}
                />
                <ProgressBar
                    value={completed}
                    transitionDuration={(transitionDuration/1000)+'s'}
                    textColor={[progressTextOnValueColor,progressTextOnBgColor]}
                    valueBarStyle={background: progressValueColor, transitionTimingFunction: 'linear'}
                    style={background: progressBgColor, width: '100%', marginTop: 5}
                    renderText={@renderProgressBarText}
                />
            </div>
