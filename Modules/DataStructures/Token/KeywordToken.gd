extends Token
class_name KeywordToken
enum KEYWORD{
	NONE,
	MODIFIER,
	DATATYPE,
	FLOWCONTROL,
	DECISION,
	LOOP,
	INSTRUCTION_SET,
	FUNCTION,
}
var Keyword:KEYWORD
func _init(keyword:KEYWORD = KEYWORD.NONE, position:TokenPosition = null, token_value = null):
	Keyword = keyword
	TokenValue = token_value
	Position = position
	Type = TYPE.KEYWORD

func _to_string() -> String:
	match Keyword:
		KEYWORD.DATATYPE:
			return '(%s, %s)' % [KEYWORD.keys()[Keyword], DataToken.DATATYPE.keys()[TokenValue]]
	return '(%s, %s)' % [KEYWORD.keys()[Keyword], TokenValue]
