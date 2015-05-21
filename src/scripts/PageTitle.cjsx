define [
    'react/addons'
    './utils'
], (React, utils) ->
    'use strict'

    React.createClass
        displayName: 'PageTitle'

        getInitialState: () ->
            time: new Date().getTime()

        updateTime: () ->
            @setState time: new Date().getTime()

        componentDidMount: () ->
            @intervalId = setInterval @updateTime, 1000

        componentWillUnmount: () ->
            clearInterval @intervalId

        getDuration: (timer) ->
            ((timer.get('hours') * 60 + timer.get('minutes')) * 60 + timer.get('seconds')) * 1000

        getTimeSinceStart: (timer) ->
            started = timer.get 'started'
            return @state.time - started if started?
            return -Infinity

        componentDidUpdate: (nextProps, nextState) ->
            time = @props.timers.map((t) => @getDuration(t) - @getTimeSinceStart(t))
            running = time.filter (v) -> isFinite v
            remaining = running.filter((v)->v>0).min()

            title = 'Timers'
            if running.size
                if remaining > 0
                    title = 'Timers - ' + utils.formatTime remaining
                else
                    title = 'Timers - DONE!'
            document.title = title

        render: () -> null
