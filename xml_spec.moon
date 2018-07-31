_buf = require"strbuffer"
package.path = '?.lua'
package.loaded.js = {
	global: {
		document: {
			createElement: (t) =>
				print "Creating #{t} node"
				setmetatable {
					appendChild: (n) => print "appending #{n} to #{@}"
					setAttribute: (k,v) => print "Setting #{k} to #{v} on #{@}"
				}, {
					__tostring: => t
				}
			createTextNode: (t) =>
				print "Inserting '#{t}'"
				setmetatable {}, {__tostring: => "Text Node (#{t})"}
		}
	}
}


((m,f) -> debug.sethook f, m) '', (event, line) ->
	switch event
		when 'line'
			print line
		when 'call', 'tail call'
			info = debug.getinfo(2)
			print 'Call: %s %s:%i'\format info.name or '<anon>', info.source, tonumber(line) or -1

fengarixml = require 'xml'

template = fengarixml.template ->
	div 'Hello World!'
	img src: 'Hello World'

template(require'js'.global.document\createElement 'TOP')
