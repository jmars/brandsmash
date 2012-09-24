define ['jquery', 'sockrpc', 'synapse', 'synapse/object'], ($, RPC, Synapse, ObjectAdapter) ->
	Remote = RPC 'index' ,'industry'
	future = Remote.industry()
	future (result) ->
		console.log result