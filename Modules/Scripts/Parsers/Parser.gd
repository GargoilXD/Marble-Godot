class_name Parser
var Index:int
var CurrentToken:Token
var Tokens:Array
var Parsed:Array

func SetNextToken() -> void:
	Index += 1
	assert(Index - Tokens.size() < 1)
	CurrentToken = Tokens[Index] if Index < Tokens.size() else null

func Parse(_tokens:Array):
	pass
