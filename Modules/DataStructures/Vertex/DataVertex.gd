extends Vertex
class_name DataVertex
var DataType:DataToken.DATATYPE
func _init(type:DataToken.DATATYPE, position:TokenPosition, vertex_value):
	DataType = type
	Position = position
	VertexValue = vertex_value

static func FromToken(token:DataToken) -> DataVertex:
	return DataVertex.new(token.DataType, token.Position, token.TokenValue)

func _to_string() -> String:
	if DataType == DataToken.DATATYPE.FUNCTION:
		return '{Subroutine: %s<%s>}' % [str(VertexValue.Identifier), str(VertexValue.Parameters)]
	if DataType == DataToken.DATATYPE.SELECTOR:
		return '{Selector: %s<%s>}' % [str(VertexValue.Identifier), str(VertexValue.Parameters)]
	return '(%s)' % str(VertexValue)
