define ['jquery', 'sockrpc'], ($, RPC) ->
	Remote = RPC 'index' ,'industry'
	console.log Remote