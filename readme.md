MoonXML
=========

A while ago I wrote a copy of the [lapis](http://leafo.net/lapis/) HTML generator syntax, but since that wasn't really suited for writing XML, I made a modified version for that. Its main purpose is to generate SVG code to be inlined in dynamically generated HTML documents, but it probably has many other use cases.

A quick example:

	print require'moonxml'.render ->
		svg ->
			rect x: 5, y: 5, width: 90, height: 90

should generate the following code

	<svg>
	<rect x="5" y="5" width="90" height="90" />
	</svg>

and could also be written as

	print require'moonxml'.render ->
		svg ->
			rect
				x: 5
				y: 5
				width: 90
				height: 90

Note that I intend to use this mainly inside [Vim](https://vim.sourceforge.io/), where I have a macro set up to feed the visual selection through the moonscript interpreter and replace it with its output.
I literally just copied the above code example, selected it, pressed Ctrl+Enter and it turned into the HTML code you see.
It's really useful and I can really recommend it to every vim user out there.

License: [The Unlicense](license.md)
