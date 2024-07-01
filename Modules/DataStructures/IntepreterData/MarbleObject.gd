class_name MarbleObject
var Value:Object
func _init(value = null) -> void:
	Value = value

func _to_string() -> String:
	return str(Value)
