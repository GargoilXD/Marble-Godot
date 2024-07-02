class_name MarbleData
var Type:DataToken.DATATYPE
var Value

func _init(type:DataToken.DATATYPE, value = null) -> void:
	Type = type
	Value = value

static func FromDataVertex(vertex:DataVertex) -> MarbleData:
	return MarbleData.new(vertex.Data_type, vertex.Data)

func _to_string() -> String:
	return '(%s %s)' % [DataToken.DATATYPE.keys()[Type], Value]
