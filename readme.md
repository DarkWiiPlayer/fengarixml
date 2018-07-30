Version 2.0 is here!
--------------------

While there is no official release yet, there won't be any feature changes until 2.0, and it will be released as soon as it has seen some more testing :)

See changelog to find out what changed (Spoiler: MoonHTML is no more)

MoonXML
========

A while ago I wrote a copy of the [lapis](//leafo.net/lapis/) HTML generator syntax, but since that wasn't really suited for writing XML, I made a modified version for that. Since the two projects shared almost all their code, I decided to merge them together into one library that does both HTML and XML generation. The only real difference is how empty tags are handled.

A quick example:

	render = (out, fnc) -> require'moonxml'.xml(fnc)(out)
	render print, ->
		svg ->
			rect x: 5, y: 5, width: 90, height: 90

should generate the following code

	<svg>
	<rect y="5" x="5" width="90" height="90" />
	</svg>

and could also be written as

	buffer = require'strbuffer'('\n')
	render = (fnc) -> require'moonxml'.xml(fnc)(buffer\append)
	render ->
		svg ->
			rect
				x: 5
				y: 5
				width: 90
				height: 90
	print buffer

The `strbuffer` rock can be found [here](//github.com/darkwiiplayer/lua_strbuffer)

Usage
------

TODO: Write :P

Warning(s)
-----

Because of how lua works, once a function is passed into `render` or `build`, its upvalues are permanently changed. This means functions may become otherwise unusable, and shouldn't be used for more than one template at the same time. Seriously, things might explode and kittens may die.
It also seems like in lua 5.2+ the environment isn't necessarily the first upvalue (?) so things break if any upvalue is accessed before any global. This will be less of a problem once a proper way to load entire files in the builder environment exists.

Compatibility with Lapis
-----

Not really an issue. This is *not* a 1:1 clone of the lapis generator syntax, but an attempt at recreating it in my own way. Many things may work the same way and simpler code snippets may work in either of the two, but more complex constructs may require some adaptation. The fact that MoonHTML flattens its arguments also means that you can do a lot more "weird stuff" with it that just wouldn't work in lapis, so be aware of that.

FengariXML
--------

I'm not sure if this should be its own project or not, but all of this code can easily be ported to generate HTML nodes directly in the browser using [Fengari](//github.com/fengari-lua/fengari), and I will probably build something like that sooner or later.

Changelog
-----

### 2.0.0

- MoonXML now also does HTML, making MoonHTML obsolete. This change was necessary because both projects shared most of their code and only differed in how they treat empty tags.
- Render functions are gone (they were one-liners, so the user can build them when needed) to reduce feature bloat
- There are no more individual environments generated on the fly, but instead, there's just a single environment containing all the XML functions

### 1.1.0

- MoonXML doesn't have any concept of buffers anymore, instead you pass it a function that handles your output (see examples)
- The pair method is gone, and instead there is emv, which only returns an environment
- build now returns a function, which in turn accepts as its first argument a function that handles output. All aditional arguments are passed to the function provided by the user

Note that I initially intended to use this mainly inside [Vim](//vim.sourceforge.io/), where I have a macro set up to feed the visual selection through the moonscript interpreter and replace it with its output. It has also grown to the point where it can perfectly be used within a web server like openresty or pegasus, or in other more high-level code like my [multitone](//github.com/darkwiiplayer/multitone) function. I can also imagine a document markup DSL with some aditional abstractions (like using `title` instead of `h1`..`h6`, etc.)

License: [The Unlicense](//unlicense.org)
