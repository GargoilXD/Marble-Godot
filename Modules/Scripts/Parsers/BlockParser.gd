extends Parser
class_name BlockParser

var RULES:Dictionary = {
	{'keyword' : ['bool', 'int', 'float', 'String', 'Array', 'Dictionary', 'var']} : ['identifier', {'operator':'assign'}, 'data'],
	{'keyword' : ['if', 'elif']}:null,
	'for':null,
	'while':null,
	'match':null,
	'enum':null,
	'func':null,
	'class':null,
	'return':null,
	
}

func Parse(_tokens:Array):
	pass
