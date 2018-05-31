escapes = {
  ['&']: '&amp;'
  ['<']: '&lt;'
  ['>']: '&gt;'
  ['"']: '&quot;'
  ["'"]: '&#039;'
}

pair= (buffer = {}) ->
  if type(buffer) != 'table'
    error 2, "Argument must be a table or nil"

  environment = {}
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
          table.insert buffer, tostring arg

  environment.raw = (text) ->
    table.insert buffer, text

  environment.text = (text) ->
    table.insert buffer, (escape text)

  environment.tag = (tagname, ...) ->
    inner, args = split flatten {...}
    table.insert buffer, "<#{tagname}#{attrib args}#{#inner==0 and ' /' or ''}>"
    handle inner unless #inner==0
    table.insert buffer, "</#{tagname}>" unless (#inner==0)


  setmetatable environment, {
    __index: (key) =>
      _ENV[key] or (...) ->
        environment.tag(key, ...)
  }
  return environment, buffer

build = (fnc) ->
  env, buf = pair!
  hlp = do -- gotta love this syntax ♥
    _ENV = env
    -> aaaaa -- needs to access a global to get the environment upvalue
  assert(type(fnc)=='function', 'wrong argument to render, expecting function')
  debug.upvaluejoin(fnc, 1, hlp, 1) -- Set environment
  fnc!
  buf

render = (fnc) ->
  return table.concat build(fnc), '\n'

{:render, :build, :pair}
