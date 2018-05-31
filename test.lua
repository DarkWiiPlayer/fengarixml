local render
render = require('xml').render
local doc_style = [[  rect {
    fill: rebeccapurple;
    transition: fill 0.3s;
  }
  rect:hover {
    fill: red;
  }
]]
return print(render(function()
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
end))
