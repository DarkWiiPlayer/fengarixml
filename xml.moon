createelement, createtext = do
	global = require'js'.global
	global\createElement, global\createTextNode

environment = do
	env = setmetatable {}, {
		__index: (key) =>
			(_ENV or _G)[key] or (...) ->
				@.tag(key, ...)
	}
	_ENV, env = env, nil

	--TODO: Remove
	export escape = (value) ->
		(=>@) tostring(value)\gsub [[[<>&]'"]], escapes

	flatten = (tab, flat={}) ->
		for key, value in pairs tab
			if type(key)=="number"
				if type(value)=="table"
					flatten(value, flat)
				else
					flat[#flat+1]=value
			else
				if type(value)=="table"
					flat[key] = table.concat value ' '
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
		for arg in *args
			switch type(arg)
				when 'table'
					handle arg
				when 'function'
					previous = Parent
					export Parent = element
					arg! -- TODO: do something about context (parent element)
					export Parent = previous
				else
					parent\appendChild createtextnode tostring arg
		element

	export node = (nodename, ...) ->
		attributes, content = split flatten {...}
		New = handle create_node(nodename), attrib
		for key, value in pairs(attributes)
			New\setAttribute tostring(key), tostring(value)
		Parent\appendChild New

	return _ENV

build = (fnc) ->
	assert(type(fnc)=='function', 'wrong argument type, expecting function')
	do
		upvaluejoin = debug.upvaluejoin
		_ENV = environment
		upvaluejoin(fnc, 1, (-> aaaa!), 1) -- Set environment
	return (parent, ...) ->
		environment.Parent = parent
		return fnc(...)

{
	:environment
	:make
}
