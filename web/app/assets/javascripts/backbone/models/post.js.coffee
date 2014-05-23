class jordan
	constructor: (name) ->
		@name = name

	catchMe: () ->
		console.log @name
		
trying = new jordan "jossie"
console.log trying.name
	
