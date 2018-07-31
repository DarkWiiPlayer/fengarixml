void = {key,true for key in *{
	"area", "base", "br", "col"
	"command", "embed", "hr", "img"
	"input", "keygen", "link", "meta"
	"param", "source", "track", "wbr"
}}

escapes = {
	['&']: '&amp;'
	['<']: '&lt;'
	['>']: '&gt;'
	['"']: '&quot;'
	["'"]: '&#039;'
}

env = (make_tag) ->
	environment = setmetatable {}, {
		__index: (key) =>
			(_ENV or _G)[key] or (...) ->
				@.tag(key, ...)
	}

	_G   = environment -- Local, doesn't override global _G in 5.2+
	_ENV = environment -- Local, doesn't affect outside world anyway

	export escape = (value) ->
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

	export tag = (tagname, ...) ->
		make_tag(print, tagname, split flatten {...})

	return environment

make = if _VERSION == 'Lua 5.1' then
	(environment) ->
		(fnc) ->
			assert(type(fnc)=='function', 'wrong argument to render, expecting function')
			setfenv(fnc, environment)
			return (out=print, ...) ->
				environment.print = out
				return fnc(...)
else
	(environment) ->
		(fnc) ->
			assert(type(fnc)=='function', 'wrong argument to render, expecting function')
			do
				upvaluejoin = debug.upvaluejoin
				_ENV = environment
				upvaluejoin(fnc, 1, (-> aaaa!), 1) -- Set environment
			return (out=print, ...) ->
				environment.print = out
				return fnc(...)

render = (out, fnc) ->
	build(fnc)(out)

attrib = (args) ->
	res = setmetatable {}, __tostring: =>
		tab = ["#{key}=\"#{value}\"" for key, value in pairs(@) when type(value)=='string' or type(value)=='number']
		#tab > 0 and ' '..table.concat(tab,' ') or ''
	for key, value in pairs(args)
		if type(key)=='string'
			res[key] = value
			r = true
	return res

--- Handles the inner HTML of a tag
handle = (print, args) ->
	for arg in *args
		switch type(arg)
			when 'table'
				handle arg
			when 'function'
				arg!
			else
				print tostring arg

environment = {
	xml: env (print, tagname, inner, args) ->
		print "<#{tagname}#{attrib args}#{#inner==0 and ' /' or ''}>"
		handle print, inner unless #inner==0
		print "</#{tagname}>" unless (#inner==0)
	html: env (print, tagname, inner, args) ->
		unless void[tagname] and #inner==0
			print "<#{tagname}#{attrib args}>"
			handle print, inner unless #inner==0
			print "</#{tagname}>"
		else
			print "<#{tagname}#{attrib args}>"
}
environment.html.html5 = ->
	environment.html.print '<!doctype html5>'

{
	:environment
	xml: make environment.xml
	html: make environment.html
}
