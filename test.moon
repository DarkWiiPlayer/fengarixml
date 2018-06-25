import render from require 'xml'

doc_style = [[
	rect {
		fill: rebeccapurple;
		transition: fill 0.3s;
	}
	rect:hover {
		fill: red;
	}
]]

print render ->
	svg{
		-> defs -> style doc_style
		height: 100
		width: 100
		viewBox: "0 0 100 100"
		->
			rect x: 5, y: 5, width: 90, height: 90
	}
