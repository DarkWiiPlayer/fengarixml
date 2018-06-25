buf = require"strbuffer"("\n")

package.path = '?.lua'
import render from require 'xml'

render buf\append, ->
	svg {
		-> defs -> style doc_style
		height: 100
		width: 100
		viewBox: "0 0 100 100"
		->
			rect x: 5, y: 5, width: 90, height: 90
	}

print(buf)
