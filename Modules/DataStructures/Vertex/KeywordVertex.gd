extends Vertex
class_name KeywordVertex
var Keyword:KeywordToken.KEYWORD
func _init(type:KeywordToken.KEYWORD, position:TokenPosition, vertex_value):
	Keyword = type
	Position = position
	VertexValue = vertex_value

static func FromToken(token:KeywordToken) -> KeywordVertex:
	return KeywordVertex.new(token.Keyword, token.Position, token.TokenValue)

func _to_string() -> String:
	#if Keyword in [DataToken.DATATYPE.CIRCLE_FUNCTION, DataToken.DATATYPE.SQUARE_FUNCTION, DataToken.DATATYPE.CURLY_FUNCTION]:
		#return 'Function(%s)' % str(VertexValue)
	return '(%s, %s)' % [str(KeywordToken.KEYWORD.keys()[Keyword]), str(VertexValue)]
