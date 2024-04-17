class_name MarbleData
var Type:DataToken.DATATYPE
var Value

func _init(type:DataToken.DATATYPE, value = null) -> void:
	Type = type
	Value = value

static func FromDataVertex(vertex:DataVertex):
	return MarbleData.new(vertex.DataType, vertex.VertexValue)

func _to_string() -> String:
	return str(Value)
