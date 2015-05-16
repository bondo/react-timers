define [
    'react'
    './App'
    '../../public/main.css'
], (React, App) ->
    'use strict'

    window.React = React
    React.render <App />, document.body
