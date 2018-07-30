s_buf = require"strbuffer"
package.path = '?.lua'
moonxml = require 'xml'

xml = (fn, ...) ->
	buf = s_buf!
	moonxml.xml(fn)(buf\append, ...)
	return tostring(buf)

html = (fn, ...) ->
	buf = s_buf!
	moonxml.html(fn)(buf\append, ...)
	return tostring(buf)

describe "moonxml xml", ->
	it "should work", ->
		assert.is_string xml -> a_thing!

	describe "tags", ->
		it "should not have closing tags when empty", ->
			assert.equal '<t />', xml -> t!
		it "should have closing tags when not empty", ->
			assert.equal '<t>test</t>', xml -> t 'test'
	
	describe "nested tags", ->
		it "should work", ->
			assert.equal '<outer><inner /></outer>', xml -> outer -> inner!
	
	describe "attributes", ->
		it "should work", ->
			assert.equal '<elem attrib="value" />', xml -> elem attrib: 'value'

describe "moonxml html", ->
	it "should work", ->
		assert.is_string html -> body!

	describe "void tags", ->
		it "should not have closing tags when empty", ->
			assert.equal '<br>', html -> br!
		it "should have closing tags when not empty", ->
			assert.equal '<br>test</br>', html -> br 'test'

	describe "non-void tags", ->
		it "should always have closing tags", ->
			assert.equal '<span></span>', html -> span!
			assert.equal '<span>test</span>', html -> span 'test'

test "additional arguments should get passed", ->
	assert.equal '<text>string</text>', xml ((t)->text (type t)), 'test'
	assert.equal '<span>string</span>', html ((t)->span (type t)), 'test'
