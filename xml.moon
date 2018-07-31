createelement, createtextnode = do
	doc = require'js'.global.document
	doc\createElement, doc\createTextNode

environment = do
	env = do
		global = _ENV
		setmetatable {}, {
			__index: (key) =>
				global[key] or (...) ->
					assert(rawget(@, 'node'), 'field "node" is missing!')(key, ...)
		}
	_ENV, env = env, nil

	--TODO: Remove
	export escape = (value) ->
		(=>@) tostring(value)\gsub [[[<>&]'"]], escapes

	flatten = (tab, flat={}) ->
		for key, value in pairs tab
			switch type(value)
				when "table"
					flatten(value, flat)
				else switch type(key)
					when "number"
						flat[#flat+1]=value
					else
						flat[key] = value
		flat

	split = (tab) ->
		ary = {}
		for k,v in ipairs(tab) do
			ary[k]=v
			tab[k]=nil
		return ary, tab

	--- Handles inner HTML for a node
	handle_inner = (element, inner) ->
		for item in *inner
			switch type(item)
				when 'table'
					handle_inner element, item
				when 'function'
					previous = Parent
					export Parent = element
					item!
					export Parent = previous
				else
					Parent\appendChild createtextnode tostring item
		element

	export node = (nodename, ...) ->
		content, attributes = split flatten {...}
		New = handle_inner createelement(nodename), content
		for key, value in pairs(attributes)
			New\setAttribute tostring(key), tostring(value)
		Parent\appendChild New

	_ENV

template = (fnc) ->
	assert(type(fnc)=='function', 'wrong argument type, expecting function')
	do
		upvaluejoin = debug.upvaluejoin
		_ENV = environment
		upvaluejoin(fnc, 1, (-> aaaa!), 1) -- Set environment
	return (parent, ...) ->
		assert(parent, 'No parent node given!')
		environment.Parent = parent
		return fnc(...)

{
	:environment
	:template
	generate: (parent, func) -> template(func)(parent)
}
