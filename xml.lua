local createelement, createtextnode
do
  local doc = require('js').global.document
  createelement, createtextnode = (function()
    local _base_0 = doc
    local _fn_0 = _base_0.createElement
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(), (function()
    local _base_0 = doc
    local _fn_0 = _base_0.createTextNode
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)()
end
local environment
do
  local env
  do
    local global = _ENV
    env = setmetatable({ }, {
      __index = function(self, key)
        return global[key] or function(...)
          return assert(rawget(self, 'node'), 'field "node" is missing!')(key, ...)
        end
      end
    })
  end
  local _ENV
  _ENV, env = env, nil
  escape = function(value)
    return (function(self)
      return self
    end)(tostring(value):gsub([[[<>&]'"]], escapes))
  end
  local flatten
  flatten = function(tab, flat)
    if flat == nil then
      flat = { }
    end
    for key, value in pairs(tab) do
      local _exp_0 = type(value)
      if "table" == _exp_0 then
        flatten(value, flat)
      else
        local _exp_1 = type(key)
        if "number" == _exp_1 then
          flat[#flat + 1] = value
        else
          flat[key] = value
        end
      end
    end
    return flat
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
  local handle_inner
  handle_inner = function(element, inner)
    for _index_0 = 1, #inner do
      local item = inner[_index_0]
      local _exp_0 = type(item)
      if 'table' == _exp_0 then
        handle_inner(element, item)
      elseif 'function' == _exp_0 then
        local previous = Parent
        Parent = element
        item()
        Parent = previous
      else
        Parent:appendChild(createtextnode(tostring(item)))
      end
    end
    return element
  end
  node = function(nodename, ...)
    local content, attributes = split(flatten({
      ...
    }))
    local New = handle_inner(createelement(nodename), content)
    for key, value in pairs(attributes) do
      New:setAttribute(tostring(key), tostring(value))
    end
    return Parent:appendChild(New)
  end
  environment = _ENV
end
local template
template = function(fnc)
  assert(type(fnc) == 'function', 'wrong argument type, expecting function')
  do
    local upvaluejoin = debug.upvaluejoin
    local _ENV = environment
    upvaluejoin(fnc, 1, (function()
      return aaaa()
    end), 1)
  end
  return function(parent, ...)
    assert(parent, 'No parent node given!')
    environment.Parent = parent
    return fnc(...)
  end
end
return {
  environment = environment,
  template = template,
  generate = function(parent, func)
    return template(func)(parent)
  end
}
