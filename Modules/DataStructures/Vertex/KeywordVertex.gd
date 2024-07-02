extends Vertex
class_name KeywordVertex
var Keyword_type:KeywordToken.KEYWORD
var Keyword:String
func _init(keyword_type:KeywordToken.KEYWORD, position:TokenPosition, keyword:String):
	Keyword_type = keyword_type
	Position = position
	Keyword = keyword

static func FromToken(token:KeywordToken) -> KeywordVertex:
	return KeywordVertex.new(token.Keyword, token.Position, token.TokenValue)

func _to_string() -> String:
	#if Keyword in [DataToken.DATATYPE.CIRCLE_FUNCTION, DataToken.DATATYPE.SQUARE_FUNCTION, DataToken.DATATYPE.CURLY_FUNCTION]:
		#return 'Function(%s)' % str(VertexValue)
	return '(%s, %s)' % [str(KeywordToken.KEYWORD.keys()[Keyword_type]), str(Keyword)]
