local escapes = {
  ['&'] = '&amp;',
  ['<'] = '&lt;',
  ['>'] = '&gt;',
  ['"'] = '&quot;',
  ["'"] = '&#039;'
}
local pair
pair = function(buffer)
  if buffer == nil then
    buffer = { }
  end
  if type(buffer) ~= 'table' then
    error(2, "Argument must be a table or nil")
  end
  local environment = { }
  local escape
  escape = function(value)
    local res = tostring(value):gsub([[[<>&]'"]], escapes)
    return res
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
      if type(value) == "table" then
        flatten(value, flat)
      else
        flat[key] = value
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
        table.insert(buffer, tostring(arg))
      end
    end
  end
  environment.raw = function(text)
    return table.insert(buffer, text)
  end
  environment.text = function(text)
    return table.insert(buffer, (escape(text)))
  end
  environment.tag = function(tagname, ...)
    local inner, args = split(flatten({
      ...
    }))
    table.insert(buffer, "<" .. tostring(tagname) .. tostring(attrib(args)) .. tostring(#inner == 0 and ' /' or '') .. ">")
    if not (#inner == 0) then
      handle(inner)
    end
    if not ((#inner == 0)) then
      return table.insert(buffer, "</" .. tostring(tagname) .. ">")
    end
  end
  setmetatable(environment, {
    __index = function(self, key)
      return _ENV[key] or function(...)
        return environment.tag(key, ...)
      end
    end
  })
  return environment, buffer
end
local build
build = function(fnc)
  local env, buf = pair()
  local hlp
  do
    local _ENV = env
    hlp = function()
      return aaaaa
    end
  end
  assert(type(fnc) == 'function', 'wrong argument to render, expecting function')
  debug.upvaluejoin(fnc, 1, hlp, 1)
  fnc()
  return buf
end
local render
render = function(fnc)
  return table.concat(build(fnc), '\n')
end
return {
  render = render,
  build = build,
  pair = pair
}
