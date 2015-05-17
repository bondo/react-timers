'use strict';

var React         = require('react')
var assign        = require('object-assign')
var normalize     = require('react-style-normalizer')
var buffer        = require('buffer-function')
var transitionend = global.document? require('transitionend-property'): 'transitionend'

var JUSTIFY_MAP = {
	left  : 'flex-start',
	right : 'flex-end',
	center: 'center'
}

module.exports = React.createClass({

	displayName: 'ReactProgressBar',

	propTypes: {
		fillOrder: function(props, name){
			var value = props[name]
			if (value != 1 && value != -1){
				return new Error('fillOrder should be either 1 or -1.')
			}
		},
		orientation: function(props, name){
			var value = props[name]

			if (value != 'vertical' && value != 'horizontal'){
				return new Error('orientation should be either "horizontal" or "vertical"')
			}
		}
	},

	getDefaultProps: function() {
		return {
			orientation: 'horizontal',
			defaultStyle: {
				overflow: 'hidden',
				boxSizing: 'border-box',
				position: 'relative',
				background: 'white',
				border: '1px solid gray'
			},

			defaultHorizontalStyle: {
				width : 200,
				height: 40
			},
			defaultVerticalStyle: {
				width : 40,
				height: 200
			},

			defaultValueBarStyle: {
				background: 'black',
				height: '100%',
				width: '100%',
				position: 'absolute',
				overflow: 'hidden',
				display: 'flex',
				flexFlow: 'row',
				alignItems: 'center',
				justifyContent: 'center'
			},

			defaultIndeterminateValueBarStyle: {
				display: 'block',
				position: 'relative'
			},

			defaultTextStyle: {
				height        : '100%',
				width         : '100%',
				position      : 'absolute',
				whiteSpace    : 'nowrap',
				display       : 'flex',
				flexFlow      : 'row',
				alignItems    : 'center',
				justifyContent: 'center'
			},

			defaultFirstTextStyle: {
			},

			defaultSecondTextStyle: {
			},

			textColor: ['white','black'],
			textAlign: 'center',

			fillOrder: 1,
			rotateText: -90,
			transitionDuration: '0.1s',
			indeterminateTransitionDuration: '1s',

			renderText: function(value){
				return value + '%'
			}
		}
	},

	getInitialState: function() {
		return {}
	},

	render: function(){
		var props = this.prepareProps(this.props, this.state)

		var firstWrap
		var secondWrap
		var indeterminate = props.indeterminate


		if (props.text && !indeterminate){
			firstWrap = React.createElement("div", {style: props.firstTextWrapStyle}, 
				React.createElement("span", {style: props.firstTextStyle}, 
					props.text
				)
			)

			secondWrap = React.createElement("div", {style: props.secondTextWrapStyle}, 
				React.createElement("span", {style: props.secondTextStyle}, 
					props.text
				)
			)
		}

		return React.createElement("div", React.__spread({},  props), 

			React.createElement("div", {style: props.valueStyle}, 
				props.valueBarChildren
			), 

			firstWrap, 
			secondWrap, 

			props.children
		)
	},

	componentDidMount: function(){
		this.checkIndeterminate = buffer(this.checkIndeterminate)

		this.checkIndeterminate()
	},

	componentWillUnmount: function() {
		this.removeIndeterminate()
	},

	componentDidUpdate: function() {
		this.checkIndeterminate()
	},

	checkIndeterminate: function() {

		if (this.props.indeterminate != this.state.indeterminateTransition){
			this.props.indeterminate && !this.props.paused?
				this.setupIndeterminate():
				this.removeIndeterminate()
		}
	},

	removeIndeterminate: function() {
		var domNode = this.getDOMNode()

		if (domNode){
			domNode.removeEventListener(transitionend, this.onTransitionEnd)
		}
	},

	setupIndeterminate: function() {
		var domNode = this.getDOMNode()

		if (domNode){
			domNode.removeEventListener(transitionend, this.onTransitionEnd)
			domNode.addEventListener(transitionend, this.onTransitionEnd)

			this.setState({
				indeterminateTransition: true,
				transitionPosition     : this.state.transitionPosition? 0: 1
			})
		}
	},

	onTransitionEnd: function() {
		this.setState({
			indeterminateTransition: false
		})
	},

	prepareProps: function(thisProps, state) {
		var props = assign({}, thisProps)

		var fillValue = props.value
		var emptyValue = 100 - props.value

		props.vertical = props.orientation == 'vertical'

		if (!props.indeterminate){

			props.fillValue  = props.fillOrder == 1? fillValue: emptyValue
			props.emptyValue = props.fillOrder == 1? emptyValue: fillValue

			props.value = this.prepareValue(props, state)
			props.text  = this.prepareText(props, state)

			props.firstTextStyle  = this.prepareFirstTextStyle(props, state)
			props.secondTextStyle = this.prepareSecondTextStyle(props, state)

			props.firstTextWrapStyle  = this.prepareFirstTextWrapStyle(props)
			props.secondTextWrapStyle = this.prepareSecondTextWrapStyle(props)

		} else {
			props.fillValue = props.paused?
								0:
								props.fillValue || 25
		}

		props.valueStyle = this.prepareValueStyle(props, state)
		props.style      = this.prepareStyle(props)

		return props
	},

	prepareFirstTextWrapStyle: function(props) {
		var style = this.prepareWrapperStyleFor(props, 0)

		return normalize(style)
	},

	prepareSecondTextWrapStyle: function(props) {

		var style = this.prepareWrapperStyleFor(props, 1)

		return normalize(style)
	},

	prepareWrapperStyleFor: function(props, index) {
		index = index || 0

		var style = {
			position: 'absolute',
			overflow: 'hidden'
		}

		var size = index?
					props.emptyValue:
					props.fillValue

		if (props.vertical){
			style.height = size + '%'
			style.width = '100%'
			style[index == 0? 'top': 'bottom'] = 0
		} else {
			style.width  = size + '%'
			style.height = '100%'
			style[index == 0? 'left': 'right'] = 0
		}

		return style
	},

	prepareCommonTextStyle: function(props, index) {
		var style = {}

		index = index || 0

		style.justifyContent = JUSTIFY_MAP[props.textAlign] || 'center'

		if (props.textColor){
			var color = Array.isArray(props.textColor) && props.textColor[index]?
							props.textColor[index]:
							props.textColor

			style.color = color
		}

		if (props.rotateText && props.vertical){
			style.transform = this.getRotateValue(props.rotateText)
		}

		if (props.vertical){
			style.flexFlow = 'column'
			style[index == 0? 'top':'bottom'] = 0
		} else {
			style[index == 0? 'left':'right'] = 0
		}

		return style
	},

	prepareFirstTextStyle: function(props, state) {
		var defaultOrientationStyle = props.defaultHorizontalFirstTextStyle
		var orientationStyle = props.horizontalFirstTextStyle

		if (props.vertical){
			defaultOrientationStyle = props.defaultVerticalFirstTextStyle
			orientationStyle = props.verticalFirstTextStyle
		}

		var style = this.prepareCommonTextStyle(props, 0)
		var percentage = (100 * 100 / props.fillValue) + '%'

		if (props.vertical){
			style.height = percentage
		} else {
			style.width = percentage
			style.left = 0
		}

		return normalize(assign({},
				props.defaultTextStyle,
				props.defaultFirstTextStyle,
				defaultOrientationStyle,
				props.textStyle,
				props.firstTextStyle,
				orientationStyle,
				style
			))
	},

	prepareSecondTextStyle: function(props, state) {
		var defaultOrientationStyle = props.defaultHorizontalSecondTextStyle
		var orientationStyle = props.horizontalSecondTextStyle

		if (props.vertical){
			defaultOrientationStyle = props.defaultVerticalSecondTextStyle
			orientationStyle = props.verticalSecondTextStyle
		}

		var style = this.prepareCommonTextStyle(props, 1)
		var percentage = (100 * 100 / props.emptyValue) + '%'

		if (props.vertical){
			style.height = percentage
		} else {
			style.width = percentage
		}

		return normalize(assign({},
				props.defaultTextStyle,
				props.defaultSecondTextStyle,
				defaultOrientationStyle,
				props.textStyle,
				props.secondTextStyle,
				orientationStyle,
				style
			))
	},

	getRotateValue: function(value) {
		return 'rotate(' + value + 'deg)'
	},

	prepareText: function(props, state) {
		return props.renderText(props.value, props)
	},

	prepareValueStyle: function(props, state) {
		var defaultIndeterminateStyle

		if (props.indeterminate){
			defaultIndeterminateStyle = props.defaultIndeterminateValueBarStyle
		}

		var style = assign({}, props.defaultValueBarStyle, defaultIndeterminateStyle, props.valueBarStyle)
		var side  = props.vertical? 'height': 'width'

		style[side] = props.fillValue + '%'

		if (props.indeterminate){
			var transitionProperty = props.vertical? 'top': 'left'
			var transitionDuration = props.indeterminateTransitionDuration || props.transitionDuration || ''

			style.transition = transitionProperty + ' ' + transitionDuration

			var transitionPropertyValue

			if (props.paused){
				transitionPropertyValue = 0
			}

			transitionPropertyValue = (state.indeterminateTransition?
											state.transitionPosition == 1?
												(100 - props.fillValue)
												:0
											:0)
			style[transitionProperty] = transitionPropertyValue + '%'
		} else {
			if (props.transitionDuration){
				style.transition = side + ' ' + props.transitionDuration
			}
		}

		if (typeof props.valueBarStyle == 'function'){
			style = props.valueBarStyle(style)
		}

		return normalize(style)
	},

	prepareStyle: function(props) {
		var defaultOrientationStyle = props.vertical?
									props.defaultVerticalStyle:
									props.defaultHorizontalStyle

		var orientationStyle = props.vertical?
									props.verticalStyle:
									props.horizontalStyle

		var style = assign({}, props.defaultStyle, defaultOrientationStyle, props.style, orientationStyle)

		return normalize(style)
	},

	prepareValue: function(props, state) {
		var value = props.value == null?
						state.value:
						props.value

		return value
	},
})