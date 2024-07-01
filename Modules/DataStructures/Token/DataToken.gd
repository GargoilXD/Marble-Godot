extends Token
class_name DataToken
enum DATATYPE{
	NONE,
	VARIANT,
	BOOLEAN,
	INTEGER,
	FLOAT,
	STRING,
	LIST,
	DICTIONARY,
	ENUMERATION,
	OBJECT,
	IDENTIFIER,
	SELECTOR,
	FUNCTION,
	PARAMETER,
	INSTRUCTIONS
}
var DataType:DATATYPE
func _init(datatype:DATATYPE = DATATYPE.NONE, position:TokenPosition = null, token_value = null):
	DataType = datatype
	TokenValue = token_value
	Position = position
	Type = TYPE.DATA

static func Convert(datatype:String) -> DATATYPE:
	match datatype:
		'Variant':
			return DATATYPE.VARIANT
		'Boolean':
			return DATATYPE.BOOLEAN
		'Integer':
			return DATATYPE.INTEGER
		'Float':
			return DATATYPE.FLOAT
		'String':
			return DATATYPE.STRING
		'List':
			return DATATYPE.LIST
		'Dictionary':
			return DATATYPE.DICTIONARY
		'Enumeration':
			return DATATYPE.ENUMERATION
		'Object':
			return DATATYPE.OBJECT
		_:
			return DATATYPE.NONE

func _to_string() -> String: return '(%s, %s)' % [DATATYPE.keys()[DataType], TokenValue]

