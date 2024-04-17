class_name Token
enum TYPE{
	NONE,
	DATA,
	KEYWORD,
	OPERATOR,
	COMMA,
	LEFT_CURLY_BRACKET,
	RIGHT_CURLY_BRACKET,
	LEFT_SQUARE_BRACKET,
	RIGHT_SQUARE_BRACKET,
	LEFT_CIRCLE_BRACKET,
	RIGHT_CIRCLE_BRACKET,
	END_OF_LINE,
	END_OF_FILE
}
var Type:TYPE
var Position:TokenPosition
var TokenValue
func _init(type:TYPE = TYPE.NONE, position:TokenPosition = null, token_value = null):
	Type = type
	TokenValue = token_value
	Position = position

func _to_string() -> String: return '(%s)' % TYPE.keys()[Type]
