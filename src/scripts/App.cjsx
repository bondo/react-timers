define [
    'react/addons'
    'immutable'
    './Timer'
    './Duration'
    './PageTitle'
], (React, {Map, fromJS}, Timer, Duration, PageTitle) ->
    'use strict'

    React.createClass
        displayName: 'App'
        mixins: [React.addons.PureRenderMixin]

        getInitialState: () ->
            timers: fromJS JSON.parse localStorage['timers'] ? '{}'
            defaults: fromJS JSON.parse localStorage['defaults'] ? '{"hours":0,"minutes":10,"seconds":0}'

        nextId: () ->
            id = parseInt(localStorage['nextId'] ? 1, 10)
            localStorage['nextId'] = id + 1
            "#{id}"

        setTimers: (timers, cb = null) ->
            @setState {timers}, ->
                localStorage['timers'] = JSON.stringify timers
                cb?()

        setDefaults: (value) ->
            defaults = fromJS value
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
            .setIn [id, 'started'], new Date().getTime()
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

        setTime: (id, fields) ->
            timers = @state.timers
            for field, value of fields when field in ['hours', 'minutes', 'seconds']
                timers = timers.setIn([id, field], value)
            @setTimers timers

        renderTimers: () ->
            <Timer
                key={timer.get 'id'}
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
                <PageTitle timers={@state.timers} />
                <h2>Timers</h2>
                <button onClick={@addTimer}>Add timer</button>
                <Duration setTime={@setDefaults} {...@state.defaults.toObject()} />
                <div className="container">{@renderTimers()}</div>
            </div>
