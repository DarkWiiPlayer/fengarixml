local buf = require("strbuffer")("\n")
package.path = '?.lua'
local render
render = require('xml').render
render((function()
  local _base_0 = buf
  local _fn_0 = _base_0.append
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)(), function()
  return svg({
    function()
      return defs(function()
        return style(doc_style)
      end)
    end,
    height = 100,
    width = 100,
    viewBox = "0 0 100 100",
    function()
      return rect({
        x = 5,
        y = 5,
        width = 90,
        height = 90
      })
    end
  })
end)
return print(buf)
