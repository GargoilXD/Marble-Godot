extends Vertex
class_name DataVertex
var Data_type:DataToken.DATATYPE
var Data
func _init(type:DataToken.DATATYPE, position:TokenPosition, data) -> void:
	Data_type = type
	Position = position
	Data = data

static func FromToken(token:DataToken) -> DataVertex:
	return DataVertex.new(token.DataType, token.Position, token.TokenValue)

func _to_string() -> String:
	if Data_type == DataToken.DATATYPE.FUNCTION:
		return '{Subroutine: %s<%s>}' % [str(Data.Identifier), str(Data.Parameters)]
	if Data_type == DataToken.DATATYPE.SELECTOR:
		return '{Selector: %s<%s>}' % [str(Data.Identifier), str(Data.Parameters)]
	return '(%s)' % str(Data)
