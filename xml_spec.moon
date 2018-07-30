s_buf = require"strbuffer"
package.path = '?.lua'
moonxml = require 'xml'

render = (fn, ...) ->
	buf = s_buf'\n'
	moonxml.xml(fn)(buf\append, ...)
	return tostring(buf)

describe "moonhtml", ->
	it "should work", ->
		assert.is_string render -> html!

	describe "tags", ->
		it "should not have closing tags when empty", ->
			assert.equal '<t />', render -> t!
		it "should have closing tags when not empty", ->
			assert.equal '<t>\ntest\n</t>', render -> t 'test'

test "additional arguments should get passed", ->
	assert.equal '<text>\nstring\n</text>', render ((t)->text (type t)), 'test'
