escapes = {
	['&']: '&amp;'
	['<']: '&lt;'
	['>']: '&gt;'
	['"']: '&quot;'
	["'"]: '&#039;'
}

env = ->
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

	export tag = (tagname, ...) ->
		inner, args = split flatten {...}
		print "<#{tagname}#{attrib args}#{#inner==0 and ' /' or ''}>"
		handle inner unless #inner==0
		print "</#{tagname}>" unless (#inner==0)

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

{
  xml: make env!
  html: make env!
  xml_render: (out, fnc) ->
    build(fnc)(out)
  html_render: (out, fnc) ->
    build(fnc)(out)
}
