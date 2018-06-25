MoonXML
=========

A while ago I wrote a copy of the [lapis](http://leafo.net/lapis/) HTML generator syntax, but since that wasn't really suited for writing XML, I made a modified version for that. Its main purpose is to generate SVG code to be inlined in dynamically generated HTML documents, but it probably has many other use cases like writing XHTML.

A quick example:

	require'moonxml'.render print, ->
		svg ->
			rect x: 5, y: 5, width: 90, height: 90

should generate the following code

	<svg>
	<rect x="5" y="5" width="90" height="90" />
	</svg>

and could also be written as

	buffer = require"strbuffer"!
	require'moonxml'.render buffer\append, ->
		svg ->
			rect
				x: 5
				y: 5
				width: 90
				height: 90
	print buffer

The `strbuffer` rock can be found [here](https://github.com/darkwiiplayer/lua_strbuffer)

Changelog
-----

### 1.1.0

- MoonXML doesn't have any concept of buffers anymore, instead you pass it a function that handles your output (see examples)
- The pair method is gone, and instead there is emv, which only returns an environment
- build now returns a function, which in turn accepts as its first argument a function that handles output. All aditional arguments are passed to the function provided by the user

Note that I intend to use this mainly inside [Vim](https://vim.sourceforge.io/), where I have a macro set up to feed the visual selection through the moonscript interpreter and replace it with its output.
I literally just copied the above code example, selected it, pressed Ctrl+Enter and it turned into the SVG code you see.
It's really useful and I can really recommend it to every vim user out there.

License: [The Unlicense](license.md)
