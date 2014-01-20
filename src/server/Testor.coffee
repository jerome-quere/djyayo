Validator = require('validator');
sanitize = require('validator').sanitize;


class Testor
	constructor: (@value, @err) ->

	_call: (method, params) ->
		if (!Validator[method].apply(@check, params))
			throw @err;
		return this;

	_test: (test) ->
		if (!test())
			throw @err;
		return this
	isMongoKey: () ->@_test(() => /^([0-9a-z]{12}|[0-9a-z]{24})$/.test(@value));
	toString: () -> "#{@value}";
	isMD5: () -> @_test ()=> /^[0-9a-zA-Z]{32}$/.test(@value);


for key of Validator.prototype when typeof Validator.prototype[key] == 'function'
	Testor.prototype[key] = do (key) -> (p...) ->
		return @_call(key, p)


module.exports = (data, err) -> new Testor(data, err);