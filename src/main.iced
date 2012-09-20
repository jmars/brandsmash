define ['jquery'], ($) ->
	$('button').bind 'click', (e) ->
		e.preventDefault()
		e.stopImmediatePropagation()
		console.log 'clicked button'