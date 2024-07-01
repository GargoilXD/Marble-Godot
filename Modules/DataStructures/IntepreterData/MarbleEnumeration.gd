class_name MarbleEnumeration
var Value:Dictionary
func _init(value = {}) -> void:
	Value = value

func _to_string() -> String:
	return str(Value)
