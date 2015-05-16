define [
    'react/addons'
    'immutable'
    './Timer'
    './Duration'
], (React, {Map, fromJS}, Timer, Duration) ->
    'use strict'

    React.createClass
        displayName: 'App'
        mixins: [React.addons.PureRenderMixin]

        getInitialState: () ->
            timers: fromJS JSON.parse localStorage['timers'] ? '{}'
            time: new Date().getTime()
            defaults: fromJS JSON.parse localStorage['defaults'] ? '{"hours":0,"minutes":10,"seconds":0}'

        updateTime: () ->
            @setState time: new Date().getTime()

        componentDidMount: () ->
            @intervalId = setInterval (=> @updateTime()), 1000

        componentWillUnmount: () ->
            console.log 'unmount'
            clearInterval @intervalId

        nextId: () ->
            id = parseInt(localStorage['nextId'] ? 1, 10)
            localStorage['nextId'] = id + 1
            "#{id}"

        setTimers: (timers, cb = null) ->
            @setState {timers}, ->
                localStorage['timers'] = JSON.stringify timers
                cb?()

        setDefaults: (name, value) ->
            console.log 'set', name, value
            defaults = @state.defaults.set name, parseInt(value, 10)
            @setState {defaults}, ->
                localStorage['defaults'] = JSON.stringify defaults

        addTimer: () ->
            id = @nextId()
            timer = Map
                id: id
                name: "Timer #{id}"
                hours: @state.defaults.get 'hours'
                minutes: @state.defaults.get 'minutes'
                seconds: @state.defaults.get 'seconds'
            @setTimers @state.timers.set(id, timer)

        onDelete: (id) ->
            @setTimers @state.timers.delete id

        onStart: (id) ->
            timers = @state.timers
            .setIn [id, 'started'], @state.time
            .setIn [id, 'notified'], false
            @setTimers timers

        onStop: (id) ->
            @setTimers @state.timers.deleteIn [id, 'started']

        onFinished: (id) ->
            return if @state.timers.getIn [id, 'notified']
            @setTimers @state.timers.setIn([id, 'notified'], true), ->
            	new Audio('beep.wav').play()

        setName: (id, name) ->
            @setTimers @state.timers.setIn([id, 'name'], name)

        setTime: (id, field, value) ->
            @setTimers @state.timers.setIn([id, field], value)

        renderTimers: () ->
            <Timer
                key={timer.get 'id'}
                time={@state.time}
                onDelete={@onDelete}
                onStart={@onStart}
                onStop={@onStop}
                onFinished={@onFinished}
                setName={@setName}
                setTime={@setTime}
                {...timer.toObject()}
            /> for timer in @state.timers.toArray()

        render: () ->
            <div>
                <h2>Timers</h2>
                <button onClick={@addTimer}>Add timer</button>
                <Duration
                    setHours={(v) => @setDefaults 'hours', v}
                    setMinutes={(v) => @setDefaults 'minutes', v}
                    setSeconds={(v) => @setDefaults 'seconds', v}
                    {...@state.defaults.toObject()}
                />
                <div className="container">{@renderTimers()}</div>
            </div>
