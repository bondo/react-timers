define [], () ->

    fromTime: (time, rounder = Math.floor) ->
        fullSeconds = rounder time / 1000
        fullMinutes = Math.floor fullSeconds / 60
        hours   = Math.floor fullMinutes / 60
        minutes = fullMinutes % 60
        seconds = fullSeconds % 60
        {hours,minutes,seconds}

    formatTime: (time, rounder = Math.floor) ->
        parsed = @fromTime time, rounder
        "#{parsed.hours}h #{parsed.minutes}m #{parsed.seconds}s"
