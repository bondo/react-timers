define [
    'react/addons'
    './utils'
], (React, utils) ->
    'use strict'

    React.createClass
        displayName: 'PageTitle'
        mixins: [React.addons.PureRenderMixin]

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
            return NaN

        componentDidUpdate: (nextProps, nextState) ->
            remaining = @props.timers.map (t) => @getDuration(t) - @getTimeSinceStart(t)
            started = remaining.filterNot isNaN
            running = started.filter (v) -> v > 0
            least = running.min()

            title = 'Timers'
            if started.size > 0
                if least? and started.size is running.size
                    title = utils.formatTime least, Math.floor, true
                else
                    title = 'DONE!'

            document.title = title

        render: () -> null
