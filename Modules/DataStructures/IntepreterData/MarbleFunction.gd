class_name MarbleFunction
var Type:DataToken.DATATYPE
var Name:String
var Parameters:Array
var Instructions:Array

func _init(type:DataToken.DATATYPE, name:String, parameters:Array = [], instructions:Array = []) -> void:
	Type = type
	Name = name
	Parameters = parameters
	Instructions = instructions

func _to_string() -> String:
	return "%s %s()" % [DataToken.DATATYPE.keys()[Type], Name]
