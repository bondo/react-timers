define [], () ->

    fromTime: (time, rounder = Math.floor, scale = 1000) ->
        fullSeconds = rounder time / scale
        fullMinutes = Math.floor fullSeconds / 60
        hours   = Math.floor fullMinutes / 60
        minutes = fullMinutes % 60
        seconds = fullSeconds % 60
        {hours,minutes,seconds}

    formatTime: (time, rounder = Math.floor, shorten = false) ->
        parsed = @fromTime time, rounder
        if parsed.hours > 0 or not shorten
            return "#{parsed.hours}h #{parsed.minutes}m #{parsed.seconds}s"
        if parsed.minutes > 0
            return "#{parsed.minutes}m #{parsed.seconds}s"
        return "#{parsed.seconds}s"

    digits: (v) -> Math.ceil( Math.log(v+1) / Math.log(10) )
