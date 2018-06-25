local escapes = {
  ['&'] = '&amp;',
  ['<'] = '&lt;',
  ['>'] = '&gt;',
  ['"'] = '&quot;',
  ["'"] = '&#039;'
}
local env
env = function()
  local environment = { }
  local print
  print = function(...)
    return environment.print(...)
  end
  local escape
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
  handle = function(args)
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
  environment.raw = function(text)
    return print(text)
  end
  environment.text = function(text)
    return raw(escape(text))
  end
  environment.tag = function(tagname, ...)
    local inner, args = split(flatten({
      ...
    }))
    print("<" .. tostring(tagname) .. tostring(attrib(args)) .. tostring(#inner == 0 and ' /' or '') .. ">")
    if not (#inner == 0) then
      handle(inner)
    end
    if not ((#inner == 0)) then
      return print("</" .. tostring(tagname) .. ">")
    end
  end
  setmetatable(environment, {
    __index = function(self, key)
      return (_ENV or _G)[key] or function(...)
        return environment.tag(key, ...)
      end
    end
  })
  return environment
end
local build
if _VERSION == 'Lua 5.1' then
  build = function(fnc)
    assert(type(fnc) == 'function', 'wrong argument to render, expecting function')
    local environment = env()
    setfenv(fnc, environment)
    return function(out, ...)
      if out == nil then
        out = print
      end
      environment.print = out
      return fnc(...)
    end
  end
else
  build = function(fnc)
    assert(type(fnc) == 'function', 'wrong argument to render, expecting function')
    local environment = env()
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
local render
render = function(out, fnc)
  return build(fnc)(out)
end
return {
  render = render,
  build = build,
  env = env
}
