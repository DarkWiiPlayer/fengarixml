escapes = {
	['&']: '&amp;'
	['<']: '&lt;'
	['>']: '&gt;'
	['"']: '&quot;'
	["'"]: '&#039;'
}

env = ->
	environment = {}
	print = (...) -> environment.print ...
	escape = (value) ->
		(=>@) tostring(value)\gsub [[[<>&]'"]], escapes

	split = (tab) ->
		ary = {}
		for k,v in ipairs(tab) do
			ary[k]=v
			tab[k]=nil
		return ary, tab

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

	attrib = (args) ->
		res = setmetatable {}, __tostring: =>
			tab = ["#{key}=\"#{value}\"" for key, value in pairs(@) when type(value)=='string' or type(value)=='number']
			#tab > 0 and ' '..table.concat(tab,' ') or ''
		for key, value in pairs(args)
			if type(key)=='string'
				res[key] = value
				r = true
		return res

	handle = (args) ->
		for arg in *args
			switch type(arg)
				when 'table'
					handle arg
				when 'function'
					arg!
				else
					print tostring arg

	environment.raw = (text) ->
		print text

	environment.text = (text) ->
		raw escape text

	environment.tag = (tagname, ...) ->
		inner, args = split flatten {...}
		print "<#{tagname}#{attrib args}#{#inner==0 and ' /' or ''}>"
		handle inner unless #inner==0
		print "</#{tagname}>" unless (#inner==0)

	setmetatable environment, {
		__index: (key) =>
			(_ENV or _G)[key] or (...) ->
				environment.tag(key, ...)
	}
	return environment

build = if _VERSION == 'Lua 5.1' then
	(fnc) ->
		assert(type(fnc)=='function', 'wrong argument to render, expecting function')
		env = env!
		setfenv(fnc, env)
		return (out=print, ...) ->
			env.raw = print
			return fnc(...)
else
	(fnc) ->
		assert(type(fnc)=='function', 'wrong argument to render, expecting function')
		env = env!
		do -- gotta love this syntax ♥
			upvaluejoin = debug.upvaluejoin
			_ENV = env
			upvaluejoin(fnc, 1, (-> aaaa!), 1) -- Set environment
		return (out=print, ...) ->
			print = out
			return fnc(...)

render = (out, fnc) ->
	build(fnc)(out)

{:render, :build, :env}
