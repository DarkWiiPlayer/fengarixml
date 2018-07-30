local void
do
  local _tbl_0 = { }
  local _list_0 = {
    "area",
    "base",
    "br",
    "col",
    "command",
    "embed",
    "hr",
    "img",
    "input",
    "keygen",
    "link",
    "meta",
    "param",
    "source",
    "track",
    "wbr"
  }
  for _index_0 = 1, #_list_0 do
    local key = _list_0[_index_0]
    _tbl_0[key] = true
  end
  void = _tbl_0
end
local escapes = {
  ['&'] = '&amp;',
  ['<'] = '&lt;',
  ['>'] = '&gt;',
  ['"'] = '&quot;',
  ["'"] = '&#039;'
}
local env
env = function(make_tag)
  local environment = setmetatable({ }, {
    __index = function(self, key)
      return (_ENV or _G)[key] or function(...)
        return self.tag(key, ...)
      end
    end
  })
  local _G = environment
  local _ENV = environment
  escape = function(value)
    return (function(self)
      return self
    end)(tostring(value):gsub([[[<>&]'"]], escapes))
  end
  local split
  split = function(tab)
    local ary = { }
    for k, v in ipairs(tab) do
      ary[k] = v
      tab[k] = nil
    end
    return ary, tab
  end
  local flatten
  flatten = function(tab, flat)
    if flat == nil then
      flat = { }
    end
    for key, value in pairs(tab) do
      if type(key) == "number" then
        if type(value) == "table" then
          flatten(value, flat)
        else
          flat[#flat + 1] = value
        end
      else
        if type(value) == "table" then
          flat[key] = table.concat(value(' '))
        else
          flat[key] = value
        end
      end
    end
    return flat
  end
  tag = function(tagname, ...)
    return make_tag(print, tagname, split(flatten({
      ...
    })))
  end
  return environment
end
local make
if _VERSION == 'Lua 5.1' then
  make = function(environment)
    return function(fnc)
      assert(type(fnc) == 'function', 'wrong argument to render, expecting function')
      setfenv(fnc, environment)
      return function(out, ...)
        if out == nil then
          out = print
        end
        environment.print = out
        return fnc(...)
      end
    end
  end
else
  make = function(environment)
    return function(fnc)
      assert(type(fnc) == 'function', 'wrong argument to render, expecting function')
      do
        local upvaluejoin = debug.upvaluejoin
        local _ENV = environment
        upvaluejoin(fnc, 1, (function()
          return aaaa()
        end), 1)
      end
      return function(out, ...)
        if out == nil then
          out = print
        end
        environment.print = out
        return fnc(...)
      end
    end
  end
end
local render
render = function(out, fnc)
  return build(fnc)(out)
end
local attrib
attrib = function(args)
  local res = setmetatable({ }, {
    __tostring = function(self)
      local tab
      do
        local _accum_0 = { }
        local _len_0 = 1
        for key, value in pairs(self) do
          if type(value) == 'string' or type(value) == 'number' then
            _accum_0[_len_0] = tostring(key) .. "=\"" .. tostring(value) .. "\""
            _len_0 = _len_0 + 1
          end
        end
        tab = _accum_0
      end
      return #tab > 0 and ' ' .. table.concat(tab, ' ') or ''
    end
  })
  for key, value in pairs(args) do
    if type(key) == 'string' then
      res[key] = value
      local r = true
    end
  end
  return res
end
local handle
handle = function(print, args)
  for _index_0 = 1, #args do
    local arg = args[_index_0]
    local _exp_0 = type(arg)
    if 'table' == _exp_0 then
      handle(arg)
    elseif 'function' == _exp_0 then
      arg()
    else
      print(tostring(arg))
    end
  end
end
local environment = {
  xml = env(function(print, tagname, inner, args)
    print("<" .. tostring(tagname) .. tostring(attrib(args)) .. tostring(#inner == 0 and ' /' or '') .. ">")
    if not (#inner == 0) then
      handle(print, inner)
    end
    if not ((#inner == 0)) then
      return print("</" .. tostring(tagname) .. ">")
    end
  end),
  html = env(function(print, tagname, inner, args)
    if not (void[tagname] and #inner == 0) then
      print("<" .. tostring(tagname) .. tostring(attrib(args)) .. ">")
      if not (#inner == 0) then
        handle(print, inner)
      end
      return print("</" .. tostring(tagname) .. ">")
    else
      return print("<" .. tostring(tagname) .. tostring(attrib(args)) .. ">")
    end
  end)
}
environment.html.html5 = function()
  return environment.html.print('<!doctype html5>')
end
return {
  environment = environment,
  xml = make(environment.xml),
  html = make(environment.html)
}
